use shinigami::engine::{Engine, EngineTrait};
use shinigami::stack::ScriptStackTrait;
use shinigami::errors::Error;
use shinigami::scriptflags::ScriptFlags;
use shinigami::scriptnum::ScriptNum;

const LOCKTIME_THRESHOLD: i64 = 500000000; // Nov 5 00:53:20 1985 UTC
pub const MAX_SEQUENCE: u32 = 0xFFFFFFFF;

pub fn opcode_checklocktimeverify(ref engine: Engine) -> Result<(), felt252> {
    if !engine.has_flag(ScriptFlags::ScriptVerifyCheckLockTimeVerify) {
        if engine.has_flag(ScriptFlags::ScriptDiscourageUpgradableNops) {
            return Result::Err(Error::SCRIPT_FAILED);
        }
        // Return as OP_NOP2
        return Result::Ok(());
    }

    let tx_locktime: i64 = engine.transaction.locktime.into();
    // Get locktime as 5 byte integer because tx_locktime is u32
    let locktime: i64 = ScriptNum::unwrap_n(
        engine.dstack.peek_byte_array(engine.dstack.len() - 1)?, 5
    );

    // Check if 'tx_locktime' and 'locktime' are same type (locktime or height)
    if !((tx_locktime < LOCKTIME_THRESHOLD && locktime < LOCKTIME_THRESHOLD)
        || (tx_locktime >= LOCKTIME_THRESHOLD && locktime >= LOCKTIME_THRESHOLD)) {
        return Result::Err(Error::UNSATISFIED_LOCKTIME);
    }

	// Check validity
    if locktime > tx_locktime || locktime < 0 {
        return Result::Err(Error::UNSATISFIED_LOCKTIME);
    }

    if engine.transaction.transaction_inputs.at(engine.tx_idx).sequence == @MAX_SEQUENCE {
        return Result::Err(Error::FINALIZED_TX);
    }

    Result::Ok(())
}
