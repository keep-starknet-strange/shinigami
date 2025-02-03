use shinigami_engine::engine::EngineImpl;
use shinigami_engine::hash_cache::HashCacheImpl;
use shinigami_engine::transaction::{
    EngineTransaction, EngineTransactionOutput, UTXO, UTXOSpanIntoOutput, UTXOIntoOutput,
};
use shinigami_engine::opcodes::Opcode;

// TODO: Move validate coinbase here

// utxo_hints: Set of existing utxos that are being spent by this transaction
pub fn validate_transaction(
    tx: @EngineTransaction, flags: u32, utxo_hints: Span<UTXO>,
) -> Result<(), felt252> {
    let input_count = tx.transaction_inputs.len();
    let utxo_count = utxo_hints.len();
    if input_count != utxo_count {
        return Result::Err('Invalid number of utxo hints');
    }

    let mut inner_result = Result::Ok(());
    let hash_cache = HashCacheImpl::new(tx, flags, utxo_hints.into());
    let mut i = 0;

    while i != input_count {
        let utxo = utxo_hints[i];

        let mut engine =
            match EngineImpl::new(utxo.pubkey_script, tx, i, flags, *utxo.amount, @hash_cache) {
            Result::Ok(engine) => engine,
            Result::Err(err) => {
                inner_result = Result::Err(err);
                break;
            },
        };
        match engine.execute() {
            Result::Ok(res) => res,
            Result::Err(err) => {
                inner_result = Result::Err(err);
                break;
            },
        };
        i += 1;
    };

    if (inner_result.is_err()) {
        return Result::Err(inner_result.unwrap_err());
    }

    Result::Ok(())
}

pub fn validate_transaction_at(
    tx: @EngineTransaction, flags: u32, prevout: UTXO, at: u32,
) -> Result<(), felt252> {
    let utxos: Span<EngineTransactionOutput> = array![prevout.clone().into()].span();
    let hash_cache = HashCacheImpl::new(tx, 0, utxos);

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
        let hash_cache = HashCacheImpl::new(tx, flags, array![].span());
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
