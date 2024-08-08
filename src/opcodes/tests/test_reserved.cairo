use shinigami::opcodes::tests::utils;
use shinigami::errors::Error;

#[test]
fn test_op_reserved() {
    let program = "OP_RESERVED";
    let mut engine = utils::test_compile_and_run_err(program, Error::OPCODE_RESERVED);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_reserved1() {
    let program = "OP_RESERVED1";
    let mut engine = utils::test_compile_and_run_err(program, Error::OPCODE_RESERVED);
    utils::check_dstack_size(ref engine, 0);
}


#[test]
fn test_op_reserved2() {
    let program = "OP_RESERVED2";
    let mut engine = utils::test_compile_and_run_err(program, Error::OPCODE_RESERVED);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_ver() {
    let program = "OP_VER";
    let mut engine = utils::test_compile_and_run_err(program, Error::OPCODE_RESERVED);
    utils::check_dstack_size(ref engine, 0);
}

fn test_op_nop_x(value: u8) {
    let program = format!("OP_NOP{}", value);
    let mut engine = utils::test_compile_and_run_err(program, Error::OPCODE_RESERVED);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_nop_x_all() {
    test_op_nop_x(1);
    test_op_nop_x(4);
    test_op_nop_x(5);
    test_op_nop_x(6);
    test_op_nop_x(7);
    test_op_nop_x(8);
    test_op_nop_x(9);
    test_op_nop_x(10);
}
