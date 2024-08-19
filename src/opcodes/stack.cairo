use shinigami::engine::{Engine, EngineTrait};
use shinigami::scriptnum::ScriptNum;
use shinigami::stack::ScriptStackTrait;
use shinigami::utils;

pub fn opcode_toaltstack(ref engine: Engine) -> Result<(), felt252> {
    let value = engine.dstack.pop_byte_array()?;
    engine.astack.push_byte_array(value);
    return Result::Ok(());
}

pub fn opcode_fromaltstack(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.astack.pop_byte_array()?;
    engine.dstack.push_byte_array(a);
    return Result::Ok(());
}

pub fn opcode_depth(ref engine: Engine) -> Result<(), felt252> {
    let depth: i64 = engine.dstack.len().into();
    engine.dstack.push_int(depth);
    return Result::Ok(());
}

pub fn opcode_drop(ref engine: Engine) -> Result<(), felt252> {
    engine.dstack.pop_byte_array()?;
    return Result::Ok(());
}

pub fn opcode_dup(ref engine: Engine) -> Result<(), felt252> {
    engine.dstack.dup_n(1)?;
    return Result::Ok(());
}

pub fn opcode_swap(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_byte_array()?;
    let b = engine.dstack.pop_byte_array()?;
    engine.dstack.push_byte_array(a);
    engine.dstack.push_byte_array(b);
    return Result::Ok(());
}

pub fn opcode_nip(ref engine: Engine) -> Result<(), felt252> {
    engine.dstack.nip_n(1)?;
    return Result::Ok(());
}

pub fn opcode_pick(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    engine.dstack.pick_n(ScriptNum::to_int32(a))?;

    return Result::Ok(());
}

pub fn opcode_ifdup(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.peek_byte_array(0)?;

    if utils::byte_array_to_bool(@a) {
        engine.dstack.push_byte_array(a);
    }
    return Result::Ok(());
}

pub fn opcode_tuck(ref engine: Engine) -> Result<(), felt252> {
    engine.dstack.tuck()?;
    return Result::Ok(());
}

pub fn opcode_2drop(ref engine: Engine) -> Result<(), felt252> {
    engine.dstack.pop_byte_array()?;
    engine.dstack.pop_byte_array()?;
    return Result::Ok(());
}

pub fn opcode_2dup(ref engine: Engine) -> Result<(), felt252> {
    engine.dstack.dup_n(2)?;
    return Result::Ok(());
}

pub fn opcode_3dup(ref engine: Engine) -> Result<(), felt252> {
    engine.dstack.dup_n(3)?;
    return Result::Ok(());
}

pub fn opcode_2swap(ref engine: Engine) -> Result<(), felt252> {
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

pub fn opcode_2rot(ref engine: Engine) -> Result<(), felt252> {
    engine.dstack.rot_n(2)?;
    return Result::Ok(());
}

pub fn opcode_rot(ref engine: Engine) -> Result<(), felt252> {
    engine.dstack.rot_n(1)?;
    return Result::Ok(());
}
pub fn opcode_over(ref engine: Engine) -> Result<(), felt252> {
    engine.dstack.over_n(1)?;
    return Result::Ok(());
}

pub fn opcode_2over(ref engine: Engine) -> Result<(), felt252> {
    engine.dstack.over_n(2)?;
    return Result::Ok(());
}
