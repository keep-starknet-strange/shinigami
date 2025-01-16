use crate::transaction::{
    EngineTransaction, EngineTransactionTrait, EngineInternalTransactionImpl,
    EngineTransactionInputTrait, EngineTransactionOutputTrait,
};
use crate::signature::constants;
use crate::signature::utils::{
    remove_opcodeseparator, transaction_procedure, is_witness_pub_key_hash,
};
use crate::transaction::{EngineTransactionOutput};
use shinigami_utils::bytecode::write_var_int;
use shinigami_utils::hash::{sha256_byte_array, simple_sha256, double_sha256};
use crate::opcodes::opcodes::Opcode;
use crate::hash_cache::{TxSigHashes, SegwitSigHashMidstate, TaprootSigHashMidState};
use crate::hash_tag::{HashTag, tagged_hash};
use crate::errors::Error;

// Calculates the signature hash for specified transaction data and hash type.
pub fn calc_signature_hash<
    I,
    O,
    T,
    impl IEngineTransactionInput: EngineTransactionInputTrait<I>,
    impl IEngineTransactionOutput: EngineTransactionOutputTrait<O>,
    impl IEngineTransaction: EngineTransactionTrait<
        T, I, O, IEngineTransactionInput, IEngineTransactionOutput,
    >,
    +Drop<I>,
    +Drop<O>,
    +Drop<T>,
>(
    sub_script: @ByteArray, hash_type: u32, transaction: @T, tx_idx: u32,
) -> u256 {
    let transaction_outputs_len: usize = transaction.get_transaction_outputs().len();
    // `SIG_HASH_SINGLE` only signs corresponding input/output pair.
    // The original Satoshi client gave a signature hash of 0x01 in cases where the input index
    // was out of bounds. This buggy/dangerous behavior is part of the consensus rules,
    // and would require a hard fork to fix.
    if hash_type & constants::SIG_HASH_MASK == constants::SIG_HASH_SINGLE
        && tx_idx >= transaction_outputs_len {
        return 0x01;
    }

    // Remove any OP_CODESEPARATOR opcodes from the subscript.
    let mut signature_script: @ByteArray = remove_opcodeseparator(sub_script);
    // Create a modified copy of the transaction according to the hash type.
    let transaction_copy: EngineTransaction = transaction_procedure(
        transaction, tx_idx, signature_script.clone(), hash_type,
    );

    let mut sig_hash_bytes: ByteArray = transaction_copy.serialize_no_witness();
    sig_hash_bytes.append_word_rev(hash_type.into(), 4);

    // Hash and return the serialized transaction data twice using SHA-256.
    double_sha256(@sig_hash_bytes)
}

// Calculates the signature hash for a Segregated Witness (SegWit) transaction and hash type.
pub fn calc_witness_signature_hash<
    I,
    O,
    T,
    impl IEngineTransactionInput: EngineTransactionInputTrait<I>,
    impl IEngineTransactionOutput: EngineTransactionOutputTrait<O>,
    impl IEngineTransaction: EngineTransactionTrait<
        T, I, O, IEngineTransactionInput, IEngineTransactionOutput,
    >,
    +Drop<I>,
    +Drop<O>,
    +Drop<T>,
>(
    sub_script: @ByteArray,
    sig_hashes_enum: TxSigHashes,
    hash_type: u32,
    transaction: @T,
    tx_idx: u32,
    amount: i64,
) -> u256 {
    let mut sig_hashes: @SegwitSigHashMidstate = Default::default();
    match sig_hashes_enum {
        TxSigHashes::Segwit(segwit_midstate) => { sig_hashes = segwit_midstate; },
        // Handle error ?
        _ => { return 0; },
    }

    // TODO: Bounds check?
    let mut sig_hash_bytes: ByteArray = "";
    sig_hash_bytes.append_word_rev(transaction.get_version().into(), 4);

    let zero: u256 = 0;
    if hash_type & constants::SIG_HASH_ANYONECANPAY == 0 {
        let hash_prevouts_v0: u256 = *sig_hashes.hash_prevouts_v0;
        sig_hash_bytes.append_word(hash_prevouts_v0.high.into(), 16);
        sig_hash_bytes.append_word(hash_prevouts_v0.low.into(), 16);
    } else {
        sig_hash_bytes.append_word(zero.high.into(), 16);
        sig_hash_bytes.append_word(zero.low.into(), 16);
    }

    if hash_type & constants::SIG_HASH_ANYONECANPAY == 0
        && hash_type & constants::SIG_HASH_MASK != constants::SIG_HASH_SINGLE
        && hash_type & constants::SIG_HASH_MASK != constants::SIG_HASH_NONE {
        let hash_sequence_v0: u256 = *sig_hashes.hash_sequence_v0;
        sig_hash_bytes.append_word(hash_sequence_v0.high.into(), 16);
        sig_hash_bytes.append_word(hash_sequence_v0.low.into(), 16);
    } else {
        sig_hash_bytes.append_word(zero.high.into(), 16);
        sig_hash_bytes.append_word(zero.low.into(), 16);
    }

    let input = transaction.get_transaction_inputs().at(tx_idx);
    sig_hash_bytes.append_word(input.get_prevout_txid().high.into(), 16);
    sig_hash_bytes.append_word(input.get_prevout_txid().low.into(), 16);
    sig_hash_bytes.append_word_rev(input.get_prevout_vout().into(), 4);

    if is_witness_pub_key_hash(sub_script) {
        // P2WKH with 0x19 OP_DUP OP_HASH160 OP_DATA_20 <pubkey hash> OP_EQUALVERIFY OP_CHECKSIG
        sig_hash_bytes.append_byte(0x19);
        sig_hash_bytes.append_byte(Opcode::OP_DUP);
        sig_hash_bytes.append_byte(Opcode::OP_HASH160);
        sig_hash_bytes.append_byte(Opcode::OP_DATA_20);
        let subscript_len = sub_script.len();
        // TODO: extractWitnessPubKeyHash
        let mut i: usize = 2;
        while i != subscript_len {
            sig_hash_bytes.append_byte(sub_script[i]);
            i += 1;
        };
        sig_hash_bytes.append_byte(Opcode::OP_EQUALVERIFY);
        sig_hash_bytes.append_byte(Opcode::OP_CHECKSIG);
    } else {
        write_var_int(ref sig_hash_bytes, sub_script.len().into());
        sig_hash_bytes.append(sub_script);
    }

    sig_hash_bytes.append_word_rev(amount.into(), 8);
    sig_hash_bytes.append_word_rev(input.get_sequence().into(), 4);

    if hash_type & constants::SIG_HASH_MASK != constants::SIG_HASH_SINGLE
        && hash_type & constants::SIG_HASH_MASK != constants::SIG_HASH_NONE {
        let hash_outputs_v0: u256 = *sig_hashes.hash_outputs_v0;
        sig_hash_bytes.append_word(hash_outputs_v0.high.into(), 16);
        sig_hash_bytes.append_word(hash_outputs_v0.low.into(), 16);
    } else if hash_type & constants::SIG_HASH_MASK == constants::SIG_HASH_SINGLE
        && tx_idx < transaction.get_transaction_outputs().len() {
        let output = transaction.get_transaction_outputs().at(tx_idx);
        let mut output_bytes: ByteArray = "";
        output_bytes.append_word_rev(output.get_value().into(), 8);
        write_var_int(ref output_bytes, output.get_publickey_script().len().into());
        output_bytes.append(output.get_publickey_script());
        let hashed_output: u256 = double_sha256(@output_bytes);
        sig_hash_bytes.append_word(hashed_output.high.into(), 16);
        sig_hash_bytes.append_word(hashed_output.low.into(), 16);
    } else {
        sig_hash_bytes.append_word(zero.high.into(), 16);
        sig_hash_bytes.append_word(zero.low.into(), 16);
    }

    sig_hash_bytes.append_word_rev(transaction.get_locktime().into(), 4);
    sig_hash_bytes.append_word_rev(hash_type.into(), 4);

    double_sha256(@sig_hash_bytes)
}

// SighashExtFlag represent the sig hash extension flag as defined in BIP-341.
pub type SighashExtFlag = u8;

// Base extension flag. Sighash digest message doesn't change. Used for Segwit v1 spends (aka
// tapscript keyspend path).
pub const BASE_SIGHASH_EXT_FLAG: SighashExtFlag = 0;
// Tapscript extesion flag. Used for tapscript base leaf version spend as defined in BIP-342.
pub const TAPSCRIPT_SIGHASH_EXT_FLAG: SighashExtFlag = 1;

// TaprootSighashOptions houses options who modify how the sighash digest is computed.
#[derive(Drop)]
pub struct TaprootSighashOptions {
    // Denotes the current message digest extension being used.
    ext_flag: SighashExtFlag,
    // Sha256 of the annix with a compact size lenght prefix.
    // sha256(compactsize(annex) || annex)
    annex_hash: @ByteArray,
    // Hash of the tapscript leaf as defined in BIP-341.
    // h_tapleaf(version || compactsize(script) || script)
    tap_leaf_hash: @ByteArray,
    // Key version as defined in BIP-341. Actually always 0.
    key_version: u8,
    // Position of the last opcode separator. Used for BIP-342 sighash message extension.
    code_sep_pos: u32,
}

#[generate_trait()]
pub impl TaprootSighashOptionsImpl of TaprootSighashOptionsTrait {
    fn new_default() -> TaprootSighashOptions {
        TaprootSighashOptions {
            ext_flag: BASE_SIGHASH_EXT_FLAG,
            annex_hash: @"",
            tap_leaf_hash: @"",
            key_version: 0,
            code_sep_pos: 0,
        }
    }

    fn new_with_annex(annex: @ByteArray) -> TaprootSighashOptions {
        TaprootSighashOptions {
            ext_flag: BASE_SIGHASH_EXT_FLAG,
            annex_hash: @sha256_byte_array(annex),
            tap_leaf_hash: @"",
            key_version: 0,
            code_sep_pos: 0,
        }
    }

    fn new_with_tapscript_version(
        code_sep_pos: u32, tap_leaf_hash: @ByteArray,
    ) -> TaprootSighashOptions {
        TaprootSighashOptions {
            ext_flag: TAPSCRIPT_SIGHASH_EXT_FLAG,
            annex_hash: @"",
            tap_leaf_hash: tap_leaf_hash,
            key_version: 0,
            code_sep_pos: code_sep_pos,
        }
    }

    // Write in msg the sihash message extension defined by the current active flag.
    fn write_digest_extensions(ref self: TaprootSighashOptions, ref msg: ByteArray) {
        // Base extension doesn'nt modify the digest at all.
        if self.ext_flag == BASE_SIGHASH_EXT_FLAG {
            return;
            // Tapscript base leaf version extension adds leaf hash, key version and code separator.
        } else if self.ext_flag == TAPSCRIPT_SIGHASH_EXT_FLAG {
            msg.append(self.tap_leaf_hash);
            msg.append_byte(self.key_version);
            msg.append_word(self.code_sep_pos.into(), 4);
        }
        return;
    }
}

// Return true if `taproot_sighash` is valid.
fn is_valid_taproot_sighash(hash_type: u32) -> bool {
    if hash_type == constants::SIG_HASH_DEFAULT
        || hash_type == constants::SIG_HASH_ALL
        || hash_type == constants::SIG_HASH_NONE
        || hash_type == constants::SIG_HASH_SINGLE
        || hash_type == 0x81
        || hash_type == 0x82
        || hash_type == 0x83 {
        return true;
    } else {
        return false;
    }
}

pub fn calc_taproot_signature_hash<
    T,
    +Drop<T>,
    I,
    +Drop<I>,
    O,
    +Drop<O>,
    impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
    impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
    impl IEngineTransactionTrait: EngineTransactionTrait<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait,
    >,
>(
    sig_hashes_enum: TxSigHashes,
    h_type: u32,
    transaction: @T,
    input_idx: u32,
    prev_output: EngineTransactionOutput,
    ref opts: TaprootSighashOptions,
) -> Result<u256, felt252> {
    if !is_valid_taproot_sighash(h_type) {
        return Result::Err(Error::TAPROOT_INVALID_SIGHASH_TYPE);
    }

    // Check if the input index is valid
    if input_idx > (transaction.get_transaction_inputs().len() - 1) {
        return Result::Err(Error::INVALID_INDEX_INPUTS);
    }

    let mut sig_msg: ByteArray = Default::default();
    // The final sighash always starts with 0x00, called sighash epoch
    sig_msg.append_byte(0x00);
    sig_msg.append_byte(h_type.try_into().unwrap());
    sig_msg.append_word_rev(transaction.get_version().into(), 4);
    sig_msg.append_word_rev(transaction.get_locktime().into(), 4);

    let mut sig_hashes: @TaprootSigHashMidState = Default::default();
    match sig_hashes_enum {
        TxSigHashes::Taproot(midstate) => { sig_hashes = midstate; },
        _ => { return Result::Err(Error::TAPROOT_INVALID_SIGHASH_MIDSTATE); },
    }

    if (h_type & constants::SIG_HASH_ANYONECANPAY) != constants::SIG_HASH_ANYONECANPAY {
        let hash_prevouts_v1: u256 = *sig_hashes.hash_prevouts_v1;
        sig_msg.append_word(hash_prevouts_v1.high.into(), 16);
        sig_msg.append_word(hash_prevouts_v1.low.into(), 16);

        let hash_input_amounts_v1: u256 = *sig_hashes.hash_input_amounts_v1;
        sig_msg.append_word(hash_input_amounts_v1.high.into(), 16);
        sig_msg.append_word(hash_input_amounts_v1.low.into(), 16);

        let hash_input_scripts_v1: u256 = *sig_hashes.hash_input_scripts_v1;
        sig_msg.append_word(hash_input_scripts_v1.high.into(), 16);
        sig_msg.append_word(hash_input_scripts_v1.low.into(), 16);

        let hash_sequence_v1: u256 = *sig_hashes.hash_sequence_v1;
        sig_msg.append_word(hash_sequence_v1.high.into(), 16);
        sig_msg.append_word(hash_sequence_v1.low.into(), 16);
    }

    // If SIGHASH_ALL or SIGHASH_DEFAULT, include all output digests
    if (h_type & constants::SIG_HASH_SINGLE) != constants::SIG_HASH_SINGLE
        && (h_type & constants::SIG_HASH_SINGLE) != constants::SIG_HASH_NONE {
        let hash_outputs_v1: u256 = *sig_hashes.hash_outputs_v1;
        sig_msg.append_word(hash_outputs_v1.high.into(), 16);
        sig_msg.append_word(hash_outputs_v1.low.into(), 16);
    }

    // Write input-specific information
    let input = transaction.get_transaction_inputs().at(input_idx);
    let witness_has_annex = opts.annex_hash.len() != 0;
    let mut spend_type: u8 = opts.ext_flag * 2;
    if witness_has_annex {
        spend_type += 1;
    }
    sig_msg.append_byte(spend_type);

    // Write input-specific data
    if (h_type & constants::SIG_HASH_ANYONECANPAY) == constants::SIG_HASH_ANYONECANPAY {
        // previous outpoint
        sig_msg.append_word(input.get_prevout_txid().high.into(), 16);
        sig_msg.append_word(input.get_prevout_txid().low.into(), 16);
        sig_msg.append_word_rev(input.get_prevout_vout().into(), 4);

        // previous output (amount and script)
        sig_msg.append_word_rev(prev_output.get_value().into(), 8);
        write_var_int(ref sig_msg, prev_output.get_publickey_script().len().into());

        // input sequence
        sig_msg.append_word_rev(input.get_sequence().into(), 4);
    } else {
        // input index
        sig_msg.append_word_rev(input_idx.into(), 4);
    }

    if witness_has_annex {
        sig_msg.append(opts.annex_hash);
    }

    // If sighash single, include the output information
    if (h_type & constants::SIG_HASH_MASK) == constants::SIG_HASH_SINGLE {
        if input_idx >= transaction.get_transaction_outputs().len() {
            return Result::Err(Error::INVALID_INDEX_INPUTS);
        }
        let output = transaction.get_transaction_outputs().at(input_idx);

        // Serialize the output
        let mut output_bytes: ByteArray = Default::default();
        output_bytes.append_word_rev(output.get_value().into(), 8);
        write_var_int(ref output_bytes, output.get_publickey_script().len().into());
        output_bytes.append(output.get_publickey_script());

        // Hash the output
        let hashed_output: u256 = simple_sha256(@output_bytes);
        sig_msg.append_word(hashed_output.high.into(), 16);
        sig_msg.append_word(hashed_output.low.into(), 16);
    }

    // Write any digest extensions
    opts.write_digest_extensions(ref sig_msg);

    // The final sighash is computed as: hash_TagSigHash(0x00 || sigMsg).
    Result::Ok(tagged_hash(HashTag::TapSighash, @sig_msg))
}

fn calc_tapscript_signature_hash() -> u256 {
    0 // TODO
}


#[cfg(test)]
mod tests {
    use super::{calc_taproot_signature_hash, TxSigHashes, TaprootSighashOptions};
    use crate::transaction::{
        EngineTransactionOutput, EngineTransaction, EngineTransactionInput, EngineOutPoint,
    };
    use crate::signature::{sighash::{BASE_SIGHASH_EXT_FLAG, TAPSCRIPT_SIGHASH_EXT_FLAG}};
    use shinigami_engine::utxo::{UTXO};
    use shinigami_utils::bytecode::hex_to_bytecode;
    use crate::hash_cache::SigHashMidstateTrait;

    #[test]
    fn test_calc_taproot_signature_hash_key_path_spend() {
        // https://learnmeabitcoin.com/technical/upgrades/taproot/#examples
        // txid 091d2aaadc409298fd8353a4cd94c319481a0b4623fb00872fe240448e93fcbe input 0
        let h_type: u32 = 0x01; // SIGHASH_ALL
        let transaction = EngineTransaction {
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

        let sig_hashes: TxSigHashes = SigHashMidstateTrait::new(@transaction, 0);
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
                    pubkey_script: hex_to_bytecode(
                        @"0x001492b8c3a56fac121ddcdffbc85b02fb9ef681038a",
                    ),
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
        let sig_hashes: TxSigHashes = SigHashMidstateTrait::new(@transaction, input_idx);
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

        let sig_hashes: TxSigHashes = SigHashMidstateTrait::new(@transaction, input_idx);
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

        let sig_hashes: TxSigHashes = SigHashMidstateTrait::new(@transaction, input_idx);
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
}
