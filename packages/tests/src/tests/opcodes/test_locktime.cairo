use shinigami_engine::errors::Error;
use shinigami_engine::flags::ScriptFlags;
use crate::utils;

#[test]
fn test_opcode_checklocktime() {
    let mut program =
        "OP_DATA_4 0x8036BE26 OP_CHECKLOCKTIMEVERIFY"; // 0x8036BE26 == 650000000 in ScriptNum
    let mut tx = utils::mock_transaction_legacy_locktime("", 700000000);

    let flags: u32 = ScriptFlags::ScriptVerifyCheckLockTimeVerify.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags(program, tx, flags);
    utils::check_dstack_size(ref engine, 1);
}

#[test]
fn test_opcode_checklocktime_unsatisfied_fail() {
    let mut program =
        "OP_DATA_4 0x8036BE26 OP_CHECKLOCKTIMEVERIFY"; // 0x8036BE26 == 650000000 in ScriptNum
    let mut tx = utils::mock_transaction_legacy_locktime("", 600000000);

    let flags: u32 = ScriptFlags::ScriptVerifyCheckLockTimeVerify.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags_err(
        program, tx, flags, Error::UNSATISFIED_LOCKTIME
    );
    utils::check_dstack_size(ref engine, 1);
}

#[test]
fn test_opcode_checklocktime_block() {
    let program = "OP_16 OP_CHECKLOCKTIMEVERIFY";

    let mut tx = utils::mock_transaction_legacy_locktime("", 20);

    let flags: u32 = ScriptFlags::ScriptVerifyCheckLockTimeVerify.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags(program, tx, flags);
    utils::check_dstack_size(ref engine, 1);
}

// This test has value who failed with opcdoe checklocktimeverify but necessary flag is not set
// so OP_CHECKLOCKTIMEVERIFY behave as OP_NOP
#[test]
fn test_opcode_checklocktime_as_op_nop() {
    let program = "OP_16 OP_CHECKLOCKTIMEVERIFY";

    let mut tx = utils::mock_transaction_legacy_locktime("", 10);

    // Running without the flag 'ScriptVerifyCheckLockTimeVerify' result as OP_NOP
    let mut engine = utils::test_compile_and_run_with_tx(program, tx);
    utils::check_dstack_size(ref engine, 1);
}

// The 'ScriptVerifyCheckLockTimeVerify' flag isn't set but 'ScriptDiscourageUpgradable' is. Should
// result as an error
#[test]
fn test_opcode_checklocktime_as_op_nop_fail() {
    let program = "OP_16 OP_CHECKLOCKTIMEVERIFY";

    let mut tx = utils::mock_transaction_legacy_locktime("", 10);

    // Running without the flag 'ScriptVerifyCheckLockTimeVerify' result as OP_NOP behavior
    // 'ScriptDiscourageUpgradableNops' prevents to have OP_NOP behavior
    let flags: u32 = ScriptFlags::ScriptDiscourageUpgradableNops.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags_err(
        program, tx, flags, Error::SCRIPT_DISCOURAGE_UPGRADABLE_NOPS
    );
    utils::check_dstack_size(ref engine, 1);
}

#[test]
fn test_opcode_checklocktime_max_sequence_fail() {
    let mut program =
        "OP_DATA_4 0x8036BE26 OP_CHECKLOCKTIMEVERIFY"; // 0x8036BE26 == 650000000 in ScriptNum
    // By default the sequence field is set to 0xFFFFFFFF
    let mut tx = utils::mock_transaction("");
    tx.locktime = 700000000;

    let flags: u32 = ScriptFlags::ScriptVerifyCheckLockTimeVerify.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags_err(
        program, tx, flags, Error::FINALIZED_TX_CLTV
    );
    utils::check_dstack_size(ref engine, 1);
}

#[test]
fn test_opcode_checksequence_block() {
    let mut program =
        "OP_DATA_4 0x40000000 OP_CHECKSEQUENCEVERIFY"; // 0x40000000 == 64 in ScriptNum
    let tx = utils::mock_transaction_legacy_sequence_v2("", 2048);

    let flags: u32 = ScriptFlags::ScriptVerifyCheckSequenceVerify.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags(program, tx, flags);
    utils::check_dstack_size(ref engine, 1);
}

#[test]
fn test_opcode_checksequence_time() {
    let mut program =
        "OP_DATA_4 0x00004000 OP_CHECKSEQUENCEVERIFY"; // 0x00004000 == 4194304 in ScriptNum
    let tx = utils::mock_transaction_legacy_sequence_v2("", 5000000);

    let flags: u32 = ScriptFlags::ScriptVerifyCheckSequenceVerify.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags(program, tx, flags);
    utils::check_dstack_size(ref engine, 1);
}

#[test]
fn test_opcode_checksequence_fail() {
    let mut program =
        "OP_DATA_4 0x40400000 OP_CHECKSEQUENCEVERIFY"; // 0x40400000 == 16448 in ScriptNum
    let tx = utils::mock_transaction_legacy_sequence_v2("", 2048);

    let flags: u32 = ScriptFlags::ScriptVerifyCheckSequenceVerify.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags_err(
        program, tx, flags, Error::UNSATISFIED_LOCKTIME
    );
    utils::check_dstack_size(ref engine, 1);
}

// This test has value who failed with opcdoe checksequenceverify but necessary flag is not set so
// OP_CHECKSEQUENCEVERIFY behave as OP_NOP
#[test]
fn test_opcode_checksequence_as_op_nop() {
    let mut program =
        "OP_DATA_4 0x40400000 OP_CHECKSEQUENCEVERIFY"; // 0x40400000 == 16448 in ScriptNum
    let tx = utils::mock_transaction_legacy_sequence_v2("", 2048);

    // Running without the flag 'ScriptVerifyCheckLockTimeVerify' result as OP_NOP
    let mut engine = utils::test_compile_and_run_with_tx(program, tx);
    utils::check_dstack_size(ref engine, 1);
}

// The 'ScriptVerifyCheckSequenceVerify' flag isn't set but 'ScriptDiscourageUpgradable' is. Should
// result as an error
#[test]
fn test_opcode_checksequence_as_op_nop_fail() {
    let mut program =
        "OP_DATA_4 0x40400000 OP_CHECKSEQUENCEVERIFY"; // 0x40400000 == 16448 in ScriptNum
    let mut tx = utils::mock_transaction_legacy_sequence_v2("", 2048);

    // Running without the flag 'ScriptVerifyCheckSequenceVerify' result as OP_NOP behavior
    // 'ScriptDiscourageUpgradableNops' prevents to have OP_NOP behavior
    let flags: u32 = ScriptFlags::ScriptDiscourageUpgradableNops.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags_err(
        program, tx, flags, Error::SCRIPT_DISCOURAGE_UPGRADABLE_NOPS
    );
    utils::check_dstack_size(ref engine, 1);
}

#[test]
fn test_opcode_checksequence_tx_version_fail() {
    let mut program =
        "OP_DATA_4 0x40000000 OP_CHECKSEQUENCEVERIFY"; // 0x40000000 == 64 in ScriptNum
    let mut tx = utils::mock_transaction("");

    // Running with tx v1
    let flags: u32 = ScriptFlags::ScriptVerifyCheckSequenceVerify.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags_err(
        program, tx, flags, Error::UNSATISFIED_LOCKTIME
    );
    utils::check_dstack_size(ref engine, 1);
}

#[test]
fn test_opcode_checksequence_disabled_bit_stack() {
    let mut program = "OP_DATA_4 0x80000000 OP_CHECKSEQUENCEVERIFY";
    let tx = utils::mock_transaction_legacy_sequence_v2("", 2048);

    let flags: u32 = ScriptFlags::ScriptVerifyCheckSequenceVerify.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags(program, tx, flags);
    utils::check_dstack_size(ref engine, 1);
}

#[test]
fn test_opcode_checksequence_disabled_bit_tx_fail() {
    let mut program =
        "OP_DATA_4 0x00004000 OP_CHECKSEQUENCEVERIFY"; // 0x00004000 == 4194304 in ScriptNum
    let mut tx = utils::mock_transaction_legacy_sequence_v2("", 2147483648);

    // Run with tx v1
    let flags: u32 = ScriptFlags::ScriptVerifyCheckSequenceVerify.into();
    let mut engine = utils::test_compile_and_run_with_tx_flags_err(
        program, tx, flags, Error::UNSATISFIED_LOCKTIME
    );
    utils::check_dstack_size(ref engine, 1);
}
