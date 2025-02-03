use shinigami_engine::transaction::{UTXO, EngineInternalTransactionTrait};
use shinigami_engine::flags::ScriptFlags;

use crate::validate;
use shinigami_utils::bytecode::hex_to_bytecode;

#[test]
fn test_p2tr_random() {
    // https://learnmeabitcoin.com/explorer/tx/fa7eb13f6d854ed32ef284983c620f74050dd6d119dc9e91ad09c083b0267f8f
    // input 1
    let raw_transaction_hex =
        "0x02000000000102c343d8dff98f817e9c2bd6d951e5ebc401ae0c6f60bb47e52e24846ae961e2f80000000000ffffffff20575041a5431f83a3d99f40816df85191a21a55155d1b862124e4c7447604880100000000ffffffff01801a00000000000022512021ecac4e3b7a2414b7c0718b80dccdc169c3caf3f2cc7727084e4c4fd2d3179602210249a825dd1e0c90daf615859baf41e34148f5c69b085408a294f0f277246223a70c093006020104020104017cac03010302538781c1a2fc329a085d8cfc4fa28795993d7b666cee024e94c40115141b8e9be4a29fa41324300a84045033ec539f60c70d582c48b9acf04150da091694d83171b44ec9bf2c4bf1ca72f7b8538e9df9bdfd3ba4c305ad11587f12bbfafa00d58ad6051d54962df196af2827a86f4bde3cf7d7c1a9dcb6e17f660badefbc892309bb145f00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let utxo_hints = array![
        UTXO {
            amount: 679,
            pubkey_script: hex_to_bytecode(
                @"0x00209848acb6efe9e969fa076ea2802b5573143d74e601802ffe66909a2a1c471053",
            ),
            block_height: 872044,
        },
        UTXO {
            amount: 10000,
            pubkey_script: hex_to_bytecode(
                @"0x5120562529047f476b9a833a5a780a75845ec32980330d76d1ac9f351dc76bce5d72",
            ),
            block_height: 872044,
        },
    ]
        .span();

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed: {}", res.unwrap_err());
}

#[test]
fn test_p2tr_script_key_path_spend() {
    /// https://learnmeabitcoin.com/explorer/tx/091d2aaadc409298fd8353a4cd94c319481a0b4623fb00872fe240448e93fcbe#input-0
    let raw_transaction_hex =
        "0x02000000000101ec9016580d98a93909faf9d2f431e74f781b438d81372bb6aab4db67725c11a70000000000ffffffff0110270000000000001600144e44ca792ce545acba99d41304460dd1f53be3840141b693a0797b24bae12ed0516a2f5ba765618dca89b75e498ba5b745b71644362298a45ca39230d10a02ee6290a91cebf9839600f7e35158a447ea182ea0e022ae0100000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let utxo_hints = array![
        UTXO {
            amount: 20000,
            pubkey_script: hex_to_bytecode(
                @"0x51200f0c8db753acbd17343a39c2f3f4e35e4be6da749f9e35137ab220e7b238a667",
            ),
            block_height: 861957,
        },
    ]
        .span();

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed: {}", res.unwrap_err());
}

#[test]
fn test_p2tr_script_path_spend_simple() {
    /// https://learnmeabitcoin.com/explorer/tx/5ff05f74d385bd39e344329330461f74b390c1b5ead87c4f51b40c555b75719d#input-1
    let raw_transaction_hex =
        "0x02000000000102c20da20832c3894854dc63f69cf7fe805323b3d476aaa8e730244b36a575d2440000000000ffffffff87adaa9d7302d05896b0d491a099208c20ea0ac9fa776ddf4b7cafcafaf8c48b0100000000ffffffff010f0e00000000000016001492b8c3a56fac121ddcdffbc85b02fb9ef681038a0247304402200c4c0bfe93f6622fa0790b6d28bf755c1a3f23e8404bb804ca8e2db080b613b102205bcf0a4e4559ba9b40e6b174cf91af061dfa21691923b410e351326708b041a00121030c7196376bc1df61b6da6ee711868fd30e370dd273332bfb02a2287d11e2e9c503010802588721c1924c163b385af7093440184af6fd6244936d1288cbb41cc3812286d3f83a332900000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let utxo_hints = array![
        UTXO {
            amount: 999,
            pubkey_script: hex_to_bytecode(
                @"0x001492b8c3a56fac121ddcdffbc85b02fb9ef681038a",
            ), // P2WPKH
            block_height: 862105,
        },
        UTXO {
            amount: 20000,
            pubkey_script: hex_to_bytecode(
                @"0x51201baeaaf9047cc42055a37a3ac981bdf7f5ab96fad0d2d07c54608e8a181b9477",
            ), // P2TR
            block_height: 862100,
        },
    ]
        .span();

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed: {}", res.unwrap_err());
}

#[test]
fn test_p2tr_script_path_spend_signature() {
    /// https://learnmeabitcoin.com/explorer/tx/797505b104b5fb840931c115ea35d445eb1f64c9279bf23aa5bb4c3d779da0c2#input-0
    let raw_transaction_hex =
        "0x020000000001013cfe8b95d22502698fd98837f83d8d4be31ee3eddd9d1ab1a95654c64604c4d10000000000ffffffff01983a0000000000001600140de745dc58d8e62e6f47bde30cd5804a82016f9e034101769105cbcbdcaaee5e58cd201ba3152477fda31410df8b91b4aee2c4864c7700615efb425e002f146a39ca0a4f2924566762d9213bd33f825fad83977fba7f0122206d4ddc0e47d2e8f82cbe2fc2d0d749e7bd3338112cecdc76d8f831ae6620dbe0ac21c0924c163b385af7093440184af6fd6244936d1288cbb41cc3812286d3f83a332900000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let utxo_hints = array![
        UTXO {
            amount: 20000,
            pubkey_script: hex_to_bytecode(
                @"0x5120f3778defe5173a9bf7169575116224f961c03c725c0e98b8da8f15df29194b80",
            ),
            block_height: 863496,
        },
    ]
        .span();

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed: {}", res.unwrap_err());
}

#[test]
fn test_p2tr_script_path_spend_tree() {
    /// https://learnmeabitcoin.com/explorer/tx/992af7eb67f37a4dfaa64ea6f03a70c35b6063ba5ee3fe41734c3460b4006463#input-0
    let raw_transaction_hex =
        "0x02000000000101d7c0aa93d852c70ed440c5295242c2ac06f41c3a2a174b5a5b112cebdf0f7bec0000000000ffffffff01260100000000000016001492b8c3a56fac121ddcdffbc85b02fb9ef681038a03010302538781c0924c163b385af7093440184af6fd6244936d1288cbb41cc3812286d3f83a33291324300a84045033ec539f60c70d582c48b9acf04150da091694d83171b44ec9bf2c4bf1ca72f7b8538e9df9bdfd3ba4c305ad11587f12bbfafa00d58ad6051d54962df196af2827a86f4bde3cf7d7c1a9dcb6e17f660badefbc892309bb145f00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let utxo_hints = array![
        UTXO {
            amount: 20000,
            pubkey_script: hex_to_bytecode(
                @"0x5120979cff99636da1b0e49f8711514c642f640d1f64340c3784942296368fadd0a5",
            ),
            block_height: 863633,
        },
    ]
        .span();

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed: {}", res.unwrap_err());
}

#[test]
fn test_p2tr_random_script_path_spend_1() {
    // https://learnmeabitcoin.com/explorer/tx/bd1fdf10ea3369b3dac2b9b7342d44754f1079aa7db6451c5da4cce4265dbcc3
    let raw_transaction_hex =
        "0x0200000000010128ccda7bf0177d7405bbd4e288a85d2a5fd71a555f7cd62e7d75358c9244041a0000000000fffffffd0122020000000000001976a914b98ed9befd3cf7fac22efea54e40d52491b57d8c88ac0340811d9ee1d730d7dc0775b98607cb2ccce01dcd718e44111f1bde1ac9d24fbadcae2e4c13c5d904ba24aeacbde92c34dbfdf84ed5e920da9b45c067d9f5b86fa88520aed85526197b4cc9913aa2715b52001131a83eadbdadd2d6bdd0d303362539bcac0063036f7264010118746578742f706c61696e3b636861727365743d7574662d38003f7b2270223a226272632d3230222c226f70223a227472616e73666572222c227469636b223a2273617473222c22616d74223a2232323835323638303530227d6821c19f2b9a3df69142a41d0ebe2ed8efafe08692e2ef196cbc4a5686152803f0fb6400000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let utxo_hints = array![
        UTXO {
            amount: 7146,
            pubkey_script: hex_to_bytecode(
                @"0x5120b77ce097b6a995438dc83b83c5bba19e631943c6090c81c2b9ab35743e42e452",
            ),
            block_height: 881907,
        },
    ]
        .span();

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed: {}", res.unwrap_err());
}

#[test]
fn test_p2tr_random_script_path_spend_2() {
    // https://learnmeabitcoin.com/explorer/tx/40f40c137beb6c5ae08d57eb2655010814eec6f933e66c99724be2344f8b7902
    let raw_transaction_hex =
        "0x02000000000101c6e6a95f072b08c1da0e15e748bab59e56cc0e5a47566c1918cef11baba2bbf30c00000000ffffffff014a01000000000000225120a2a5c17ca99d71c81a66c829187536b6145db4d1e61512f0fdd385876de7820f03404b8d01275f4cf9815c2fb1cba0edc71b368402be754d2ab2cda6c99bde1fd5cd6e64270a11f60526d5ecae2533b9808c6908b168bfa25730f2049ed77faaad9c7a2075a03c3645df9c06df091f89e4dd47bf8ccedd53301842eb50d36fff9edfdf94ac0063036f7264010118746578742f706c61696e3b636861727365743d7574662d3800347b2270223a226272632d3230222c226f70223a226d696e74222c227469636b223a2278706179222c22616d74223a22313030227d6821c175a03c3645df9c06df091f89e4dd47bf8ccedd53301842eb50d36fff9edfdf9400000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let utxo_hints = array![
        UTXO {
            amount: 488,
            pubkey_script: hex_to_bytecode(
                @"0x51204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32b",
            ),
            block_height: 881907,
        },
    ]
        .span();

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed: {}", res.unwrap_err());
}

#[test]
fn test_p2tr_random_script_path_spend_3() {
    // https://learnmeabitcoin.com/explorer/tx/f3bba2ab1bf1ce18196c56475a0ecc569eb5ba48e7150edac1082b075fa9e6c6
    let raw_transaction_hex =
        "0x0200000000010147dbe048b21565f10d03808a3ed5f8030b942aad4c8112a5d7094d2530cd24650000000000fdffffff144a01000000000000225120a2a5c17ca99d71c81a66c829187536b6145db4d1e61512f0fdd385876de7820fe8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32be8010000000000002251204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32b03400ec04fa07854f7c870a1bc0e783cc97c0bd9f8b6a6192174a2a268a6df862691b7ce89f1dde410eac72a7a222ef958335a9772333b2239253b78f790067984327a2075a03c3645df9c06df091f89e4dd47bf8ccedd53301842eb50d36fff9edfdf94ac0063036f7264010118746578742f706c61696e3b636861727365743d7574662d3800347b2270223a226272632d3230222c226f70223a226d696e74222c227469636b223a2278706179222c22616d74223a22313030227d6821c175a03c3645df9c06df091f89e4dd47bf8ccedd53301842eb50d36fff9edfdf9400000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let utxo_hints = array![
        UTXO {
            amount: 10623,
            pubkey_script: hex_to_bytecode(
                @"0x51204845f95bbdd877fcfba46b2a02becca0f94c3d3d2ca7a3522f1d420d1f88a32b",
            ),
            block_height: 881907,
        },
    ]
        .span();

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed: {}", res.unwrap_err());
}

#[test]
fn test_p2tr_random_script_path_spend_4() {
    // https://learnmeabitcoin.com/explorer/tx/8c727d45e093f0dd7a020015ea9d2633512b5f3722e2637d6e2b0c29a9fdd62b
    let raw_transaction_hex =
        "0x020000000001018fc2ac008741d32506aa9f294813739a82cfab330d66e7d85cedb7496822ab400100000000fdffffff024a01000000000000225120c5c606aa47431abad250d98744e8fb089001161d7c1d7032bdacfca5b22e07d7b79c0600000000002251206e13a855c521df8b696cd09ba3de268020bb56532720b3842aed83981e2bf94e0340f27baa700c3fd2d24d57b5383a55f83b46a4e1645e2788f618e986c4ae316579a75399dc9bc7420c00f55956d72a568962e954504fd35c1e8e9b93d51e131cef6a2070d0006b8a2e5ef4fd4386f4f94d86286d4689d52d29d4bfe1ef6320c8f6f9e4ac0063036f726401010a746578742f706c61696e00327b2270223a226272632d3230222c226f70223a226d696e74222c227469636b223a2266646370222c22616d74223a2231227d6821c170d0006b8a2e5ef4fd4386f4f94d86286d4689d52d29d4bfe1ef6320c8f6f9e400000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let utxo_hints = array![
        UTXO {
            amount: 433861,
            pubkey_script: hex_to_bytecode(
                @"0x51206e13a855c521df8b696cd09ba3de268020bb56532720b3842aed83981e2bf94e",
            ),
            block_height: 881907,
        },
    ]
        .span();

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed: {}", res.unwrap_err());
}

#[test]
fn test_p2tr_random_4() { // https://learnmeabitcoin.com/explorer/tx/385490f4b2755f3004b150a128bc16ead6e653badde4f5e06867021ac6bbf85b
// excesive witness
}

#[test]
fn test_p2tr_random_key_path_spend_1() {
    // https://learnmeabitcoin.com/explorer/tx/790f31e9ee2ed21b68c80de1fb7c9711bf57679a48c63ad2dbf838f281ef7cfa
    let raw_transaction_hex =
        "0x02000000000101782db273da2dc3e60036e0b3dc7a858e0c74ed92db2714cc0b32cb8cb7ea34b01200000000ffffffff0b2c7b00000000000016001480474f7d8c92897fd2bd4935302791b141d87b0e2a7b000000000000160014d539a3ccf4182b033bb3045d20f21c639be2390bf5870000000000001600145beed69d078f126ff25ee33b443ab272eea308e5f8a600000000000016001468aaefa4b5dc1319789dba27f4a76caa06d4a7a18f700000000000001600141e1a1248943b02f1cfac3ec5ff70d436ec810df6fe6f0000000000001600143498e645a4cd37afcc605c4e455151efdbd7f2a0465b000000000000160014b7d10ece4390e767af09a51b36757843c78626697255000000000000160014ed805953b03271204d835879074cdc3dfb2a0b5ec3640000000000001600143f1557c3a47b6271e46ace7ca42551c002e6bbfa3e3a00000000000017a9142d120dc83adb6569dd2f1e169593bc3534f02743874d825500000000002251207a719d9336839f47365cc604d18ad60e8b2e9f2a0a339c540d8b8554b939b3350140babb45b690ce43653b555a24c30f05f2399e75397b9310242cd733c39ae733bf6f34e9cbcef0bef02c61457f068f8e3120b1aaea764f1975b20bbe03869061ea00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let utxo_hints = array![
        UTXO {
            amount: 5893880,
            pubkey_script: hex_to_bytecode(
                @"0x51207a719d9336839f47365cc604d18ad60e8b2e9f2a0a339c540d8b8554b939b335",
            ),
            block_height: 881907,
        },
    ]
        .span();

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed: {}", res.unwrap_err());
}

#[test]
fn test_p2tr_random_key_path_spend_2() {
    // https://learnmeabitcoin.com/explorer/tx/b034eab78ccb320bcc1427db92ed740c8e857adcb3e03600e6c32dda73b22d78#output-18
    let raw_transaction_hex =
        "0x0200000000010115cb5e10ace920cf4c09beb60a11d9e4a64c991d62f061a116c851ec203423030600000000ffffffff136d5c000000000000160014f5b894645c49a9b170a8fd413bb9a1b844464011499c000000000000160014f9b5253bdf4f144f588d99d9a41d374245743e3f0d5f00000000000016001404f95621ddbf25770f7b7d8f74bb5957c92a715eba4b00000000000016001465b5c452063fbe620385a870ba07e7c09e4d60a406dc0000000000001600148c1256cf76cdf7980f8cf7aa20b03ca20fcdf60202cc0000000000001600148b806a540c1428c515d6bcda797134a8d83aaf4e1ca70000000000001600147c8f0dbb3a8759cd5cfe1b83b57b635ca631d587f468000000000000160014762c3aa2e4403c400ae0f2f6007d33af82bc7ceedb49000000000000160014406ee74b8161b8a8b813250e41fbd32298e2ee5c637c00000000000016001406bc7854923d9216f4cde70e356cdd78fa034463154200000000000016001433e53f6e03276cd26b8f520d9cab23d083eb2992108800000000000016001481720b25c722d7ebbbe6fc998c8a270ebc1ea34f0fc9000000000000160014cb4a9ec046f3581f060c6b40235be2b70105f4d2ae1001000000000017a9148e989b1083f15c4f0b483ac704829c739d306f0187bc93000000000000160014deb530e26a650f128a26cc5693a59f85f5508b2b80550000000000001600142c1e6c4dc8f900595c1ee79834b7ced92731c25b151f0000000000001600146378d66576723b5108a14f93ee76226438c74ee47955000000000000160014b9e2016bc8637aeea92e3e38ccb18313240baecff8ee5900000000002251207a719d9336839f47365cc604d18ad60e8b2e9f2a0a339c540d8b8554b939b3350140db7009ad1a459a67db4d8afc43565656cec786668a451a4fd757a462b45057b215d6e535c171cebc9b1f87a5fd57dface99341773c934982723a01d0450f7c9600000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let utxo_hints = array![
        UTXO {
            amount: 6502185,
            pubkey_script: hex_to_bytecode(
                @"0x51207a719d9336839f47365cc604d18ad60e8b2e9f2a0a339c540d8b8554b939b335",
            ),
            block_height: 881907,
        },
    ]
        .span();

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed: {}", res.unwrap_err());
}

#[test]
fn test_p2tr_random_key_path_spend_3() {
    // https://learnmeabitcoin.com/explorer/tx/a885a3d51390bd385f2c79038ebf9e7d7116090d43f8d4c8456cdfb9dfa1c492
    let raw_transaction_hex =
        "0x02000000000101bd2782402f00bc774d05d3dfb336065a3f286a18942e0d0cbb970262658287b00300000000ffffffff093565000000000000160014aea8a2ae8bc3ebdd2eab196577d66eb738710d085c2801000000000017a914277bd30de4f98fbf3ca93ade41952c7f9908967a87693e000000000000160014eed52783013872479e240a659ea0c271db3f33528d5f0000000000001600143b0c55909e7e48ba7b07420383fba2536da6a43b14d600000000000016001446159c58b1d1d7ff34f7ef3420ecfa3a8aba00b2d77e000000000000160014ecfaff82ae1c54a0b9408e9155d21c8b43abdd28ef7a000000000000160014042282c2c8b3ff94d7cc24f41d68aa1e5f52ad31cc59000000000000160014d9326fc51864a4dac6cc5b503b447ccf53f4217667e28a00000000002251207a719d9336839f47365cc604d18ad60e8b2e9f2a0a339c540d8b8554b939b3350140357ffa68ded2642375bd6b1989f47c4c8a843917db310cf215f5b3dd135bf1d799a577ddd7718174157ca2f8118749554c7e55473379bd0891d2c42ffa7ddf3700000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let utxo_hints = array![
        UTXO {
            amount: 9390930,
            pubkey_script: hex_to_bytecode(
                @"0x51207a719d9336839f47365cc604d18ad60e8b2e9f2a0a339c540d8b8554b939b335",
            ),
            block_height: 881907,
        },
    ]
        .span();

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags, utxo_hints);
    assert!(res.is_ok(), "Transaction validation failed: {}", res.unwrap_err());
}
