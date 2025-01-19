use crate::signature::sighash::{
    calc_taproot_signature_hash, TaprootSighashOptions, BASE_SIGHASH_EXT_FLAG,
    TAPSCRIPT_SIGHASH_EXT_FLAG,
};

use crate::transaction::{
    EngineTransactionOutput, EngineTransaction, EngineTransactionInput, EngineOutPoint,
    EngineInternalTransactionTrait, UTXO,
};
use crate::hash_cache::{TxSigHashes, SigHashMidstateTrait};
use shinigami_engine::utxo::{};
use shinigami_utils::bytecode::hex_to_bytecode;
use shinigami_utils::byte_array::{U256IntoByteArray};


#[test]
fn test_new_sigHashMidstate() {
    // https://github.com/bitcoin/bips/blob/master/bip-0341/wallet-test-vectors.json#l227
    let raw_transaction_hex =
        "0x02000000097de20cbff686da83a54981d2b9bab3586f4ca7e48f57f5b55963115f3b334e9c010000000000000000d7b7cab57b1393ace2d064f4d4a2cb8af6def61273e127517d44759b6dafdd990000000000fffffffff8e1f583384333689228c5d28eac13366be082dc57441760d957275419a418420000000000fffffffff0689180aa63b30cb162a73c6d2a38b7eeda2a83ece74310fda0843ad604853b0100000000feffffffaa5202bdf6d8ccd2ee0f0202afbbb7461d9264a25e5bfd3c5a52ee1239e0ba6c0000000000feffffff956149bdc66faa968eb2be2d2faa29718acbfe3941215893a2a3446d32acd050000000000000000000e664b9773b88c09c32cb70a2a3e4da0ced63b7ba3b22f848531bbb1d5d5f4c94010000000000000000e9aa6b8e6c9de67619e6a3924ae25696bb7b694bb677a632a74ef7eadfd4eabf0000000000ffffffffa778eb6a263dc090464cd125c466b5a99667720b1c110468831d058aa1b82af10100000000ffffffff0200ca9a3b000000001976a91406afd46bcdfd22ef94ac122aa11f241244a37ecc88ac807840cb0000000020ac9a87f5594be208f8532db38cff670c450ed2fea8fcdefcc9a663f78bab962b0065cd1d";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let utxos = array![
        UTXO {
            amount: 420000000,
            pubkey_script: hex_to_bytecode(
                @"0x512053a1f6e454df1aa2776a2814a721372d6258050de330b3c6d10ee8f4e0dda343",
            ),
            block_height: Default::default(),
        },
        UTXO {
            amount: 462000000,
            pubkey_script: hex_to_bytecode(
                @"0x5120147c9c57132f6e7ecddba9800bb0c4449251c92a1e60371ee77557b6620f3ea3",
            ),
            block_height: Default::default(),
        },
        UTXO {
            amount: 294000000,
            pubkey_script: hex_to_bytecode(@"0x76a914751e76e8199196d454941c45d1b3a323f1433bd688ac"),
            block_height: Default::default(),
        },
        UTXO {
            amount: 504000000,
            pubkey_script: hex_to_bytecode(
                @"0x5120e4d810fd50586274face62b8a807eb9719cef49c04177cc6b76a9a4251d5450e",
            ),
            block_height: Default::default(),
        },
        UTXO {
            amount: 630000000,
            pubkey_script: hex_to_bytecode(
                @"0x512091b64d5324723a985170e4dc5a0f84c041804f2cd12660fa5dec09fc21783605",
            ),
            block_height: Default::default(),
        },
        UTXO {
            amount: 378000000,
            pubkey_script: hex_to_bytecode(@"0x00147dd65592d0ab2fe0d0257d571abf032cd9db93dc"),
            block_height: Default::default(),
        },
        UTXO {
            amount: 672000000,
            pubkey_script: hex_to_bytecode(
                @"0x512075169f4001aa68f15bbed28b218df1d0a62cbbcf1188c6665110c293c907b831",
            ),
            block_height: Default::default(),
        },
        UTXO {
            amount: 546000000,
            pubkey_script: hex_to_bytecode(
                @"0x5120712447206d7a5238acc7ff53fbe94a3b64539ad291c7cdbc490b7577e4b17df5",
            ),
            block_height: Default::default(),
        },
        UTXO {
            amount: 588000000,
            pubkey_script: hex_to_bytecode(
                @"0x512077e30a5522dd9f894c3f8b8bd4c4b2cf82ca7da8a3ea6a239655c39c050ab220",
            ),
            block_height: Default::default(),
        },
    ];

    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, 0, utxos);
    let sig_hash = SigHashMidstateTrait::new(@transaction);

    let expected_hash_prevouts =
        0xe3b33bb4ef3a52ad1fffb555c0d82828eb22737036eaeb02a235d82b909c4c3f_u256;
    let expected_hash_sequence =
        0x18959c7221ab5ce9e26c3cd67b22c24f8baa54bac281d8e6b05e400e6c3a957e_u256;
    let expected_hash_outputs =
        0xa2e6dab7c1f0dcd297c8d61647fd17d821541ea69c3cc37dcbad7f90d4eb4bc5_u256;

    let exepected_hash_amount =
        0x58a6964a4f5f8f0b642ded0a8a553be7622a719da71d1f5befcefcdee8e0fde6_u256;
    let expected_hash_script_pubkeys =
        0x23ad0f61ad2bca5ba6a7693f50fce988e17c3780bf2b1e720cfbb38fbdd52e21_u256;

    assert_eq!(sig_hash.taproot.hash_prevouts_v1, expected_hash_prevouts);
    assert_eq!(sig_hash.taproot.hash_sequence_v1, expected_hash_sequence);
    assert_eq!(sig_hash.taproot.hash_outputs_v1, expected_hash_outputs);

    assert_eq!(sig_hash.taproot.hash_input_scripts_v1, expected_hash_script_pubkeys);
    assert_eq!(sig_hash.taproot.hash_input_amounts_v1, exepected_hash_amount);
}

#[test]
fn test_calc_taproot_signature_hash_key_path_spend() {
    // https://learnmeabitcoin.com/technical/upgrades/taproot/#examples
    // txid 091d2aaadc409298fd8353a4cd94c319481a0b4623fb00872fe240448e93fcbe input 0
    let h_type: u32 = 0x01; // SIGHASH_ALL
    let transaction = EngineTransaction {
        txid: 0,
        version: 2,
        transaction_inputs: array![
            EngineTransactionInput {
                previous_outpoint: EngineOutPoint {
                    txid: 0xec9016580d98a93909faf9d2f431e74f781b438d81372bb6aab4db67725c11a7_u256, //le
                    vout: 0,
                },
                signature_script: Default::default(),
                sequence: 0xffffffff,
                witness: array![
                    hex_to_bytecode(
                        @"0xb693a0797b24bae12ed0516a2f5ba765618dca89b75e498ba5b745b71644362298a45ca39230d10a02ee6290a91cebf9839600f7e35158a447ea182ea0e022ae01",
                    ),
                ],
            },
        ],
        transaction_outputs: array![
            EngineTransactionOutput {
                value: 10000,
                publickey_script: hex_to_bytecode(
                    @"0x00144e44ca792ce545acba99d41304460dd1f53be384",
                ),
            },
        ],
        locktime: 0,
        utxos: array![
            UTXO {
                amount: 20000,
                pubkey_script: hex_to_bytecode(
                    @"0x51200f0c8db753acbd17343a39c2f3f4e35e4be6da749f9e35137ab220e7b238a667",
                ),
                block_height: 861957,
            },
        ],
    };

    let sig_hashes: TxSigHashes = SigHashMidstateTrait::new(@transaction);
    let input_idx: u32 = 0;
    let prev_output: EngineTransactionOutput = Default::default();

    let mut opts = TaprootSighashOptions {
        ext_flag: BASE_SIGHASH_EXT_FLAG, // key path spend
        annex_hash: @"",
        tap_leaf_hash: @"",
        key_version: 0,
        code_sep_pos: 0,
    };

    let result = calc_taproot_signature_hash(
        sig_hashes, h_type, @transaction, input_idx, prev_output, ref opts,
    );
    let expected_hash = 0xa7b390196945d71549a2454f0185ece1b47c56873cf41789d78926852c355132_u256;

    assert_eq!(result.is_ok(), true);
    assert_eq!(result.unwrap(), expected_hash);
}

// no signature so useless ?
#[test]
fn test_calc_taproot_signature_hash_script_path_spend_simple() {
    // txid 5ff05f74d385bd39e344329330461f74b390c1b5ead87c4f51b40c555b75719d input 1
    let h_type: u32 = 0x01; // SIGHASH_ALL
    let transaction = EngineTransaction {
        txid: 0,
        version: 2,
        transaction_inputs: array![
            EngineTransactionInput {
                previous_outpoint: EngineOutPoint {
                    txid: 0xC20DA20832C3894854DC63F69CF7FE805323B3D476AAA8E730244B36A575D244_u256, //le
                    vout: 0,
                },
                signature_script: Default::default(),
                sequence: 0xffffffff,
                witness: array![
                    hex_to_bytecode(
                        @"0x304402200c4c0bfe93f6622fa0790b6d28bf755c1a3f23e8404bb804ca8e2db080b613b102205bcf0a4e4559ba9b40e6b174cf91af061dfa21691923b410e351326708b041a001",
                    ),
                    hex_to_bytecode(
                        @"0x030c7196376bc1df61b6da6ee711868fd30e370dd273332bfb02a2287d11e2e9c5" //verify
                    ),
                ],
            },
            EngineTransactionInput {
                previous_outpoint: EngineOutPoint {
                    txid: 0x87ADAA9D7302D05896B0D491A099208C20EA0AC9FA776DDF4B7CAFCAFAF8C48B_u256, //le
                    vout: 1,
                },
                signature_script: Default::default(),
                sequence: 0xffffffff,
                witness: array![
                    hex_to_bytecode(@"0x08"),
                    hex_to_bytecode(@"0x5887"),
                    hex_to_bytecode(
                        @"0xc1924c163b385af7093440184af6fd6244936d1288cbb41cc3812286d3f83a3329",
                    ),
                ],
            },
        ],
        transaction_outputs: array![
            EngineTransactionOutput {
                value: 3599,
                publickey_script: hex_to_bytecode(
                    @"0x001492b8c3a56fac121ddcdffbc85b02fb9ef681038a",
                ),
            },
        ],
        locktime: 0,
        utxos: array![
            UTXO {
                amount: 999,
                pubkey_script: hex_to_bytecode(@"0x001492b8c3a56fac121ddcdffbc85b02fb9ef681038a"),
                block_height: 862105,
            },
            UTXO {
                amount: 20000,
                pubkey_script: hex_to_bytecode(
                    @"0x51201baeaaf9047cc42055a37a3ac981bdf7f5ab96fad0d2d07c54608e8a181b9477",
                ),
                block_height: 862100,
            },
        ],
    };

    let input_idx: u32 = 1;
    let sig_hashes: TxSigHashes = SigHashMidstateTrait::new(@transaction);
    let prev_output: EngineTransactionOutput = Default::default();

    let mut opts = TaprootSighashOptions {
        ext_flag: TAPSCRIPT_SIGHASH_EXT_FLAG, // script path spend
        annex_hash: @"",
        tap_leaf_hash: @hex_to_bytecode(
            @"0xe4b47d76d2f78791323a035811c350bb7875568006cb60f0e171efb70c11bda4",
        ),
        key_version: 0,
        code_sep_pos: 0,
    };

    let result = calc_taproot_signature_hash(
        sig_hashes, h_type, @transaction, input_idx, prev_output, ref opts,
    );
    // println!("result: {:x}", result.unwrap());

    assert_eq!(result.is_ok(), true);
}

#[test]
fn test_calc_taproot_signature_hash_script_path_spend_signature() {
    // txid 797505b104b5fb840931c115ea35d445eb1f64c9279bf23aa5bb4c3d779da0c2 input 0
    let input_idx: u32 = 0;
    let h_type: u32 = 0x01; // SIGHASH_ALL
    let transaction = EngineTransaction {
        txid: 0,
        version: 2,
        transaction_inputs: array![
            EngineTransactionInput {
                previous_outpoint: EngineOutPoint {
                    txid: 0x3CFE8B95D22502698FD98837F83D8D4BE31EE3EDDD9D1AB1A95654C64604C4D1_u256, //le
                    vout: 0,
                },
                signature_script: Default::default(),
                sequence: 0xffffffff,
                witness: array![
                    hex_to_bytecode(
                        @"0x01769105cbcbdcaaee5e58cd201ba3152477fda31410df8b91b4aee2c4864c7700615efb425e002f146a39ca0a4f2924566762d9213bd33f825fad83977fba7f01",
                    ),
                    hex_to_bytecode(
                        @"0x206d4ddc0e47d2e8f82cbe2fc2d0d749e7bd3338112cecdc76d8f831ae6620dbe0ac",
                    ),
                    hex_to_bytecode(
                        @"0xc0924c163b385af7093440184af6fd6244936d1288cbb41cc3812286d3f83a3329",
                    ),
                ],
            },
        ],
        transaction_outputs: array![
            EngineTransactionOutput {
                value: 15000,
                publickey_script: hex_to_bytecode(
                    @"0x00140de745dc58d8e62e6f47bde30cd5804a82016f9e",
                ),
            },
        ],
        locktime: 0,
        utxos: array![
            UTXO {
                amount: 20000,
                pubkey_script: hex_to_bytecode(
                    @"0x5120f3778defe5173a9bf7169575116224f961c03c725c0e98b8da8f15df29194b80",
                ),
                block_height: 863496,
            },
        ],
    };

    let sig_hashes: TxSigHashes = SigHashMidstateTrait::new(@transaction);
    let prev_output: EngineTransactionOutput = Default::default();

    let mut opts = TaprootSighashOptions {
        ext_flag: TAPSCRIPT_SIGHASH_EXT_FLAG,
        annex_hash: @"",
        tap_leaf_hash: @hex_to_bytecode(
            @"0x858dfe26a3dd48a2c1fcee1d631f0aadf6a61135fc51f75758e945bca534ef16",
        ),
        key_version: 0,
        code_sep_pos: 0xffffffff,
    };

    let result = calc_taproot_signature_hash(
        sig_hashes, h_type, @transaction, input_idx, prev_output, ref opts,
    );
    let expected_hash = 0x752453d473e511a0da2097d664d69fe5eb89d8d9d00eab924b42fc0801a980c9_u256;

    assert_eq!(result.is_ok(), true);
    assert_eq!(result.unwrap(), expected_hash);
}

// no signature so useless ?
#[test]
fn test_calc_taproot_signature_hash_script_path_spend_tree() {
    // txid 992af7eb67f37a4dfaa64ea6f03a70c35b6063ba5ee3fe41734c3460b4006463 input 0
    let input_idx: u32 = 0;
    let h_type: u32 = 0x01; // SIGHASH_ALL
    let transaction = EngineTransaction {
        txid: 0,
        version: 2,
        transaction_inputs: array![
            EngineTransactionInput {
                previous_outpoint: EngineOutPoint {
                    txid: 0xD7C0AA93D852C70ED440C5295242C2AC06F41C3A2A174B5A5B112CEBDF0F7BEC_u256, //le
                    vout: 0,
                },
                signature_script: Default::default(),
                sequence: 0xffffffff,
                witness: array![
                    hex_to_bytecode(@"0x03"),
                    hex_to_bytecode(@"0x5387"),
                    hex_to_bytecode(
                        @"0xc0924c163b385af7093440184af6fd6244936d1288cbb41cc3812286d3f83a33291324300a84045033ec539f60c70d582c48b9acf04150da091694d83171b44ec9bf2c4bf1ca72f7b8538e9df9bdfd3ba4c305ad11587f12bbfafa00d58ad6051d54962df196af2827a86f4bde3cf7d7c1a9dcb6e17f660badefbc892309bb145f",
                    ),
                ],
            },
        ],
        transaction_outputs: array![
            EngineTransactionOutput {
                value: 294,
                publickey_script: hex_to_bytecode(
                    @"0x001492b8c3a56fac121ddcdffbc85b02fb9ef681038a",
                ),
            },
        ],
        locktime: 0,
        utxos: array![
            UTXO {
                amount: 10000,
                pubkey_script: hex_to_bytecode(
                    @"0x5120979cff99636da1b0e49f8711514c642f640d1f64340c3784942296368fadd0a5",
                ),
                block_height: 863496,
            },
        ],
    };

    let sig_hashes: TxSigHashes = SigHashMidstateTrait::new(@transaction);
    let prev_output: EngineTransactionOutput = Default::default();

    let mut opts = TaprootSighashOptions {
        ext_flag: TAPSCRIPT_SIGHASH_EXT_FLAG,
        annex_hash: @"",
        tap_leaf_hash: @hex_to_bytecode(
            @"0x160bd30406f8d5333be044e6d2d14624470495da8a3f91242ce338599b233931",
        ),
        key_version: 0,
        code_sep_pos: 0xffffffff,
    };

    let result = calc_taproot_signature_hash(
        sig_hashes, h_type, @transaction, input_idx, prev_output, ref opts,
    );

    assert_eq!(result.is_ok(), true);
}
