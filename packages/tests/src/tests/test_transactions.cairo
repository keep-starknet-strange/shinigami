use shinigami_engine::transaction::EngineInternalTransactionTrait;
use crate::utxo::UTXO;
use crate::validate;
use shinigami_utils::byte_array::u256_from_byte_array_with_offset;
use shinigami_utils::bytecode::hex_to_bytecode;

// TODO: txid byte order reverse

#[test]
fn test_deserialize_transaction() {
    // Block 150007 transaction 7
    // tx: d823f0d96563ec214a2342c8637a5775038ca05e56ca069631c96f400ca2f9f7
    let raw_transaction_hex =
        "0x010000000291056d7ab3e99f9506f248783e0801c9039082d7d876dd45a8ab1f0a166226e2000000008c493046022100a3deff7d28eca94e018cfafcf4e705cc6bb56ce1dab83a6377e6e97d28d305d90221008cfc8d40bb8e336f5210a4197760f6b9650ae6ec4682cc1626841d9c87d1b0f20141049305a94c5b8e71d8be2a2d7188d74cb38affc9dc83ab77cc2fedf7c03a82a56175b9c335ce4546a943a2215a9c04757f08c2cc97f731a208ea767119050e0b97ffffffff465345e66a84047bf58a3787456d8023c38e04734c72d7f7039b9220ac503b6e000000008a47304402202ff5fe06ff3ee680e069cd28ff3ed9a60050ba52ed811a739a29b81e3667074602203c0d1b63d0c495ee1b63886e42c2db0c4cb041ce0c957ad7febe0fbcd23498ee014104cc2cb6eb11b7b504e1aa2826cf8ce7568bc757d7f58ab1eaa0b5e6945ccdcc5b111c0c1163a28037b89501e0b83e3fdceb22a2fd80533e5211acac060b17b2a4ffffffff0243190600000000001976a914a2baed4cdeda71053537312ee32cf0ab9f22cf1888acc0451b11000000001976a914f3e0b1ca6d94a95e1f3683ea6f3d2b563ad475e688ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    assert_eq!(transaction.version, 1, "Version is not correct");
    assert_eq!(transaction.transaction_inputs.len(), 2, "Transaction inputs length is not correct");
    let input0 = transaction.transaction_inputs[0];
    let expected_txid_hex = "0x91056d7ab3e99f9506f248783e0801c9039082d7d876dd45a8ab1f0a166226e2";
    let expected_txid = hex_to_bytecode(@expected_txid_hex);
    let expected_sig_script_hex =
        "0x493046022100a3deff7d28eca94e018cfafcf4e705cc6bb56ce1dab83a6377e6e97d28d305d90221008cfc8d40bb8e336f5210a4197760f6b9650ae6ec4682cc1626841d9c87d1b0f20141049305a94c5b8e71d8be2a2d7188d74cb38affc9dc83ab77cc2fedf7c03a82a56175b9c335ce4546a943a2215a9c04757f08c2cc97f731a208ea767119050e0b97";
    let expected_sig_script = hex_to_bytecode(@expected_sig_script_hex);
    assert_eq!(
        input0.previous_outpoint.txid,
        @u256_from_byte_array_with_offset(@expected_txid, 0, 32),
        "Outpoint txid on input 1 is not correct"
    );
    assert_eq!(input0.previous_outpoint.vout, @0, "Outpoint vout on input 1 is not correct");
    assert_eq!(
        input0.signature_script, @expected_sig_script, "Script sig on input 1 is not correct"
    );
    assert_eq!(input0.sequence, @0xFFFFFFFF, "Sequence on input 1 is not correct");

    let input1 = transaction.transaction_inputs[1];
    let expected_txid_hex = "0x465345e66a84047bf58a3787456d8023c38e04734c72d7f7039b9220ac503b6e";
    let expected_txid = hex_to_bytecode(@expected_txid_hex);
    let expected_sig_script_hex =
        "0x47304402202ff5fe06ff3ee680e069cd28ff3ed9a60050ba52ed811a739a29b81e3667074602203c0d1b63d0c495ee1b63886e42c2db0c4cb041ce0c957ad7febe0fbcd23498ee014104cc2cb6eb11b7b504e1aa2826cf8ce7568bc757d7f58ab1eaa0b5e6945ccdcc5b111c0c1163a28037b89501e0b83e3fdceb22a2fd80533e5211acac060b17b2a4";
    let expected_sig_script = hex_to_bytecode(@expected_sig_script_hex);
    assert_eq!(
        input1.previous_outpoint.txid,
        @u256_from_byte_array_with_offset(@expected_txid, 0, 32),
        "Outpoint txid on input 2 is not correct"
    );
    assert_eq!(input1.previous_outpoint.vout, @0, "Outpoint vout on input 2 is not correct");
    assert_eq!(
        input1.signature_script, @expected_sig_script, "Script sig on input 2 is not correct"
    );
    assert_eq!(input1.sequence, @0xFFFFFFFF, "Sequence on input 2 is not correct");

    let output0 = transaction.transaction_outputs[0];
    assert_eq!(output0.value, @399683, "Output 1 value is not correct");
    let expected_pk_script_hex = "0x76a914a2baed4cdeda71053537312ee32cf0ab9f22cf1888ac";
    let expected_pk_script = hex_to_bytecode(@expected_pk_script_hex);
    assert_eq!(output0.publickey_script, @expected_pk_script, "Output 1 pk_script is not correct");

    let output1 = transaction.transaction_outputs[1];
    assert_eq!(output1.value, @287000000, "Output 2 value is not correct");
    let expected_pk_script_hex = "0x76a914f3e0b1ca6d94a95e1f3683ea6f3d2b563ad475e688ac";
    let expected_pk_script = hex_to_bytecode(@expected_pk_script_hex);
    assert_eq!(output1.publickey_script, @expected_pk_script, "Output 2 pk_script is not correct");

    assert_eq!(transaction.locktime, 0, "Lock time is not correct");
}


#[test]
fn test_deserialize_first_p2pkh_transaction() {
    // First ever P2PKH transaction
    // tx: 6f7cf9580f1c2dfb3c4d5d043cdbb128c640e3f20161245aa7372e9666168516
    let raw_transaction_hex =
        "0x0100000002f60b5e96f09422354ab150b0e506c4bffedaf20216d30059cc5a3061b4c83dff000000004a493046022100e26d9ff76a07d68369e5782be3f8532d25ecc8add58ee256da6c550b52e8006b022100b4431f5a9a4dcb51cbdcaae935218c0ae4cfc8aa903fe4e5bac4c208290b7d5d01fffffffff7272ef43189f5553c2baea50f59cde99b3220fd518884d932016d055895b62d000000004a493046022100a2ab7cdc5b67aca032899ea1b262f6e8181060f5a34ee667a82dac9c7b7db4c3022100911bc945c4b435df8227466433e56899fbb65833e4853683ecaa12ee840d16bf01ffffffff0100e40b54020000001976a91412ab8dc588ca9d5787dde7eb29569da63c3a238c88ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    assert_eq!(transaction.version, 1, "Version is not correct");
    assert_eq!(transaction.transaction_inputs.len(), 2, "Transaction inputs length is not correct");
    let input0 = transaction.transaction_inputs[0];
    let expected_txid_hex = "0xf60b5e96f09422354ab150b0e506c4bffedaf20216d30059cc5a3061b4c83dff";
    let expected_txid = hex_to_bytecode(@expected_txid_hex);
    let expected_sig_script_hex =
        "0x493046022100e26d9ff76a07d68369e5782be3f8532d25ecc8add58ee256da6c550b52e8006b022100b4431f5a9a4dcb51cbdcaae935218c0ae4cfc8aa903fe4e5bac4c208290b7d5d01";
    let expected_sig_script = hex_to_bytecode(@expected_sig_script_hex);
    assert_eq!(
        input0.previous_outpoint.txid,
        @u256_from_byte_array_with_offset(@expected_txid, 0, 32),
        "Outpoint txid on input 1 is not correct"
    );
    assert_eq!(input0.previous_outpoint.vout, @0, "Outpoint vout on input 1 is not correct");
    assert_eq!(
        input0.signature_script, @expected_sig_script, "Script sig on input 1 is not correct"
    );
    assert_eq!(input0.sequence, @0xFFFFFFFF, "Sequence on input 1 is not correct");

    let input1 = transaction.transaction_inputs[1];
    let expected_txid_hex = "0xf7272ef43189f5553c2baea50f59cde99b3220fd518884d932016d055895b62d";
    let expected_txid = hex_to_bytecode(@expected_txid_hex);
    let expected_sig_script_hex =
        "0x493046022100a2ab7cdc5b67aca032899ea1b262f6e8181060f5a34ee667a82dac9c7b7db4c3022100911bc945c4b435df8227466433e56899fbb65833e4853683ecaa12ee840d16bf01";
    let expected_sig_script = hex_to_bytecode(@expected_sig_script_hex);
    assert_eq!(
        input1.previous_outpoint.txid,
        @u256_from_byte_array_with_offset(@expected_txid, 0, 32),
        "Outpoint txid on input 2 is not correct"
    );
    assert_eq!(input1.previous_outpoint.vout, @0, "Outpoint vout on input 2 is not correct");
    assert_eq!(
        input1.signature_script, @expected_sig_script, "Script sig on input 2 is not correct"
    );
    assert_eq!(input1.sequence, @0xFFFFFFFF, "Sequence on input 2 is not correct");

    let output0 = transaction.transaction_outputs[0];
    assert_eq!(output0.value, @10000000000, "Output 1 value is not correct");
    let expected_pk_script_hex = "0x76a91412ab8dc588ca9d5787dde7eb29569da63c3a238c88ac";
    let expected_pk_script = hex_to_bytecode(@expected_pk_script_hex);
    assert_eq!(output0.publickey_script, @expected_pk_script, "Output 1 pk_script is not correct");

    assert_eq!(transaction.locktime, 0, "Lock time is not correct");
}

#[test]
fn test_deserialize_p2wsh_transaction() {
    // https://learnmeabitcoin.com/explorer/tx/64f427122f7951687aea608b5474509a30616d4e5773a83bc1ed8b8271ad1991
    let raw_transaction_hex =
        "0x020000000001018a39b5cdd48c7d45a31a89cd675a95f5de78aebeeda1e55ac35d7110c3bacfc60000000000ffffffff01204e0000000000001976a914ee63c8c790952de677d1f8019c9474d84098d6e188ac0202123423aa20a23421f2ba909c885a3077bb6f8eb4312487797693bbcfe7e311f797e3c5b8fa8700000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    assert_eq!(transaction.version, 2, "Version is not correct");
    assert_eq!(transaction.transaction_inputs.len(), 1, "Transaction inputs length is not correct");
    let input0 = transaction.transaction_inputs[0];
    let expected_txid_hex = "0x8a39b5cdd48c7d45a31a89cd675a95f5de78aebeeda1e55ac35d7110c3bacfc6";
    let expected_txid = hex_to_bytecode(@expected_txid_hex);
    let expected_witness_1_hex = "0x1234";
    let expected_witness_1 = hex_to_bytecode(@expected_witness_1_hex);
    let expected_witness_2_hex =
        "0xaa20a23421f2ba909c885a3077bb6f8eb4312487797693bbcfe7e311f797e3c5b8fa87";
    let expected_witness_2 = hex_to_bytecode(@expected_witness_2_hex);

    assert_eq!(input0.previous_outpoint.vout, @0, "Outpoint vout on input 1 is not correct");
    assert_eq!(
        input0.previous_outpoint.txid,
        @u256_from_byte_array_with_offset(@expected_txid, 0, 32),
        "Outpoint txid on input 1 is not correct"
    );
    assert_eq!(input0.signature_script.len(), 0, "Script sig on input 1 is not empty");
    assert_eq!(input0.witness.len(), 2, "Witness length on input 1 is not correct");
    assert_eq!(input0.witness[0], @expected_witness_1, "Witness 1 on input 1 is not correct");
    assert_eq!(input0.witness[1], @expected_witness_2, "Witness 2 on input 1 is not correct");
    assert_eq!(input0.sequence, @0xFFFFFFFF, "Sequence on input 1 is not correct");

    let output0 = transaction.transaction_outputs[0];
    assert_eq!(output0.value, @20000, "Output 1 value is not correct");
    let expected_pk_script_hex = "0x76a914ee63c8c790952de677d1f8019c9474d84098d6e188ac";
    let expected_pk_script = hex_to_bytecode(@expected_pk_script_hex);
    assert_eq!(output0.publickey_script, @expected_pk_script, "Output 1 pk_script is not correct");

    assert_eq!(transaction.locktime, 0, "Lock time is not correct");
}

#[test]
fn test_deserialize_p2wpkh_transaction() {
    // https://learnmeabitcoin.com/explorer/tx/c178d8dacdfb989f9d4fa45828ed188cd54a0414d625c3e61e75c5e3ac15a83a#output-0
    let raw_transaction_hex =
        "0x020000000001016972546966be990440a0665b73d0f4c3c942592d1f64d1033717aaa3e2c2ec913300000000ffffffff024087100000000000160014841b80d2cc75f5345c482af96294d04fdd66b2b760e31600000000001600142e8734f8e263e516d47fcaa2dfe1bd01e0dc935802473044022042e5e3ed2a41214ae864634b6fde33ca2ff312f3d89d6aa3e14c026d50d8ed3202206c38dcd0432a0724490356fbf599cdae40e334c3667a9253f8f4cc57cf3c4480012103f465315805ed271eb972e43d84d2a9e19494d10151d9f6adb32b8534bfd764ab00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    assert_eq!(transaction.version, 2, "Transaction version is incorrect");
    assert_eq!(transaction.transaction_inputs.len(), 1, "Incorrect number of transaction inputs");
    let input0 = transaction.transaction_inputs[0];
    let expected_txid_hex = "0x6972546966be990440a0665b73d0f4c3c942592d1f64d1033717aaa3e2c2ec91";
    let expected_txid = hex_to_bytecode(@expected_txid_hex);

    assert_eq!(input0.previous_outpoint.vout, @51, "Outpoint vout on input 0 is incorrect");
    assert_eq!(
        input0.previous_outpoint.txid,
        @u256_from_byte_array_with_offset(@expected_txid, 0, 32),
        "Outpoint txid on input 0 is incorrect"
    );
    assert_eq!(input0.signature_script.len(), 0, "Signature script on input 0 should be empty");

    let expected_witness_1_hex =
        "0x3044022042e5e3ed2a41214ae864634b6fde33ca2ff312f3d89d6aa3e14c026d50d8ed3202206c38dcd0432a0724490356fbf599cdae40e334c3667a9253f8f4cc57cf3c448001";
    let expected_witness_2_hex =
        "0x03f465315805ed271eb972e43d84d2a9e19494d10151d9f6adb32b8534bfd764ab";
    let expected_witness_1 = hex_to_bytecode(@expected_witness_1_hex);
    let expected_witness_2 = hex_to_bytecode(@expected_witness_2_hex);

    assert_eq!(input0.witness.len(), 2, "Witness length on input 0 is incorrect");
    assert_eq!(input0.witness[0], @expected_witness_1, "Witness 1 on input 0 is incorrect");
    assert_eq!(input0.witness[1], @expected_witness_2, "Witness 2 on input 0 is incorrect");
    assert_eq!(input0.sequence, @0xFFFFFFFF, "Sequence on input 0 is incorrect");

    assert_eq!(transaction.transaction_outputs.len(), 2, "Incorrect number of transaction outputs");
    let output0 = transaction.transaction_outputs[0];
    let output1 = transaction.transaction_outputs[1];

    assert_eq!(output0.value, @1083200, "Output 0 value is incorrect");
    let expected_pk_script0_hex = "0x0014841b80d2cc75f5345c482af96294d04fdd66b2b7";
    let expected_pk_script0 = hex_to_bytecode(@expected_pk_script0_hex);
    assert_eq!(output0.publickey_script, @expected_pk_script0, "Output 0 pk_script is incorrect");

    assert_eq!(output1.value, @1500000, "Output 1 value is incorrect");
    let expected_pk_script1_hex = "0x00142e8734f8e263e516d47fcaa2dfe1bd01e0dc9358";
    let expected_pk_script1 = hex_to_bytecode(@expected_pk_script1_hex);
    assert_eq!(output1.publickey_script, @expected_pk_script1, "Output 1 pk_script is incorrect");

    assert_eq!(transaction.locktime, 0, "Locktime is incorrect");
}


#[test]
fn test_deserialize_coinbase_transaction() { // TODO
}

#[test]
fn test_validate_transaction() {
    // First ever transaction from Satoshi -> Hal Finney
    // tx: f4184fc596403b9d638783cf57adfe4c75c605f6356fbc91338530e9831e9e16
    let raw_transaction_hex =
        "0x0100000001c997a5e56e104102fa209c6a852dd90660a20b2d9c352423edce25857fcd3704000000004847304402204e45e16932b8af514961a1d3a1a25fdf3f4f7732e9d624c6c61548ab5fb8cd410220181522ec8eca07de4860a4acdd12909d831cc56cbbac4622082221a8768d1d0901ffffffff0200ca9a3b00000000434104ae1a62fe09c5f51b13905f07f06b99a2f7159b2225f374cd378d71302fa28414e7aab37397f554a7df5f142c21c1b7303b8a0626f1baded5c72a704f7e6cd84cac00286bee0000000043410411db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a6909a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f656b412a3ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);

    // Setup UTXO hints ( previous valid outputs used to execute this transaction )
    let prevout_pk_script =
        "0x410411db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a6909a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f656b412a3ac";
    let prev_out = UTXO {
        amount: 5000000000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 9
    };
    let utxo_hints = array![prev_out];

    // Run Shinigami and validate the transaction execution
    let res = validate::validate_transaction(@transaction, 0, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed");
}
