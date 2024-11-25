use crate::engine::Engine;
use crate::scriptnum::ScriptNum;
use crate::stack::ScriptStackTrait;
use shinigami_utils::byte_array::byte_array_to_bool;

pub fn opcode_toaltstack<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let value = engine.dstack.pop_byte_array()?;
    engine.astack.push_byte_array(value);
    return Result::Ok(());
}

pub fn opcode_fromaltstack<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.astack.pop_byte_array()?;
    engine.dstack.push_byte_array(a);
    return Result::Ok(());
}

pub fn opcode_depth<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let depth: i64 = engine.dstack.len().into();
    engine.dstack.push_int(depth);
    return Result::Ok(());
}

pub fn opcode_drop<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.pop_byte_array()?;
    return Result::Ok(());
}

pub fn opcode_dup<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.dup_n(1)?;
    return Result::Ok(());
}

pub fn opcode_swap<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_byte_array()?;
    let b = engine.dstack.pop_byte_array()?;
    engine.dstack.push_byte_array(a);
    engine.dstack.push_byte_array(b);
    return Result::Ok(());
}

pub fn opcode_nip<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.nip_n(1)?;
    return Result::Ok(());
}

pub fn opcode_pick<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    engine.dstack.pick_n(ScriptNum::to_int32(a))?;

    return Result::Ok(());
}

pub fn opcode_ifdup<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.peek_byte_array(0)?;

    if byte_array_to_bool(@a) {
        engine.dstack.push_byte_array(a);
    }
    return Result::Ok(());
}

pub fn opcode_tuck<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.tuck()?;
    return Result::Ok(());
}

pub fn opcode_2drop<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.pop_byte_array()?;
    engine.dstack.pop_byte_array()?;
    return Result::Ok(());
}

pub fn opcode_2dup<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.dup_n(2)?;
    return Result::Ok(());
}

pub fn opcode_3dup<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.dup_n(3)?;
    return Result::Ok(());
}

pub fn opcode_2swap<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_byte_array()?;
    let b = engine.dstack.pop_byte_array()?;
    let c = engine.dstack.pop_byte_array()?;
    let d = engine.dstack.pop_byte_array()?;
    engine.dstack.push_byte_array(b);
    engine.dstack.push_byte_array(a);
    engine.dstack.push_byte_array(d);
    engine.dstack.push_byte_array(c);
    return Result::Ok(());
}

pub fn opcode_2rot<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.rot_n(2)?;
    return Result::Ok(());
}

pub fn opcode_rot<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.rot_n(1)?;
    return Result::Ok(());
}

pub fn opcode_roll<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let value = engine.dstack.pop_int()?;
    engine.dstack.roll_n(ScriptNum::to_int32(value))?;
    return Result::Ok(());
}

pub fn opcode_over<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.over_n(1)?;
    return Result::Ok(());
}

pub fn opcode_2over<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    engine.dstack.over_n(2)?;
    return Result::Ok(());
}
