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

#[test]
fn test_op_verif() {
    let program = "OP_VERIF";
    let mut engine = utils::test_compile_and_run_err(program, Error::OPCODE_RESERVED);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_vernotif() {
    let program = "OP_VERNOTIF";
    let mut engine = utils::test_compile_and_run_err(program, Error::OPCODE_RESERVED);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_verif_if() {
    let program = "OP_0 OP_IF OP_VERIF OP_ENDIF OP_1";
    let mut engine = utils::test_compile_and_run_err(program, Error::OPCODE_RESERVED);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_vernotif_if() {
    let program = "OP_0 OP_IF OP_VERNOTIF OP_ENDIF OP_1";
    let mut engine = utils::test_compile_and_run_err(program, Error::OPCODE_RESERVED);
    utils::check_dstack_size(ref engine, 0);
}
