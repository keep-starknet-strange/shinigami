use shinigami::engine::{Engine, EngineTrait};
use shinigami::stack::ScriptStackTrait;
use shinigami::opcodes::tests::utils;
use shinigami::utils::hex_to_bytecode;
use shinigami::errors::Error;

#[test]
fn test_op_ripemd160() {
    // 0x5368696E6967616D69 == 'Shinigami'
    let program = "OP_PUSHDATA1 0x09 0x5368696E6967616D69 OP_RIPEMD160";
    let mut engine = utils::test_compile_and_run(program);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![hex_to_bytecode(@"0xE51F342A8246B579DAE6B574D161345865E3CE3D")];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}
