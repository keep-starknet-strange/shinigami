use shinigami::signature::constants;
use shinigami::transaction::{Transaction, TransactionInput, TransactionOutput, OutPoint};
use shinigami::opcodes::Opcode;

// Removes `OP_CODESEPARATOR` opcodes from the `script`.
// By removing this opcode, the script becomes suitable for hashing and signature verification.
pub fn remove_opcodeseparator(script: @ByteArray) -> @ByteArray {
    let mut parsed_script: ByteArray = "";
    let mut i: usize = 0;

    while i < script.len() {
        let value = script[i];
        if value != Opcode::OP_CODESEPARATOR {
            parsed_script.append_byte(value);
        }
        i += 1;
    };

    @parsed_script
}

// Prepares a modified copy of the transaction, ready for signature hashing.
//
// This function processes a transaction by modifying its inputs and outputs according to the hash
// type, which determines which parts of the transaction are included in the signature hash.
//
// @param transaction The original transaction to be processed.
// @param index The index of the current input being processed.
// @param signature_script The script that is added to the transaction input during processing.
// @param hash_type The hash type that dictates how the transaction should be modified.
// @return A modified copy of the transaction based on the provided hash type.
pub fn transaction_procedure(
    ref transaction: Transaction, index: u32, signature_script: ByteArray, hash_type: u32
) -> Transaction {
    let hash_type_masked = hash_type & constants::SIG_HASH_MASK;
    let mut transaction_copy = transaction.clone();
    let mut i: usize = 0;
    let mut transaction_input: Span<TransactionInput> = transaction_copy.transaction_inputs;
    let mut processed_transaction_input: Array<TransactionInput> = ArrayTrait::<
        TransactionInput
    >::new();
    let mut processed_transaction_output: Array<TransactionOutput> = ArrayTrait::<
        TransactionOutput
    >::new();

    while i < transaction_input.len() {
        let mut temp_transaction_input: @TransactionInput = transaction_input.pop_front().unwrap();

        if hash_type_masked == constants::SIG_HASH_SINGLE && i < index {
            processed_transaction_output
                .append(TransactionOutput { value: -1, publickey_script: "", });
        }

        if i == index {
            processed_transaction_input
                .append(
                    TransactionInput {
                        previous_outpoint: *temp_transaction_input.previous_outpoint,
                        signature_script: signature_script.clone(),
                        witness: temp_transaction_input.witness.clone(),
                        sequence: *temp_transaction_input.sequence
                    }
                );
        } else {
            if hash_type & constants::SIG_HASH_ANYONECANPAY != 0 {
                continue;
            }
            let mut temp_sequence = *temp_transaction_input.sequence;
            if hash_type_masked == constants::SIG_HASH_NONE
                || hash_type_masked == constants::SIG_HASH_SINGLE {
                temp_sequence = 0;
            }
            processed_transaction_input
                .append(
                    TransactionInput {
                        previous_outpoint: *temp_transaction_input.previous_outpoint,
                        signature_script: "",
                        witness: temp_transaction_input.witness.clone(),
                        sequence: temp_sequence
                    }
                );
        }

        i += 1;
    };

    transaction_copy.transaction_inputs = processed_transaction_input.span();

    if hash_type_masked == constants::SIG_HASH_NONE {
        transaction_copy.transaction_outputs = ArrayTrait::<TransactionOutput>::new().span();
    }

    if hash_type_masked == constants::SIG_HASH_SINGLE {
        transaction_copy.transaction_outputs = processed_transaction_output.span();
    }

    transaction_copy
}

// Checks if the given script is a Pay-to-Witness-Public-Key-Hash (P2WPKH) script.
// A P2WPKH script has a length of 22 bytes and starts with a version byte (`0x00`)
// followed by a 20-byte public key hash.
//
// Thus, a Pay-to-Witness-Public-Key-Hash script is of the form:
// `OP_0 OP_DATA_20 <20-byte public key hash>`
pub fn is_witness_pub_key_hash(script: @ByteArray) -> bool {
    if script.len() == constants::WITNESS_V0_PUB_KEY_HASH_LEN
        && script[0] == Opcode::OP_0
        && script[1] == Opcode::OP_DATA_20 {
        return true;
    }
    false
}
