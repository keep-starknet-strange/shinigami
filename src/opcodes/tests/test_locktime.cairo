use shinigami::engine::{Engine, EngineTrait};
use shinigami::stack::ScriptStackTrait;
use shinigami::opcodes::tests::utils;
use shinigami::utils::hex_to_bytecode;
use shinigami::errors::Error;
use shinigami::scriptflags::ScriptFlags;
use shinigami::scriptnum::ScriptNum;
use shinigami::opcodes::locktime::MAX_SEQUENCE;

#[test]
fn test_opcode_checklocktime() {
    let mut program =
        "OP_DATA_4 0x8036BE26 OP_CHECKLOCKTIMEVERIFY"; // 0x8036BE26 == 650000000 in ScriptNum
    let mut tx = utils::mock_transaction_locktime("");
    tx.locktime = 700000000;

    let flags: u32 = ScriptFlags::ScriptVerifyCheckLockTimeVerify.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags(program, tx, flags);
    utils::check_dstack_size(ref engine, 1);
}
#[test]
fn test_opcode_checklocktime_unsatisfied_fail() {
    let program = "OP_DATA_4 0x26BE3680 OP_CHECKLOCKTIMEVERIFY"; // 0x26BE3680 == 650000000
    let mut tx = utils::mock_transaction("");
    tx.locktime = 600000000;

    let flags: u32 = ScriptFlags::ScriptVerifyCheckLockTimeVerify.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags_err(
        program, tx, flags, Error::UNSATISFIED_LOCKTIME
    );
    utils::check_dstack_size(ref engine, 1);
}

#[test]
fn test_opcode_checklocktime_height() {
    let program = "OP_16 OP_CHECKLOCKTIMEVERIFY";

    let mut tx = utils::mock_transaction_locktime("");
    tx.locktime = 20;

    let flags: u32 = ScriptFlags::ScriptVerifyCheckLockTimeVerify.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags(program, tx, flags);
    utils::check_dstack_size(ref engine, 1);
}

#[test]
// This test has value who failed with opcdoe checklocktimeverify but necessary flag is not set
fn test_opcode_checklocktime_as_op_nop2() {
    let program = "OP_16 OP_CHECKLOCKTIMEVERIFY";

    let mut tx = utils::mock_transaction_locktime("");
    tx.locktime = 10;

    // Running without the flag 'ScriptVerifyCheckLockTimeVerify' result as OP_NOP2
    let mut engine = utils::test_compile_and_run_with_tx(program, tx);
    utils::check_dstack_size(ref engine, 1);
}

#[test]
// This test has value who failed with opcdoe checklocktimeverify but necessary flag is not set
fn test_opcode_checklocktime_as_op_nop2_fail() {
    let program = "OP_16 OP_CHECKLOCKTIMEVERIFY";

    let mut tx = utils::mock_transaction_locktime("");
    tx.locktime = 10;

    // Running without the flag 'ScriptVerifyCheckLockTimeVerify' result as OP_NOP2 behavior
    // 'ScriptDiscourageUpgradableNops' prevents to have OP_NOP behavior
    let flags: u32 = ScriptFlags::ScriptDiscourageUpgradableNops.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags_err(
        program, tx, flags, Error::SCRIPT_FAILED
    );
    utils::check_dstack_size(ref engine, 1);
}

#[test]
fn test_opcode_checklocktime_sequence_fail() {
    let mut program =
        "OP_DATA_4 0x8036BE26 OP_CHECKLOCKTIMEVERIFY"; // 0x8036BE26 == 650000000 in ScriptNum
	// By default the sequence field is set to MAX_SEQUENCE / 0xFFFFFFFF
    let mut tx = utils::mock_transaction("");
    tx.locktime = 700000000;

    let flags: u32 = ScriptFlags::ScriptVerifyCheckLockTimeVerify.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags_err(
        program, tx, flags, Error::FINALIZED_TX
    );
    utils::check_dstack_size(ref engine, 1);
}
