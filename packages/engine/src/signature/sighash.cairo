use crate::transaction::{
    EngineTransaction, EngineTransactionTrait, EngineInternalTransactionImpl,
    EngineTransactionInputTrait, EngineTransactionOutputTrait
};
use crate::signature::constants;
use crate::signature::utils::{
    remove_opcodeseparator, transaction_procedure, is_witness_pub_key_hash
};
use crate::hash_cache::SegwitSigHashMidstate;
use shinigami_utils::bytecode::write_var_int;
use shinigami_utils::hash::{sha256_byte_array, double_sha256};
use crate::opcodes::opcodes::Opcode;

// Calculates the signature hash for specified transaction data and hash type.
pub fn calc_signature_hash<
    I,
    O,
    T,
    impl IEngineTransactionInput: EngineTransactionInputTrait<I>,
    impl IEngineTransactionOutput: EngineTransactionOutputTrait<O>,
    impl IEngineTransaction: EngineTransactionTrait<
        T, I, O, IEngineTransactionInput, IEngineTransactionOutput
    >,
    +Drop<I>,
    +Drop<O>,
    +Drop<T>
>(
    sub_script: @ByteArray, hash_type: u32, transaction: @T, tx_idx: u32
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
        transaction, tx_idx, signature_script.clone(), hash_type
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
        T, I, O, IEngineTransactionInput, IEngineTransactionOutput
    >,
    +Drop<I>,
    +Drop<O>,
    +Drop<T>
>(
    sub_script: @ByteArray,
    sig_hashes: @SegwitSigHashMidstate,
    hash_type: u32,
    transaction: @T,
    tx_idx: u32,
    amount: i64
) -> u256 {
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
    code_sep_pos: u32
}

#[generate_trait()]
pub impl TaprootSighashOptionsImpl of TaprootSighashOptionsTrait {
    fn new_default() -> TaprootSighashOptions {
        TaprootSighashOptions {
            ext_flag: BASE_SIGHASH_EXT_FLAG,
            annex_hash: @"",
            tap_leaf_hash: @"",
            key_version: 0,
            code_sep_pos: 0
        }
    }

    fn new_with_annex(annex: @ByteArray) -> TaprootSighashOptions {
        TaprootSighashOptions {
            ext_flag: BASE_SIGHASH_EXT_FLAG,
            annex_hash: @sha256_byte_array(annex),
            tap_leaf_hash: @"",
            key_version: 0,
            code_sep_pos: 0
        }
    }

    fn new_with_tapscript_version(
        code_sep_pos: u32, tap_leaf_hash: @ByteArray
    ) -> TaprootSighashOptions {
        TaprootSighashOptions {
            ext_flag: TAPSCRIPT_SIGHASH_EXT_FLAG,
            annex_hash: @"",
            tap_leaf_hash: tap_leaf_hash,
            key_version: 0,
            code_sep_pos: code_sep_pos
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
pub fn is_valid_taproot_sighash(hash_type: u32) -> bool {
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

pub fn calc_taproot_signature_hash() -> u256 {
    0 // TODO
}

pub fn calc_tapscript_signature_hash() -> u256 {
    0 // TODO
}

