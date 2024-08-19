use shinigami::scriptnum::ScriptNum;
use shinigami::opcodes::tests::utils;
use shinigami::errors::Error;

#[test]
fn test_op_nop() {
    let program = "OP_NOP";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_EMPTY_STACK);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_nop_with_add() {
    let program = "OP_1 OP_1 OP_ADD OP_NOP";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(2)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

fn test_op_if_false() {
    let program = "OP_0 OP_IF OP_1 OP_ENDIF";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_if_true() {
    let program = "OP_1 OP_IF OP_1 OP_ENDIF";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_notif_false() {
    let program = "OP_0 OP_NOTIF OP_1 OP_ENDIF";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_notif_true() {
    let program = "OP_1 OP_NOTIF OP_1 OP_ENDIF";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_EMPTY_STACK);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_else_false() {
    let program = "OP_0 OP_IF OP_0 OP_ELSE OP_1 OP_ENDIF";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_else_true() {
    let program = "OP_1 OP_IF OP_0 OP_ELSE OP_1 OP_ENDIF";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

// TODO: No end_if, ...
// TODO: Nested if statements tests

#[test]
fn test_op_verify_empty_stack() {
    let program = "OP_VERIFY";
    let mut engine = utils::test_compile_and_run_err(program, Error::STACK_UNDERFLOW);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_verify_true() {
    let program = "OP_TRUE OP_VERIFY";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_EMPTY_STACK);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_verify_false() {
    let program = "OP_0 OP_VERIFY";
    let mut engine = utils::test_compile_and_run_err(program, Error::VERIFY_FAILED);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_return() {
    let program = "OP_RETURN OP_1";
    let mut engine = utils::test_compile_and_run_err(program, 'opcode_return: returned early');
    utils::check_dstack_size(ref engine, 0);
}

fn test_op_nop_x(value: u8) {
    let program = format!("OP_NOP{}", value);
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_EMPTY_STACK);
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
