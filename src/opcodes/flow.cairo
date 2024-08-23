use shinigami::engine::Engine;
use shinigami::stack::ScriptStackTrait;
use shinigami::cond_stack::ConditionalStackTrait;
use shinigami::opcodes::Opcode;
use shinigami::opcodes::utils;

pub fn is_branching_opcode(opcode: u8) -> bool {
    if opcode == Opcode::OP_IF
        || opcode == Opcode::OP_NOTIF
        || opcode == Opcode::OP_ELSE
        || opcode == Opcode::OP_ENDIF {
        return true;
    }
    return false;
}

pub fn is_data_opcode(opcode: u8) -> bool {
    if opcode == Opcode::OP_DATA_1 || opcode == Opcode::OP_DATA_75 {
        return true;
    }
    return false;
}

pub fn is_pushing_opcode(opcode: u8) -> bool {
    if opcode == Opcode::OP_PUSHDATA1 
        || opcode == Opcode::OP_PUSHDATA2 
        || opcode == Opcode::OP_PUSHDATA4 {
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
