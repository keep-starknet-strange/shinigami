use crate::engine::{Engine, EngineInternalImpl};
use crate::transaction::{
    EngineTransactionTrait, EngineTransactionInputTrait, EngineTransactionOutputTrait,
};
use crate::errors::Error;
use crate::flags::ScriptFlags;
use crate::scriptnum::ScriptNum;
use crate::stack::ScriptStackTrait;

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

pub fn opcode_checklocktimeverify<
    T,
    +Drop<T>,
    +Default<T>,
    I,
    +Drop<I>,
    impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
    O,
    +Drop<O>,
    impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
    impl IEngineTransactionTrait: EngineTransactionTrait<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait,
    >,
>(
    ref engine: Engine<T>,
) -> Result<(), felt252> {
    if !engine.has_flag(ScriptFlags::ScriptVerifyCheckLockTimeVerify) {
        if engine.has_flag(ScriptFlags::ScriptDiscourageUpgradableNops) {
            return Result::Err(Error::SCRIPT_DISCOURAGE_UPGRADABLE_NOPS);
        }
        // Behave as OP_NOP
        return Result::Ok(());
    }

    let tx_locktime: i64 = EngineTransactionTrait::<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait,
    >::get_locktime(engine.transaction)
        .into();
    // Get locktime as 5 byte integer because 'tx_locktime' is u32
    let stack_locktime: i64 = ScriptNum::try_into_num_n_bytes(
        engine.dstack.peek_byte_array(0)?, 5, engine.dstack.verify_minimal_data,
    )?;

    if stack_locktime < 0 {
        return Result::Err(Error::UNSATISFIED_LOCKTIME);
    }

    // Check if tx sequence is not 'SEQUENCE_MAX' else if tx may be considered as finalized and the
    // behavior of OP_CHECKLOCKTIMEVERIFY can be bypassed
    let transaction_input = EngineTransactionTrait::<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait,
    >::get_transaction_inputs(engine.transaction)
        .at(engine.tx_idx);
    let sequence = EngineTransactionInputTrait::<I>::get_sequence(transaction_input);
    if sequence == SEQUENCE_MAX {
        return Result::Err(Error::FINALIZED_TX_CLTV);
    }

    verify_locktime(tx_locktime, LOCKTIME_THRESHOLD.into(), stack_locktime)
}

pub fn opcode_checksequenceverify<
    T,
    +Drop<T>,
    +Default<T>,
    I,
    +Drop<I>,
    impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
    O,
    +Drop<O>,
    impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
    impl IEngineTransactionTrait: EngineTransactionTrait<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait,
    >,
>(
    ref engine: Engine<T>,
) -> Result<(), felt252> {
    if !engine.has_flag(ScriptFlags::ScriptVerifyCheckSequenceVerify) {
        if engine.has_flag(ScriptFlags::ScriptDiscourageUpgradableNops) {
            return Result::Err(Error::SCRIPT_DISCOURAGE_UPGRADABLE_NOPS);
        }
        // Behave as OP_NOP
        return Result::Ok(());
    }

    // Get sequence as 5 byte integer because 'sequence' is u32
    let stack_sequence: i64 = ScriptNum::try_into_num_n_bytes(
        engine.dstack.peek_byte_array(0)?, 5, engine.dstack.verify_minimal_data,
    )?;

    if stack_sequence < 0 {
        return Result::Err(Error::NEGATIVE_LOCKTIME);
    }

    // Redefine 'stack_sequence' to perform bitwise operation easily
    let stack_sequence_u64: u64 = stack_sequence.try_into().unwrap();

    // Disabled bit set in 'stack_sequence' result as OP_NOP behavior
    if stack_sequence_u64 & SEQUENCE_LOCKTIME_DISABLED.into() != 0 {
        return Result::Ok(());
    }

    // Prevent trigger OP_CHECKSEQUENCEVERIFY before tx version 2
    let version = EngineTransactionTrait::<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait,
    >::get_version(engine.transaction);
    if version < 2 {
        return Result::Err(Error::UNSATISFIED_LOCKTIME);
    }

    let transaction_input = EngineTransactionTrait::<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait,
    >::get_transaction_inputs(engine.transaction)
        .at(engine.tx_idx);
    let tx_sequence: u32 = EngineTransactionInputTrait::<I>::get_sequence(transaction_input);

    // Disabled bit set in 'tx_sequence' result is an error
    if tx_sequence & SEQUENCE_LOCKTIME_DISABLED != 0 {
        return Result::Err(Error::UNSATISFIED_LOCKTIME);
    }

    // Mask off non-consensus bits before comparisons
    let locktime_mask = SEQUENCE_LOCKTIME_IS_SECOND | SEQUENCE_LOCKTIME_MASK;
    verify_locktime(
        (tx_sequence & locktime_mask).into(),
        SEQUENCE_LOCKTIME_IS_SECOND.into(),
        (stack_sequence_u64 & locktime_mask.into()).try_into().unwrap(),
    )
}
