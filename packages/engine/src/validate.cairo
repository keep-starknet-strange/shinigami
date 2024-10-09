use crate::engine::EngineImpl;
use crate::hash_cache::HashCacheImpl;
use crate::transaction::Transaction;
use crate::utxo::UTXO;
use crate::opcodes::Opcode;

// TODO: Move validate coinbase here

// TODO: Remove hints?
// utxo_hints: Set of existing utxos that are being spent by this transaction
pub fn validate_transaction(
    tx: @Transaction, flags: u32, utxo_hints: Array<UTXO>
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
            utxo.pubkey_script, tx, i, flags, *utxo.amount, @hash_cache
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

pub fn validate_p2ms(
    tx: @Transaction, flags: u32, utxo_hints: Array<UTXO>
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
        if redeem_script.len() < 4 || redeem_script[redeem_script.len() - 1] != Opcode::OP_CHECKMULTISIG {
            err = 'P2MS: Invalid redeem script';
            break;
        }

        // Extract m and n from the script
        let m: u32 = redeem_script[0].into();
        let n: u32 = redeem_script[redeem_script.len() - 2].into();

        // Check if m and n are valid
        if m == 0 || n == 0 || m > n || n > 15 {
            err = 'P2MS: Invalid m or n';
            break;
        }

        // Check if the number of public keys matches n
        // This is a rough estimate, as we don't parse the script fully
        let script_len: u32 = redeem_script.len().into();
        if script_len != (n * 33) + 3 && script_len != (n * 65) + 3 {
            err = 'P2MS: Invalid public keys';
            break;
        }

        // Verify signatures using the EngineImpl
        let hash_cache = HashCacheImpl::new(tx);
        let mut engine = EngineImpl::new(
            redeem_script, tx, i, flags, *utxo.amount, @hash_cache
        ).unwrap();
        
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