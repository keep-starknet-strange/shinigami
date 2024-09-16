use crate::engine::{Engine, EngineExtrasTrait};
use crate::stack::ScriptStackTrait;
use utils::byte_array::byte_array_to_felt252_le;

pub fn opcode_false<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.push_byte_array("");
    return Result::Ok(());
}

pub fn opcode_push_data<T, +Drop<T>>(n: usize, ref engine: Engine<T>) -> Result<(), felt252> {
    let data = EngineExtrasTrait::<T>::pull_data(ref engine, n)?;
    engine.dstack.push_byte_array(data);
    return Result::Ok(());
}

pub fn opcode_push_data_x<T, +Drop<T>>(n: usize, ref engine: Engine<T>) -> Result<(), felt252> {
    let data_len_bytes = EngineExtrasTrait::<T>::pull_data(ref engine, n)?;
    let data_len: usize = byte_array_to_felt252_le(@data_len_bytes)
        .try_into()
        .unwrap();
    let data = engine.pull_data(data_len)?;
    engine.dstack.push_byte_array(data);
    return Result::Ok(());
}

pub fn opcode_n<T, +Drop<T>>(n: i64, ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.push_int(n);
    return Result::Ok(());
}

pub fn opcode_1negate<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.push_int(-1);
    return Result::Ok(());
}
