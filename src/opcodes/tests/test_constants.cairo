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
    test_op_data(7);
    test_op_data(8);
    test_op_data(9);
    test_op_data(10);
    test_op_data(11);
    test_op_data(12);
    test_op_data(13);
    test_op_data(14);
    test_op_data(15);
    test_op_data(16);
    test_op_data(17);
    test_op_data(18);
    test_op_data(19);
    test_op_data(20);
    test_op_data(21);
    test_op_data(22);
    test_op_data(23);
    test_op_data(24);
    test_op_data(25);
    test_op_data(26);
    test_op_data(27);
    test_op_data(28);
    test_op_data(29);
    test_op_data(30);
    test_op_data(31);
    test_op_data(32);
    test_op_data(33);
    test_op_data(34);
    test_op_data(35);
    test_op_data(36);
    test_op_data(37);
    test_op_data(38);
    test_op_data(39);
    test_op_data(40);
    test_op_data(41);
    test_op_data(42);
    test_op_data(43);
    test_op_data(44);
    test_op_data(45);
    test_op_data(46);
    test_op_data(47);
    test_op_data(48);
    test_op_data(49);
    test_op_data(50);
    test_op_data(51);
    test_op_data(52);
    test_op_data(53);
    test_op_data(54);
    test_op_data(55);
    test_op_data(56);
    test_op_data(57);
    test_op_data(58);
    test_op_data(59);
    test_op_data(60);
    test_op_data(61);
    test_op_data(62);
    test_op_data(63);
    test_op_data(64);
    test_op_data(65);
    test_op_data(66);
    test_op_data(67);
    test_op_data(68);
    test_op_data(69);
    test_op_data(70);
    test_op_data(71);
    test_op_data(72);
    test_op_data(73);
    test_op_data(74);
    test_op_data(75);
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
