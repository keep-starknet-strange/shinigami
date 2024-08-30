use core::sha256::compute_sha256_byte_array;
use crate::engine::Engine;
use crate::opcodes::utils;
use crate::signature::BaseSigVerifierTrait;
use crate::stack::ScriptStackTrait;

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
