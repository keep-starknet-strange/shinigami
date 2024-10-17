use shinigami_engine::transaction::EngineInternalTransactionTrait;
use crate::utxo::UTXO;
use crate::validate;
use shinigami_utils::bytecode::hex_to_bytecode;

#[test]
fn test_p2wpkh_create_transaction() {
    // https://learnmeabitcoin.com/explorer/tx/c178d8dacdfb989f9d4fa45828ed188cd54a0414d625c3e61e75c5e3ac15a83a
    let raw_transaction_hex =
        "0x020000000001016972546966be990440a0665b73d0f4c3c942592d1f64d1033717aaa3e2c2ec913300000000ffffffff024087100000000000160014841b80d2cc75f5345c482af96294d04fdd66b2b760e31600000000001600142e8734f8e263e516d47fcaa2dfe1bd01e0dc935802473044022042e5e3ed2a41214ae864634b6fde33ca2ff312f3d89d6aa3e14c026d50d8ed3202206c38dcd0432a0724490356fbf599cdae40e334c3667a9253f8f4cc57cf3c4480012103f465315805ed271eb972e43d84d2a9e19494d10151d9f6adb32b8534bfd764ab00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    let prevout_script = "0x00140d6c887ce96acf1fdd900f24f4e5cbffbef4683c";
    let prevout = UTXO {
        amount: 151398, pubkey_script: hex_to_bytecode(@prevout_script), block_height: 680226
    };

    let utxo_hints = array![prevout];
    let res = validate::validate_transaction(@transaction, 0, utxo_hints);

    assert!(res.is_ok(), "Transaction validation failed");
}

#[test]
fn test_p2wpkh_unlock_transaction() {
    // https://learnmeabitcoin.com/explorer/tx/1674761a2b5cb6c7ea39ef58483433e8735e732f5d5815c9ef90523a91ed34a6
    let raw_transaction_hex =
        "0x020000000001013aa815ace3c5751ee6c325d614044ad58c18ed2858a44f9d9f98fbcddad878c10000000000ffffffff01344d10000000000016001430cd68883f558464ec7939d9f960956422018f0702483045022100c7fb3bd38bdceb315a28a0793d85f31e4e1d9983122b4a5de741d6ddca5caf8202207b2821abd7a1a2157a9d5e69d2fdba3502b0a96be809c34981f8445555bdafdb012103f465315805ed271eb972e43d84d2a9e19494d10151d9f6adb32b8534bfd764ab00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    let prevout_script = "0x0014841b80d2cc75f5345c482af96294d04fdd66b2b7";
    let prevout = UTXO {
        amount: 1083200, pubkey_script: hex_to_bytecode(@prevout_script), block_height: 681995
    };

    let utxo_hints = array![prevout];
    let res = validate::validate_transaction(@transaction, 0, utxo_hints);

    assert!(res.is_ok(), "Transaction validation failed");
}

#[test]
fn test_p2wpkh_first_transaction() {
    // https://learnmeabitcoin.com/explorer/tx/dfcec48bb8491856c353306ab5febeb7e99e4d783eedf3de98f3ee0812b92bad
    let raw_transaction_hex =
        "0x010000000001017405e391018c5e9dc79f324f9607c9c46d21b02f66dabaa870b4add871d6379f01000000171600148d7a0a3461e3891723e5fdf8129caa0075060cffffffffff01fcf60200000000001600148d7a0a3461e3891723e5fdf8129caa0075060cff0248304502210088025cffdaf69d310c6fed11832edd9c19b6a912c132262701ad0e6133227d9202207d73bbf777abd2aeae995d684e6bb1a048c5ac722e16de48bdd35643df7decf001210283409659355b6d1cc3c32decd5d561abaac86c37a353b52895a5e6c196d6f44800000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    let prevout_script = "0xa914811ee2fb2d0c96b478992e1c07320b253ef3ee2687";
    let prevout = UTXO {
        amount: 224000, pubkey_script: hex_to_bytecode(@prevout_script), block_height: 481819
    };

    let utxo_hints = array![prevout];

    let res = validate::validate_transaction(@transaction, 0, utxo_hints);
    assert!(res.is_ok(), "P2WPKH Transaction validation failed");
}

#[test]
fn test_p2wpkh_first_witness_spend() {
    // https://learnmeabitcoin.com/explorer/tx/f91d0a8a78462bc59398f2c5d7a84fcff491c26ba54c4833478b202796c8aafd
    let raw_transaction_hex =
        "0x01000000000101ad2bb91208eef398def3ed3e784d9ee9b7befeb56a3053c3561849b88bc4cedf0000000000ffffffff037a3e0100000000001600148d7a0a3461e3891723e5fdf8129caa0075060cff7a3e0100000000001600148d7a0a3461e3891723e5fdf8129caa0075060cff0000000000000000256a2342697462616e6b20496e632e204a6170616e20737570706f727473205365675769742102483045022100a6e33a7aff720ba9f33a0a8346a16fdd022196862796d511d31978c40c9ad48b02206fb8f67bd699a8c952b3386a81d122c366d2d36cd08e2de21207e6aa6f96ce9501210283409659355b6d1cc3c32decd5d561abaac86c37a353b52895a5e6c196d6f44800000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    let prevout_script = "0x00148d7a0a3461e3891723e5fdf8129caa0075060cff";
    let prevout = UTXO {
        amount: 194300, pubkey_script: hex_to_bytecode(@prevout_script), block_height: 481824
    };
    let utxo_hints = array![prevout];

    let res = validate::validate_transaction(@transaction, 0, utxo_hints);
    assert!(res.is_ok(), "P2WPKH first follow-up spend witness validation failed");
}

#[test]
fn test_p2wpkh_uncompressed_key_scriptpubkey_validation() {
    // https://learnmeabitcoin.com/explorer/tx/7c53ba0f1fc65f021749cac6a9c163e499fcb2e539b08c040802be55c33d32fe
    let raw_transaction_hex =
        "0x020000000122998d36f7953b150106cfa0a8722b51309c3eca93256e3a2402e14083fe8db2010000006a473044022076a81ac13cf50982401b0ef7fef518d5f72ffa6a7f95175c9bc16b0d57c4cc3e02202dce5bb27c1bc390d6a120806a0bbe2d8dd682918dc050d374ad29f2aba67703012102ee49077747264b56032c80bc588c7fb724f282bf8969e5efef3030770d4aaf2affffffff01905f010000000000160014671041727b982843f7e3db4669c2f542e05096fb00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    let prevout_script = "0x76a9149acd0fbc308ea273b61bad6322a17c8a7694845d88ac";
    let prevout = UTXO {
        amount: 100000, pubkey_script: hex_to_bytecode(@prevout_script), block_height: 801368
    };

    let utxo_hints = array![prevout];

    let res = validate::validate_transaction(@transaction, 0, utxo_hints);
    assert!(res.is_ok(), "P2WPKH uncompressed key ScriptPubKey validation failed");
}

