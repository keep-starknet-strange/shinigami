use crate::errors::Error;
use crate::opcodes::tests::utils;
use crate::scriptnum::ScriptNum;
use crate::utils::hex_to_bytecode;

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
    let program = format!("OP_PUSHDATA2 0x0001 {} OP_SHA256", byte_data);
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
fn test_op_hash160() {
    // 0x5368696E6967616D69 == 'Shinigami'
    let program = "OP_PUSHDATA1 0x09 0x5368696E6967616D69 OP_HASH160";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0x122ACAB01A6C742866AA84B2DD65870BC1210769")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_hash160_1() {
    let program = "OP_1 OP_HASH160";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0xC51B66BCED5E4491001BD702669770DCCF440982")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_hash160_2() {
    let program = "OP_2 OP_HASH160";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0xA6BB94C8792C395785787280DC188D114E1F339B")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_hash160_data_8() {
    let program = "OP_DATA_8 0x0102030405060708 OP_HASH160";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0x16421b3d07efa2543203d69c093984eba95f9d0d")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_hash160_push_data_2() {
    let byte_data: ByteArray =
        "0x000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF";
    let program = format!("OP_PUSHDATA2 0x0001 {} OP_HASH160", byte_data);
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_dstack = array![hex_to_bytecode(@"0x07A536D93E0B9A779874E1287A226B8230CDA46E")];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_hash160_14_double_hash160() {
    let program = "OP_14 OP_HASH160 OP_HASH160";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0x03DD47CAF3B9A1EC04C224DB9CB0E6AE0FEEC59E")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_hash256() {
    // 0x5368696E6967616D69 == 'Shinigami'
    let program = "OP_PUSHDATA1 0x09 0x5368696E6967616D69 OP_HASH256";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![
        hex_to_bytecode(@"0x39C02658ED1416713CF4098382E80D07786EED7004FC3FD89B38C7165FDABC80")
    ];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_hash256_1() {
    let program = "OP_1 OP_HASH256";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![
        hex_to_bytecode(@"0x9C12CFDC04C74584D787AC3D23772132C18524BC7AB28DEC4219B8FC5B425F70")
    ];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_hash256_2() {
    let program = "OP_2 OP_HASH256";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![
        hex_to_bytecode(@"0x1CC3ADEA40EBFD94433AC004777D68150CCE9DB4C771BC7DE1B297A7B795BBBA")
    ];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_hash256_data_8() {
    let program = "OP_DATA_8 0x0102030405060708 OP_HASH256";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![
        hex_to_bytecode(@"0x2502FA942289B144EDB4CD31C0313624C030885420A86363CE91589D78F8295A")
    ];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_hash256_push_data_2() {
    let byte_data: ByteArray =
        "0x000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF";
    let program = format!("OP_PUSHDATA2 0x0001 {} OP_HASH256", byte_data);
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let hex_data: ByteArray = hex_to_bytecode(
        @"0x60BD11C69262F84DDFEA5F0D116D40AF862C4DD8C2A92FB90E368B132E8FA89C"
    );
    let expected_dstack = array![hex_data];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_hash256_14_double_hash256() {
    let program = "OP_14 OP_HASH256 OP_HASH256";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let hex_data: ByteArray = hex_to_bytecode(
        @"0x26AA6C7A9B46E9C409F09C179F7DEFF54F7AF5571D38DE5E5D9BA3932B91F55B"
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
    let program = format!("OP_PUSHDATA2 0x0001 {} OP_RIPEMD160", byte_data);
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let hex_data: ByteArray = hex_to_bytecode(@"0x9C4FA072DB2C871A5635E37F791E93AB45049676");
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

#[test]
fn test_op_checksig_valid() {
    let script_sig =
        "OP_DATA_71 0x3044022008f4f37e2d8f74e18c1b8fde2374d5f28402fb8ab7fd1cc5b786aa40851a70cb02201f40afd1627798ee8529095ca4b205498032315240ac322c9d8ff0f205a93a5801 OP_DATA_33 0x024aeaf55040fa16de37303d13ca1dde85f4ca9baa36e2963a27a1c0c1165fe2b1";
    let script_pubkey =
        "OP_DUP OP_HASH160 OP_DATA_20 0x4299ff317fcd12ef19047df66d72454691797bfc OP_EQUALVERIFY OP_CHECKSIG";
    let mut transaction = utils::mock_transaction(script_sig);
    let mut engine = utils::test_compile_and_run_with_tx(script_pubkey, transaction);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_checksig_wrong_signature() {
    let script_sig =
        "OP_DATA_71 0x3044022008f4f37e2d8f74f18c1b8fde2374d5f28402fb8ab7fd1cc5b786aa40851a70cb02201f40afd1627798ee8529095ca4b205498032315240ac322c9d8ff0f205a93a5801 OP_DATA_33 0x024aeaf55040fa16de37303d13ca1dde85f4ca9baa36e2963a27a1c0c1165fe2b1";
    let script_pubkey =
        "OP_DUP OP_HASH160 OP_DATA_20 0x4299ff317fcd12ef19047df66d72454691797bfc OP_EQUALVERIFY OP_CHECKSIG";
    let mut transaction = utils::mock_transaction(script_sig);
    let mut engine = utils::test_compile_and_run_with_tx_err(
        script_pubkey, transaction, Error::SCRIPT_FAILED
    );
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_checksig_invalid_hash_type() {
    let script_sig =
        "OP_DATA_71 0x3044022008f4f37e2d8f74e18c1b8fde2374d5f28402fb8ab7fd1cc5b786aa40851a70cb02201f40afd1627798ee8529095ca4b205498032315240ac322c9d8ff0f205a93a5807 OP_DATA_33 0x024aeaf55040fa16de37303d13ca1dde85f4ca9baa36e2963a27a1c0c1165fe2b1";
    let script_pubkey =
        "OP_DUP OP_HASH160 OP_DATA_20 0x4299ff317fcd12ef19047df66d72454691797bfc OP_EQUALVERIFY OP_CHECKSIG";
    let mut transaction = utils::mock_transaction(script_sig);
    let mut engine = utils::test_compile_and_run_with_tx_err(
        script_pubkey, transaction, Error::SCRIPT_FAILED
    );
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![""];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_checksig_empty_signature() {
    let script_sig =
        "OP_0 OP_DATA_33 0x024aeaf55040fa16de37303d13ca1dde85f4ca9baa36e2963a27a1c0c1165fe2b1";
    let script_pubkey =
        "OP_DUP OP_HASH160 OP_DATA_20 0x4299ff317fcd12ef19047df66d72454691797bfc OP_EQUALVERIFY OP_CHECKSIG";
    let mut transaction = utils::mock_transaction(script_sig);
    let mut engine = utils::test_compile_and_run_with_tx_err(
        script_pubkey, transaction, Error::SCRIPT_FAILED
    );
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(0)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_checksig_too_short_signature() {
    let script_sig =
        "OP_1 OP_DATA_33 0x024aeaf55040fa16de37303d13ca1dde85f4ca9baa36e2963a27a1c0c1165fe2b1";
    let script_pubkey =
        "OP_DUP OP_HASH160 OP_DATA_20 0x4299ff317fcd12ef19047df66d72454691797bfc OP_EQUALVERIFY OP_CHECKSIG";
    let mut transaction = utils::mock_transaction(script_sig);
    let mut engine = utils::test_compile_and_run_with_tx_err(
        script_pubkey, transaction, 'invalid sig fmt: too short'
    );
    utils::check_dstack_size(ref engine, 0);
    let expected_stack = array![];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_sha1() {
    // 0x5368696E6967616D69 == 'Shinigami'
    let program = "OP_PUSHDATA1 0x09 0x5368696E6967616D69 OP_SHA1";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0x845AD2AB31A509E064B49D2360EB2A5C39BE4856")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_sha1_1() {
    let program = "OP_1 OP_SHA1";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0xBF8B4530D8D246DD74AC53A13471BBA17941DFF7")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_sha1_2() {
    let program = "OP_2 OP_SHA1";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0xC4EA21BB365BBEEAF5F2C654883E56D11E43C44E")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_op_sha1_data_8() {
    let program = "OP_DATA_8 0x0102030405060708 OP_SHA1";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0xDD5783BCF1E9002BC00AD5B83A95ED6E4EBB4AD5")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_sha1_push_data_2() {
    let byte_data: ByteArray =
        "0x000102030405060708090A0B0C0D0E0F101112131415161718191A1B1C1D1E1F202122232425262728292A2B2C2D2E2F303132333435363738393A3B3C3D3E3F404142434445464748494A4B4C4D4E4F505152535455565758595A5B5C5D5E5F606162636465666768696A6B6C6D6E6F707172737475767778797A7B7C7D7E7F808182838485868788898A8B8C8D8E8F909192939495969798999A9B9C9D9E9FA0A1A2A3A4A5A6A7A8A9AAABACADAEAFB0B1B2B3B4B5B6B7B8B9BABBBCBDBEBFC0C1C2C3C4C5C6C7C8C9CACBCCCDCECFD0D1D2D3D4D5D6D7D8D9DADBDCDDDEDFE0E1E2E3E4E5E6E7E8E9EAEBECEDEEEFF0F1F2F3F4F5F6F7F8F9FAFBFCFDFEFF";
    let program = format!("OP_PUSHDATA2 0x0001 {} OP_SHA1", byte_data);
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let hex_data: ByteArray = hex_to_bytecode(@"0x4916D6BDB7F78E6803698CAB32D1586EA457DFC8");
    let expected_dstack = array![hex_data];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}

#[test]
fn test_op_sha1_14_double_sha1() {
    let program = "OP_14 OP_SHA1 OP_SHA1";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0xC0BDFDD54F44A37833C74DA7613B87A5BA9A8452")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}
