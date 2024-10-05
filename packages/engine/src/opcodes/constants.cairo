use crate::engine::{Engine, EngineInternalTrait};
use crate::transaction::{
    EngineTransactionTrait, EngineTransactionInputTrait, EngineTransactionOutputTrait
};
use crate::stack::ScriptStackTrait;
use shinigami_utils::byte_array::byte_array_to_felt252_le;

pub fn opcode_false<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.push_byte_array("");
    return Result::Ok(());
}

pub fn opcode_push_data<
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
>(n: usize, ref engine: Engine<T>) -> Result<(), felt252> {
    let data = EngineInternalTrait::<I, O, T>::pull_data(ref engine, n)?;
    engine.dstack.push_byte_array(data);
    return Result::Ok(());
}

pub fn opcode_push_data_x<
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
>(n: usize, ref engine: Engine<T>) -> Result<(), felt252> {
    let data_len_bytes = EngineInternalTrait::<I, O, T>::pull_data(ref engine, n)?;
    let data_len: usize = byte_array_to_felt252_le(@data_len_bytes).try_into().unwrap();
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
