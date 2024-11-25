use shinigami_engine::engine::EngineImpl;
use shinigami_engine::hash_cache::HashCacheImpl;
use shinigami_engine::transaction::EngineTransaction;
use shinigami_engine::opcodes::Opcode;
use crate::utxo::UTXO;
use crate::utils::find_last_index;
use shinigami_utils::hash::sha256_byte_array;
use shinigami_utils::bytecode::bytecode_to_hex;
use shinigami_utils::bytecode::hex_to_bytecode;
use shinigami_utils::byte_array::sub_byte_array;

// TODO: Move validate coinbase here

// TODO: Remove hints?
// utxo_hints: Set of existing utxos that are being spent by this transaction
pub fn validate_transaction(
    tx: @EngineTransaction, flags: u32, utxo_hints: Array<UTXO>
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

pub fn validate_transaction_at(
    tx: @EngineTransaction, flags: u32, prevout: UTXO, at: u32
) -> Result<(), felt252> {
    let hash_cache = HashCacheImpl::new(tx);
    let mut engine = EngineImpl::new(
        @prevout.pubkey_script, tx, at, flags, prevout.amount, @hash_cache
    )
        .unwrap();
    let res = engine.execute();
    if res.is_err() {
        return Result::Err(res.unwrap_err());
    }

    Result::Ok(())
}

pub fn validate_p2ms(
    tx: @EngineTransaction, flags: u32, utxo_hints: Array<UTXO>
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


pub fn validate_p2sh(
    tx: @EngineTransaction, flags: u32, utxo_hints: Array<UTXO>, indx: u32
) -> Result<(), felt252> {
    if tx.transaction_inputs.len() == 0 {
        return Result::Err('P2SH: No inputs');
    }

    let signature_script = bytecode_to_hex(tx.transaction_inputs[indx].signature_script);
    let scriptSig_bytes = hex_to_bytecode(@signature_script);

    let mut redeem_Script_start_index = 0;
    let mut redeem_script_size = 0;
    if scriptSig_bytes[0] == 0 || scriptSig_bytes[0] == 1 || scriptSig_bytes[0] == 2 {
        //OP_0 OP_PushData <Sig> OP_PushData <RedeemScript>  Standard locking scripts
        if (flags == 0) {
            redeem_Script_start_index = (2 + scriptSig_bytes[1] + 1).into();
        } else if (flags == 1) {
            redeem_Script_start_index =
                (1
                    + 1
                    + scriptSig_bytes[1]
                    + 1
                    + scriptSig_bytes[(1 + 1 + scriptSig_bytes[1]).into()]
                    + scriptSig_bytes[(1
                        + 1
                        + scriptSig_bytes[1]
                        + scriptSig_bytes[(1 + 1 + scriptSig_bytes[1]).into()])
                        .into()]
                    + 1)
                .into();
        }
        redeem_script_size = (scriptSig_bytes.len()) - redeem_Script_start_index;
    } else {
        // non-standard locking script containing a mathematical puzzle
        redeem_Script_start_index = find_last_index(scriptSig_bytes.clone());
        redeem_script_size = (scriptSig_bytes.len()) - redeem_Script_start_index;
    }

    let redeem_script = sub_byte_array(
        @scriptSig_bytes, ref redeem_Script_start_index, redeem_script_size
    );
    if redeem_script.len() == 0 {
        return Result::Err('P2SH: Redeem Script size = 0');
    }
    if redeem_script.len() > 520 {
        return Result::Err('P2SH: Redeem Script size > 520');
    }

    let hashed_redeem_script: ByteArray = ripemd160::ripemd160_hash(
        @sha256_byte_array(@redeem_script)
    )
        .into();

    let script_pubkey = utxo_hints[0].pubkey_script;
    let mut script_hash_start_index = 2;
    let script_hash: ByteArray = sub_byte_array(script_pubkey, ref script_hash_start_index, 20);

    if hashed_redeem_script != script_hash {
        return Result::Err('P2SH: Signature mismatch');
    }

    let hash_cache = HashCacheImpl::new(tx);
    let mut engine = EngineImpl::new(
        script_pubkey, tx, indx, flags, *utxo_hints[0].amount, @hash_cache
    )
        .unwrap();

    let res = engine.execute();

    if res.is_err() {
        let err = res.unwrap_err();
        Result::Err(err)
    } else {
        Result::Ok(())
    }
}
