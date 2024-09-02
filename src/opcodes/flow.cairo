use crate::cond_stack::ConditionalStackTrait;
use crate::engine::Engine;
use crate::opcodes::{utils, Opcode};
use crate::stack::ScriptStackTrait;

pub fn is_branching_opcode(opcode: u8) -> bool {
    if opcode == Opcode::OP_IF
        || opcode == Opcode::OP_NOTIF
        || opcode == Opcode::OP_ELSE
        || opcode == Opcode::OP_ENDIF {
        return true;
    }
    return false;
}

pub fn opcode_nop() -> Result<(), felt252> {
    return Result::Ok(());
}

// TODO: MOve to cond_stack
const op_cond_false: u8 = 0;
const op_cond_true: u8 = 1;
const op_cond_skip: u8 = 2;
pub fn opcode_if(ref engine: Engine) -> Result<(), felt252> {
    let mut cond = op_cond_false;
    // TODO: Pop if bool
    if engine.cond_stack.branch_executing() {
        let ok = engine.dstack.pop_bool()?;
        if ok {
            cond = op_cond_true;
        }
    } else {
        cond = op_cond_skip;
    }
    engine.cond_stack.push(cond);
    return Result::Ok(());
}

pub fn opcode_notif(ref engine: Engine) -> Result<(), felt252> {
    let mut cond = op_cond_false;
    if engine.cond_stack.branch_executing() {
        let ok = engine.dstack.pop_bool()?;
        if !ok {
            cond = op_cond_true;
        }
    } else {
        cond = op_cond_skip;
    }
    engine.cond_stack.push(cond);
    return Result::Ok(());
}

pub fn opcode_else(ref engine: Engine) -> Result<(), felt252> {
    if engine.cond_stack.len() == 0 {
        return Result::Err('opcode_else: no matching if');
    }

    engine.cond_stack.swap_condition();
    return Result::Ok(());
}

pub fn opcode_endif(ref engine: Engine) -> Result<(), felt252> {
    if engine.cond_stack.len() == 0 {
        return Result::Err('opcode_endif: no matching if');
    }

    engine.cond_stack.pop()?;
    return Result::Ok(());
}

pub fn opcode_verify(ref engine: Engine) -> Result<(), felt252> {
    utils::abstract_verify(ref engine)?;
    return Result::Ok(());
}

pub fn opcode_return(ref engine: Engine) -> Result<(), felt252> {
    return Result::Err('opcode_return: returned early');
}

pub fn opcode_push(opcode: u8, script : @ByteArray, mut opcode_idx : usize) -> usize {
    let mut result : usize = 0;
    if opcode == Opcode::OP_PUSHDATA1{ 
        let nextop_code = script[opcode_idx + 1];
        let opcode_u32 : u32 = nextop_code.into();
        opcode_idx += opcode_u32 + 2; // return this
        result = opcode_idx;
    } else if opcode == Opcode::OP_PUSHDATA2{ 
        let nextop_code1 = script[opcode_idx + 1];
        let nextop_code2 = script[opcode_idx + 2];
        let opcode_u32_1 : u32 = nextop_code1.into();
        let opcode_u32_2 : u32 = nextop_code2.into();
        opcode_idx += opcode_u32_1 + opcode_u32_2 + 3;
        result = opcode_idx;
    }else if opcode == Opcode::OP_PUSHDATA4{ 
        let nextop_code1 = script[opcode_idx + 1];
        let nextop_code2 = script[opcode_idx + 2];
        let nextop_code3 = script[opcode_idx + 3];
        let nextop_code4 = script[opcode_idx + 4];
        let opcode_u32_1 : u32 = nextop_code1.into();
        let opcode_u32_2 : u32 = nextop_code2.into();
        let opcode_u32_3 : u32 = nextop_code3.into();
        let opcode_u32_4 : u32 = nextop_code4.into();
        opcode_idx += opcode_u32_1 + opcode_u32_2 + opcode_u32_3 + opcode_u32_4 + 5;
        result = opcode_idx;
    } 

    return result;
}