use shinigami::utils::{int_to_hex, hex_to_bytecode};
use shinigami::scriptnum::ScriptNum;
use shinigami::opcodes::tests::utils;
use shinigami::errors::Error;

fn test_op_n(value: u8) {
    let program = format!("OP_{}", value);
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(value.into())];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_0() {
    let program = "OP_0";
    let mut engine = utils::test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_true() {
    let program = "OP_TRUE";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_n_all() {
    test_op_n(1);
    test_op_n(2);
    test_op_n(3);
    test_op_n(4);
    test_op_n(5);
    test_op_n(6);
    test_op_n(7);
    test_op_n(8);
    test_op_n(9);
    test_op_n(10);
    test_op_n(11);
    test_op_n(12);
    test_op_n(13);
    test_op_n(14);
    test_op_n(15);
    test_op_n(16);
}

#[test]
fn test_op_1negate() {
    let program = "OP_1NEGATE";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(-1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

fn test_op_data(value: u8) {
    let mut hex_data: ByteArray = "0x";
    let mut i = 0;
    while i < value {
        hex_data.append_word(int_to_hex(i + 1), 2);
        i += 1;
    };

    let program = format!("OP_DATA_{} {}", value, hex_data);
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@hex_data)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_data_all() {
    test_op_data(1);
    test_op_data(2);
    test_op_data(3);
    test_op_data(4);
    test_op_data(5);
    test_op_data(6);
}

#[test]
fn test_op_push_data1() {
    let program = "OP_PUSHDATA1 0x01 0x42";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0x42")];
    utils::check_expected_dstack(ref engine, expected_stack.span());

    let program = "OP_PUSHDATA1 0x02 0x4243";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0x4243")];
    utils::check_expected_dstack(ref engine, expected_stack.span());

    let program = "OP_PUSHDATA1 0x10 0x42434445464748494A4B4C4D4E4F5051";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0x42434445464748494A4B4C4D4E4F5051")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}
