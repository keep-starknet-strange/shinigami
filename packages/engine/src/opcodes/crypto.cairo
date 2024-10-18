use crate::engine::{Engine, EngineExtrasTrait};
use crate::transaction::{
    EngineTransactionTrait, EngineTransactionInputTrait, EngineTransactionOutputTrait, Transaction
};
use crate::stack::ScriptStackTrait;
use crate::scriptflags::ScriptFlags;
use crate::signature::signature;
use crate::signature::sighash;
use crate::signature::signature::{BaseSigVerifierTrait, TaprootSigVerifierTrait};
use starknet::secp256_trait::{is_valid_signature};
use core::sha256::compute_sha256_byte_array;
use core::num::traits::OverflowingAdd;
use crate::opcodes::utils;
use crate::scriptnum::ScriptNum;
use crate::errors::Error;
use crate::taproot::TaprootContextTrait;

const MAX_KEYS_PER_MULTISIG: i64 = 20;
const BASE_SEGWIT_VERSION: i64 = 0;

pub fn opcode_sha256<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let arr = @engine.dstack.pop_byte_array()?;
    let res = compute_sha256_byte_array(arr).span();
    let mut res_bytes: ByteArray = "";
    let mut i: usize = 0;
    while i != res.len() {
        res_bytes.append_word((*res[i]).into(), 4);
        i += 1;
    };
    engine.dstack.push_byte_array(res_bytes);
    return Result::Ok(());
}

pub fn opcode_hash160<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let m = engine.dstack.pop_byte_array()?;
    let res = compute_sha256_byte_array(@m).span();
    let mut res_bytes: ByteArray = "";
    let mut i: usize = 0;
    while i != res.len() {
        res_bytes.append_word((*res[i]).into(), 4);
        i += 1;
    };
    let h: ByteArray = ripemd160::ripemd160_hash(@res_bytes).into();
    engine.dstack.push_byte_array(h);
    return Result::Ok(());
}

pub fn opcode_hash256<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let m = engine.dstack.pop_byte_array()?;
    let res = compute_sha256_byte_array(@m).span();
    let mut res_bytes: ByteArray = "";
    let mut i: usize = 0;
    while i != res.len() {
        res_bytes.append_word((*res[i]).into(), 4);
        i += 1;
    };
    let res2 = compute_sha256_byte_array(@res_bytes).span();
    let mut res2_bytes: ByteArray = "";
    let mut j: usize = 0;
    while j != res2.len() {
        res2_bytes.append_word((*res2[j]).into(), 4);
        j += 1;
    };
    engine.dstack.push_byte_array(res2_bytes);
    return Result::Ok(());
}

pub fn opcode_ripemd160<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let m = engine.dstack.pop_byte_array()?;
    let h: ByteArray = ripemd160::ripemd160_hash(@m).into();
    engine.dstack.push_byte_array(h);
    return Result::Ok(());
}

pub fn opcode_checksig<
    T,
    +Drop<T>,
    I,
    +Drop<I>,
    impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
    O,
    +Drop<O>,
    impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
    impl IEngineTransactionTrait: EngineTransactionTrait<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait
    >
>(
    ref engine: Engine<T>
) -> Result<(), felt252> {
    let pk_bytes = engine.dstack.pop_byte_array()?;
    let full_sig_bytes = engine.dstack.pop_byte_array()?;

    if full_sig_bytes.len() < 1 {
        engine.dstack.push_bool(false);
        return Result::Ok(());
    }

    // TODO: add witness context inside engine to check if witness is active
    //       if witness is active use BaseSigVerifier
    let mut is_valid: bool = false;
    if engine.witness_program.len() == 0 {
        let res = BaseSigVerifierTrait::new(ref engine, @full_sig_bytes, @pk_bytes);
        if res.is_err() {
            // TODO: Some errors can return an error code instead of pushing false?
            engine.dstack.push_bool(false);
            return Result::Ok(());
        }
        let mut sig_verifier = res.unwrap();

        is_valid = sig_verifier.verify(ref engine);
    } else if engine.is_witness_active(BASE_SEGWIT_VERSION) {
        // TODO: Implement
        is_valid = false;
    } else if engine.use_taproot {
        engine.taproot_context.use_ops_budget()?;
        if pk_bytes.len() == 0 {
            return Result::Err(Error::TAPROOT_EMPTY_PUBKEY);
        }

        let mut verifier = TaprootSigVerifierTrait::<
            Transaction
        >::new_base(@full_sig_bytes, @pk_bytes)?;
        is_valid = TaprootSigVerifierTrait::<Transaction>::verify(ref verifier);
    }

    if !is_valid && @engine.use_taproot == @true {
        return Result::Err(Error::SIG_NULLFAIL);
    }
    if !is_valid && engine.has_flag(ScriptFlags::ScriptVerifyNullFail) && full_sig_bytes.len() > 0 {
        return Result::Err(Error::SIG_NULLFAIL);
    }

    engine.dstack.push_bool(is_valid);
    return Result::Ok(());
}

pub fn opcode_checkmultisig<
    T,
    +Drop<T>,
    I,
    +Drop<I>,
    impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
    O,
    +Drop<O>,
    impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
    impl IEngineTransactionTrait: EngineTransactionTrait<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait
    >
>(
    ref engine: Engine<T>
) -> Result<(), felt252> {
    if engine.use_taproot {
        return Result::Err(Error::TAPROOT_MULTISIG);
    }

    // Get number of public keys and construct array
    let num_keys = engine.dstack.pop_int()?;
    let mut num_pub_keys: i64 = ScriptNum::to_int32(num_keys).into();
    if num_pub_keys < 0 {
        return Result::Err('check multisig: num pk < 0');
    }
    if num_pub_keys > MAX_KEYS_PER_MULTISIG {
        return Result::Err('check multisig: num pk > max');
    }
    engine.num_ops += num_pub_keys.try_into().unwrap();
    if engine.num_ops > 201 { // TODO: Hardcoded limit
        return Result::Err(Error::SCRIPT_TOO_MANY_OPERATIONS);
    }
    let mut pub_keys = ArrayTrait::<ByteArray>::new();
    let mut i: i64 = 0;
    let mut err: felt252 = 0;
    while i != num_pub_keys {
        match engine.dstack.pop_byte_array() {
            Result::Ok(pk) => pub_keys.append(pk),
            Result::Err(e) => err = e
        };
        i += 1;
    };
    if err != 0 {
        return Result::Err(err);
    }

    // Get number of required sigs and construct array
    let num_sig_base = engine.dstack.pop_int()?;
    let mut num_sigs: i64 = ScriptNum::to_int32(num_sig_base).into();
    if num_sigs < 0 {
        return Result::Err('check multisig: num sigs < 0');
    }
    if num_sigs > num_pub_keys {
        return Result::Err('check multisig: num sigs > pk');
    }
    let mut sigs = ArrayTrait::<ByteArray>::new();
    i = 0;
    err = 0;
    while i != num_sigs {
        match engine.dstack.pop_byte_array() {
            Result::Ok(s) => sigs.append(s),
            Result::Err(e) => err = e
        };
        i += 1;
    };
    if err != 0 {
        return Result::Err(err);
    }

    // Historical bug
    let dummy = engine.dstack.pop_byte_array()?;

    if engine.has_flag(ScriptFlags::ScriptStrictMultiSig) && dummy.len() != 0 {
        return Result::Err(Error::SCRIPT_STRICT_MULTISIG);
    }

    let mut script = engine.sub_script();

    // TODO: add witness context inside engine to check if witness is active
    let mut s: u32 = 0;
    while s != sigs.len() {
        script = signature::remove_signature(script, sigs.at(s));
        s += 1;
    };

    let mut success = true;
    num_pub_keys += 1; // Offset due to decrementing it in the loop
    let mut pub_key_idx: i64 = -1;
    let mut sig_idx: i64 = 0;

    while num_sigs != 0 {
        pub_key_idx += 1;
        num_pub_keys -= 1;
        if num_sigs > num_pub_keys {
            success = false;
            break;
        }

        let sig = sigs.at(sig_idx.try_into().unwrap());
        let pub_key = pub_keys.at(pub_key_idx.try_into().unwrap());
        if sig.len() == 0 {
            continue;
        }

        let res = signature::parse_base_sig_and_pk(ref engine, pub_key, sig);
        if res.is_err() {
            success = false;
            err = res.unwrap_err();
            break;
        }
        let (parsed_pub_key, parsed_sig, hash_type) = res.unwrap();
        let sig_hash: u256 = sighash::calc_signature_hash(
            @script, hash_type, ref engine.transaction, engine.tx_idx
        );
        if is_valid_signature(sig_hash, parsed_sig.r, parsed_sig.s, parsed_pub_key) {
            sig_idx += 1;
            num_sigs -= 1;
        }
    };
    if err != 0 {
        return Result::Err(err);
    }

    if !success && engine.has_flag(ScriptFlags::ScriptVerifyNullFail) {
        let mut err = '';
        for s in sigs {
            if s.len() > 0 {
                err = Error::SIG_NULLFAIL;
                break;
            }
        };
        if err != '' {
            return Result::Err(err);
        }
    }

    engine.dstack.push_bool(success);
    Result::Ok(())
}

pub fn opcode_codeseparator<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.last_code_sep = engine.opcode_idx;

    if !engine.use_taproot {
        // TODO: Check if this is correct
        engine.taproot_context.code_sep = engine.opcode_idx;
    } else if engine.witness_program.len() == 0
        && engine.has_flag(ScriptFlags::ScriptVerifyConstScriptCode) {
        return Result::Err(Error::CODESEPARATOR_NON_SEGWIT);
    }

    Result::Ok(())
}

pub fn opcode_checksigverify<
    T,
    +Drop<T>,
    I,
    +Drop<I>,
    impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
    O,
    +Drop<O>,
    impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
    impl IEngineTransactionTrait: EngineTransactionTrait<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait
    >
>(
    ref engine: Engine<T>
) -> Result<(), felt252> {
    opcode_checksig(ref engine)?;
    utils::abstract_verify(ref engine)?;
    return Result::Ok(());
}

pub fn opcode_checkmultisigverify<
    T,
    +Drop<T>,
    I,
    +Drop<I>,
    impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
    O,
    +Drop<O>,
    impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
    impl IEngineTransactionTrait: EngineTransactionTrait<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait
    >
>(
    ref engine: Engine<T>
) -> Result<(), felt252> {
    opcode_checkmultisig(ref engine)?;
    utils::abstract_verify(ref engine)?;
    return Result::Ok(());
}

pub fn opcode_sha1<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let m = engine.dstack.pop_byte_array()?;
    let h: ByteArray = sha1::sha1_hash(@m).into();
    engine.dstack.push_byte_array(h);
    return Result::Ok(());
}

// https://github.com/btcsuite/btcd/blob/67b8efd3ba53b60ff0eba5d79babe2c3d82f6c54/txscript/opcode.go#L2126
// opcodeCheckSigAdd implements the OP_CHECKSIGADD operation defined in BIP
// 342. This is a replacement for OP_CHECKMULTISIGVERIFY and OP_CHECKMULTISIG
// that lends better to batch sig validation, as well as a possible future of
// signature aggregation across inputs.
//
// The op code takes a public key, an integer (N) and a signature, and returns
// N if the signature was the empty vector, and n+1 otherwise.
//
// Stack transformation: [... pubkey n signature] -> [... n | n+1 ] -> [...]
pub fn opcode_checksigadd<
    T,
    +Drop<T>,
    I,
    +Drop<I>,
    impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
    O,
    +Drop<O>,
    impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
    impl IEngineTransactionTrait: EngineTransactionTrait<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait
    >
>(
    ref engine: Engine<T>
) -> Result<(), felt252> {
    // This op code can only be used if tapscript execution is active.
    // Before the soft fork, this opcode was marked as an invalid reserved
    // op code.
    if !engine.use_taproot {
        return Result::Err(Error::OPCODE_RESERVED);
    }

    let pk_bytes: ByteArray = engine.dstack.pop_byte_array()?;
    let n: i64 = engine.dstack.pop_int()?;
    let sig_bytes: ByteArray = engine.dstack.pop_byte_array()?;

    // Only non-empty signatures count towards the total tapscript sig op
    // limit.
    if sig_bytes.len() != 0 {
        // Account for changes in the sig ops budget after this execution.
        engine.taproot_context.use_ops_budget()?;
    }

    // Empty public keys immediately cause execution to fail.
    if pk_bytes.len() == 0 {
        return Result::Err(Error::TAPROOT_EMPTY_PUBKEY);
    }

    // If the signature is empty, then we'll just push the value N back
    // onto the stack and continue from here.
    if sig_bytes.len() == 0 {
        engine.dstack.push_int(n);
        return Result::Ok(());
    }

    // Otherwise, we'll attempt to validate the signature as normal.
    //
    // If the constructor fails immediately, then it's because the public
    // key size is zero, so we'll fail all script execution.
    let mut verifier = TaprootSigVerifierTrait::<
        Transaction
    >::new(@sig_bytes, @pk_bytes, engine.taproot_context.annex)?;
    if !(TaprootSigVerifierTrait::<Transaction>::verify(ref verifier)) {
        return Result::Err(Error::TAPROOT_INVALID_SIG);
    }

    // Otherwise, we increment the accumulatorInt by one, and push that
    // back onto the stack.
    let (n_add_1, overflow) = n.overflowing_add(1);
    if overflow {
        return Result::Err(Error::STACK_OVERFLOW);
    }
    engine.dstack.push_int(n_add_1);
    Result::Ok(())
}
