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
    ];

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags);
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
    ];

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags);
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
    ];

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags);
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
            ), // P2TR
            block_height: 863496,
        },
    ];

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags);
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
            ), // P2TR
            block_height: 863633,
        },
    ];

    let flags: u32 = ScriptFlags::ScriptVerifyWitness.into()
        | ScriptFlags::ScriptBip16.into()
        | ScriptFlags::ScriptVerifyTaproot.into();
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, utxo_hints);

    let res = validate::validate_transaction(@transaction, flags);
    assert!(res.is_ok(), "Transaction validation failed: {}", res.unwrap_err());
}
