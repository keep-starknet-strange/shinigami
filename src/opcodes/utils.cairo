use crate::engine::Engine;
use crate::errors::Error;
use crate::stack::ScriptStackTrait;

pub fn abstract_verify(ref engine: Engine) -> Result<(), felt252> {
    let verified = engine.dstack.pop_bool()?;
    if !verified {
        return Result::Err(Error::VERIFY_FAILED);
    }
    Result::Ok(())
}

pub fn not_implemented(ref engine: Engine) -> Result<(), felt252> {
    return Result::Err(Error::OPCODE_NOT_IMPLEMENTED);
}

pub fn opcode_reserved(msg: ByteArray, ref engine: Engine) -> Result<(), felt252> {
    return Result::Err(Error::OPCODE_RESERVED);
}

pub fn opcode_disabled(ref engine: Engine) -> Result<(), felt252> {
    return Result::Err(Error::OPCODE_DISABLED);
}
