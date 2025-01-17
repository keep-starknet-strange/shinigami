use shinigami_engine::errors::Error;
use shinigami_engine::scriptnum::ScriptNum;
use shinigami_utils::hex::int_to_hex;
use shinigami_utils::bytecode::hex_to_bytecode;
use crate::utils::{
    test_compile_and_run, test_compile_and_run_err, check_expected_dstack, check_dstack_size,
};

fn test_op_n(value: u8) {
    let program = format!("OP_{}", value);
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(value.into())];
    check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_0() {
    let program = "OP_0";
    let mut engine = test_compile_and_run_err(program, Error::SCRIPT_FAILED);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_true() {
    let program = "OP_TRUE";
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    check_expected_dstack(ref engine, expected_stack.span());
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
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(-1)];
    check_expected_dstack(ref engine, expected_stack.span());
}

fn test_op_data(value: u8) {
    let mut hex_data: ByteArray = "0x";
    let mut i = 0;
    while i != value {
        hex_data.append_word(int_to_hex(i + 1), 2);
        i += 1;
    };

    let program = format!("OP_DATA_{} {}", value, hex_data);
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@hex_data)];
    check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
#[available_gas(1000000000000)]
fn test_op_data_all() {
    let mut n = 1;

    while n != 76 {
        test_op_data(n);
        n += 1;
    }
}

#[test]
fn test_op_push_data1() {
    let program = "OP_PUSHDATA1 0x01 0x42";
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0x42")];
    check_expected_dstack(ref engine, expected_stack.span());

    let program = "OP_PUSHDATA1 0x02 0x4243";
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0x4243")];
    check_expected_dstack(ref engine, expected_stack.span());

    let program = "OP_PUSHDATA1 0x10 0x42434445464748494A4B4C4D4E4F5051";
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0x42434445464748494A4B4C4D4E4F5051")];
    check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_push_data2() {
    let program = "OP_PUSHDATA2 0x0100 0x42";
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0x42")];
    check_expected_dstack(ref engine, expected_stack.span());
    let program = "OP_PUSHDATA2 0x0200 0x4243";
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0x4243")];
    check_expected_dstack(ref engine, expected_stack.span());
    let byte_data: ByteArray =
        "0x000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF";
    let program = format!("OP_PUSHDATA2 0x0001 {}", byte_data);
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@byte_data)];
    check_expected_dstack(ref engine, expected_stack.span());
    // Test error case: data bytes fewer than specified in length field
    let program: ByteArray = "OP_PUSHDATA2 0x0300 0x4243";
    let mut engine = test_compile_and_run_err(program, Error::SCRIPT_INVALID);
    // fail to pull data so nothing is pushed into the dstack.
    check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_push_data4() {
    let program = "OP_PUSHDATA4 0x01000000 0x42";
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0x42")];
    check_expected_dstack(ref engine, expected_stack.span());

    let program = "OP_PUSHDATA4 0x02000000 0x4243";
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0x4243")];
    check_expected_dstack(ref engine, expected_stack.span());

    let byte_data: ByteArray =
        "0x000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF";
    let program = format!("OP_PUSHDATA4 0x00010000 {}", byte_data);
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@byte_data)];
    check_expected_dstack(ref engine, expected_stack.span());

    // Test error case: data bytes fewer than specified in length field
    let program = "OP_PUSHDATA4 0x01 0x4243";
    let mut engine = test_compile_and_run_err(program, Error::SCRIPT_INVALID);
    check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_pushdata1_in_if() {
    let program =
        "OP_0 OP_IF OP_PUSHDATA1 0x4c 0x81818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181 OP_ENDIF OP_1";
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_pushdata1_in_if_with_disabled() {
    let program =
        "OP_0 OP_IF OP_PUSHDATA1 0x4c 0x8181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181 OP_ENDIF OP_1";
    let mut engine = test_compile_and_run_err(program, Error::OPCODE_DISABLED);
    check_dstack_size(ref engine, 0);
}

#[test]
fn test_op_pushdata2_in_if() {
    let program =
        "OP_0 OP_IF OP_PUSHDATA2 0x4c00 0x81818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181 OP_ENDIF OP_1";
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_pushdata4_in_if() {
    let program =
        "OP_0 OP_IF OP_PUSHDATA4 0x4c000000 0x81818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181818181 OP_ENDIF OP_1";
    let mut engine = test_compile_and_run(program);
    check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    check_expected_dstack(ref engine, expected_stack.span());
}
