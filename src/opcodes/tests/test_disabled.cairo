use crate::errors::Error;
use crate::opcodes::tests::utils;

// TODO is there a way to define this as a const?
fn disabled_opcodes() -> core::array::Array<ByteArray> {
    let mut disabled_opcodes = ArrayTrait::<ByteArray>::new();
    disabled_opcodes.append("OP_CAT");
    disabled_opcodes.append("OP_SUBSTR");
    disabled_opcodes.append("OP_LEFT");
    disabled_opcodes.append("OP_RIGHT");
    disabled_opcodes.append("OP_INVERT");
    disabled_opcodes.append("OP_AND");
    disabled_opcodes.append("OP_OR");
    disabled_opcodes.append("OP_XOR");
    disabled_opcodes.append("OP_2MUL");
    disabled_opcodes.append("OP_2DIV");
    disabled_opcodes.append("OP_MUL");
    disabled_opcodes.append("OP_DIV");
    disabled_opcodes.append("OP_MOD");
    disabled_opcodes.append("OP_LSHIFT");
    disabled_opcodes.append("OP_RSHIFT");
    disabled_opcodes
}

#[test]
fn test_op_code_disabled() {
    let disabled_opcodes = disabled_opcodes();
    let mut i: usize = 0;
    while i < disabled_opcodes.len() {
        let mut engine = utils::test_compile_and_run_err(
            disabled_opcodes.at(i).clone(), Error::OPCODE_DISABLED
        );
        utils::check_dstack_size(ref engine, 0);
        i += 1;
    }
}

#[test]
fn test_disabled_opcodes_if_block() {
    let disabled_opcodes = disabled_opcodes();
    let mut i: usize = 0;
    while i < disabled_opcodes.len() {
        let program = format!(
            "OP_1 OP_IF {} OP_ELSE OP_DROP OP_ENDIF", disabled_opcodes.at(i).clone()
        );
        let mut engine = utils::test_compile_and_run_err(program, Error::OPCODE_DISABLED);
        utils::check_dstack_size(ref engine, 0);
        i += 1;
    }
}

#[test]
fn test_disabled_opcodes_else_block() {
    let disabled_opcodes = disabled_opcodes();
    let mut i: usize = 0;
    while i < disabled_opcodes.len() {
        let program = format!(
            "OP_0 OP_IF OP_DROP OP_ELSE {} OP_ENDIF", disabled_opcodes.at(i).clone()
        );
        let mut engine = utils::test_compile_and_run_err(program, Error::OPCODE_DISABLED);
        utils::check_dstack_size(ref engine, 0);
        i += 1;
    }
}


#[test]
fn test_disabled_opcode_in_unexecd_if_block() {
    let disabled_opcodes = disabled_opcodes();
    let mut i: usize = 0;
    while i < disabled_opcodes.len() {
        let program = format!(
            "OP_0 OP_IF {} OP_ELSE OP_DROP OP_ENDIF", disabled_opcodes.at(i).clone()
        );
        let mut engine = utils::test_compile_and_run_err(program, Error::OPCODE_DISABLED);
        utils::check_dstack_size(ref engine, 0);
        i += 1;
    }
}

