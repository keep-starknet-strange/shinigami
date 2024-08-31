use crate::errors::Error;
use crate::opcodes::tests::utils;
use crate::scriptnum::ScriptNum;
use crate::utils::hex_to_bytecode;

#[test]
fn test_p2pkh_first_tx() {
    let program =
        "OP_DUP OP_HASH160 OP_PUSHBYTES_20 17194e1bd175fb5b1b2a1f9d221f6f5c29e19283 OP_EQUALVERIFY OP_CHECKSIG";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let hex_data: ByteArray = hex_to_bytecode(
        @"0xD6CDF7C9478A78B29F16C7E6DDCC5612E827BEAF6F4AEF7C1BB6FEF56BBB9A0F"
    );
    let expected_dstack = array![hex_data];
    utils::check_expected_dstack(ref engine, expected_dstack.span());
}
