use shinigami_engine::transaction::EngineInternalTransactionTrait;
use shinigami_engine::engine::EngineImpl;
use shinigami_engine::hash_cache::HashCacheImpl;
use crate::utxo::UTXO;
use crate::validate::validate_p2sh;
use shinigami_utils::bytecode::hex_to_bytecode;


#[test]
fn test_p2sh_transaction_1() {
//https://learnmeabitcoin.com/explorer/tx/4d8eabfc8e6c266fb0ccd815d37dd69246da634df0effd5a5c922e4ec37880f6 
     let raw_transaction_hex =
            "0x0100000003a5ee1a0fd80dfbc3142df136ab56e082b799c13aa977c048bdf8f61bd158652c000000006b48304502203b0160de302cded63589a88214fe499a25aa1d86a2ea09129945cd632476a12c022100c77727daf0718307e184d55df620510cf96d4b5814ae3258519c0482c1ca82fa0121024f4102c1f1cf662bf99f2b034eb03edd4e6c96793cb9445ff519aab580649120ffffffff0fce901eb7b7551ba5f414735ff93b83a2a57403df11059ec88245fba2aaf1a0000000006a47304402204089adb8a1de1a9e22aa43b94d54f1e54dc9bea745d57df1a633e03dd9ede3c2022037d1e53e911ed7212186028f2e085f70524930e22eb6184af090ba4ab779a5b90121030644cb394bf381dbec91680bdf1be1986ad93cfb35603697353199fb285a119effffffff0fce901eb7b7551ba5f414735ff93b83a2a57403df11059ec88245fba2aaf1a0010000009300493046022100a07b2821f96658c938fa9c68950af0e69f3b2ce5f8258b3a6ad254d4bc73e11e022100e82fab8df3f7e7a28e91b3609f91e8ebf663af3a4dc2fd2abd954301a5da67e701475121022afc20bf379bc96a2f4e9e63ffceb8652b2b6a097f63fbee6ecec2a49a48010e2103a767c7221e9f15f870f1ad9311f5ab937d79fcaeee15bb2c722bca515581b4c052aeffffffff02a3b81b00000000001976a914ea00917f128f569cbdf79da5efcd9001671ab52c88ac80969800000000001976a9143dec0ead289be1afa8da127a7dbdd425a05e25f688ac00000000";
        let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
        let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);
        
        
        let prevout_pubkey="0xa914748284390f9e263a4b766a75d0633c50426eb87587";
        let prev_out_1of2_invalid = UTXO {
            amount: 10000000,
            pubkey_script: hex_to_bytecode(@prevout_pubkey),
            block_height: 177625
        };

         let utxo_hints = array![prev_out_1of2_invalid];

     let res = validate_p2sh(@transaction, 0, utxo_hints, 2);
     assert!(res.is_ok(), "P2SH failed!:{:?}",res.unwrap_err());
}

#[test]
fn test_p2sh_transaction_2() {
//https://learnmeabitcoin.com/explorer/tx/7edb32d4ffd7a385b763c7a8e56b6358bcd729e747290624e18acdbe6209fc45 
     let raw_transaction_hex =
            "0x0100000001c8cc2b56525e734ff63a13bc6ad06a9e5664df8c67632253a8e36017aee3ee40000000009000483045022100ad0851c69dd756b45190b5a8e97cb4ac3c2b0fa2f2aae23aed6ca97ab33bf88302200b248593abc1259512793e7dea61036c601775ebb23640a0120b0dba2c34b79001455141042f90074d7a5bf30c72cf3a8dfd1381bdbd30407010e878f3a11269d5f74a58788505cdca22ea6eab7cfb40dc0e07aba200424ab0d79122a653ad0c7ec9896bdf51aefeffffff0120f40e00000000001976a9141d30342095961d951d306845ef98ac08474b36a088aca7270400";
        let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
        let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);
        
        let prevout_pubkey="0xa914e9c3dd0c07aac76179ebc76a6c78d4d67c6c160a87";

        let prev_out_1of2_invalid = UTXO {
            amount: 990000,
            pubkey_script: hex_to_bytecode(@prevout_pubkey),
            block_height: 272298
        };

         let utxo_hints = array![prev_out_1of2_invalid];

     let res = validate_p2sh(@transaction, 0, utxo_hints, 0);
     assert!(res.is_ok(), "P2SH failed!:{:?}",res.unwrap_err());
}


#[test]
fn test_p2sh_transaction_3() {
//https://learnmeabitcoin.com/explorer/tx/30c239f3ae062c5f1151476005fd0057adfa6922de1b38d0f11eb657a8157b30
     let raw_transaction_hex =
            "0x010000000c3e10e0814786d6e02dfab4e2569d01a63191b8449bb0f5b9af580fc754ae83b9000000006c493046022100b387bc213db8a333f737e7e6b47ac5e56ba707e97682c1d6ae1d01e28fcfba620221009b7651bbf054babce6884937d598f845f533bac5dc0ec235b0e3408532b9c6e101210308b4492122999b36c09e50121544aa402cef45cd41970f1be6b71dcbd092a35effffffff40629a5c656e8a9fb80ae8a5d55b80fbb598a059bad06c50fcddf404e932d59e000000006a473044022011097b0f58e39fe1f0df7b3159456b12c3b244dcdf6a0fd138ec17d76d41eb5c02202fb5e7cec4f2efbcc90989693b7b6309fcaa27d6aac71eb3dcef60e27a7e7357012103c241a14762ef670d96c0afa470463512f5f356e0752216d34d55b6bfa38acd93ffffffff5763070e224f18dbc8211e60c05ae31543958b248eb08c9e5989167c60b3c570000000006c49304602210088db31bb970f2e77a745d15b8a31d64734c8a9eca3a24540ffa850c90f8a6f50022100bc43eb2a20d70da74cfb2be8eee69c0c1adf741130792aa882a0cda9f7df4b6f012102b5e2177732d3f19abd0e15ac5ff2d5546f70e3f91674b110ccdee8458554f1acffffffff5b4e96a245f6fbc2efb910e25e9dd7a26e0ef8486eebd50dc658ae7d9719e5fd000000006a4730440220656be7132d238e4a848f0da1c3bdc0e22b475e1b66011e1b0536e18cbfe553f502205c89da6c8dad09f5e171404bf66fc19c7d5d2066d4ff4eff3f0766d31688cc4d012102086323b48e87d7fcacb014a58889f20a9881956bf46898c4ffda84b23c965d31ffffffff6889fe551cb869bf20284c64fc3adc229fded6e11fc8b79ec11bb2e499bd0d6c290000006a4730440220226d97d92d855bb2dad731b0cf339727e0f4449c89b1cc1cff7a9432db2a53fb02203478f549e5997b0dccd6abbc5bb206ce40f706672e27b58e3bab210da105dbcf012103c241a14762ef670d96c0afa470463512f5f356e0752216d34d55b6bfa38acd93ffffffff6a1c310490053bfc791ec646907941d3df59bfa8db1b21789d8780c7489695c1000000006a473044022079913e50a223d46c3800f33a6071651aabeecbcc7c726a78aca04dd2832ebe92022075275dbfadcfcca48fa834e7130d24b1055e9ee1470e0bf7ecdf0d9091b27fdc012102fbb8f0fcb28163dd56e26fd7d4b85b71016e62696e577057ddeac36d08a03e26ffffffff79d87f7daedaee7c6e80059b38cde214fec5e4546fbdccc7c24c01c47dce1c23200000008c493046022100ec02daed0c2ab978f588a0486deef52e62b6aa82297b994fe5486d79f8457acb02210098750e260959d6bbd4d47a018b27ea15493d4cd4cb7c96136282745c41aa1c9b014104658e3e86e3740257ebf67085deb14b877955aac502a6b5dcec0cfe1f3026f27b3a772a189b1bb2c28d026bc626a48710edffa9d40830286b80b3ac5709509974ffffffff9a19e8ede8836c192fe816d80d392bb7bb5453f320a78854a83e46bd9f27bf1e000000006c4930460221008b06d1813afd4f368a9570405df7978dca0b4400d173c937931942d88776bfa4022100a7a85b09e50e12e474b634a22fbe6645227dc13cbba2aaa2a84bb1da5e1dc2f1012103c241a14762ef670d96c0afa470463512f5f356e0752216d34d55b6bfa38acd93ffffffffd3090eb0855eee3d1dba53d68edeca6c368a37d3bba9579da3ac675ece42d7680e0000008a47304402204e2518419626eb846e0ef96fb7eda1d7b954b2821482b771f372484c0e327e560220370108f1a7b4676973585c861f5365d8fc2b2b170d922d6fccb15216976a82f80141044884e2974c370394aae8121735a56eaa7215a6a46661f1ca9454c1b99611ae34903e9515b2902f2a22104d10bfd1c2303b38a14be5f2b62b0591ca0d8bbb6864fffffffff61ff40c78b3e12e7d1f9a9db04a7b7736510014fc15a950d575c159b4b0b7a5000000008c493046022100b9b7c3ac969ee98295ec063c84f05c4bf4ee0d4c25448847d44c8e4af3425af7022100cfc90b396f524c366d66a44fa77502dd6f338a584ce653332bcb8909d14360c00141048501beadf835ce4da4078dce8a9dd57964f91da9d675b3d23d45f0de71a03b24d0daf75f29cd521531d5b4389331fe6891e7e1214710cf73e7dbc91cd41cfcecffffffff4471e66e1622bf197ba49ab31d1bd29b4917af60ce103bb6713ffb709b300c45000000006b483045022100a84f83410eb3b40959830b444a85dc1251486afa6e27288bd22fb5771d09795302207d604b1d1c3f8f2d3a9c2ee1007f6b034f69339d0de4f567c12f54af14e208b6012102cbac13c0b22e24ab33131c69e36bdbbe0218cd7f43dcbf9a4b488aadc8ac23b4ffffffff4471e66e1622bf197ba49ab31d1bd29b4917af60ce103bb6713ffb709b300c45010000009100473044022100d0ed946330182916da16a6149cd313a4b1a7b41591ee52fb3e79d64e36139d66021f6ccf173040ef24cb45c4db3e9c771c938a1ba2cf8d2404416f70886e360af401475121022afc20bf379bc96a2f4e9e63ffceb8652b2b6a097f63fbee6ecec2a49a48010e2103a767c7221e9f15f870f1ad9311f5ab937d79fcaeee15bb2c722bca515581b4c052aeffffffff0196e756080000000017a914748284390f9e263a4b766a75d0633c50426eb8758700000000";
        let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
        let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);
        
        
        let prevout_pubkey="0xa914748284390f9e263a4b766a75d0633c50426eb87587";

        let prev_out = UTXO {
            amount: 10000000,
            pubkey_script: hex_to_bytecode(@prevout_pubkey),
            block_height: 183729
        };

         let utxo_hints = array![prev_out];

     let res = validate_p2sh(@transaction, 0, utxo_hints, 11);
     assert!(res.is_ok(), "P2SH failed!:{:?}",res.unwrap_err());
}

//fails: transaction not able to deserialize
#[test]
fn test_p2sh_transaction_4() {
//https://learnmeabitcoin.com/explorer/tx/cc11ca9e9dc188663c41eb23b15370f68eded56b7ec54dd5bc4f2d2ae93addb2
     let raw_transaction_hex =
            "0x010000000113fc91b458c8ed3a826cfc984ab454246036f91a4beafb56b88b115e8db1add300000000fd5f0100483044022018b88c05ab571cf31bf317a98ed5909cf43218f472bfbeb82b6857d3b1edf4ee0220686627e66b368e298114a097b5814a76fdaac23f7728a42d38415552ba68c8220101493046022100b7a70f4c3b2b5d24475f9664bb77b6046c0251c89b446aad8a86b584b74ed414022100d53dd27b741801a908fdf7c2ee259f444f549b56d7a6c682599ef67b1edb6d24014cc9524104f3d35132084eb1b99b6506178c20adb42d26296012e452e392689bdb6553db33ba24b900000892805de1646821c7b0fb50b3d879c26e2b493b7041e6215356a04104ab4ecc9e8ea2da0562af25bcaede00c4d5a00db60edc17672376decf0a35a34fdc9f1ffad1fb74fd7b1b198b9231c25df88e0769bec49975649b4b3f40adafb04104f7149f270717c00f6cc09b9ce3c22791c4aab1af40a5107aacca85b6f644cc0d84459e308f998d801b8d9d355f8ec33b0e41866841e2870754cf667a9821703d53aeffffffff0140fa97000000000017a9146ebdbaf0840274a6b23b0643b75ef4e8e24f37b88700000000";
        let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
        println!("running");
        let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);
        println!("running2");
        println!("{:?}",transaction.print());
        
        let prevout_pubkey="0xa914b4acb9d78d6a6256964a60484c95de490eaaae7587";

        let prev_out = UTXO {
            amount: 9980000,
            pubkey_script: hex_to_bytecode(@prevout_pubkey),
            block_height: 232595
        };

         let utxo_hints = array![prev_out];

     let res = validate_p2sh(@transaction, 0, utxo_hints, 0);
     assert!(res.is_ok(), "P2SH failed!:{:?}",res.unwrap_err());
}

#[test]
fn test_p2sh_transaction_5() {
//https://learnmeabitcoin.com/explorer/tx/09afa3b1393f99bb01aa754dd4b89293fd8d6c9741488b537d14f7f81de1450e
     let raw_transaction_hex =
            "0x01000000017fa897c3556271c34cb28c03c196c2d912093264c9d293cb4980a2635474467d010000000f5355540b6f93598893578893588851ffffffff01501e0000000000001976a914aa2482ce71d219018ef334f6cc551ee88abd920888ac00000000";
        let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
       
        let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction);
        
        let prevout_pubkey="0xa914da5a92e670a66538be1c550af352646000b2367d87";

        let prev_out = UTXO {
            amount: 10000,
            pubkey_script: hex_to_bytecode(@prevout_pubkey),
            block_height: 384639
        };

         let utxo_hints = array![prev_out];

     let res = validate_p2sh(@transaction, 0, utxo_hints, 0);
     assert!(res.is_ok(), "P2SH failed!:{:?}",res.unwrap_err());
}
