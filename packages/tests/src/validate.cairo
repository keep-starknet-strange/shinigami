use shinigami_engine::engine::EngineImpl;
use shinigami_engine::hash_cache::HashCacheImpl;
use shinigami_engine::transaction::EngineTransaction;
use shinigami_engine::opcodes::Opcode;
use crate::utxo::UTXO;

// TODO: Move validate coinbase here

// TODO: Remove hints?
// utxo_hints: Set of existing utxos that are being spent by this transaction
pub fn validate_transaction(
    tx: @EngineTransaction, flags: u32, utxo_hints: Array<UTXO>,
) -> Result<(), felt252> {
    let input_count = tx.transaction_inputs.len();
    if input_count != utxo_hints.len() {
        return Result::Err('Invalid number of utxo hints');
    }

    let mut i = 0;
    let mut err = '';
    while i != input_count {
        let utxo = utxo_hints[i];
        let hash_cache = HashCacheImpl::new(tx);
        // TODO: Error handling
        let mut engine = EngineImpl::new(
            utxo.pubkey_script, tx, i, flags, *utxo.amount, @hash_cache,
        )
            .unwrap();
        let res = engine.execute();
        if res.is_err() {
            err = res.unwrap_err();
            break;
        }

        i += 1;
    };
    if err != '' {
        return Result::Err(err);
    }

    Result::Ok(())
}

pub fn validate_transaction_at(
    tx: @EngineTransaction, flags: u32, prevout: UTXO, at: u32,
) -> Result<(), felt252> {
    let hash_cache = HashCacheImpl::new(tx);
    let mut engine = EngineImpl::new(
        @prevout.pubkey_script, tx, at, flags, prevout.amount, @hash_cache,
    )
        .unwrap();
    let res = engine.execute();
    if res.is_err() {
        return Result::Err(res.unwrap_err());
    }

    Result::Ok(())
}

pub fn validate_p2ms(
    tx: @EngineTransaction, flags: u32, utxo_hints: Array<UTXO>,
) -> Result<(), felt252> {
    // Check if the transaction has at least one input
    if tx.transaction_inputs.len() == 0 {
        return Result::Err('P2MS: No inputs');
    }

    let mut i = 0;
    let input_count = tx.transaction_inputs.len();
    let mut err = '';
    loop {
        if i == input_count {
            break;
        }

        let utxo = utxo_hints[i];

        // We'll use the UTXO's pubkey_script as the redeem script
        let redeem_script = utxo.pubkey_script;

        // Check if the redeem script is not empty
        if redeem_script.len() == 0 {
            err = 'P2MS: Empty redeem script';
            break;
        }

        // Check if the redeem script follows the P2MS pattern
        if redeem_script.len() < 4 || redeem_script[redeem_script.len()
            - 1] != Opcode::OP_CHECKMULTISIG {
            err = 'P2MS: Invalid redeem script';
            break;
        }

        // Extract m and n from the script
        let m: u32 = (redeem_script[0] - 0x50).try_into().unwrap();
        let n: u32 = (redeem_script[redeem_script.len() - 2] - 0x50).try_into().unwrap();

        // Check if m and n are valid
        if m == 0 || n == 0 || m > n || n > 20 {
            err = 'P2MS: Invalid m or n';
            break;
        }

        // Count and validate public keys
        let mut pubkey_count = 0;
        let mut script_index = 1; // Start after m
        while script_index < redeem_script.len() - 2 { // Stop before n and OP_CHECKMULTISIG
            if script_index >= redeem_script.len() {
                err = 'P2MS: Unexpected end of script';
                break;
            }
            let key_len: u32 = redeem_script[script_index].into();
            if key_len != 33 && key_len != 65 {
                err = 'P2MS: Invalid public key length';
                break;
            }
            pubkey_count += 1;
            script_index += key_len + 1; // Move to the next key
        };

        if pubkey_count != n {
            err = 'P2MS: n != m count';
            break;
        }

        // Verify signatures using the EngineImpl
        let hash_cache = HashCacheImpl::new(tx);
        let mut engine = EngineImpl::new(redeem_script, tx, i, flags, *utxo.amount, @hash_cache)
            .unwrap();

        let res = engine.execute();
        if res.is_err() {
            err = res.unwrap_err();
            break;
        }

        i += 1;
    };

    if err != '' {
        Result::Err(err)
    } else {
        Result::Ok(())
    }
}
