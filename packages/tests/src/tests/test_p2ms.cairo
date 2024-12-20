use shinigami_engine::transaction::EngineInternalTransactionTrait;
use shinigami_engine::utxo::{UTXO};

use crate::validate;
use shinigami_utils::bytecode::hex_to_bytecode;

#[test]
fn test_p2ms_1_of_2() {
    // First P2MS transaction made on 30 Jan 2012
    // tx: 23b397edccd3740a74adb603c9756370fafcde9bcc4483eb271ecad09a94dd63
    let prevout_pk_script =
        "0x514104cc71eb30d653c0c3163990c47b976f3fb3f37cccdcbedb169a1dfef58bbfbfaff7d8a473e7e2e6d317b87bafe8bde97e3cf8f065dec022b51d11fcdd0d348ac4410461cbdcc5409fb4b4d42b51d33381354d80e550078cb532a34bfa2fcfdeb7d76519aecc62770f5b0e4ef8551946d8a540911abe3e7854a26f39f58b25c15342af52ae";
    let prev_out = UTXO {
        amount: 1000000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 164467
    };

    let raw_transaction_hex =
        "0x0100000001b14bdcbc3e01bdaad36cc08e81e69c82e1060bc14e518db2b49aa43ad90ba26000000000490047304402203f16c6f40162ab686621ef3000b04e75418a0c0cb2d8aebeac894ae360ac1e780220ddc15ecdfc3507ac48e1681a33eb60996631bf6bf5bc0a0682c4db743ce7ca2b01ffffffff0140420f00000000001976a914660d4ef3a743e3e696ad990364e555c271ad504b88ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);
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
    // tx: 10c61e258e0a2b19b245a96a2d0a1538fe81cd4ecd547e0a3df7ed6fd3761ada
    let prevout_pk_script =
        "0x52410496ec45f878b62c46c4be8e336dff7cc58df9b502178cc240eb3d31b1266f69f5767071aa3e017d1b82a0bb28dab5e27d4d8e9725b3e68ed5f8a2d45c730621e34104cc71eb30d653c0c3163990c47b976f3fb3f37cccdcbedb169a1dfef58bbfbfaff7d8a473e7e2e6d317b87bafe8bde97e3cf8f065dec022b51d11fcdd0d348ac4410461cbdcc5409fb4b4d42b51d33381354d80e550078cb532a34bfa2fcfdeb7d76519aecc62770f5b0e4ef8551946d8a540911abe3e7854a26f39f58b25c15342af53ae";
    let prev_out = UTXO {
        amount: 1000000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 165227
    };

    let raw_transaction_hex =
        "0x010000000139c92b102879eb95f14e7344e4dd7d481e1238b1bfb1fa0f735068d2927b231400000000910047304402208fc06d216ebb4b6a3a3e0f906e1512c372fa8a9c2a92505d04e9b451ea7acd0c0220764303bb7e514ddd77855949d941c934e9cbda8e3c3827bfdb5777477e73885b014730440220569ec6d2e81625dd18c73920e0079cdb4c1d67d3d7616759eb0c18cf566b3d3402201c60318f0a62e3ba85ca0f158d4dfe63c0779269eb6765b6fc939fc51e7a8ea901ffffffff0140787d01000000001976a914641ad5051edd97029a003fe9efb29359fcee409d88ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);
    let utxo_hints = array![prev_out];

    let res = validate::validate_p2ms(@transaction, 0, utxo_hints);
    assert!(res.is_ok(), "P2MS 2-of-3 transaction validation failed");
}

#[test]
fn test_p2ms_3_of_3() {
    // Second P2MS transaction made on 03 Feb 2012
    // tx: e8ac451e7f47d566d4dd822a67fea2181ecfa7c7ba96d9faa63e2f6b26e55fd3
    let prevout_pk_script =
        "0x534104c46d6462f67f990211d3a7077f005e67154f5f785b3edc06af3de62649a15bad35905fa7af9f272f80379a41525ad57a2245c2edc4807e3e49f43eb1c1b119794104cc71eb30d653c0c3163990c47b976f3fb3f37cccdcbedb169a1dfef58bbfbfaff7d8a473e7e2e6d317b87bafe8bde97e3cf8f065dec022b51d11fcdd0d348ac4410461cbdcc5409fb4b4d42b51d33381354d80e550078cb532a34bfa2fcfdeb7d76519aecc62770f5b0e4ef8551946d8a540911abe3e7854a26f39f58b25c15342af53ae";
    let prev_out = UTXO {
        amount: 50000000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 165224
    };

    let raw_transaction_hex =
        "0x0100000001269ca5990a6bdd62b12dc7c03d05edbb98b94742c075c44686a911df75a7ae2d00000000d9004730440220c0949354ad3a8b7162360a3b513683c417b38ea237805580d75e14950f3a4fed02206f95bc753511e96d82592b01eea4ce0f05b76d24c19e6b707a6468f1f7943a18014730440220a5f9c09fb40a6b02a7d20fcd246ba72995f34613b5afe18bd1b8b197b756aea402200511aecc66f7d7738baca0515c18444ba024d30ef304cdcf375fa163d4217b34014730440220938b9fd2b543e544eeb09abe519a1dbe900ec2761eff7277d8fea2e8397b6687022002886dd0e36aeb18c0c8752303f6898776552f7f877ff1d900d9078b26314aba01ffffffff0180f0fa02000000001976a914641ad5051edd97029a003fe9efb29359fcee409d88ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);
    let utxo_hints = array![prev_out];

    let res = validate::validate_p2ms(@transaction, 0, utxo_hints);
    assert!(res.is_ok(), "P2MS 3-of-3 transaction validation failed");
}

#[test]
fn test_p2ms_1of2_invalid_pubkey() {
    // Test case for 1-of-2 multisig with an invalid public key
    // tx: 99cb2139052dc88508f2fe35235c1c5685229a45bef3db70413c5ac43c41ca0a
    let prevout_pk_script_1of2_invalid =
        "0x5121037953dbf08030f67352134992643d033417eaa6fcfb770c038f364ff40d7615882100dd28dfb81abe444429c466a1e3ab7c22365c48f234ef0f8d40397202969d4e9552ae";
    let prev_out_1of2_invalid = UTXO {
        amount: 92750000,
        pubkey_script: hex_to_bytecode(@prevout_pk_script_1of2_invalid),
        block_height: 229517
    };

    let raw_transaction_hex =
        "0x01000000013de6aff69d5ebeca70a84d1dcef768bbcadbad210084012f8cda24233c8db278000000004b00493046022100a41a9015c847f404a14fcc81bf711ee2ce57583987948d54ebe540aafca97e0d022100d4e30d1ca42f77df8290b8975aa8fc0733d7c0cfdd5067ca516bac6c4012b47a01ffffffff01607d860500000000475121037953dbf08030f67352134992643d033417eaa6fcfb770c038f364ff40d7615882100dd28dfb81abe444429c466a1e3ab7c22365c48f234ef0f8d40397202969d4e9552ae00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);
    let utxo_hints = array![prev_out_1of2_invalid];

    let res = validate::validate_p2ms(@transaction, 0, utxo_hints);
    assert!(res.is_err(), "P2MS 1-of-2 with invalid public key should fail validation");
}

#[test]
fn test_p2ms_2_of_3_random() {
    // Random 2-of-3 multisig transaction
    // tx: 949591ad468cef5c41656c0a502d9500671ee421fadb590fbc6373000039b693
    let prevout_pk_script =
        "0x524104d81fd577272bbe73308c93009eec5dc9fc319fc1ee2e7066e17220a5d47a18314578be2faea34b9f1f8ca078f8621acd4bc22897b03daa422b9bf56646b342a24104ec3afff0b2b66e8152e9018fe3be3fc92b30bf886b3487a525997d00fd9da2d012dce5d5275854adc3106572a5d1e12d4211b228429f5a7b2f7ba92eb0475bb14104b49b496684b02855bc32f5daefa2e2e406db4418f3b86bca5195600951c7d918cdbe5e6d3736ec2abf2dd7610995c3086976b2c0c7b4e459d10b34a316d5a5e753ae";
    let prev_out = UTXO {
        amount: 1690000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 442241
    };

    let raw_transaction_hex =
        "0x010000000110a5fee9786a9d2d72c25525e52dd70cbd9035d5152fac83b62d3aa7e2301d58000000009300483045022100af204ef91b8dba5884df50f87219ccef22014c21dd05aa44470d4ed800b7f6e40220428fe058684db1bb2bfb6061bff67048592c574effc217f0d150daedcf36787601483045022100e8547aa2c2a2761a5a28806d3ae0d1bbf0aeff782f9081dfea67b86cacb321340220771a166929469c34959daf726a2ac0c253f9aff391e58a3c7cb46d8b7e0fdc4801ffffffff0180a21900000000001976a914971802edf585cdbc4e57017d6e5142515c1e502888ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);
    let utxo_hints = array![prev_out];

    let res = validate::validate_p2ms(@transaction, 0, utxo_hints);
    assert!(res.is_ok(), "Random 2-of-3 multisig transaction validation failed");
}

#[test]
fn test_p2ms_1_of_1() {
    // Test case for 1-of-1 multisig
    // tx: a38824b0a5e5aa373ab79e05b3e17d4e0cfa67908a509cf7b64314282d9aece8
    let prevout_pk_script =
        "0x51210281feb90c058c3436f8bc361930ae99fcfb530a699cdad141d7244bfcad521a1f51ae";
    let prev_out = UTXO {
        amount: 20000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 431077
    };

    let raw_transaction_hex =
        "0x01000000160bc5e16112acf01a64ab1013c7e9b34f76e2949c441ab46a086f66e9fd7a14930100000069463043021f6f7901a657289e36c25f5697a943e5013cb212ad10a2507dcace9e0e4c79230220480a8b35a574a7ba9c6073ada81c74e8e3aa63be92783211cd4dcb7d0d058346012103a2d725439d181166ac95e210f46f66c3f1088066bbfd4f534dd59488a02b4c3afffffffff3ed1ba6b8573906c810041d3418258492b1f7404656f4beb9a5adc304a5c0eb000000004746304302202ea812a99f9f8749bcd86e4e6dd0dba57fed2d7710152eec2a7688705f91cdd7021f176a029635ac01704dc425a2ba3f52e2f2290ab259a915c563be9c78083e3d01ffffffff8d68f286af7ec5a9450130f3e3c603bef4a95eaf9629b904c917d3b8f8e5486a00000000894630430220564f7beba5e28cd71fab7d3e8f359af94718938e451a653a5753896b50f87837021f32395bf3973c4b3f10ea86c7b81e38dcc2349a355ea3710d2c3bb57e8af2fb014104ab24a3241d2ab64955b9c7891fa7e7f0f5272c19db9034fdb02ef0414ab2583ea0588dabd07956b5f455e58fbf1da0c554362fc6600c3761b71aa933fd078496ffffffff1628a0ef1d36fdb5e4d16ca3768bce09328a6b8bc51c4ff37a629417454cc9560000000089463043021f0383c75fbdffb8ebc153577b4504cefe30f17969935e6cc4983adde4e069a5022070ece7763f97010534edcb6f80e1cfee88c1e30d0672cf47750c4f4e81771a2301410413c550cdb368790ba8ff0b70ac219b3016e9dcb11d8c7d62f77f94d133700e1e99f5ddfbdb8a2a2748ab2d93e1ec35c475f75e1a3a1f02bedb95ae3bdf757ed0ffffffff0bc5e16112acf01a64ab1013c7e9b34f76e2949c441ab46a086f66e9fd7a149300000000480046304302206b77a5f4395be4702a6fdf9d8233fc43ebcbb46010cba836be326cf548b9f993021f3267322bda863128d87be3cd4f3f1d3d1b4593113469bda89bd2b525b296a101ffffffffe75eb07f3d1bb6f1513555f04c58e3a41bfbac3408bdfa52ea32af01d79e1dac000000004800463043021f0ce39527434f3486c4f936f6fd8c3a3a5d7c889ee26b53be4f1302d87a82ca02202e543448f986aedc8ae72834e9ffab070267b022fada952bdcd25f2e459dbd1601ffffffffe75eb07f3d1bb6f1513555f04c58e3a41bfbac3408bdfa52ea32af01d79e1dac0100000069463043022020a90bb3d2a2056784ba36ba8582919695fc38b8a4c4809cb8d8c9b80027acff021f59c9d5a20f41debd5ba18ba1e95e458205b2b0db47a5010ae4e8b41989851101210281feb90c058c3436f8bc361930ae99fcfb530a699cdad141d7244bfcad521a1fffffffff4f29f13df6ddd7958770536d0edb19f4be03649ffa16b829f443e6536dfb333800000000474630430220345e21582d8a72ea3a4c390cfb021750147d5e490359fbcc7ef2345ee6284e90021f566b1fc655a0551383c36a5a94ad1fd44354ccbd48f1971895b6b422ba0e7301ffffffff1e563aa032652ef37a62964bda78ffa0ca97c9e644703f4494fc653f09c151e901000000480046304302203a0f649a666d4d3d5dec37cad6ff5fafea7c8767c54f6b715725bebc353176e9021f065a848bb213d0f4d0f69d156f284d25585d21bc28a288e54f15f36bb6b3bd01ffffffff1e563aa032652ef37a62964bda78ffa0ca97c9e644703f4494fc653f09c151e9020000006946304302207c4c5f02f2d8975418062107ee53d7fa9b7156437b4042deee63b38ab872a1c0021f30bf4f46ceec9c11bf72fae4fda65e57815742185264d6de872a9b6061326c01210281feb90c058c3436f8bc361930ae99fcfb530a699cdad141d7244bfcad521a1fffffffff3b8e11f993e5d512fbe70f6bd69df5510d87af895405f7bb07a3c3e5346813e6010000004800463043021f270dca121a53d5fd4a3fde799c0d24433c6893c48dae8ebfcd3675b66f06e10220183b3b56de5389fd6b5a7a71973df1a22da4c992ecc3bd32947be98b9ff9a5e601ffffffff3b8e11f993e5d512fbe70f6bd69df5510d87af895405f7bb07a3c3e5346813e60200000069463043021f34293f84b57d2805e6304d658c3764bc4da25685b0496d9c380115fcfb454b02206ae45d29bf23350371592f1bfba867b6fb2e594a4127d5f4e629ad7d4d018a4c01210281feb90c058c3436f8bc361930ae99fcfb530a699cdad141d7244bfcad521a1fffffffff288de338771ab35855db114211dc0fbbe772ad0ffba74e61ee21b5b53f8dac49010000004800463043021f6a4e7fdb0caac5b8864d0ca6b554c8bc1218df0fcefbd290e35a5659d82f85022075a2ea7b65c9eb69271179b4bf3c30a4b38b1867d1aa69059ca6073fe4317f0101ffffffff288de338771ab35855db114211dc0fbbe772ad0ffba74e61ee21b5b53f8dac4902000000694630430220478ef2590f1234e3daf0c9427ebc323d04f9ad25ddd8ea97eb51c66fa9c87e2e021f42500217ac76ce8368560e8521e58b050d62d9fd5bd40f4e8cf3acc286ebcc01210281feb90c058c3436f8bc361930ae99fcfb530a699cdad141d7244bfcad521a1fffffffff8ef083f541c2de13ae0233a35313b5c0fa936ae0f370c45077553d9508b0c71f01000000480046304302207a227400e6d30d1066a4659e5c655fc5870a12b229271bcb92c8a0fa90701604021f1e9783d80b8ef66f7a046c26022320259f1725aa9dba3549b9ecc2a3da627301ffffffff8ef083f541c2de13ae0233a35313b5c0fa936ae0f370c45077553d9508b0c71f02000000694630430220196990be449654b189ecd889240fe82d985af2cd42b690237415f3af72f507e6021f540f28bf9d553ce3d34c3e423241b498c5bfd91c69430d585811526d52570a012102c9c4ae505aeb0a50f1aa138e206c565ce6c49e0bf53d65fa1b2a8c80fd67f76cffffffff38e8175faf2547691f8fc068b7f0f55ce935f0ca5c2bb0cdb4c963c75ae7f5d60000000069463043021f432f653385412babd4a2cd040224c86b33eaaa8a0f269db23f431b3635e99102204df783d7a847551f5fd4d035e1d6fbb4f805d02e185fc0652e9948f203ce87e301210281feb90c058c3436f8bc361930ae99fcfb530a699cdad141d7244bfcad521a1fffffffff0a0ffeda5bd362eff2b94acbf57e122517d4f646fbc2905b57111c5eae41427f0000000089463043021f7bb3bc842a55b53b82390910bd1841c82dc81aec59c802f76c339bdf009e2f022042dc6eb57e126ed43d5b80645fc4403d2f139e5778e11628c65c124f8fae724b0141043f4a57ae0ab1537a4989c8364aba45f809950d233c8d517f08b040a5e9e3f5cd72c408045d551e74b9d03ec2747374c9adbf70edbdae19b97b50f08f6940b75bffffffff3087672cbdd861bd4ebad66b6d1d2cf247ba70aa11eb2042cc65f67c00ca5df500000000894630430220660ebc07d3f0e526b3ffd315009f80b3dc795bf17e95110b00250187a5aeafc0021f2e2cc2144b22cbffe429ea739a7887aa8e57fa29be7b860e8c239427563c500141043f4a57ae0ab1537a4989c8364aba45f809950d233c8d517f08b040a5e9e3f5cd72c408045d551e74b9d03ec2747374c9adbf70edbdae19b97b50f08f6940b75bffffffff68559862052c2544cda16af407017b091fd9b378c9ebeb58dd7957b6ba007aa602000000894630430220758a9dc0ff31e2876451a036491361cbc0e35b8a5239248ec163a79e7dc215c6021f0370556d36e1dc82d35aff0ea725687441d31d037d7d1573e4e01c3164ee650141043f4a57ae0ab1537a4989c8364aba45f809950d233c8d517f08b040a5e9e3f5cd72c408045d551e74b9d03ec2747374c9adbf70edbdae19b97b50f08f6940b75bffffffff04f2365e9cc619ac1b1d75b94cee48137dd559427b888d81d86fac8a5a15d0d30000000089463043021f206e176f5625b4677d616cb8a0150ca581aa368830452b2f6d09a2ce46d9cb022009bf3af7a5286bc8d93326f1de80e207021868a5acd72f24bf5ad2a3a15053e70141043f4a57ae0ab1537a4989c8364aba45f809950d233c8d517f08b040a5e9e3f5cd72c408045d551e74b9d03ec2747374c9adbf70edbdae19b97b50f08f6940b75bffffffffc7d8b5acf21826368095a66aa016566571c5c6b36ffda3d919a7c4aa756a1d8e0000000069463043021f5d87c2d418050a0f6c3c82d9924d6fe30de08577dcdfea9a0e2090cfb6001e02203d852275d29b51ef676e4ff3012a012c62f3c082aa4b842d85725f33d516ebaa012103a2d725439d181166ac95e210f46f66c3f1088066bbfd4f534dd59488a02b4c3affffffff0280c3c901000000001976a914161d7a3d0ee15c793ab300433192f949d8f3566588ac581d0909000000001976a9141c7260b625f21287e7c9c1147f2fd73ed69025a288ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);

    let res = validate::validate_transaction_at(@transaction, 0, prev_out, 5);
    assert!(res.is_ok(), "P2MS 1-of-1 transaction validation failed");
}

#[test]
#[available_gas(100_000_000_000)]
fn test_p2ms_20_of_20() {
    // Test case for 20-of-20 multisig
    // tx: da738e29f64e90ae46dcc3e6b4154041d6324abbe7919e722d486a4a3148b7dc
    let prevout_pk_script =
        "0x0114410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc3455410478d430274f8c5ec1321338151e9f27f4c676a008bdf8638d07c0b6be9ab35c71a1518063243acd4dfe96b66e3f2ec8013c8e072cd09b3834a19f81f659cc34550114ae";
    let prev_out = UTXO {
        amount: 2201000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 284029
    };

    let raw_transaction_hex =
        "0x0100000001bbb397fdf39cf8b14a49148861c751543172a6f6500e679e079a7aecfbf7aac400000000fdb50500483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401483045022100e222a0a6816475d85ad28fbeb66e97c931081076dc9655da3afc6c1d81b43f9802204681f9ea9d52a31c9c47cf78b71410ecae6188d7c31495f5f1adfe0df5864a7401ffffffff0180841e00000000001976a9144663e5aab48b092c7478620d867ef2976bce149a88ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let transaction = EngineInternalTransactionTrait::deserialize(
        raw_transaction, array![prev_out]
    );

    let res = validate::validate_transaction(@transaction, 0);
    assert!(res.is_ok(), "P2MS 20-of-20 transaction validation failed");
}
