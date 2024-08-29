use shinigami::engine::{Engine, EngineTrait};
use shinigami::stack::ScriptStackTrait;
use shinigami::errors::Error;
use shinigami::scriptflags::ScriptFlags;
use shinigami::scriptnum::ScriptNum;

const LOCKTIME_THRESHOLD: u32 = 500000000; // Nov 5 00:53:20 1985 UTC
const SEQUENCE_LOCKTIME_DISABLED: u32 = 0x80000000;
const SEQUENCE_LOCKTIME_IS_SECOND: u32 = 0x00400000;
const SEQUENCE_LOCKTIME_MASK: u32 = 0x0000FFFF;
const SEQUENCE_MAX: u32 = 0xFFFFFFFF;

fn verify_locktime(tx_locktime: i64, threshold: i64, stack_locktime: i64) -> Result<(), felt252> {
    // Check if 'tx_locktime' and 'locktime' are same type (locktime or height)
    if !((tx_locktime < threshold && stack_locktime < threshold)
        || (tx_locktime >= threshold && stack_locktime >= threshold)) {
        return Result::Err(Error::UNSATISFIED_LOCKTIME);
    }

    // Check validity
    if stack_locktime > tx_locktime {
        return Result::Err(Error::UNSATISFIED_LOCKTIME);
    }

    Result::Ok(())
}

pub fn opcode_checklocktimeverify(ref engine: Engine) -> Result<(), felt252> {
    if !engine.has_flag(ScriptFlags::ScriptVerifyCheckLockTimeVerify) {
        if engine.has_flag(ScriptFlags::ScriptDiscourageUpgradableNops) {
            return Result::Err(Error::SCRIPT_DISCOURAGE_UPGRADABLE_NOPS);
        }
        // Behave as OP_NOP
        return Result::Ok(());
    }

    let tx_locktime: i64 = engine.transaction.locktime.into();
    // Get locktime as 5 byte integer because 'tx_locktime' is u32
    let stack_locktime: i64 = ScriptNum::try_into_num_n_bytes(
        engine.dstack.peek_byte_array(0)?, 5
    )?;

    if stack_locktime < 0 {
        return Result::Err(Error::UNSATISFIED_LOCKTIME);
    }

    // Check if tx sequence is not 'SEQUENCE_MAX' else if tx may be considered as finalized and the
    // behavior of OP_CHECKLOCKTIMEVERIFY can be bypassed
    if engine.transaction.transaction_inputs.at(engine.tx_idx).sequence == @SEQUENCE_MAX {
        return Result::Err(Error::FINALIZED_TX_CLTV);
    }

    verify_locktime(tx_locktime, LOCKTIME_THRESHOLD.into(), stack_locktime)
}

pub fn opcode_checksequenceverify(ref engine: Engine) -> Result<(), felt252> {
    if !engine.has_flag(ScriptFlags::ScriptVerifyCheckSequenceVerify) {
        if engine.has_flag(ScriptFlags::ScriptDiscourageUpgradableNops) {
            return Result::Err(Error::SCRIPT_DISCOURAGE_UPGRADABLE_NOPS);
        }
        // Behave as OP_NOP
        return Result::Ok(());
    }

    // Get sequence as 5 byte integer because 'sequence' is u32
    let stack_sequence: i64 = ScriptNum::try_into_num_n_bytes(
        engine.dstack.peek_byte_array(0)?, 5
    )?;

    if stack_sequence < 0 {
        return Result::Err(Error::UNSATISFIED_LOCKTIME);
    }

    // Redefine 'stack_sequence' to perform bitwise operation easily
    let stack_sequence_u32: u32 = stack_sequence.try_into().unwrap();

    // Disabled bit set in 'stack_sequence' result as OP_NOP behavior
    if stack_sequence_u32 & SEQUENCE_LOCKTIME_DISABLED != 0 {
        return Result::Ok(());
    }

    // Prevent trigger OP_CHECKSEQUENCEVERIFY before tx version 2
    if engine.transaction.version < 2 {
        return Result::Err(Error::INVALID_TX_VERSION);
    }

    let tx_sequence: u32 = *engine.transaction.transaction_inputs.at(engine.tx_idx).sequence;

    // Disabled bit set in 'tx_sequence' result is an error
    if tx_sequence & SEQUENCE_LOCKTIME_DISABLED != 0 {
        return Result::Err(Error::UNSATISFIED_LOCKTIME);
    }

    // Mask off non-consensus bits before comparisons
    let locktime_mask = SEQUENCE_LOCKTIME_IS_SECOND | SEQUENCE_LOCKTIME_MASK;
    verify_locktime(
        (tx_sequence & locktime_mask).into(),
        SEQUENCE_LOCKTIME_IS_SECOND.into(),
        (stack_sequence_u32 & locktime_mask).into()
    )
}
