use shinigami::transaction::TransactionTrait;
use shinigami::transaction::Transaction;
use shinigami::transaction::TransactionOutput;
use shinigami::transaction::TransactionInput;
use shinigami::utils;

#[test]
fn test_basic_coinbase_transaction() {
    let block_height = Option::None;
    let coinbase_data = "test";
    let fees = 1000;
    let outputs = array![TransactionOutput { value: 0, publickey_script: "miner" }].span();

    let tx = TransactionTrait::new_coinbase(block_height, coinbase_data, fees, outputs);

    assert(tx.transaction_inputs.len() == 1, 'Should have one input');
    assert(tx.transaction_inputs.at(0).previous_outpoint.hash == @0, 'Input hash should be 0');
    assert(
        tx.transaction_inputs.at(0).previous_outpoint.index == @0xFFFFFFFF,
        'Input index should be max'
    );

    // Check coinbase script format
    let script = tx.transaction_inputs.at(0).signature_script;
    assert(script.len() == 4, 'Incorrect script length');

    // Check output value
    let expected_reward = TransactionTrait::calculate_block_subsidy(1) + fees;
    assert(tx.transaction_outputs.at(0).value == @expected_reward, 'Incorrect output value');
}

#[test]
fn test_coinbase_transaction_multiple_outputs() {
    let block_height = Option::Some(21000);
    let coinbase_data = "test";
    let fees = 2000;
    let outputs = array![
        TransactionOutput { value: 100, publickey_script: "output1" },
        TransactionOutput { value: 200, publickey_script: "output2" }
    ]
        .span();

    let tx = TransactionTrait::new_coinbase(block_height, coinbase_data.clone(), fees, outputs);

    assert(tx.transaction_outputs.len() == 3, 'Should have 3 outputs');
    assert(tx.transaction_outputs.at(1).value == @100, 'Incorrect output1 value');
    assert(tx.transaction_outputs.at(2).value == @200, 'Incorrect output2 value');

    // Check coinbase script format
    let script = tx.transaction_inputs.at(0).signature_script;
    assert(script.len() == 7, 'Incorrect script length');
}

#[test]
fn test_block_subsidy_calculation() {
    assert(TransactionTrait::calculate_block_subsidy(0) == 5000000000, 'Incorrect genesis subsidy');
    assert(
        TransactionTrait::calculate_block_subsidy(210000) == 2500000000, 'Incorrect halving subsidy'
    );
    assert(
        TransactionTrait::calculate_block_subsidy(420000) == 1250000000,
        'Incorrect 2nd halving subsidy'
    );
    assert(
        TransactionTrait::calculate_block_subsidy(13440000) == 0, 'Should be 0 after 64 halvings'
    );
}

#[test]
fn test_coinbase_transaction_block_height_encoding() {
    let fees = 1000;
    let outputs = array![TransactionOutput { value: 0, publickey_script: "miner" }].span();

    let tx0 = TransactionTrait::new_coinbase(Option::Some(0), "test", fees, outputs);
    assert(tx0.transaction_inputs.at(0).signature_script.len() == 5, 'Incorrect script length');

    let tx252 = TransactionTrait::new_coinbase(Option::Some(252), "test", fees, outputs);
    assert(tx252.transaction_inputs.at(0).signature_script.len() == 5, 'Incorrect script length');

    let tx253 = TransactionTrait::new_coinbase(Option::Some(253), "test", fees, outputs);
    assert(tx253.transaction_inputs.at(0).signature_script.len() == 7, 'Incorrect script length');

    let tx65535 = TransactionTrait::new_coinbase(Option::Some(65535), "test", fees, outputs);
    assert(tx65535.transaction_inputs.at(0).signature_script.len() == 7, 'Incorrect script length');

    let tx65536 = TransactionTrait::new_coinbase(Option::Some(65536), "test", fees, outputs);
    assert(tx65536.transaction_inputs.at(0).signature_script.len() == 9, 'Incorrect script length');
}

#[test]
fn test_encode_compact_size() {
    assert(utils::encode_compact_size(0).len() == 1, 'Incorrect encoding for 0');
    assert(utils::encode_compact_size(252).len() == 1, 'Incorrect encoding for 252');
    assert(utils::encode_compact_size(253).len() == 3, 'Incorrect encoding for 253');
    assert(utils::encode_compact_size(65535).len() == 3, 'Incorrect encoding for 65535');
    assert(utils::encode_compact_size(65536).len() == 5, 'Incorrect encoding for 65536');
}

