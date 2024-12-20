use shinigami_engine::transaction::EngineInternalTransactionTrait;
use shinigami_utils::bytecode::hex_to_bytecode;

#[test]
fn test_block_subsidy_calculation() {
    assert(
        EngineInternalTransactionTrait::calculate_block_subsidy(0) == 5000000000,
        'Incorrect genesis subsidy'
    );
    assert(
        EngineInternalTransactionTrait::calculate_block_subsidy(210000) == 2500000000,
        'Incorrect halving subsidy'
    );
    assert(
        EngineInternalTransactionTrait::calculate_block_subsidy(420000) == 1250000000,
        'Incorrect 2nd halving subsidy'
    );
    assert(
        EngineInternalTransactionTrait::calculate_block_subsidy(13440000) == 0,
        'Should be 0 after 64 halvings'
    );
}

#[test]
fn test_validate_coinbase_block_0() {
    // Test the genesis block coinbase transaction
    let raw_transaction_hex =
        "0x01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff4d04ffff001d0104455468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73ffffffff0100f2052a01000000434104678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5fac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);
    assert!(
        transaction.validate_coinbase(0, 5000000000).is_ok(),
        "Genesis block coinbase transaction invalid"
    );
}

#[test]
fn test_validate_coinbase_block_1() {
    // Test the second block coinbase transaction
    let raw_transaction_hex =
        "0x01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff0704ffff001d0104ffffffff0100f2052a0100000043410496b538e853519c726a2c91e61ec11600ae1390813a627c66fb8be7947be63c52da7589379515d4e0a604f8141781e62294721166bf621e73a82cbf2342c858eeac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);
    assert!(
        transaction.validate_coinbase(1, 5000000000).is_ok(), "Block 1 coinbase transaction invalid"
    );
}

#[test]
fn test_validate_coinbase_block_150007() {
    // Test a random block from learnmebitcoin
    let raw_transaction_hex =
        "0x01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff0804233fa04e028b12ffffffff0130490b2a010000004341047eda6bd04fb27cab6e7c28c99b94977f073e912f25d1ff7165d9c95cd9bbe6da7e7ad7f2acb09e0ced91705f7616af53bee51a238b7dc527f2be0aa60469d140ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);
    assert!(
        transaction.validate_coinbase(150007, 350000).is_ok(),
        "Block 150007 coinbase transaction invalid"
    );
}

#[test]
fn test_validate_coinbase_block_227835() {
    // Test the last block before BIP34 was activated
    let raw_transaction_hex =
        "0x01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff0f0479204f51024f09062f503253482fffffffff01da495f9500000000232103ddcdae35e28aca364daa1397612d2dafd891ee136d2ca5ab83faff6bc12ed67eac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);
    assert!(
        transaction.validate_coinbase(227835, 6050010).is_ok(),
        "Block 227835 coinbase transaction invalid"
    );
}

#[test]
fn test_validate_coinbase_block_227836() {
    // Test the first block after BIP34 was activated
    let raw_transaction_hex =
        "0x01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff2703fc7903062f503253482f04ac204f510858029a11000003550d3363646164312f736c7573682f0000000001207e6295000000001976a914e285a29e0704004d4e95dbb7c57a98563d9fb2eb88ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);
    assert!(
        transaction.validate_coinbase(227836, 6260000).is_ok(),
        "Block 227836 coinbase transaction invalid"
    );
}

#[test]
fn test_validate_coinbase_block_400021() {
    // Test a random block from learnmebitcoin
    let raw_transaction_hex =
        "0x01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff1b03951a0604f15ccf5609013803062b9b5a0100072f425443432f200000000001ebc31495000000001976a9142c30a6aaac6d96687291475d7d52f4b469f665a688ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);
    assert!(
        transaction.validate_coinbase(400021, 1166059).is_ok(),
        "Block 400021 coinbase transaction invalid"
    );
}

#[test]
fn test_validate_coinbase_block_481823() {
    // Test the last block before BIP141 segwit
    let raw_transaction_hex =
        "0x01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff4e031f5a070473319e592f4254432e434f4d2f4e59412ffabe6d6dcceb2a9d0444c51cabc4ee97a1a000036ca0cb48d25b94b78c8367d8b868454b0100000000000000c0309b21000008c5f8f80000ffffffff0291920b5d0000000017a914e083685a1097ce1ea9e91987ab9e94eae33d8a13870000000000000000266a24aa21a9ede6c99265a6b9e1d36c962fda0516b35709c49dc3b8176fa7e5d5f1f6197884b400000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);
    assert!(
        transaction.validate_coinbase(481823, 311039505).is_ok(),
        "Block 481823 coinbase transaction invalid"
    );
}

#[test]
#[ignore]
fn test_validate_coinbase_block_481824() {
    // Test the first block after BIP141 segwit
    let raw_transaction_hex =
        "0x010000000001010000000000000000000000000000000000000000000000000000000000000000ffffffff6403205a07f4d3f9da09acf878c2c9c96c410d69758f0eae0e479184e0564589052e832c42899c867100010000000000000000db9901006052ce25d80acfde2f425443432f20537570706f7274202f4e59412f00000000000000000000000000000000000000000000025d322c57000000001976a9142c30a6aaac6d96687291475d7d52f4b469f665a688ac0000000000000000266a24aa21a9ed6c3c4dff76b5760d58694147264d208689ee07823e5694c4872f856eacf5a5d80120000000000000000000000000000000000000000000000000000000000000000000000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);
    assert!(
        transaction.validate_coinbase(481824, 212514269).is_ok(),
        "Block 481824 coinbase transaction invalid"
    );
}

#[test]
#[ignore]
fn test_validate_coinbase_block_538403() {
    // Test random block from learnmebitcoin
    let raw_transaction_hex =
        "0x010000000001010000000000000000000000000000000000000000000000000000000000000000ffffffff2503233708184d696e656420627920416e74506f6f6c373946205b8160a4256c0000946e0100ffffffff02f595814a000000001976a914edf10a7fac6b32e24daa5305c723f3de58db1bc888ac0000000000000000266a24aa21a9edfaa194df59043645ba0f58aad74bfd5693fa497093174d12a4bb3b0574a878db0120000000000000000000000000000000000000000000000000000000000000000000000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);
    assert!(
        transaction.validate_coinbase(538403, 6517).is_ok(),
        "Block 538403 coinbase transaction invalid"
    );
}
// TODO: Test invalid coinbase


