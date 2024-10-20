use shinigami_engine::transaction::EngineInternalTransactionTrait;
use shinigami_engine::flags::ScriptFlags;
use shinigami_engine::errors::Error;

use crate::validate;
use crate::utxo::UTXO;
use shinigami_utils::bytecode::hex_to_bytecode;

// P2WSH with P2MS
// https://learnmeabitcoin.com/explorer/tx/b38a88b073743bcc84170071cff4b68dec6fb5dc0bc8ffcb3d4ca632c2c78255
#[ignore]
#[test]
fn test_learnmeabitcoin_usage() {
    let prevout_pk_script =
        "0x002065f91a53cb7120057db3d378bd0f7d944167d43a7dcbff15d6afc4823f1d3ed3";
    let prev_out = UTXO {
        amount: 53519352, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 630000,
    };

    let raw_transaction_hex =
        "0x010000000001016542b657eea04a75b1582969b5b532b3110b392b4b553297435a11b064e2eb460100000000ffffffff02c454fd000000000017a9145e7be6ec3e2382c669aaf3c71da1056f47b9024d875b07330200000000220020ea166bf0492c6f908e45404932e0f39c0571a71007c22b872548cd20f19a92f504004730440220415899bbee08e42376d06e8f86c92b4987613c2816352fe09cd1479fd639f18c02200db57f508f69e266d76c23891708158bda18690c165a41b0aa88303b97609f780147304402203973de2303e8787767090dd25c8a4dc97ce1aa7eb4c0962f13952ed4e856ff8e02203f1bb425def789eea8be46407d10b3c8730407176aef4dc2c29865eb5e5542bf0169522103848e308569b644372a5eb26665f1a8c34ca393c130b376db2fae75c43500013c2103cec1ee615c17e06d4f4b0a08617dffb8e568936bdff18fb057832a58ad4d1b752103eed7ae80c34d70f5ba93f93965f69f3c691da0f4607f242f4fd6c7a48789233e53aeee9c0900";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    let utxo_hints = array![prev_out];
    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into() | ScriptFlags::ScriptBip16.into();
    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed");
}

// https://learnmeabitcoin.com/explorer/tx/b38a88b073743bcc84170071cff4b68dec6fb5dc0bc8ffcb3d4ca632c2c78255
#[test]
fn test_learnmeabitcoin_usage_wrong_hash_in_pubkey_script() {
    // original hash script
    // "0x002065f91a53cb7120057db3d378bd0f7d944167d43a7dcbff15d6afc4823f1d3ed3";
    let prevout_pk_script =
        "0x0020f5f91a53cb7120057db3d378bd0f7d944167d43a7dcbff15d6afc4823f1d3ed3";
    let prev_out = UTXO {
        amount: 53519352, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 630000,
    };

    let raw_transaction_hex =
        "0x010000000001016542b657eea04a75b1582969b5b532b3110b392b4b553297435a11b064e2eb460100000000ffffffff02c454fd000000000017a9145e7be6ec3e2382c669aaf3c71da1056f47b9024d875b07330200000000220020ea166bf0492c6f908e45404932e0f39c0571a71007c22b872548cd20f19a92f504004730440220415899bbee08e42376d06e8f86c92b4987613c2816352fe09cd1479fd639f18c02200db57f508f69e266d76c23891708158bda18690c165a41b0aa88303b97609f780147304402203973de2303e8787767090dd25c8a4dc97ce1aa7eb4c0962f13952ed4e856ff8e02203f1bb425def789eea8be46407d10b3c8730407176aef4dc2c29865eb5e5542bf0169522103848e308569b644372a5eb26665f1a8c34ca393c130b376db2fae75c43500013c2103cec1ee615c17e06d4f4b0a08617dffb8e568936bdff18fb057832a58ad4d1b752103eed7ae80c34d70f5ba93f93965f69f3c691da0f4607f242f4fd6c7a48789233e53aeee9c0900";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    let utxo_hints = array![prev_out];
    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into() | ScriptFlags::ScriptBip16.into();
    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_err(), "Transaction validation should fail");
    assert!(res.unwrap_err() == Error::WITNESS_PROGRAM_MISMATCH, "Wrong error");
}

// https://learnmeabitcoin.com/explorer/tx/b38a88b073743bcc84170071cff4b68dec6fb5dc0bc8ffcb3d4ca632c2c78255
#[test]
fn test_learnmeabitcoin_usage_different_witness_script_from_hash() {
    let prevout_pk_script =
        "0x002065f91a53cb7120057db3d378bd0f7d944167d43a7dcbff15d6afc4823f1d3ed3";
    let prev_out = UTXO {
        amount: 53519352, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 630000,
    };

    // original witness script
    // 522103848e308569b644372a5eb26665f1a8c34ca393c130b376db2fae75c43500013c2103cec1ee615c17e06d4f4b0a08617dffb8e568936bdff18fb057832a58ad4d1b752103eed7ae80c34d70f5ba93f93965f69f3c691da0f4607f242f4fd6c7a48789233e53ae
    // modificed witness script (first public key is different)
    // 522103f48e308569b644372a5eb26665f1a8c34ca393c130b376db2fae75c43500013c2103cec1ee615c17e06d4f4b0a08617dffb8e568936bdff18fb057832a58ad4d1b752103eed7ae80c34d70f5ba93f93965f69f3c691da0f4607f242f4fd6c7a48789233e53ae
    let raw_transaction_hex =
        "0x010000000001016542b657eea04a75b1582969b5b532b3110b392b4b553297435a11b064e2eb460100000000ffffffff02c454fd000000000017a9145e7be6ec3e2382c669aaf3c71da1056f47b9024d875b07330200000000220020ea166bf0492c6f908e45404932e0f39c0571a71007c22b872548cd20f19a92f504004730440220415899bbee08e42376d06e8f86c92b4987613c2816352fe09cd1479fd639f18c02200db57f508f69e266d76c23891708158bda18690c165a41b0aa88303b97609f780147304402203973de2303e8787767090dd25c8a4dc97ce1aa7eb4c0962f13952ed4e856ff8e02203f1bb425def789eea8be46407d10b3c8730407176aef4dc2c29865eb5e5542bf0169522103f48e308569b644372a5eb26665f1a8c34ca393c130b376db2fae75c43500013c2103cec1ee615c17e06d4f4b0a08617dffb8e568936bdff18fb057832a58ad4d1b752103eed7ae80c34d70f5ba93f93965f69f3c691da0f4607f242f4fd6c7a48789233e53aeee9c0900";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    let utxo_hints = array![prev_out];
    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into() | ScriptFlags::ScriptBip16.into();
    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_err(), "Transaction validation should fail");
    assert!(res.unwrap_err() == Error::WITNESS_PROGRAM_MISMATCH, "Wrong error");
}

// P2WSH with custom script
// https://learnmeabitcoin.com/explorer/tx/64f427122f7951687aea608b5474509a30616d4e5773a83bc1ed8b8271ad1991
#[test]
fn test_custom_hash_puzzle() {
    let prevout_pk_script =
        "0x0020ee4fd29ce2f9ca8411778f8e94687d5e75ec3e86cc530ca9ad1787e5208cc996";
    let prev_out = UTXO {
        amount: 30000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 802087
    };

    let raw_transaction_hex =
        "0x020000000001018a39b5cdd48c7d45a31a89cd675a95f5de78aebeeda1e55ac35d7110c3bacfc60000000000ffffffff01204e0000000000001976a914ee63c8c790952de677d1f8019c9474d84098d6e188ac0202123423aa20a23421f2ba909c885a3077bb6f8eb4312487797693bbcfe7e311f797e3c5b8fa8700000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    let utxo_hints = array![prev_out];
    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into() | ScriptFlags::ScriptBip16.into();
    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed");
}

// https://learnmeabitcoin.com/explorer/tx/64f427122f7951687aea608b5474509a30616d4e5773a83bc1ed8b8271ad1991
#[test]
fn test_custom_hash_puzzle_invalid_unlock_code() {
    let prevout_pk_script =
        "0x0020ee4fd29ce2f9ca8411778f8e94687d5e75ec3e86cc530ca9ad1787e5208cc996";
    let prev_out = UTXO {
        amount: 30000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 802087
    };

    // replace unlock code 1234 by 2345
    let raw_transaction_hex =
        "0x020000000001018a39b5cdd48c7d45a31a89cd675a95f5de78aebeeda1e55ac35d7110c3bacfc60000000000ffffffff01204e0000000000001976a914ee63c8c790952de677d1f8019c9474d84098d6e188ac0202234523aa20a23421f2ba909c885a3077bb6f8eb4312487797693bbcfe7e311f797e3c5b8fa8700000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    let utxo_hints = array![prev_out];
    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into() | ScriptFlags::ScriptBip16.into();
    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_err(), "Transaction validation should fail");
    assert!(res.unwrap_err() == Error::SCRIPT_FAILED, "Wrong error");
}

// https://learnmeabitcoin.com/explorer/tx/64f427122f7951687aea608b5474509a30616d4e5773a83bc1ed8b8271ad1991
#[test]
fn test_custom_hash_puzzle_wrong_hash_script_in_pubkey_script() {
    // original hash script "0x0020ee4fd29ce2f9ca8411778f8e94687d5e75ec3e86cc530ca9ad1787e5208cc996"
    let prevout_pk_script =
        "0x0020fe4fd29ce2f9ca8411778f8e94687d5e75ec3e86cc530ca9ad1787e5208cc996";
    let prev_out = UTXO {
        amount: 30000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 802087
    };

    let raw_transaction_hex =
        "0x020000000001018a39b5cdd48c7d45a31a89cd675a95f5de78aebeeda1e55ac35d7110c3bacfc60000000000ffffffff01204e0000000000001976a914ee63c8c790952de677d1f8019c9474d84098d6e188ac0202123423aa20a23421f2ba909c885a3077bb6f8eb4312487797693bbcfe7e311f797e3c5b8fa8700000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    let utxo_hints = array![prev_out];
    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into() | ScriptFlags::ScriptBip16.into();
    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_err(), "Transaction validation should fail");
    assert!(res.unwrap_err() == Error::WITNESS_PROGRAM_MISMATCH, "Wrong error");
}

// https://learnmeabitcoin.com/explorer/tx/64f427122f7951687aea608b5474509a30616d4e5773a83bc1ed8b8271ad1991
#[test]
fn test_custom_hash_puzzle_different_witness_script_from_hash() {
    let prevout_pk_script =
        "0x0020ee4fd29ce2f9ca8411778f8e94687d5e75ec3e86cc530ca9ad1787e5208cc996";
    let prev_out = UTXO {
        amount: 30000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 802087
    };

    // original witness script
    // aa20a23421f2ba909c885a3077bb6f8eb4312487797693bbcfe7e311f797e3c5b8fa87
    // modified witness script (hash is different)
    // aa20b23421f2ba909c885a3077bb6f8eb4312487797693bbcfe7e311f797e3c5b8fa87
    let raw_transaction_hex =
        "0x020000000001018a39b5cdd48c7d45a31a89cd675a95f5de78aebeeda1e55ac35d7110c3bacfc60000000000ffffffff01204e0000000000001976a914ee63c8c790952de677d1f8019c9474d84098d6e188ac0202123423ba20a23421f2ba909c885a3077bb6f8eb4312487797693bbcfe7e311f797e3c5b8fa8700000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    let utxo_hints = array![prev_out];
    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into() | ScriptFlags::ScriptBip16.into();
    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_err(), "Transaction validation should fail");
    assert!(res.unwrap_err() == Error::WITNESS_PROGRAM_MISMATCH, "Wrong error");
}
