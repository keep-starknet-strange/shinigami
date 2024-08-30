use crate::engine::{Engine, EngineTrait};
use crate::stack::ScriptStackTrait;
use crate::utils;

pub fn opcode_false(ref engine: Engine) -> Result<(), felt252> {
    engine.dstack.push_byte_array("");
    return Result::Ok(());
}

pub fn opcode_push_data(n: usize, ref engine: Engine) -> Result<(), felt252> {
    let data = engine.pull_data(n)?;
    engine.dstack.push_byte_array(data);
    return Result::Ok(());
}

pub fn opcode_push_data_x(n: usize, ref engine: Engine) -> Result<(), felt252> {
    let data_len: usize = utils::byte_array_to_felt252(@engine.pull_data(n)?).try_into().unwrap();
    let data = engine.pull_data(data_len)?;
    engine.dstack.push_byte_array(data);
    return Result::Ok(());
}

pub fn opcode_n(n: i64, ref engine: Engine) -> Result<(), felt252> {
    engine.dstack.push_int(n);
    return Result::Ok(());
}

pub fn opcode_1negate(ref engine: Engine) -> Result<(), felt252> {
    engine.dstack.push_int(-1);
    return Result::Ok(());
}
