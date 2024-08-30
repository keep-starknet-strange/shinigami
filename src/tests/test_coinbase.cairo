use shinigami::transaction::{Transaction, TransactionTrait, TransactionInput, TransactionOutput};
use shinigami::utils;

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
    let version = 2;
    let fees = 1000;
    let outputs = array![TransactionOutput { value: 0, publickey_script: "miner" }].span();

    let tx0 = TransactionTrait::new_coinbase(version, Option::Some(0), "test", fees, outputs);
    assert(tx0.transaction_inputs.at(0).signature_script.len() == 5, 'Incorrect script length');

    let tx252 = TransactionTrait::new_coinbase(version, Option::Some(252), "test", fees, outputs);
    assert(tx252.transaction_inputs.at(0).signature_script.len() == 5, 'Incorrect script length');

    let tx253 = TransactionTrait::new_coinbase(version, Option::Some(253), "test", fees, outputs);
    assert(tx253.transaction_inputs.at(0).signature_script.len() == 7, 'Incorrect script length');

    let tx65535 = TransactionTrait::new_coinbase(
        version, Option::Some(65535), "test", fees, outputs
    );
    assert(tx65535.transaction_inputs.at(0).signature_script.len() == 7, 'Incorrect script length');

    let tx65536 = TransactionTrait::new_coinbase(
        version, Option::Some(65536), "test", fees, outputs
    );
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

#[test]
fn test_genesis_block_coinbase() {
    let version = 1;
    let block_height = Option::None;
    let coinbase_data = "test";
    let fees = 0;
    let outputs = array![
        TransactionOutput {
            value: 5000000000,
            publickey_script: "4104678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5fac"
        }
    ]
        .span();

    let tx = TransactionTrait::new_coinbase(version, block_height, coinbase_data, fees, outputs);

    assert(tx.version == 1, 'Incorrect version');
    assert(tx.transaction_inputs.len() == 1, 'Should have one input');
    assert(tx.transaction_outputs.at(0).value == @5000000000, 'Incorrect output value');

    // Check coinbase script
    let script = tx.transaction_inputs.at(0).signature_script;
    assert(script.len() == 4, 'Incorrect script length');
}

#[test]
fn test_block_1_coinbase() {
    let version = 1;
    let block_height = Option::None;
    let coinbase_data = "test";
    let fees = 0;
    let outputs = array![
        TransactionOutput {
            value: 5000000000,
            publickey_script: "410411db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a6909a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f656b412a3ac"
        }
    ]
        .span();

    let tx = TransactionTrait::new_coinbase(version, block_height, coinbase_data, fees, outputs);

    assert(tx.version == 1, 'Incorrect version');
    assert(tx.transaction_inputs.len() == 1, 'Should have one input');
    assert(tx.transaction_outputs.at(0).value == @5000000000, 'Incorrect output value');

    // Check coinbase script
    let script = tx.transaction_inputs.at(0).signature_script;
    assert(script.len() == 4, 'Incorrect script length');
}

#[test]
fn test_block_227836_coinbase() {
    let version = 2;
    let block_height = Option::Some(227836);
    let coinbase_data = "test";
    let fees = 0;
    let total_reward = TransactionTrait::calculate_block_subsidy(227836) + fees;
    let outputs = array![
        TransactionOutput {
            value: 2506260000,
            publickey_script: "76a914338c84849423992471bffb1a54a8d9b1d69dc28a88ac"
        }
    ]
        .span();

    let tx = TransactionTrait::new_coinbase(version, block_height, coinbase_data, fees, outputs);

    assert(tx.version == 2, 'Incorrect version');
    assert(tx.transaction_inputs.len() == 1, 'Should have one input');
    assert(tx.transaction_outputs.at(0).value == @total_reward, 'Incorrect output value');

    // Check coinbase script
    let script = tx.transaction_inputs.at(0).signature_script;
    assert(script.len() >= 4, 'Script too short');
    // TODO: Verify the exact script content if possible
}

#[test]
fn test_block_481823_coinbase() {
    let version = 1;
    let block_height = Option::Some(481823);
    let coinbase_data = "test";
    let fees = 79829;
    let total_reward = TransactionTrait::calculate_block_subsidy(481823) + fees;
    let outputs = array![
        TransactionOutput {
            value: 1561039505,
            publickey_script: "76a914d3c96dc04a62f488a0f4a7f3ccbe70c24764d0b188ac"
        }
    ]
        .span();

    let tx = TransactionTrait::new_coinbase(version, block_height, coinbase_data, fees, outputs);

    assert(tx.version == 1, 'Incorrect version');
    assert(tx.transaction_inputs.len() == 1, 'Should have one input');
    assert(tx.transaction_outputs.at(0).value == @total_reward, 'Incorrect output value');

    // Check coinbase script
    let script = tx.transaction_inputs.at(0).signature_script;
    assert(script.len() >= 7, 'Script too short');
    // TODO: Verify the exact script content if possible
}

#[test]
fn test_coinbase_transaction_multiple_outputs() {
    let version = 2;
    let block_height = Option::Some(21000);
    let coinbase_data = "test";
    let fees = 2000;
    let expected_subsidy = TransactionTrait::calculate_block_subsidy(21000);
    let total_reward = expected_subsidy + fees;
    let outputs = array![
        TransactionOutput { value: 100, publickey_script: "output1" },
        TransactionOutput { value: 200, publickey_script: "output2" }
    ]
        .span();

    let tx = TransactionTrait::new_coinbase(
        version, block_height, coinbase_data.clone(), fees, outputs
    );

    assert(tx.transaction_outputs.len() == 3, 'Should have 3 outputs');
    assert(tx.transaction_outputs.at(0).value == @total_reward, 'Incorrect output1 value');
    assert(tx.transaction_outputs.at(1).value == @100, 'Incorrect output1 value');
    assert(tx.transaction_outputs.at(2).value == @200, 'Incorrect output2 value');

    // Check coinbase script format
    let script = tx.transaction_inputs.at(0).signature_script;
    assert(script.len() == 7, 'Incorrect script length');
}
