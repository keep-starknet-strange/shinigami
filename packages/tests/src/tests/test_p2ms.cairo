use shinigami_engine::transaction::EngineInternalTransactionTrait;
use crate::utxo::UTXO;
use crate::validate;
use shinigami_utils::bytecode::hex_to_bytecode;

#[test]
fn test_p2ms_1_of_2() {
    // First P2MS transaction made on 30 Jan 2012
    // tx: 60a20bd93aa49ab4b28d514ec10b06e1829ce6818ec06cd3aabd013ebcdc4bb1
    let prevout_pk_script =
        "0x514104cc71eb30d653c0c3163990c47b976f3fb3f37cccdcbedb169a1dfef58bbfbfaff7d8a473e7e2e6d317b87bafe8bde97e3cf8f065dec022b51d11fcdd0d348ac4410461cbdcc5409fb4b4d42b51d33381354d80e550078cb532a34bfa2fcfdeb7d76519aecc62770f5b0e4ef8551946d8a540911abe3e7854a26f39f58b25c15342af52ae";
    let prev_out = UTXO {
        amount: 1000000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 164467
    };

    let raw_transaction_hex =
        "0x0100000001b14bdcbc3e01bdaad36cc08e81e69c82e1060bc14e518db2b49aa43ad90ba26000000000490047304402203f16c6f40162ab686621ef3000b04e75418a0c0cb2d8aebeac894ae360ac1e780220ddc15ecdfc3507ac48e1681a33eb60996631bf6bf5bc0a0682c4db743ce7ca2b01ffffffff0140420f00000000001976a914660d4ef3a743e3e696ad990364e555c271ad504b88ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);
    let utxo_hints = array![prev_out];

    let res = validate::validate_p2ms(@transaction, 0, utxo_hints);
    match res {
        Result::Ok(()) => {},
        Result::Err(err) => panic!("P2MS 1-of-2 transaction validation failed: {}", err),
    }
}

#[test]
fn test_p2ms_2_of_3() {
    // Third P2MS transaction made on 03 Feb 2012
    // tx: 14237b92d26850730ffab1bfb138121e487ddde444734ef195eb7928102bc939
    let prevout_pk_script =
        "0x52410496ec45f878b62c46c4be8e336dff7cc58df9b502178cc240eb3d31b1266f69f5767071aa3e017d1b82a0bb28dab5e27d4d8e9725b3e68ed5f8a2d45c730621e34104cc71eb30d653c0c3163990c47b976f3fb3f37cccdcbedb169a1dfef58bbfbfaff7d8a473e7e2e6d317b87bafe8bde97e3cf8f065dec022b51d11fcdd0d348ac4410461cbdcc5409fb4b4d42b51d33381354d80e550078cb532a34bfa2fcfdeb7d76519aecc62770f5b0e4ef8551946d8a540911abe3e7854a26f39f58b25c15342af53ae";
    let prev_out = UTXO {
        amount: 1000000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 164467
    };

    let raw_transaction_hex =
        "0x010000000139c92b102879eb95f14e7344e4dd7d481e1238b1bfb1fa0f735068d2927b231400000000910047304402208fc06d216ebb4b6a3a3e0f906e1512c372fa8a9c2a92505d04e9b451ea7acd0c0220764303bb7e514ddd77855949d941c934e9cbda8e3c3827bfdb5777477e73885b014730440220569ec6d2e81625dd18c73920e0079cdb4c1d67d3d7616759eb0c18cf566b3d3402201c60318f0a62e3ba85ca0f158d4dfe63c0779269eb6765b6fc939fc51e7a8ea901ffffffff0140787d01000000001976a914641ad5051edd97029a003fe9efb29359fcee409d88ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);
    let utxo_hints = array![prev_out];

    let res = validate::validate_p2ms(@transaction, 0, utxo_hints);
    assert!(res.is_ok(), "P2MS 2-of-3 transaction validation failed");
}

#[test]
fn test_p2ms_3_of_3() {
    // Second P2MS transaction made on 03 Feb 2012
    // tx: 2daea775df11a98646c475c04247b998bbed053dc0c72db162dd6b0a99a59c26
    let prevout_pk_script =
        "0x534104c46d6462f67f990211d3a7077f005e67154f5f785b3edc06af3de62649a15bad35905fa7af9f272f80379a41525ad57a2245c2edc4807e3e49f43eb1c1b119794104cc71eb30d653c0c3163990c47b976f3fb3f37cccdcbedb169a1dfef58bbfbfaff7d8a473e7e2e6d317b87bafe8bde97e3cf8f065dec022b51d11fcdd0d348ac4410461cbdcc5409fb4b4d42b51d33381354d80e550078cb532a34bfa2fcfdeb7d76519aecc62770f5b0e4ef8551946d8a540911abe3e7854a26f39f58b25c15342af53ae";
    let prev_out = UTXO {
        amount: 50000000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 165224
    };

    let raw_transaction_hex =
        "0x0100000001269ca5990a6bdd62b12dc7c03d05edbb98b94742c075c44686a911df75a7ae2d00000000d9004730440220c0949354ad3a8b7162360a3b513683c417b38ea237805580d75e14950f3a4fed02206f95bc753511e96d82592b01eea4ce0f05b76d24c19e6b707a6468f1f7943a18014730440220a5f9c09fb40a6b02a7d20fcd246ba72995f34613b5afe18bd1b8b197b756aea402200511aecc66f7d7738baca0515c18444ba024d30ef304cdcf375fa163d4217b34014730440220938b9fd2b543e544eeb09abe519a1dbe900ec2761eff7277d8fea2e8397b6687022002886dd0e36aeb18c0c8752303f6898776552f7f877ff1d900d9078b26314aba01ffffffff0180f0fa02000000001976a914641ad5051edd97029a003fe9efb29359fcee409d88ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);
    let utxo_hints = array![prev_out];

    let res = validate::validate_p2ms(@transaction, 0, utxo_hints);
    assert!(res.is_ok(), "P2MS 3-of-3 transaction validation failed");
}

// #[test]
// fn test_p2ms_1of1() {
//     // Test case for 1-of-1 multisig
//     let prevout_pk_script_1of1 =
//         "0x514104cc71eb30d653c0c3163990c47b976f3fb3f37cccdcbedb169a1dfef58bbfbfaff7d8a473e7e2e6d317b87bafe8bde97e3cf8f065dec022b51d11fcdd0d348ac4410461cbdcc5409fb4b4d42b51d33381354d80e550078cb532a34bfa2fcfdeb7d76519aecc62770f5b0e4ef8551946d8a540911abe3e7854a26f39f58b25c15342af52ae";
//     let prev_out_1of1 = UTXO {
//         amount: 1000000,
//         pubkey_script: hex_to_bytecode(@prevout_pk_script_1of1),
//         block_height: 164467
//     };

//     let raw_transaction_hex =
//         "0x0100000001b14bdcbc3e01bdaad36cc08e81e69c82e1060bc14e518db2b49aa43ad90ba26000000000490047304402203f16c6f40162ab686621ef3000b04e75418a0c0cb2d8aebeac894ae360ac1e780220ddc15ecdfc3507ac48e1681a33eb60996631bf6bf5bc0a0682c4db743ce7ca2b01ffffffff0140420f00000000001976a914660d4ef3a743e3e696ad990364e555c271ad504b88ac00000000";
//     let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
//     let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);
//     let utxo_hints = array![prev_out_1of1];

//     let res = validate::validate_p2ms(@transaction, 0, utxo_hints);
//     assert!(res.is_ok(), "P2MS 1-of-1 multisig validation failed");
// }

#[test]
fn test_p2ms_1of2_invalid_pubkey() {
    // Test case for 1-of-2 multisig with an invalid public key
    // tx: 99cb2139052dc88508f2fe35235c1c5685229a45bef3db70413c5ac43c41ca0a
    let prevout_pk_script_1of2_invalid =
        "0x5121037953dbf08030f67352134992643d033417eaa6fcfb770c038f364ff40d7615882100dd28dfb81abe444429c466a1e3ab7c22365c48f234ef0f8d40397202969d4e9552ae";
    let prev_out_1of2_invalid = UTXO {
        amount: 92700000,
        pubkey_script: hex_to_bytecode(@prevout_pk_script_1of2_invalid),
        block_height: 229563
    };

    let raw_transaction_hex =
        "0x0100000001b14bdcbc3e01bdaad36cc08e81e69c82e1060bc14e518db2b49aa43ad90ba26000000000490047304402203f16c6f40162ab686621ef3000b04e75418a0c0cb2d8aebeac894ae360ac1e780220ddc15ecdfc3507ac48e1681a33eb60996631bf6bf5bc0a0682c4db743ce7ca2b01ffffffff0140420f00000000001976a914660d4ef3a743e3e696ad990364e555c271ad504b88ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);
    let utxo_hints = array![prev_out_1of2_invalid];

    let res = validate::validate_p2ms(@transaction, 0, utxo_hints);
    assert!(res.is_err(), "P2MS 1-of-2 with invalid public key should fail validation");
}

// #[test]
// fn test_p2ms_edge_cases() {
//     // Test case for 1-of-1 multisig
//     let prevout_pk_script_1of1 = "0x514104cc71eb30d653c0c3163990c47b976f3fb3f37cccdcbedb169a1dfef58bbfbfaff7d8a473e7e2e6d317b87bafe8bde97e3cf8f065dec022b51d11fcdd0d348ac4410461cbdcc5409fb4b4d42b51d33381354d80e550078cb532a34bfa2fcfdeb7d76519aecc62770f5b0e4ef8551946d8a540911abe3e7854a26f39f58b25c15342af52ae";
//     let prev_out_1of1 = UTXO {
//         amount: 1000000,
//         pubkey_script: hex_to_bytecode(@prevout_pk_script_1of1),
//         block_height: 164467
//     };

//     // Test case for 1-of-2 multisig with an invalid public key
//     let prevout_pk_script_1of2_invalid = "0x5121037953dbf08030f67352134992643d033417eaa6fcfb770c038f364ff40d7615882100bd2fda4cf456d64386a0756f580101a607c25bd8d6814693bdf16e2a7ba3e45c52ae";
//     let prev_out_1of2_invalid = UTXO {
//         amount: 92750000,
//         pubkey_script: hex_to_bytecode(@prevout_pk_script_1of2_invalid),
//         block_height: 229517
//     };

//     // Test case for 2-of-3 multisig with maximum allowed public keys (20)
//     let prevout_pk_script_3of3 = "0x0114410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc34550114ae";
//     let prev_out_3of3 = UTXO {
//         amount: 2201000,
//         pubkey_script: hex_to_bytecode(@prevout_pk_script_3of3),
//         block_height: 284029
//     };

//     let raw_transaction_hex = "0x0100000001b14bdcbc3e01bdaad36cc08e81e69c82e1060bc14e518db2b49aa43ad90ba26000000000490047304402203f16c6f40162ab686621ef3000b04e75418a0c0cb2d8aebeac894ae360ac1e780220ddc15ecdfc3507ac48e1681a33eb60996631bf6bf5bc0a0682c4db743ce7ca2b01ffffffff0140420f00000000001976a914660d4ef3a743e3e696ad990364e555c271ad504b88ac00000000"; // Replace with actual transaction hex
//     let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
//     let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);
//     let utxo_hints = array![prev_out_1of1, prev_out_1of2_invalid, prev_out_3of3];

//     let res = validate::validate_p2ms(@transaction, 0, utxo_hints);
//     assert!(res.is_ok(), "P2MS edge cases validation failed");
// }

#[test]
fn test_p2ms_1_of_1() {
    // Transaction data from the provided transaction
    // TXID: ac1d9ed701af32ea52fabd0834acfb1ba4e3584cf0553551f1b61b3d7fb05ee7
    // Block: 431,077
    // Inputs: 1
    // Outputs: 3
    // Fee: 20,000 sats
    // Amount: 30,858,918 sats

    // Previous output public key script (P2MS)
    let prevout_pk_script =
        "0x51210281feb90c058c3436f8bc361930ae99fcfb530a699cdad141d7244bfcad521a1f51ae"; // P2MS script
    let prev_out = UTXO {
        amount: 20000, // Amount for the P2MS output
        pubkey_script: hex_to_bytecode(@prevout_pk_script),
        block_height: 431077
    };

    // Raw transaction hex
    let raw_transaction_hex =
        "0x0100000001ffc0d6d6b592cd2b4160300a278ea5e250b5055b5536dcfb2da5dcc46022765a00000000694630430220575ddd235a989befbf98f43b008666e56af07be89e47e09d18690c75846fb587021f00830605aa09febc51132001e0dbcad860e54d4657b55aaf961b527a935b8a01210281feb90c058c3436f8bc361930ae99fcfb530a699cdad141d7244bfcad521a1fffffffff03204e0000000000002551210281feb90c058c3436f8bc361930ae99fcfb530a699cdad141d7244bfcad521a1f51ae204e0000000000001976a914a988f8039a203cf86136e0d32b9d77eafa5a6bef88ac46f4d501000000001976a914161d7a3d0ee15c793ab300433192f949d8f3566588ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);
    let utxo_hints = array![prev_out];

    // Validate the P2MS transaction
    let res = validate::validate_p2ms(@transaction, 0, utxo_hints);
    assert!(res.is_ok(), "P2MS 1-of-1 transaction validation failed");
}