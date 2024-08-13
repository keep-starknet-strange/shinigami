use shinigami::engine::{Engine, EngineTrait};
use shinigami::stack::ScriptStackTrait;
use shinigami::opcodes::tests::utils;
use shinigami::utils::hex_to_bytecode;
use shinigami::errors::Error;

fn test_opcode_sha256_1() {
    let program = "OP_1 OP_SHA256";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let hex_data: ByteArray = hex_to_bytecode(
        @"0x4BF5122F344554C53BDE2EBB8CD2B7E3D1600AD631C385A5D7CCE23C7785459A"
    );
    let expected_dstack = array![hex_data];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_opcode_sha256_2() {
    let program = "OP_2 OP_SHA256";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let hex_data: ByteArray = hex_to_bytecode(
        @"0xDBC1B4C900FFE48D575B5DA5C638040125F65DB0FE3E24494B76EA986457D986"
    );
    let expected_dstack = array![hex_data];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_opcode_sha256_data_8() {
    let program = "OP_DATA_8 0x0102030405060708 OP_SHA256";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let hex_data: ByteArray = hex_to_bytecode(
        @"0x66840DDA154E8A113C31DD0AD32F7F3A366A80E8136979D8F5A101D3D29D6F72"
    );
    let expected_dstack = array![hex_data];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_opcode_sha256_push_data_2() {
    let byte_data: ByteArray =
        "0x000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF";
    let program = format!("OP_PUSHDATA2 0x0100 {} OP_SHA256", byte_data);
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let hex_data: ByteArray = hex_to_bytecode(
        @"0x40AFF2E9D2D8922E47AFD4648E6967497158785FBD1DA870E7110266BF944880"
    );
    let expected_dstack = array![hex_data];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_opcode_sha256_14_double_sha256() {
    let program = "OP_14 OP_SHA256 OP_SHA256";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let hex_data: ByteArray = hex_to_bytecode(
        @"0xD6CDF7C9478A78B29F16C7E6DDCC5612E827BEAF6F4AEF7C1BB6FEF56BBB9A0F"
    );
    let expected_dstack = array![hex_data];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_ripemd160() {
    // 0x5368696E6967616D69 == 'Shinigami'
    let program = "OP_PUSHDATA1 0x09 0x5368696E6967616D69 OP_RIPEMD160";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0xE51F342A8246B579DAE6B574D161345865E3CE3D")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_ripemd160_1() {
    let program = "OP_1 OP_RIPEMD160";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0xF291BA5015DF348C80853FA5BB0F7946F5C9E1B3")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_ripemd160_2() {
    let program = "OP_2 OP_RIPEMD160";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0x1E9955C5DBF77215CC79235668861E435FA2C3AB")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_ripemd160_data_8() {
    let program = "OP_DATA_8 0x0102030405060708 OP_RIPEMD160";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0xC9883EECE7DCA619B830DC9D87E82C38478111C0")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_ripemd160_push_data_2() {
    let byte_data: ByteArray =
        "0x000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF";
    let program = format!("OP_PUSHDATA2 0x0100 {} OP_RIPEMD160", byte_data);
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let hex_data: ByteArray = hex_to_bytecode(
        @"0x9C4FA072DB2C871A5635E37F791E93AB45049676"
    );
    let expected_dstack = array![hex_data];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_ripemd160_14_double_ripemd160() {
    let program = "OP_14 OP_RIPEMD160 OP_RIPEMD160";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0xA407E5C9190ACA4F4A6C676D130F5A72CEFB0D60")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}
