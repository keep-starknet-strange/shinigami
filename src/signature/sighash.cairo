use shinigami::utils::{int_size_in_bytes, double_sha256};
use shinigami::transaction::{Transaction, TransactionTrait, TransactionInput, TransactionOutput};
use shinigami::signature::{constants, utils};

// Calculates the signature hash for specified transaction data and hash type.
pub fn calc_signature_hash(
    sub_script: @ByteArray, hash_type: u32, ref transaction: Transaction, tx_idx: u32
) -> u256 {
    let transaction_outputs_len: usize = transaction.transaction_outputs.len();
    // `SIG_HASH_SINGLE` only signs corresponding input/output pair.
    // The original Satoshi client gave a signature hash of 0x01 in cases where the input index
    // was out of bounds. This buggy/dangerous behavior is part of the consensus rules,
    // and would require a hard fork to fix.
    if hash_type & constants::SIG_HASH_MASK == constants::SIG_HASH_SINGLE
        && tx_idx >= transaction_outputs_len {
        return 0x01;
    }

    // Remove any OP_CODESEPARATOR opcodes from the subscript.
    let mut signature_script: @ByteArray = utils::remove_opcodeseparator(sub_script);
    // Create a modified copy of the transaction according to the hash type.
    let transaction_copy: Transaction = utils::transaction_procedure(
        ref transaction, tx_idx, signature_script.clone(), hash_type
    );

    let mut sig_hash_bytes: ByteArray = transaction_copy.serialize_no_witness();
    sig_hash_bytes.append_word_rev(hash_type.into(), 4);

    // Hash and return the serialized transaction data twice using SHA-256.
    double_sha256(@sig_hash_bytes)
}

// Calculates the signature hash for a Segregated Witness (SegWit) transaction and hash type.
pub fn calc_witness_transaction_hash(
    sub_script: @ByteArray, hash_type: u32, ref transaction: Transaction, index: u32, amount: i64
) -> u256 {
    let transaction_outputs_len: usize = transaction.transaction_outputs.len();
    if hash_type & constants::SIG_HASH_MASK == constants::SIG_HASH_SINGLE
        && index > transaction_outputs_len {
        return 0x01;
    }
    let mut sig_hash_bytes: ByteArray = "";
    let mut input_byte: ByteArray = "";
    let mut output_byte: ByteArray = "";
    let mut sequence_byte: ByteArray = "";
    // Serialize the transaction's version number.
    sig_hash_bytes.append_word_rev(transaction.version.into(), 4);
    // Serialize each input in the transaction.
    let input_len: usize = transaction.transaction_inputs.len();
    let mut i: usize = 0;
    while i < input_len {
        let input: @TransactionInput = transaction.transaction_inputs.at(i);

        let input_hash: u256 = *input.previous_outpoint.hash;
        let vout: u32 = *input.previous_outpoint.index;
        let sequence: u32 = *input.sequence;

        input_byte.append_word(input_hash.high.into(), 16);
        input_byte.append_word(input_hash.low.into(), 16);
        input_byte.append_word_rev(vout.into(), 4);
        sequence_byte.append_word_rev(sequence.into(), 4);

        i += 1;
    };
    // Serialize each output if not using SIG_HASH_SINGLE or SIG_HASH_NONE else serialize only the
    // relevant output.
    if hash_type & constants::SIG_HASH_SINGLE != constants::SIG_HASH_SINGLE
        && hash_type & constants::SIG_HASH_NONE != constants::SIG_HASH_NONE {
        let output_len: usize = transaction.transaction_outputs.len();

        i = 0;
        while i < output_len {
            let output: @TransactionOutput = transaction.transaction_outputs.at(i);
            let value: i64 = *output.value;
            let script: @ByteArray = output.publickey_script;
            let script_len: usize = script.len();

            output_byte.append_word_rev(value.into(), 8);
            output_byte.append_word_rev(script_len.into(), int_size_in_bytes(script_len));
            output_byte.append(script);

            i += 1;
        };
    } else if hash_type & constants::SIG_HASH_SINGLE == constants::SIG_HASH_SINGLE {
        if index < transaction.transaction_outputs.len() {
            let output: @TransactionOutput = transaction.transaction_outputs.at(index);
            let value: i64 = *output.value;
            let script: @ByteArray = output.publickey_script;
            let script_len: usize = script.len();

            output_byte.append_word_rev(value.into(), 8);
            output_byte.append_word_rev(script_len.into(), int_size_in_bytes(script_len));
            output_byte.append(script);
        }
    }
    let mut hash_prevouts: u256 = 0;
    if hash_type & constants::SIG_HASH_ANYONECANPAY != constants::SIG_HASH_ANYONECANPAY {
        hash_prevouts = double_sha256(@input_byte);
    }

    let mut hash_sequence: u256 = 0;
    if hash_type & constants::SIG_HASH_ANYONECANPAY != constants::SIG_HASH_ANYONECANPAY
        && hash_type & constants::SIG_HASH_SINGLE != constants::SIG_HASH_SINGLE
        && hash_type & constants::SIG_HASH_NONE != constants::SIG_HASH_NONE {
        hash_sequence = double_sha256(@sequence_byte);
    }

    let mut hash_outputs: u256 = 0;
    if hash_type & constants::SIG_HASH_ANYONECANPAY == constants::SIG_HASH_ANYONECANPAY
        || hash_type & constants::SIG_HASH_SINGLE == constants::SIG_HASH_SINGLE
        || hash_type & constants::SIG_HASH_ALL == constants::SIG_HASH_ALL {
        hash_sequence = double_sha256(@output_byte);
    }

    // Append the hashed previous outputs and sequences.
    sig_hash_bytes.append_word_rev(hash_prevouts.high.into(), 16);
    sig_hash_bytes.append_word_rev(hash_prevouts.low.into(), 16);
    sig_hash_bytes.append_word_rev(hash_sequence.high.into(), 16);
    sig_hash_bytes.append_word_rev(hash_sequence.low.into(), 16);
    // Add the input being signed.

    let mut input: @TransactionInput = transaction.transaction_inputs.at(i);
    let input_hash: u256 = *input.previous_outpoint.hash;
    let vout: u32 = *input.previous_outpoint.index;
    let sequence: u32 = *input.sequence;
    sig_hash_bytes.append_word_rev(input_hash.high.into(), 16);
    sig_hash_bytes.append_word_rev(input_hash.low.into(), 16);
    sig_hash_bytes.append_word_rev(vout.into(), 4);
    // Check if the script is a witness pubkey hash and serialize accordingly.
    if utils::is_witness_pub_key_hash(sub_script) {
        sig_hash_bytes.append_byte(0x19);
        sig_hash_bytes.append_byte(0x76);
        sig_hash_bytes.append_byte(0xa9);
        sig_hash_bytes.append_byte(0x14);
        i = 2;
        while i < sub_script.len() {
            sig_hash_bytes.append_byte(sub_script[i]);
            i += 1;
        };
        sig_hash_bytes.append_byte(0x88);
        sig_hash_bytes.append_byte(0xac);
    } else {
        sig_hash_bytes.append(sub_script);
    }
    // Serialize the amount and sequence number.
    sig_hash_bytes.append_word_rev(amount.into(), 8);
    sig_hash_bytes.append_word_rev(sequence.into(), 4);
    // Serialize the hashed outputs.
    sig_hash_bytes.append_word_rev(hash_outputs.high.into(), 16);
    sig_hash_bytes.append_word_rev(hash_outputs.low.into(), 16);
    // Serialize the transaction's locktime and hash type.
    sig_hash_bytes.append_word_rev(transaction.locktime.into(), 4);
    sig_hash_bytes.append_word_rev(hash_type.into(), 4);
    // Hash and return the serialized transaction data twice using SHA-256.
    double_sha256(@sig_hash_bytes)
}
