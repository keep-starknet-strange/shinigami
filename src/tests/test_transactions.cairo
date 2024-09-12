use crate::transaction::TransactionTrait;
use crate::utxo::UTXO;
use crate::validate;
use crate::utils;

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
fn test_deserialize_first_p2pkh_transaction(){
    // First ever P2PKH transaction 
    // tx: 6f7cf9580f1c2dfb3c4d5d043cdbb128c640e3f20161245aa7372e9666168516
    let raw_transaction_hex = "0x0100000002f60b5e96f09422354ab150b0e506c4bffedaf20216d30059cc5a3061b4c83dff000000004a493046022100e26d9ff76a07d68369e5782be3f8532d25ecc8add58ee256da6c550b52e8006b022100b4431f5a9a4dcb51cbdcaae935218c0ae4cfc8aa903fe4e5bac4c208290b7d5d01fffffffff7272ef43189f5553c2baea50f59cde99b3220fd518884d932016d055895b62d000000004a493046022100a2ab7cdc5b67aca032899ea1b262f6e8181060f5a34ee667a82dac9c7b7db4c3022100911bc945c4b435df8227466433e56899fbb65833e4853683ecaa12ee840d16bf01ffffffff0100e40b54020000001976a91412ab8dc588ca9d5787dde7eb29569da63c3a238c88ac00000000";
    let raw_transaction = utils::hex_to_bytecode(@raw_transaction_hex);
    let transaction = TransactionTrait::deserialize(raw_transaction);

    assert_eq!(transaction.version, 1, "Version is not correct");
    assert_eq!(transaction.transaction_inputs.len(), 2, "Transaction inputs length is not correct");
    let input0 = transaction.transaction_inputs[0];
    let expected_txid_hex = "0xf60b5e96f09422354ab150b0e506c4bffedaf20216d30059cc5a3061b4c83dff";
    let expected_txid = utils::hex_to_bytecode(@expected_txid_hex);
    let expected_sig_script_hex =
        "0x493046022100e26d9ff76a07d68369e5782be3f8532d25ecc8add58ee256da6c550b52e8006b022100b4431f5a9a4dcb51cbdcaae935218c0ae4cfc8aa903fe4e5bac4c208290b7d5d01";
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
    let expected_txid_hex = "0xf7272ef43189f5553c2baea50f59cde99b3220fd518884d932016d055895b62d";
    let expected_txid = utils::hex_to_bytecode(@expected_txid_hex);
    let expected_sig_script_hex =
        "0x493046022100a2ab7cdc5b67aca032899ea1b262f6e8181060f5a34ee667a82dac9c7b7db4c3022100911bc945c4b435df8227466433e56899fbb65833e4853683ecaa12ee840d16bf01";
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
    assert_eq!(output0.value, @10000000000, "Output 1 value is not correct");
    let expected_pk_script_hex = "0x76a91412ab8dc588ca9d5787dde7eb29569da63c3a238c88ac";
    let expected_pk_script = utils::hex_to_bytecode(@expected_pk_script_hex);
    assert_eq!(output0.publickey_script, @expected_pk_script, "Output 1 pk_script is not correct");

    assert_eq!(transaction.locktime, 0, "Lock time is not correct");
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
    let raw_transaction = utils::hex_to_bytecode(@raw_transaction_hex);
    let transaction = TransactionTrait::deserialize(raw_transaction);

    // Setup UTXO hints ( previous valid outputs used to execute this transaction )
    let prevout_pk_script =
        "0x410411db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a6909a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f656b412a3ac";
    let prev_out = UTXO {
        amount: 5000000000,
        pubkey_script: utils::hex_to_bytecode(@prevout_pk_script),
        block_height: 9
    };
    let utxo_hints = array![prev_out];

    // Run Shinigami and validate the transaction execution
    let res = validate::validate_transaction(transaction, 0, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed");
}

#[test]
fn test_p2pkh_transaction() {
    // First ever P2PKH transaction 
    // tx: 6f7cf9580f1c2dfb3c4d5d043cdbb128c640e3f20161245aa7372e9666168516
    //let raw_transaction_hex = "0x0100000002f60b5e96f09422354ab150b0e506c4bffedaf20216d30059cc5a3061b4c83dff000000004a493046022100e26d9ff76a07d68369e5782be3f8532d25ecc8add58ee256da6c550b52e8006b022100b4431f5a9a4dcb51cbdcaae935218c0ae4cfc8aa903fe4e5bac4c208290b7d5d01fffffffff7272ef43189f5553c2baea50f59cde99b3220fd518884d932016d055895b62d000000004a493046022100a2ab7cdc5b67aca032899ea1b262f6e8181060f5a34ee667a82dac9c7b7db4c3022100911bc945c4b435df8227466433e56899fbb65833e4853683ecaa12ee840d16bf01ffffffff0100e40b54020000001976a91412ab8dc588ca9d5787dde7eb29569da63c3a238c88ac00000000";
    // tx that spent it because it reveals pubkey https://learnmeabitcoin.com/explorer/tx/12e753ef5cc30925a6eee2c457aa7f53022443ca013ea81882a6b59b69e342a6
    let raw_transaction_hex = "0x01000000030dd7891efbf67da47c651531db8aab3144ed7a524e4ae1e30b773525e27ddd7b000000004948304502206f6a68710a51f77e5a1fa4d1037a23a76723724a51fd54710949e0189ee02dfa022100dad3454ade12fe84f3818e14c41ec2e02bbb154dd3136a094cdf86f67ebbe0b601ffffffff16851666962e37a75a246101f2e340c628b1db3c045d4d3cfb2d1c0f58f97c6f000000008b48304502203f004eeed0cef2715643e2f25a27a28f3c578e94c7f0f6a4df104e7d163f7f8f022100b8b248c1cfd8f77a0365107a9511d759b7544d979dd152a955c867afac0ef7860141044d05240cfbd8a2786eda9dadd520c1609b8593ff8641018d57703d02ba687cf2f187f0cee2221c3afb1b5ff7888caced2423916b61444666ca1216f26181398cffffffffffda5d38e91fd9a0d92872d51f83cb746fc7bf5d3ff13402f8d0d5ed60ddc79c0000000049483045022100b6fd43f2fa16e092678283f64d2e08fb2070b4af2b3ddfb9ca3c5e238288acaa02200c5a28e0a4fc1a540f6eeb30ccc4788050eae46964fe33ccb4500c3de1320c2501ffffffff02c0c62d00000000001976a91417194e1bd175fb5b1b2a1f9d221f6f5c29e1928388ac00c817a8040000001976a91465bda9b05f7e9a8f96a7f4ba0996a877708ef90888ac00000000";
    let raw_transaction = utils::hex_to_bytecode(@raw_transaction_hex);
    let transaction = TransactionTrait::deserialize(raw_transaction);
    //let transaction = TransactionTrait::btc_decode(raw_transaction, BASE_ENCODING);


    let prevout_pk_script_output0 = "0x4104889fcdfd7c5430d13f1eb5f508e2e87f38d2406fad8425a824e032ccb371ef62465331e1a6334d7c3770a2ad2a958e740130343399d01dbd87426db850f9faf9ac";
    let prevout_pkh_script_output1 = "0x76a91412ab8dc588ca9d5787dde7eb29569da63c3a238c88ac";
    let prevout_pk_script_output2 = "0x4104f51707ee3fd26b490bb83582f22c73b97c364b9c51a80c49e6a9bc491538f5206fc0ca8fc4c97dfd0a8b2ae9b82d1ef94599ce51eaf9ba82ce4a69d9ac9dc225ac";
    // let prevout_pkh_script_output2 = "0x76a91412ab8dc588ca9d5787dde7eb29569da63c3a238c88ac";
    //  let prevout_pkh_script_output3 = "0x4104f51707ee3fd26b490bb83582f22c73b97c364b9c51a80c49e6a9bc491538f5206fc0ca8fc4c97dfd0a8b2ae9b82d1ef94599ce51eaf9ba82ce4a69d9ac9dc225ac";

    //let prevout_pk_script_output1 = "0x76a91412ab8dc588ca9d5787dde7eb29569da63c3a238c88ac";
    
    let prev_out0 = UTXO {
        amount: 5000000000,
        pubkey_script: utils::hex_to_bytecode(@prevout_pk_script_output0),
        block_height: 728
    };

    let prev_out1 = UTXO {
        amount: 10000000000,
        pubkey_script: utils::hex_to_bytecode(@prevout_pkh_script_output1),
        block_height: 728
    };

    let prev_out2 = UTXO {
        amount: 10000000000,
        pubkey_script: utils::hex_to_bytecode(@prevout_pk_script_output2),
        block_height: 728
    };

    let utxo_hints = array![prev_out0, prev_out1, prev_out2];

    // Run Shinigami and validate the transaction execution
    let res = validate::validate_transaction(transaction, 0, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed");
}