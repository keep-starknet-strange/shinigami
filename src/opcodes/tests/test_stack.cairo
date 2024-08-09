use shinigami::scriptnum::ScriptNum;
use shinigami::opcodes::tests::utils;
use shinigami::errors::Error;

#[test]
fn test_op_toaltstack() {
    let program = "OP_1 OP_TOALTSTACK";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_EMPTY_STACK);
    utils::check_dstack_size(ref engine, 0);
    utils::check_astack_size(ref engine, 1);
    let expected_astack = array![ScriptNum::wrap(1)];
    utils::check_expected_astack(ref engine, expected_astack.span());
}

#[test]
fn test_op_toaltstack_underflow() {
    let program = "OP_TOALTSTACK";
    let mut engine = utils::test_compile_and_run_err(program, Error::STACK_UNDERFLOW);
    utils::check_dstack_size(ref engine, 0);
    utils::check_astack_size(ref engine, 0);
}

#[test]
fn test_op_ifdup_zero_top_stack() {
    let program = "OP_0 OP_IFDUP";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_dstack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_ifdup_non_zero_top_stack() {
    let program = "OP_1 OP_IFDUP";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 2);
    let expected_dstack = array![ScriptNum::wrap(1), ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_ifdup_multi_non_zero_top_stack() {
    let program = "OP_0 OP_1 OP_2 OP_ADD OP_IFDUP";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 3);
    let expected_dstack = array![ScriptNum::wrap(0), ScriptNum::wrap(3), ScriptNum::wrap(3)];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_depth_empty_stack() {
    let program = "OP_DEPTH";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_dstack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_depth_one_item() {
    let program = "OP_1 OP_DEPTH";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 2);
    let expected_dstack = array![ScriptNum::wrap(1), ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_depth_multiple_items() {
    let program = "OP_1 OP_1 OP_ADD OP_1 OP_DEPTH";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 3);
    let expected_dstack = array![ScriptNum::wrap(2), ScriptNum::wrap(1), ScriptNum::wrap(2)];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_drop() {
    let program = "OP_1 OP_2 OP_DROP";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_dstack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_drop_underflow() {
    let program = "OP_DROP";
    let mut engine = utils::test_compile_and_run_err(program, Error::STACK_UNDERFLOW);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_dup() {
    let program = "OP_1 OP_2 OP_DUP";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 3);
    let expected_dstack = array![ScriptNum::wrap(1), ScriptNum::wrap(2), ScriptNum::wrap(2)];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_swap() {
    let program = "OP_1 OP_2 OP_3 OP_SWAP";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 3);
    let expected_dstack = array![ScriptNum::wrap(1), ScriptNum::wrap(3), ScriptNum::wrap(2)];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_swap_mid() {
    let program = "OP_1 OP_2 OP_3 OP_SWAP OP_4 OP_5";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 5);
    let expected_dstack = array![
        ScriptNum::wrap(1),
        ScriptNum::wrap(3),
        ScriptNum::wrap(2),
        ScriptNum::wrap(4),
        ScriptNum::wrap(5)
    ];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_opcode_tuck() {
    let program = "OP_1 OP_2 OP_TUCK";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 3);
    let expected_dstack = array![ScriptNum::wrap(2), ScriptNum::wrap(1), ScriptNum::wrap(2)];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_2drop() {
    let program = "OP_1 OP_2 OP_2DROP";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_EMPTY_STACK);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_2drop_underflow() {
    let program = "OP_1 OP_2DROP";
    let mut engine = utils::test_compile_and_run_err(program, Error::STACK_UNDERFLOW);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_2dup() {
    let program = "OP_1 OP_2 OP_2DUP";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 4);
    let expected_dstack = array![
        ScriptNum::wrap(1), ScriptNum::wrap(2), ScriptNum::wrap(1), ScriptNum::wrap(2)
    ];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_3dup() {
    let program = "OP_1 OP_2 OP_3 OP_3DUP";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 6);
    let expected_dstack = array![
        ScriptNum::wrap(1),
        ScriptNum::wrap(2),
        ScriptNum::wrap(3),
        ScriptNum::wrap(1),
        ScriptNum::wrap(2),
        ScriptNum::wrap(3)
    ];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_2swap() {
    let program = "OP_1 OP_2 OP_3 OP_4 OP_2SWAP";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 4);
    let expected_dstack = array![
        ScriptNum::wrap(3), ScriptNum::wrap(4), ScriptNum::wrap(1), ScriptNum::wrap(2)
    ];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_2swap_mid() {
    let program = "OP_1 OP_2 OP_3 OP_4 OP_2SWAP OP_5 OP_6";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 6);
    let expected_dstack = array![
        ScriptNum::wrap(3),
        ScriptNum::wrap(4),
        ScriptNum::wrap(1),
        ScriptNum::wrap(2),
        ScriptNum::wrap(5),
        ScriptNum::wrap(6)
    ];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_2swap_underflow() {
    let program = "OP_1 OP_2 OP_3 OP_2SWAP";
    let _ = utils::test_compile_and_run_err(program, Error::STACK_UNDERFLOW);
}

#[test]
fn test_op_nip() {
    let program = "OP_1 OP_2 OP_NIP";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_dstack = array![ScriptNum::wrap(2)];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_nip_multi() {
    let program = "OP_1 OP_2 OP_3 OP_NIP";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 2);
    let expected_dstack = array![ScriptNum::wrap(1), ScriptNum::wrap(3)];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_nip_out_of_bounds() {
    let program = "OP_NIP";
    let mut engine = utils::test_compile_and_run_err(program, Error::STACK_OUT_OF_RANGE);
    utils::check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_rot() {
    let program = "OP_1 OP_2 OP_3 OP_ROT";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 3);
    let expected_dstack = array![ScriptNum::wrap(2), ScriptNum::wrap(3), ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_2rot() {
    let program = "OP_1 OP_2 OP_3 OP_4 OP_5 OP_6 OP_2ROT";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 6);
    let expected_dstack = array![
        ScriptNum::wrap(3),
        ScriptNum::wrap(4),
        ScriptNum::wrap(5),
        ScriptNum::wrap(6),
        ScriptNum::wrap(1),
        ScriptNum::wrap(2)
    ];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_rot_insufficient_items() {
    let program = "OP_1 OP_2 OP_ROT";
    let mut engine = utils::test_compile_and_run_err(program, Error::STACK_OUT_OF_RANGE);
    utils::check_dstack_size(ref engine, 2);
}

#[test]
fn test_op_2rot_insufficient_items() {
    let program = "OP_1 OP_2 OP_3 OP_4 OP_5 OP_2ROT";
    let mut engine = utils::test_compile_and_run_err(program, Error::STACK_OUT_OF_RANGE);
    utils::check_dstack_size(ref engine, 5);
}

#[test]
fn test_opcode_sha256() {
    let program = "OP_1 OP_SHA256";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_dstack = array!["@1274352175"];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}
