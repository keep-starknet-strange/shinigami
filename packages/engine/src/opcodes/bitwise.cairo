use crate::engine::Engine;
use crate::opcodes::utils;
use crate::stack::ScriptStackTrait;

pub fn opcode_equal<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_byte_array()?;
    let b = engine.dstack.pop_byte_array()?;
    engine.dstack.push_bool(if a == b {
        true
    } else {
        false
    });
    return Result::Ok(());
}

pub fn opcode_equal_verify<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    opcode_equal(ref engine)?;
    utils::abstract_verify(ref engine)?;
    return Result::Ok(());
}
