use shinigami_engine::errors::Error;
use shinigami_engine::scriptnum::ScriptNum;
use crate::utils;

#[test]
fn test_op_equal() {
    let program = "OP_1 OP_1 OP_EQUAL";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_equal_false() {
    let program = "OP_0 OP_1 OP_EQUAL";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}
