use crate::utils::{hex_to_bytecode};
use crate::compiler::CompilerImpl;
use crate::engine::{EngineImpl};
use crate::transaction::TransactionTrait;
use crate::validate;
use crate::utxo::UTXO;
use crate::utils;

// https://learnmeabitcoin.com/explorer/tx/3db8816c460f674e47f0e5799656721a249acdd53cd43a530c83384577485947
#[test]
fn test_compressed_pubkey() {
    let prevout_pk_script = "0x76a9147fbff43f08b409a03febae114cf0885c37ffd7c488ac";
    let prev_out = UTXO {
        amount: 3000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 606376
    };
    let raw_transaction_hex =
        "0x010000000135655162f2df3af5e5f12b5b4b545e9069ed61897974622888b9c47e0f55e105000000006b483045022100bdd3796f6a6bb7f8ca42a70438a3150501f9ec760195b4d3314b1b4b21aac29402202f8479c9384a737bb323cd8600d9e3c5a379334a55acf7c3f4a4ca1eaaabe97e012103e49d61c45a729c427038b967df38459a2579a2c37057cf6a2efb2c3048f676aaffffffff018c0a000000000000232103203b768951584fe9af6d9d9e6ff26a5f76e453212f19ba163774182ab8057f3eac00000000";
    let raw_transaction = utils::hex_to_bytecode(@raw_transaction_hex);
    let transaction = TransactionTrait::deserialize(raw_transaction);
    let utxo_hints = array![prev_out];

    let res = validate::validate_transaction(transaction, 0, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed");
}

// https://learnmeabitcoin.com/explorer/tx/a16f3ce4dd5deb92d98ef5cf8afeaf0775ebca408f708b2146c4fb42b41e14be
#[test]
fn test_block_181_tx_mainnet() {
    let prevout_pk_script =
        "0x410411db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a6909a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f656b412a3ac";
    let prev_out = UTXO {
        amount: 3000000000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 170
    };
    let raw_transaction_hex =
        "0x0100000001169e1e83e930853391bc6f35f605c6754cfead57cf8387639d3b4096c54f18f40100000048473044022027542a94d6646c51240f23a76d33088d3dd8815b25e9ea18cac67d1171a3212e02203baf203c6e7b80ebd3e588628466ea28be572fe1aaa3f30947da4763dd3b3d2b01ffffffff0200ca9a3b00000000434104b5abd412d4341b45056d3e376cd446eca43fa871b51961330deebd84423e740daa520690e1d9e074654c59ff87b408db903649623e86f1ca5412786f61ade2bfac005ed0b20000000043410411db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a6909a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f656b412a3ac00000000";
    let raw_transaction = utils::hex_to_bytecode(@raw_transaction_hex);
    let transaction = TransactionTrait::deserialize(raw_transaction);
    let utxo_hints = array![prev_out];

    let res = validate::validate_transaction(transaction, 0, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed");
}

// https://learnmeabitcoin.com/explorer/tx/591e91f809d716912ca1d4a9295e70c3e78bab077683f79350f101da64588073
#[test]
fn test_block_182_tx_mainnet() {
    let prevout_pk_script =
        "0x410411db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a6909a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f656b412a3ac";
    let prev_out = UTXO {
        amount: 3000000000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 170
    };
    let raw_transaction_hex =
        "0x0100000001be141eb442fbc446218b708f40caeb7507affe8acff58ed992eb5ddde43c6fa1010000004847304402201f27e51caeb9a0988a1e50799ff0af94a3902403c3ad4068b063e7b4d1b0a76702206713f69bd344058b0dee55a9798759092d0916dbbc3e592fee43060005ddc17401ffffffff0200e1f5050000000043410401518fa1d1e1e3e162852d68d9be1c0abad5e3d6297ec95f1f91b909dc1afe616d6876f92918451ca387c4387609ae1a895007096195a824baf9c38ea98c09c3ac007ddaac0000000043410411db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a6909a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f656b412a3ac00000000";
    let raw_transaction = utils::hex_to_bytecode(@raw_transaction_hex);
    let transaction = TransactionTrait::deserialize(raw_transaction);
    let utxo_hints = array![prev_out];

    let res = validate::validate_transaction(transaction, 0, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed");
}

// https://learnmeabitcoin.com/explorer/tx/a3b0e9e7cddbbe78270fa4182a7675ff00b92872d8df7d14265a2b1e379a9d33
#[test]
fn test_block_496_tx_mainnet() {
    let prevout_pk_script =
        "0x41044ca7baf6d8b658abd04223909d82f1764740bdc9317255f54e4910f888bd82950e33236798517591e4c2181f69b5eaa2fa1f21866780a0cc5d8396a04fd36310ac";
    let prevout_pk_script_2 =
        "0x4104fe1b9ccf732e1f6b760c5ed3152388eeeadd4a073e621f741eb157e6a62e3547c8e939abbd6a513bf3a1fbe28f9ea85a4e64c526702435d726f7ff14da40bae4ac";
    let prevout_pk_script_3 =
        "0x4104bed827d37474beffb37efe533701ac1f7c600957a4487be8b371346f016826ee6f57ba30d88a472a0e4ecd2f07599a795f1f01de78d791b382e65ee1c58b4508ac";
    let prev_out = UTXO {
        amount: 5000000000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 360
    };
    let prev_out2 = UTXO {
        amount: 1000000000, pubkey_script: hex_to_bytecode(@prevout_pk_script_2), block_height: 187
    };
    let prev_out3 = UTXO {
        amount: 100000000, pubkey_script: hex_to_bytecode(@prevout_pk_script_3), block_height: 248
    };

    let raw_transaction_hex =
        "0x010000000321f75f3139a013f50f315b23b0c9a2b6eac31e2bec98e5891c924664889942260000000049483045022100cb2c6b346a978ab8c61b18b5e9397755cbd17d6eb2fe0083ef32e067fa6c785a02206ce44e613f31d9a6b0517e46f3db1576e9812cc98d159bfdaf759a5014081b5c01ffffffff79cda0945903627c3da1f85fc95d0b8ee3e76ae0cfdc9a65d09744b1f8fc85430000000049483045022047957cdd957cfd0becd642f6b84d82f49b6cb4c51a91f49246908af7c3cfdf4a022100e96b46621f1bffcf5ea5982f88cef651e9354f5791602369bf5a82a6cd61a62501fffffffffe09f5fe3ffbf5ee97a54eb5e5069e9da6b4856ee86fc52938c2f979b0f38e82000000004847304402204165be9a4cbab8049e1af9723b96199bfd3e85f44c6b4c0177e3962686b26073022028f638da23fc003760861ad481ead4099312c60030d4cb57820ce4d33812a5ce01ffffffff01009d966b01000000434104ea1feff861b51fe3f5f8a3b12d0f4712db80e919548a80839fc47c6a21e66d957e9c5d8cd108c7a2d2324bad71f9904ac0ae7336507d785b17a2c115e427a32fac00000000";
    let raw_transaction = utils::hex_to_bytecode(@raw_transaction_hex);
    let transaction = TransactionTrait::deserialize(raw_transaction);
    let utxo_hints = array![prev_out, prev_out2, prev_out3];

    let res = validate::validate_transaction(transaction, 0, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed");
}
