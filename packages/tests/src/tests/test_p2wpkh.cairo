use shinigami_engine::transaction::{UTXO, EngineInternalTransactionTrait};
use crate::validate;
use shinigami_utils::bytecode::hex_to_bytecode;
use shinigami_engine::flags::ScriptFlags;

#[test]
fn test_p2wpkh_create_transaction() {
    // https://learnmeabitcoin.com/explorer/tx/c178d8dacdfb989f9d4fa45828ed188cd54a0414d625c3e61e75c5e3ac15a83a
    let raw_transaction_hex =
        "0x020000000001016972546966be990440a0665b73d0f4c3c942592d1f64d1033717aaa3e2c2ec913300000000ffffffff024087100000000000160014841b80d2cc75f5345c482af96294d04fdd66b2b760e31600000000001600142e8734f8e263e516d47fcaa2dfe1bd01e0dc935802473044022042e5e3ed2a41214ae864634b6fde33ca2ff312f3d89d6aa3e14c026d50d8ed3202206c38dcd0432a0724490356fbf599cdae40e334c3667a9253f8f4cc57cf3c4480012103f465315805ed271eb972e43d84d2a9e19494d10151d9f6adb32b8534bfd764ab00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let prevout_script = "0x0014841b80d2cc75f5345c482af96294d04fdd66b2b7";
    let prevout = UTXO {
        amount: 2595489, pubkey_script: hex_to_bytecode(@prevout_script), block_height: 680226,
    };

    let utxo_hints = array![prevout];
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);
    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into() | ScriptFlags::ScriptBip16.into();

    let res = validate::validate_transaction(@transaction, flags);

    assert!(res.is_ok(), "Transaction validation failed");
}

#[test]
fn test_p2wpkh_unlock_transaction() {
    // https://learnmeabitcoin.com/explorer/tx/1674761a2b5cb6c7ea39ef58483433e8735e732f5d5815c9ef90523a91ed34a6
    let raw_transaction_hex =
        "0x020000000001013aa815ace3c5751ee6c325d614044ad58c18ed2858a44f9d9f98fbcddad878c10000000000ffffffff01344d10000000000016001430cd68883f558464ec7939d9f960956422018f0702483045022100c7fb3bd38bdceb315a28a0793d85f31e4e1d9983122b4a5de741d6ddca5caf8202207b2821abd7a1a2157a9d5e69d2fdba3502b0a96be809c34981f8445555bdafdb012103f465315805ed271eb972e43d84d2a9e19494d10151d9f6adb32b8534bfd764ab00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let prevout_script = "0x0014841b80d2cc75f5345c482af96294d04fdd66b2b7";
    let prevout = UTXO {
        amount: 1083200, pubkey_script: hex_to_bytecode(@prevout_script), block_height: 681995,
    };

    let utxo_hints = array![prevout];
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);
    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into() | ScriptFlags::ScriptBip16.into();

    let res = validate::validate_transaction(@transaction, flags);

    assert!(res.is_ok(), "Transaction validation failed");
}

#[test]
fn test_p2wpkh_first_transaction() {
    // https://learnmeabitcoin.com/explorer/tx/dfcec48bb8491856c353306ab5febeb7e99e4d783eedf3de98f3ee0812b92bad
    let raw_transaction_hex =
        "0x010000000001017405e391018c5e9dc79f324f9607c9c46d21b02f66dabaa870b4add871d6379f01000000171600148d7a0a3461e3891723e5fdf8129caa0075060cffffffffff01fcf60200000000001600148d7a0a3461e3891723e5fdf8129caa0075060cff0248304502210088025cffdaf69d310c6fed11832edd9c19b6a912c132262701ad0e6133227d9202207d73bbf777abd2aeae995d684e6bb1a048c5ac722e16de48bdd35643df7decf001210283409659355b6d1cc3c32decd5d561abaac86c37a353b52895a5e6c196d6f44800000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let prevout_script = "0xa914811ee2fb2d0c96b478992e1c07320b253ef3ee2687";
    let prevout = UTXO {
        amount: 224000, pubkey_script: hex_to_bytecode(@prevout_script), block_height: 481819,
    };

    let utxo_hints = array![prevout];
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);
    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into() | ScriptFlags::ScriptBip16.into();

    let res = validate::validate_transaction(@transaction, flags);
    assert!(res.is_ok(), "P2WPKH Transaction validation failed");
}

#[test]
fn test_p2wpkh_first_witness_spend() {
    // https://learnmeabitcoin.com/explorer/tx/f91d0a8a78462bc59398f2c5d7a84fcff491c26ba54c4833478b202796c8aafd
    let raw_transaction_hex =
        "0x01000000000101ad2bb91208eef398def3ed3e784d9ee9b7befeb56a3053c3561849b88bc4cedf0000000000ffffffff037a3e0100000000001600148d7a0a3461e3891723e5fdf8129caa0075060cff7a3e0100000000001600148d7a0a3461e3891723e5fdf8129caa0075060cff0000000000000000256a2342697462616e6b20496e632e204a6170616e20737570706f727473205365675769742102483045022100a6e33a7aff720ba9f33a0a8346a16fdd022196862796d511d31978c40c9ad48b02206fb8f67bd699a8c952b3386a81d122c366d2d36cd08e2de21207e6aa6f96ce9501210283409659355b6d1cc3c32decd5d561abaac86c37a353b52895a5e6c196d6f44800000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let prevout_script = "0x00148d7a0a3461e3891723e5fdf8129caa0075060cff";
    let prevout = UTXO {
        amount: 194300, pubkey_script: hex_to_bytecode(@prevout_script), block_height: 481824,
    };
    let utxo_hints = array![prevout];
    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into() | ScriptFlags::ScriptBip16.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags);
    assert!(res.is_ok(), "P2WPKH first follow-up spend witness validation failed");
}

#[test]
fn test_p2wpkh_uncompressed_key_scriptpubkey_validation() {
    // https://learnmeabitcoin.com/explorer/tx/7c53ba0f1fc65f021749cac6a9c163e499fcb2e539b08c040802be55c33d32fe
    let raw_transaction_hex =
        "0x020000000122998d36f7953b150106cfa0a8722b51309c3eca93256e3a2402e14083fe8db2010000006a473044022076a81ac13cf50982401b0ef7fef518d5f72ffa6a7f95175c9bc16b0d57c4cc3e02202dce5bb27c1bc390d6a120806a0bbe2d8dd682918dc050d374ad29f2aba67703012102ee49077747264b56032c80bc588c7fb724f282bf8969e5efef3030770d4aaf2affffffff01905f010000000000160014671041727b982843f7e3db4669c2f542e05096fb00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let prevout_script = "0x76a9149acd0fbc308ea273b61bad6322a17c8a7694845d88ac";
    let prevout = UTXO {
        amount: 100000, pubkey_script: hex_to_bytecode(@prevout_script), block_height: 801368,
    };

    let utxo_hints = array![prevout];
    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into() | ScriptFlags::ScriptBip16.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags);
    assert!(res.is_ok(), "P2WPKH uncompressed key ScriptPubKey validation failed");
}

#[test]
fn test_p2wpkh_witness_2_inputs() {
    // https://learnmeabitcoin.com/explorer/tx/56f9d30585cc95e7966c486226f4da03020062fc75e655ed374452aafde03272
    let raw_transaction_hex =
        "0x02000000000102deefe06aa69f80ad316550aeb7a4b8fe279bb0181d71e3a43b234a5f931eb6cd0100000000ffffffffd8ed5ef7e0afcffa1716b4d470e6dafd8305137081369c301d71d366e195b00b0200000000ffffffff0400000000000000000c6a5d0900c0a2331ca2dc0f022202000000000000160014979bdd94f2d5972c062a7839ef114c193eca970a2202000000000000225120a365ace264b94ec9b2b2241ba41b3ab1ab016350658486f0fd42a978e90ab9f92f0e460000000000160014d58d2895ae676864b28af1d980c797d83f4d781f0247304402202f99c628b507bfe95b525e54d2649a8382e8d9c97bb7da93e83040753a577ed602200d0f5e0c9c366ba1ecbff1869b1d9c0e2278ba5a70457ecc40b2f935537f2e3e0121035a26b0237c4df831928d00bd8df3d5221fdb34062897b27c6dc466d767a86e1702473044022074dabb4f9613706b568a97af03f7c9666df1cf3dc8d78dc61519033b18773caf022025df383ec808080ac125682c83327131f76aace608989f26ed8bbb2bdd7886c0012103497a874c3412319689cc435756a820c3cf4cbb22d88ccafa29a8dc5e74eaa53800000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let utxo_hints = array![
        UTXO {
            amount: 546,
            pubkey_script: hex_to_bytecode(@"0x0014979bdd94f2d5972c062a7839ef114c193eca970a"),
            block_height: 880786,
        },
        UTXO {
            amount: 4599697,
            pubkey_script: hex_to_bytecode(@"0x0014d58d2895ae676864b28af1d980c797d83f4d781f"),
            block_height: 880782,
        },
    ];
    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into() | ScriptFlags::ScriptBip16.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags);
    assert!(res.is_ok(), "P2WPKH witness 2 inputs validation failed");
}

#[test]
fn test_p2wpkh_15_inputs_nested() { // d38c7541b88af8af648e780ce7f92ee7041d7b960b16faec84bd6689beb8aeed
}

//ok (gas usage est.: 3192030989)
//ok (gas usage est.: 2146289982)
#[test]
fn test_p2wpkh_22inputs() {
    // https://learnmeabitcoin.com/explorer/tx/90789187c53b3802c7c2699e022cdef466d85e395bb5053c0f90432de6fa60ca
    let raw_transaction_hex =
        "0x0100000000011697fe4526c3870632b15620aa192c7a4944696cd4a49786118178069d401540f40100000000ffffffff0de959b5fab905118df123e303556d5093afbdf2ffc337b07886da182ff9ba880100000000ffffffff5475b73e980b22beb8d673775fff4254d1e512a2faa9dc83830a294d3624c37f0100000000ffffffff08705ae2b312006685297cbdfc91e1cee9243807af8aa479118f7ef1af686ac70100000000ffffffff228c5559aa7a11a46017a71075f38420021d57f4b56438b6324645af140d9de80100000000ffffffffb3cfec275ae024dc5f56d8e38523f7bdd0d9606c8d155b15e33a95f09c3cdd3b0100000000ffffffffe377da329a1335aae7c95ed18a4b09fe76474da6712a224d63d997a56e32511e0100000000ffffffffb8a1eb6d48e8193a166a8128a8139f9d6bdff6bef97a24feb5ca1c5297565def0100000000ffffffff0fd85772b5f737978f3ea94bf72b840d3e8ea0d87b913c284ae2d830f21300260100000000ffffffffc4ab74d83f9567ef610dda0cdd9799289244c7962af0bd96ddd141635772eccc0100000000ffffffff948828e5c10fd0eafb604894fef7572ab22b7ee2358b8e199826a04ab6b1f4030100000000fffffffffe15838e6eb0ca5c6fa93867af51f7d8f37a247b5634f348981e9cf2fb2bbf4a0100000000ffffffff71019329e62b3b7b83e376acad51ced99082932b9e7c315c2e53f096172903910100000000ffffffff5bb2c4f02c52e7c6090b01ca7e9407bb373725a39a7a71dc57da5d0084d1d38d0100000000ffffffff96d3f83230a46102cdb345def84ecf0085325ef9f3d69f596d1d539bab827af00100000000ffffffffbf9d767ac7f5d1c475d5ad3a08b44f6f25f16645bfa3ef5fb546deb5cc1c4f430100000000ffffffff69706388b9e44e486c87f836320af3c32788d2a763b2ae8951701af6b34abba50100000000ffffffffbd89ab4ce44e7ef9e5b723649d9db2b464d7cc046f030c2a85817d72908f17f70100000000ffffffffc5d0c328bf3987780c3f45d8a8e24acfcf138436f8fac01fbae1ca24d73fcdb00100000000ffffffff742376eb55c5564f3cc3740ccc7bf251d8c2e4c7e96cac1763a329d548f63b180100000000ffffffff9bf8c35768d8a0764032c95ec119319a4a8260e5e140c9fac3a3fa56effe093c0100000000ffffffff5b6ad6b0f829a62a3588f6f34041f0a5a663086fa8a0cce146fad813199064fb0100000000ffffffff02ba7f040000000000160014871c2c320ac0c3bb6069d5969d0629be2776b5eb051c000000000000160014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05024830450221009fdb8dfff0563f29c63aea841fb7f02fe1e0a3957d62c65f39b15dfd9d52557b02201f52af258dd879e2825401fed5a97e2c8c0532f5723ec04ba0d5b0ea3eb8a92e0121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e2402473044022042d3e89e9786d57973a7d1a228d41605cdba75d05c519b76c83297e2db00aef5022057b61e8c6f67713db92158c4c1dfb3bad7e780b706095ca19d8159052522a6120121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e2402473044022078f486e7ec56915f22bb4d7721c0efb877f84926a1c166c7bcb41acc690aaa4202207a8f01bbbae9bd7ea7532542b4dfc8c1e06189d5d67533f08a72be0c8d590c710121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e2402473044022023bb66589b9b24ccc85802ffea81ca014a34b905245b17d574d01efa4b9578c602204744119909b19213b3d9ec856ea32d616dd40f003cc018008a321e52bdf7f4150121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e24024730440220606a9ebfcb77bf8313ee8bd4985091d4e1f87e167829de62503839dbed08d45802201c95468719196f4133bcc153981c06fbd5c4bff6a8e016ceec0afc3902e446540121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e2402473044022017165749cab84361872582c299214d6ee93f25adee431d7cc7e10b2ec84f624c022073c5cf5c5e96078f1d91dd174a554e209146010a6f3abc4b81480ba3877687990121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e240247304402207de5f3f43f5caeb59cedcb1094317a4bf5de4c65891639a79d15d2b4606fb0480220722cbabf99a75e5441cee3e1c6ae4e99bfeac3d6779be633e7094e4b769d2b270121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e240248304502210084e6876590803196112633dedbcf480c2b75871f440583fdfd3759553ab04dbb02205fec4e4ab0b7f4bf6fec325e550880327707728a67a98a99eb8916c5f2ed793d0121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e2402473044022077181f1c474d51471646d9bc8121e40a1e99bb90855ccb190a0a411abc9b837202204eaa9534e8dcc33cdede8d95f03deb86c943546999a00ab9837d6e87307189630121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e240247304402204490eb986989ed13afb14b7fc19a7814e0415e9f6067f4e88550e96a9cc6807d02203be2f9e523edae0c24ecace7a0ac558d8c6dd07a86c3ed73ae947626f5d797a00121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e240247304402204fcaad7b469a618333712dd5746d781a87a4a88e3bd7588c55a336d0657e7d940220600f8b8d30ad67ab5e8b37fd91d1432923d91b1a5a00069ea8967c4b401320c80121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e2402473044022100d75e00d7153e92f83cab3fde24e580d8f478fde5b34c6004e672546ece33b3b5021f136702f6196fd7c7b8d56d625c9bf5fe3fce44f4695a4260d299d7e8a9e5830121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e240247304402200d960465363e0c431fbd625d25874b86fc5c2efa240a0d284614d8e4e90207b602201bc75e71aaa5afd41fcc8b1a1f22ca5fc201843eeb16225b92ac50f7c6b126230121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e2402483045022100e1a69147aa24dbdda21ddb5059a9102f23b5c7b17361d46602e78e0b8659449602203043e2bcd1b6aefd44907812d5c1142a9d81539955db975f2c364050f7607ca10121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e2402483045022100add73f5021de94725d0038c4df709b6ba7bc0d1022e754049b08290987e8d82302207a8a993db9717bc807eb187d8519b085ab91026bb701cda0c0f6a0d9d3e16fc10121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e2402473044022072a74424eeb20ef60cf14f974e3f5561330825bf516a9c466274803fca1d3c7a02204eac147ea28b745c85610da1791b5a150c2e13b19a109d3001281bb3442ece070121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e2402483045022100d04e0eea25df44fbc678584043d786a04d466131f6d5cb761f38cec66a4ba13402205d1f0493a6009b31dccb7fed8e2d31185766870c16c40c5ddc0dbf0a81fcde410121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e2402483045022100b10d1420797de6e421fb7754c5c5e477f03ef609a35e7ec284a1c623922fbf910220593f7b2c5d3210dc7fa415cbd371da12950512f9050ffea78946a3f9bf27d11a0121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e240247304402203429b072cb14c9780d0d3e9dd1d8317206b9cda44ef9a00fbd47d860e38db8a30220747757d59495ea5ba8728695f33c5c6b037d26fff47835036e16a9604f6aec1d0121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e2402483045022100f6a122dd1b07e5e58c312ce814db33f94ed45b492cdc621b3c8497ad44b91b6902200a4d0edb2447e9adc4d92e40a8aad38dbd32f47e592340733601165dc1db1e2e0121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e240247304402206cf209e3bb98f92e4dcafaa6f29fe55588bdf2e3e93317a1ce3fd02368f2bc81022041add1c7851364352aaf460bd04cb05698d975a58dcf32965d6d983e826086eb0121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e2402483045022100c8fbb447a7ee6ad38cb6a080dba7ba5eeb3324e307112ad9d2038ea94e12e906022021c9ded1105c7dc8ae551c210d9c9f3c461c8c1ffeb0d722935578a192382c0e0121033669ed2cbe07aff6c24659c41bf90d6c01e7c8d736abda6575a0f38afd175e2400000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let utxo_hints = array![
        UTXO {
            amount: 5540,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 872397,
        },
        UTXO {
            amount: 5683,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 878913,
        },
        UTXO {
            amount: 5798,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 879202,
        },
        UTXO {
            amount: 6579,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 870372,
        },
        UTXO {
            amount: 7201,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 877800,
        },
        UTXO {
            amount: 7929,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 871463,
        },
        UTXO {
            amount: 8884,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
        UTXO {
            amount: 9169,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
        UTXO {
            amount: 9405,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
        UTXO {
            amount: 9476,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
        UTXO {
            amount: 10673,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
        UTXO {
            amount: 11136,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
        UTXO {
            amount: 12653,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
        UTXO {
            amount: 14386,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
        UTXO {
            amount: 14873,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
        UTXO {
            amount: 15078,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
        UTXO {
            amount: 16961,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
        UTXO {
            amount: 20442,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
        UTXO {
            amount: 21459,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
        UTXO {
            amount: 22133,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
        UTXO {
            amount: 22880,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
        UTXO {
            amount: 51522,
            pubkey_script: hex_to_bytecode(@"0x0014414e3d2b4339a60557c54aa10bdfefaa5cc2bd05"),
            block_height: 1,
        },
    ];
    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into() | ScriptFlags::ScriptBip16.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags);
    assert!(res.is_ok(), "P2WPKH witness 22 inputs validation failed");
}
