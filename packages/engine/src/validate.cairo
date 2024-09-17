use crate::engine::EngineInternalImpl;
use crate::transaction::Transaction;
use crate::utxo::UTXO;

// TODO: Move validate coinbase here

// TODO: Remove hints?
// utxo_hints: Set of existing utxos that are being spent by this transaction
pub fn validate_transaction(
    tx: Transaction, flags: u32, utxo_hints: Array<UTXO>
) -> Result<(), felt252> {
    let input_count = tx.transaction_inputs.len();
    if input_count != utxo_hints.len() {
        return Result::Err('Invalid number of utxo hints');
    }

    let mut i = 0;
    let mut err = '';
    while i != input_count {
        let utxo = utxo_hints[i];
        // TODO: Error handling
        let mut engine = EngineInternalImpl::new(utxo.pubkey_script, tx.clone(), i, flags, *utxo.amount)
            .unwrap();
        let res = engine.execute();
        if res.is_err() {
            err = res.unwrap_err();
            break;
        }

        i += 1;
    };
    if err != '' {
        return Result::Err(err);
    }

    Result::Ok(())
}
