use crate::engine::{Engine, EngineExtrasTrait};
use crate::stack::ScriptStackTrait;
use shinigami_utils::byte_array::byte_array_to_felt252_le;
use crate::opcodes::{Opcode};
use crate::errors::Error;
use crate::scriptflags::ScriptFlags;


pub fn opcode_false<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.push_byte_array("");
    return Result::Ok(());
}

pub fn opcode_push_data<T, +Drop<T>>(n: usize, ref engine: Engine<T>) -> Result<(), felt252> {
    let data = EngineExtrasTrait::<T>::pull_data(ref engine, n)?;
    check_discouraged_opcode(ref engine, @data)?;
    engine.dstack.push_byte_array(data);
    return Result::Ok(());
}

pub fn opcode_push_data_x<T, +Drop<T>>(n: usize, ref engine: Engine<T>) -> Result<(), felt252> {
    let data_len_bytes = EngineExtrasTrait::<T>::pull_data(ref engine, n)?;
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

pub fn check_discouraged_opcode<T, +Drop<T>>(ref engine: Engine<T>, data: @ByteArray) -> Result<(), felt252>{
    if !engine.has_flag(ScriptFlags::ScriptDiscourageUpgradableNops){
        return Result::Ok(());
    }
    let nop_opcodes = array![
        Opcode::OP_NOP1, Opcode::OP_CHECKLOCKTIMEVERIFY, Opcode::OP_CHECKSEQUENCEVERIFY, Opcode::OP_NOP4, Opcode::OP_NOP5,
        Opcode::OP_NOP6, Opcode::OP_NOP7, Opcode::OP_NOP8, Opcode::OP_NOP9, Opcode::OP_NOP10,
    ];
    let mut result = false;
    for opcode in nop_opcodes{
        if data[0] == opcode{
            result = true;
            break;
        }
    };
    if result{
        return Result::Err(Error::SCRIPT_DISCOURAGE_UPGRADABLE_NOPS);
    }
    return Result::Ok(());
}