use shinigami::engine::{Engine, EngineTrait};
use shinigami::stack::ScriptStackTrait;
use shinigami::opcodes::utils;

pub fn opcode_equal(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_byte_array()?;
    let b = engine.dstack.pop_byte_array()?;
    engine.dstack.push_bool(if a == b {
        true
    } else {
        false
    });
    return Result::Ok(());
}

pub fn opcode_equal_verify(ref engine: Engine) -> Result<(), felt252> {
    opcode_equal(ref engine)?;
    utils::abstract_verify(ref engine)?;
    return Result::Ok(());
}
