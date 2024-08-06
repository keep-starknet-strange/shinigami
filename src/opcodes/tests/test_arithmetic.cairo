use shinigami::scriptnum::ScriptNum;
use shinigami::opcodes::tests::utils;
use shinigami::errors::Error;

#[test]
fn test_op_1add() {
    let program = "OP_1 OP_1ADD";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(2)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_1sub() {
    let program = "OP_2 OP_1SUB";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_negate_1() {
    let program = "OP_1 OP_NEGATE";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(-1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_negate_0() {
    let program = "OP_0 OP_NEGATE";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_negate_negative() {
    let program = "OP_1 OP_2 OP_SUB OP_NEGATE";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_abs_positive() {
    let program = "OP_2 OP_ABS";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(2)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_abs_negative() {
    let program = "OP_0 OP_1SUB OP_ABS";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_abs_zero() {
    let program = "OP_0 OP_ABS";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_not() {
    let program = "OP_1 OP_NOT";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_add() {
    let program = "OP_1 OP_2 OP_ADD";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(3)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_sub() {
    let program = "OP_1 OP_1 OP_SUB";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());

    let program = "OP_3 OP_1 OP_SUB";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(2)];
    utils::check_expected_dstack(ref engine, expected_stack.span());

    let program = "OP_1 OP_2 OP_SUB";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(-1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_bool_and_one() {
    let program = "OP_1 OP_3 OP_BOOLAND";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_bool_and_zero() {
    let program = "OP_0 OP_4 OP_BOOLAND";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_bool_or_one() {
    let program = "OP_0 OP_1 OP_BOOLOR";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_bool_or_zero() {
    let program = "OP_0 OP_0 OP_BOOLOR";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_bool_or_both() {
    let program = "OP_1 OP_1 OP_BOOLOR";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_numequal_true() {
    let program = "OP_2 OP_2 OP_NUMEQUAL";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_numequal_false() {
    let program = "OP_2 OP_3 OP_NUMEQUAL";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_numequalverify_true() {
    let program = "OP_2 OP_2 OP_NUMEQUALVERIFY";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_EMPTY_STACK);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_numequalverify_false() {
    let program = "OP_2 OP_3 OP_NUMEQUALVERIFY";
    let mut engine = utils::test_compile_and_run_err(program, Error::VERIFY_FAILED);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_numnotequal_true() {
    let program = "OP_2 OP_3 OP_NUMNOTEQUAL";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_numnotequal_false() {
    let program = "OP_3 OP_3 OP_NUMNOTEQUAL";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_lessthan() {
    let program = "OP_1 OP_2 OP_LESSTHAN";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_lessthan_reverse() {
    let program = "OP_2 OP_1 OP_LESSTHAN";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_lessthan_equal() {
    let program = "OP_1 OP_1 OP_LESSTHAN";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_greater_than_true() {
    let program = "OP_1 OP_0 OP_GREATERTHAN";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_greater_than_false() {
    let program = "OP_0 OP_1 OP_GREATERTHAN";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_greater_than_equal_false() {
    let program = "OP_1 OP_1 OP_GREATERTHAN";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_less_than_or_equal_true_for_less_than() {
    let program = "OP_2 OP_3 OP_LESSTHANOREQUAL";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_less_than_or_equal_true_for_equal() {
    let program = "OP_2 OP_2 OP_LESSTHANOREQUAL";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_less_than_or_equal_false_for_greater_than() {
    let program = "OP_3 OP_2 OP_LESSTHANOREQUAL";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_greater_than_or_equal_true_for_greater_than() {
    let program = "OP_3 OP_2 OP_GREATERTHANOREQUAL";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_greater_than_or_equal_true_for_equal() {
    let program = "OP_2 OP_2 OP_GREATERTHANOREQUAL";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_greater_than_or_equal_false_for_less_than() {
    let program = "OP_2 OP_3 OP_GREATERTHANOREQUAL";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_min_min_first() {
    let program = "OP_1 OP_2 OP_MIN";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_min_min_second() {
    let program = "OP_2 OP_1 OP_MIN";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_min_same_value() {
    let program = "OP_1 OP_1 OP_MIN";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_max() {
    let program = "OP_1 OP_0 OP_MAX";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_within_true() {
    let program = "OP_1 OP_0 OP_3 OP_WITHIN";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_within_false() {
    let program = "OP_2 OP_0 OP_1 OP_WITHIN";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}
