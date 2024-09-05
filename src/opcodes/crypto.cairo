use shinigami::engine::Engine;
use shinigami::stack::ScriptStackTrait;
use shinigami::signature::BaseSigVerifierTrait;
use core::sha256::compute_sha256_byte_array;
use core::num::traits::OverflowingAdd;
use shinigami::opcodes::utils;

pub fn opcode_sha256(ref engine: Engine) -> Result<(), felt252> {
    let arr = @engine.dstack.pop_byte_array()?;
    let res = compute_sha256_byte_array(arr).span();
    let mut res_bytes: ByteArray = "";
    let mut i: usize = 0;
    while i < res.len() {
        res_bytes.append_word((*res[i]).into(), 4);
        i += 1;
    };
    engine.dstack.push_byte_array(res_bytes);
    return Result::Ok(());
}

pub fn opcode_hash160(ref engine: Engine) -> Result<(), felt252> {
    let m = engine.dstack.pop_byte_array()?;
    let res = compute_sha256_byte_array(@m).span();
    let mut res_bytes: ByteArray = "";
    let mut i: usize = 0;
    while i < res.len() {
        res_bytes.append_word((*res[i]).into(), 4);
        i += 1;
    };
    let h: ByteArray = ripemd160::ripemd160_hash(@res_bytes).into();
    engine.dstack.push_byte_array(h);
    return Result::Ok(());
}

pub fn opcode_hash256(ref engine: Engine) -> Result<(), felt252> {
    let m = engine.dstack.pop_byte_array()?;
    let res = compute_sha256_byte_array(@m).span();
    let mut res_bytes: ByteArray = "";
    let mut i: usize = 0;
    while i < res.len() {
        res_bytes.append_word((*res[i]).into(), 4);
        i += 1;
    };
    let res2 = compute_sha256_byte_array(@res_bytes).span();
    let mut res2_bytes: ByteArray = "";
    let mut j: usize = 0;
    while j < res2.len() {
        res2_bytes.append_word((*res2[j]).into(), 4);
        j += 1;
    };
    engine.dstack.push_byte_array(res2_bytes);
    return Result::Ok(());
}

pub fn opcode_ripemd160(ref engine: Engine) -> Result<(), felt252> {
    let m = engine.dstack.pop_byte_array()?;
    let h: ByteArray = ripemd160::ripemd160_hash(@m).into();
    engine.dstack.push_byte_array(h);
    return Result::Ok(());
}

pub fn opcode_checksig(ref engine: Engine) -> Result<(), felt252> {
    let pk_bytes = engine.dstack.pop_byte_array()?;
    let full_sig_bytes = engine.dstack.pop_byte_array()?;

    if full_sig_bytes.len() < 1 {
        engine.dstack.push_bool(false);
        return Result::Ok(());
    }

    // TODO: add witness context inside engine to check if witness is active
    //       if witness is active use BaseSigVerifier
    let mut is_valid: bool = false;
    let mut sig_verifier = BaseSigVerifierTrait::new(ref engine, @full_sig_bytes, @pk_bytes)?;

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

    engine.dstack.push_bool(is_valid);
    return Result::Ok(());
}

pub fn opcode_codeseparator(ref engine: Engine) -> Result<(), felt252> {
    engine.last_code_sep = engine.opcode_idx;

    // TODO Disable OP_CODESEPARATOR for non-segwit scripts.
    // if engine.witness_program.len() == 0 &&
    // engine.has_flag(ScriptFlags::ScriptVerifyConstScriptCode) {

    // return Result::Err('opcode_codeseparator:non-segwit');
    // }

    Result::Ok(())
}

pub fn opcode_checksigverify(ref engine: Engine) -> Result<(), felt252> {
    opcode_checksig(ref engine)?;
    utils::abstract_verify(ref engine)?;
    return Result::Ok(());
}

pub fn opcode_sha1(ref engine: Engine) -> Result<(), felt252> {
    let m = engine.dstack.pop_byte_array()?;
    let h: ByteArray = sha1::sha1_hash(@m).into();
    engine.dstack.push_byte_array(h);
    return Result::Ok(());
}

pub fn opcode_checksigadd(ref engine: Engine) -> Result<(), felt252> {
    let pk_bytes = engine.dstack.pop_byte_array()?;
    let n = engine.dstack.pop_int()?;
    let sig_bytes = engine.dstack.pop_byte_array()?;

    if pk_bytes.len() == 0 {
        return Result::Err('EmptyPublicKey');
    }

    let mut is_valid = false;

    if n > 0x7FFFFFFF || n < -0x80000000 {
        return Result::Err('InvalidScriptNum');
    }

    if pk_bytes.len() == 32 {
        if sig_bytes.len() > 0 {
            let mut sig_verifier = BaseSigVerifierTrait::new(ref engine, @sig_bytes, @pk_bytes)?;
            is_valid = sig_verifier.verify(ref engine);
            if !is_valid {
                return Result::Err('InvalidSignature');
            }
        }
    } else {
        // Unknown public key type
        if sig_bytes.len() > 0 {
            is_valid = true;
        }
    }

    let result = if sig_bytes.len() == 0 {
        n
    } else {
        let (result, overflow) = n.overflowing_add(1);
        if overflow {
            return Result::Err('IntegerOverflow');
        }
        result
    };

    engine.dstack.push_int(result);
    Result::Ok(())
}
