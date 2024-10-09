use crate::engine::{Engine, EngineInternalImpl};
use crate::transaction::{
    EngineTransactionTrait, EngineTransactionInputTrait, EngineTransactionOutputTrait
};
use crate::stack::ScriptStackTrait;
use crate::scriptflags::ScriptFlags;
use crate::signature::signature;
use crate::signature::sighash;
use crate::signature::signature::BaseSigVerifierTrait;
use starknet::secp256_trait::{is_valid_signature};
use core::sha256::compute_sha256_byte_array;
use crate::opcodes::utils;
use crate::scriptnum::ScriptNum;
use crate::errors::Error;

const MAX_KEYS_PER_MULTISIG: i64 = 20;

pub fn opcode_sha256<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let arr = @engine.dstack.pop_byte_array()?;
    let res = compute_sha256_byte_array(arr).span();
    let mut res_bytes: ByteArray = "";
    let mut i: usize = 0;
    let end = res.len();
    while i != end {
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
    let end = res.len();
    while i != end {
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
    let end = res.len();
    while i != end {
        res_bytes.append_word((*res[i]).into(), 4);
        i += 1;
    };
    let res2 = compute_sha256_byte_array(@res_bytes).span();
    let mut res2_bytes: ByteArray = "";
    let mut j: usize = 0;
    let end = res2.len();
    while j != end {
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

    let res = BaseSigVerifierTrait::new(ref engine, @full_sig_bytes, @pk_bytes);

    if res.is_err() {
        // TODO: Some errors can return an error code instead of pushing false?
        if res.unwrap_err() == Error::SCRIPT_ERR_SIG_DER {
            return Result::Err(Error::SCRIPT_ERR_SIG_DER);
        };
        engine.dstack.push_bool(false);
        return Result::Ok(());
    }
    let mut sig_verifier = res.unwrap();

    if sig_verifier.verify(ref engine) {
        is_valid = true;
    } else {
        is_valid = false;
    }
    // else use BaseSigWitnessVerifier
    // let mut sig_verifier: BaseSigWitnessVerifier = BaseSigWitnessVerifierTrait::new(ref engine,
    // @full_sig_bytes, @pk_bytes)?;

    // if sig_verifier.verify(ref engine) {
    //     is_valid = true;
    // } else {
    //     is_valid = false;
    // }

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
    // TODO Error on taproot exec

    let verify_der = engine.has_flag(ScriptFlags::ScriptVerifyDERSignatures);
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
    let end = sigs.len();
    while s != end {
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
            @script, hash_type, engine.transaction, engine.tx_idx
        );

        if is_valid_signature(sig_hash, parsed_sig.r, parsed_sig.s, parsed_pub_key) {
            sig_idx += 1;
            num_sigs -= 1;
        }
    };

    if err != 0 {
        return Result::Err(err);
    }

    if !success {
        if engine.has_flag(ScriptFlags::ScriptVerifyNullFail) {
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
        } else if verify_der {
            return Result::Err(Error::SCRIPT_ERR_SIG_DER);
        }
    }

    engine.dstack.push_bool(success);
    Result::Ok(())
}

pub fn opcode_codeseparator<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.last_code_sep = engine.opcode_idx;

    // TODO Disable OP_CODESEPARATOR for non-segwit scripts.
    // if engine.witness_program.len() == 0 &&
    // engine.has_flag(ScriptFlags::ScriptVerifyConstScriptCode) {

    // return Result::Err('opcode_codeseparator:non-segwit');
    // }

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
