use crate::engine::{Engine, EngineExtrasTrait};
use crate::cond_stack::ConditionalStackTrait;
use crate::opcodes::{utils, Opcode};
use crate::scriptflags::ScriptFlags;
use crate::errors::Error;

pub fn is_branching_opcode(opcode: u8) -> bool {
    if opcode == Opcode::OP_IF
        || opcode == Opcode::OP_NOTIF
        || opcode == Opcode::OP_ELSE
        || opcode == Opcode::OP_ENDIF {
        return true;
    }
    return false;
}

pub fn opcode_nop<T, +Drop<T>>(ref engine: Engine<T>, opcode: u8) -> Result<(), felt252> {
    if opcode != Opcode::OP_NOP && EngineExtrasTrait::<T>::has_flag(ref engine, ScriptFlags::ScriptDiscourageUpgradableNops) {
        return Result::Err(Error::SCRIPT_DISCOURAGE_UPGRADABLE_NOPS);
    }
    return Result::Ok(());
}

// TODO: MOve to cond_stack
const op_cond_false: u8 = 0;
const op_cond_true: u8 = 1;
const op_cond_skip: u8 = 2;
pub fn opcode_if<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let mut cond = op_cond_false;
    // TODO: Pop if bool
    if engine.cond_stack.branch_executing() {
        let ok = engine.pop_if_bool()?;
        if ok {
            cond = op_cond_true;
        }
    } else {
        cond = op_cond_skip;
    }
    engine.cond_stack.push(cond);
    return Result::Ok(());
}

pub fn opcode_notif<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let mut cond = op_cond_false;
    if engine.cond_stack.branch_executing() {
        let ok = engine.pop_if_bool()?;
        if !ok {
            cond = op_cond_true;
        }
    } else {
        cond = op_cond_skip;
    }
    engine.cond_stack.push(cond);
    return Result::Ok(());
}

pub fn opcode_else<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    if engine.cond_stack.len() == 0 {
        return Result::Err('opcode_else: no matching if');
    }

    engine.cond_stack.swap_condition();
    return Result::Ok(());
}

pub fn opcode_endif<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    if engine.cond_stack.len() == 0 {
        return Result::Err('opcode_endif: no matching if');
    }

    engine.cond_stack.pop()?;
    return Result::Ok(());
}

pub fn opcode_verify<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    utils::abstract_verify(ref engine)?;
    return Result::Ok(());
}

pub fn opcode_return<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    return Result::Err('opcode_return: returned early');
}
