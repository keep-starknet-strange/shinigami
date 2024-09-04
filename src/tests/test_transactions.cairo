use shinigami::transaction::TransactionTrait;
use shinigami::utils;

// TODO: txid byte order reverse

#[test]
fn test_deserialize_transaction() {
    // Block 150007 transaction 7
    // tx: d823f0d96563ec214a2342c8637a5775038ca05e56ca069631c96f400ca2f9f7
    let raw_transaction_hex =
        "0x010000000291056d7ab3e99f9506f248783e0801c9039082d7d876dd45a8ab1f0a166226e2000000008c493046022100a3deff7d28eca94e018cfafcf4e705cc6bb56ce1dab83a6377e6e97d28d305d90221008cfc8d40bb8e336f5210a4197760f6b9650ae6ec4682cc1626841d9c87d1b0f20141049305a94c5b8e71d8be2a2d7188d74cb38affc9dc83ab77cc2fedf7c03a82a56175b9c335ce4546a943a2215a9c04757f08c2cc97f731a208ea767119050e0b97ffffffff465345e66a84047bf58a3787456d8023c38e04734c72d7f7039b9220ac503b6e000000008a47304402202ff5fe06ff3ee680e069cd28ff3ed9a60050ba52ed811a739a29b81e3667074602203c0d1b63d0c495ee1b63886e42c2db0c4cb041ce0c957ad7febe0fbcd23498ee014104cc2cb6eb11b7b504e1aa2826cf8ce7568bc757d7f58ab1eaa0b5e6945ccdcc5b111c0c1163a28037b89501e0b83e3fdceb22a2fd80533e5211acac060b17b2a4ffffffff0243190600000000001976a914a2baed4cdeda71053537312ee32cf0ab9f22cf1888acc0451b11000000001976a914f3e0b1ca6d94a95e1f3683ea6f3d2b563ad475e688ac00000000";
    let raw_transaction = utils::hex_to_bytecode(@raw_transaction_hex);
    let transaction = TransactionTrait::deserialize(raw_transaction);

    assert_eq!(transaction.version, 1, "Version is not correct");
    assert_eq!(transaction.transaction_inputs.len(), 2, "Transaction inputs length is not correct");
    let input0 = transaction.transaction_inputs[0];
    let expected_txid_hex = "0x91056d7ab3e99f9506f248783e0801c9039082d7d876dd45a8ab1f0a166226e2";
    let expected_txid = utils::hex_to_bytecode(@expected_txid_hex);
    let expected_sig_script_hex =
        "0x493046022100a3deff7d28eca94e018cfafcf4e705cc6bb56ce1dab83a6377e6e97d28d305d90221008cfc8d40bb8e336f5210a4197760f6b9650ae6ec4682cc1626841d9c87d1b0f20141049305a94c5b8e71d8be2a2d7188d74cb38affc9dc83ab77cc2fedf7c03a82a56175b9c335ce4546a943a2215a9c04757f08c2cc97f731a208ea767119050e0b97";
    let expected_sig_script = utils::hex_to_bytecode(@expected_sig_script_hex);
    assert_eq!(
        input0.previous_outpoint.txid,
        @utils::u256_from_byte_array_with_offset(@expected_txid, 0, 32),
        "Outpoint txid on input 1 is not correct"
    );
    assert_eq!(input0.previous_outpoint.vout, @0, "Outpoint vout on input 1 is not correct");
    assert_eq!(
        input0.signature_script, @expected_sig_script, "Script sig on input 1 is not correct"
    );
    assert_eq!(input0.sequence, @0xFFFFFFFF, "Sequence on input 1 is not correct");

    let input1 = transaction.transaction_inputs[1];
    let expected_txid_hex = "0x465345e66a84047bf58a3787456d8023c38e04734c72d7f7039b9220ac503b6e";
    let expected_txid = utils::hex_to_bytecode(@expected_txid_hex);
    let expected_sig_script_hex =
        "0x47304402202ff5fe06ff3ee680e069cd28ff3ed9a60050ba52ed811a739a29b81e3667074602203c0d1b63d0c495ee1b63886e42c2db0c4cb041ce0c957ad7febe0fbcd23498ee014104cc2cb6eb11b7b504e1aa2826cf8ce7568bc757d7f58ab1eaa0b5e6945ccdcc5b111c0c1163a28037b89501e0b83e3fdceb22a2fd80533e5211acac060b17b2a4";
    let expected_sig_script = utils::hex_to_bytecode(@expected_sig_script_hex);
    assert_eq!(
        input1.previous_outpoint.txid,
        @utils::u256_from_byte_array_with_offset(@expected_txid, 0, 32),
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
    let expected_pk_script = utils::hex_to_bytecode(@expected_pk_script_hex);
    assert_eq!(output0.publickey_script, @expected_pk_script, "Output 1 pk_script is not correct");

    let output1 = transaction.transaction_outputs[1];
    assert_eq!(output1.value, @287000000, "Output 2 value is not correct");
    let expected_pk_script_hex = "0x76a914f3e0b1ca6d94a95e1f3683ea6f3d2b563ad475e688ac";
    let expected_pk_script = utils::hex_to_bytecode(@expected_pk_script_hex);
    assert_eq!(output1.publickey_script, @expected_pk_script, "Output 2 pk_script is not correct");

    assert_eq!(transaction.locktime, 0, "Lock time is not correct");
}

#[test]
fn test_deserialize_coinbase_transaction() { // TODO
}
