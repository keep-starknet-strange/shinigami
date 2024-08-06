use shinigami::opcodes::tests::utils;
use shinigami::errors::Error;

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
