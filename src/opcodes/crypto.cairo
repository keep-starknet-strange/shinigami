use shinigami::engine::{Engine, EngineTrait};
use shinigami::stack::ScriptStackTrait;
use shinigami::scriptflags::ScriptFlags;

pub fn opcode_checksig(ref engine: Engine) -> Result<(), felt252> {
    let mut _pkBytes = engine.dstack.pop_byte_array();

    let mut full_sig_bytes = engine.dstack.pop_byte_array().unwrap();
    
    if full_sig_bytes.len() < 1 {
        engine.dstack.push_int(0);
    }

    return Result::Ok(());
}

pub fn opcode_codeseparator(ref engine: Engine) -> Result<(), felt252> {
	engine.last_code_sep += 1;

	// TODO Disable OP_CODESEPARATOR for non-segwit scripts.
	// if engine.witness_program.len() == 0 &&
	// 	engine.has_flag(ScriptFlags::ScriptVerifyConstScriptCode) {

	// 	return Result::Err('opcode_codeseparator:non-segwit');
	// }

    Result::Ok(())
}