use crate::signature::constants;
use crate::transaction::{
    EngineTransaction, EngineOutPoint, EngineTransactionInput, EngineTransactionOutput,
    EngineTransactionTrait, EngineTransactionInputTrait, EngineTransactionOutputTrait,
};
use crate::parser;
use crate::opcodes::Opcode;


#[derive(Clone, Copy, Drop, Default)]
pub struct VerifyResult {
    pub sig_valid: bool,
    pub sig_match: bool,
}

// Removes `OP_CODESEPARATOR` opcodes from the `script`.
// By removing this opcode, the script becomes suitable for hashing and signature verification.
pub fn remove_opcodeseparator(script: @ByteArray) -> @ByteArray {
    let mut parsed_script: ByteArray = "";
    let mut i: usize = 0;

    // TODO: tokenizer/standardize script parsing
    let script_len = script.len();
    while i < script_len {
        let opcode = script[i];
        // TODO: Error handling
        if opcode == Opcode::OP_CODESEPARATOR {
            i += 1;
            continue;
        }
        let data_len = parser::data_len(script, i).unwrap();
        let end = i + data_len + 1;
        while i != end {
            parsed_script.append_byte(script[i]);
            i += 1;
        }
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
pub fn transaction_procedure<
    I,
    O,
    T,
    impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
    impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
    impl IEngineTransactionTrait: EngineTransactionTrait<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait,
    >,
    +Drop<O>,
    +Drop<I>,
    +Drop<T>,
>(
    transaction: @T, index: u32, signature_script: ByteArray, hash_type: u32,
) -> EngineTransaction {
    let hash_type_masked = hash_type & constants::SIG_HASH_MASK;
    let mut transaction_inputs_clone = array![];
    for input in transaction
        .get_transaction_inputs() {
            let new_transaction_input = EngineTransactionInput {
                previous_outpoint: EngineOutPoint {
                    txid: input.get_prevout_txid(), vout: input.get_prevout_vout(),
                },
                signature_script: input.get_signature_script().clone(),
                witness: input.get_witness().into(),
                sequence: input.get_sequence(),
            };
            transaction_inputs_clone.append(new_transaction_input);
        };

    let mut transaction_outputs_clone = array![];
    for output in transaction
        .get_transaction_outputs() {
            let new_transaction_output = EngineTransactionOutput {
                value: output.get_value(), publickey_script: output.get_publickey_script().clone(),
            };
            transaction_outputs_clone.append(new_transaction_output);
        };

    let mut transaction_copy = EngineTransaction {
        version: transaction.get_version(),
        transaction_inputs: transaction_inputs_clone,
        transaction_outputs: transaction_outputs_clone,
        locktime: transaction.get_locktime(),
        // utxos: array![],
    };
    let mut i: usize = 0;
    let mut transaction_input: Array<EngineTransactionInput> = transaction_copy.transaction_inputs;
    let mut processed_transaction_input: Array<EngineTransactionInput> = ArrayTrait::<
        EngineTransactionInput,
    >::new();
    let mut processed_transaction_output: Array<EngineTransactionOutput> = ArrayTrait::<
        EngineTransactionOutput,
    >::new();

    let tx_input_len = transaction_input.len();
    while i != tx_input_len {
        // TODO: Optimize this
        let mut temp_transaction_input: EngineTransactionInput = transaction_input[i].clone();

        if hash_type_masked == constants::SIG_HASH_SINGLE && i < index {
            processed_transaction_output
                .append(EngineTransactionOutput { value: -1, publickey_script: "" });
        }

        if i == index {
            processed_transaction_input
                .append(
                    EngineTransactionInput {
                        previous_outpoint: temp_transaction_input.previous_outpoint,
                        signature_script: signature_script.clone(),
                        witness: temp_transaction_input.witness.clone(),
                        sequence: temp_transaction_input.sequence,
                    },
                );
        } else {
            if hash_type & constants::SIG_HASH_ANYONECANPAY != 0 {
                continue;
            }
            let mut temp_sequence = temp_transaction_input.sequence;
            if hash_type_masked == constants::SIG_HASH_NONE
                || hash_type_masked == constants::SIG_HASH_SINGLE {
                temp_sequence = 0;
            }
            processed_transaction_input
                .append(
                    EngineTransactionInput {
                        previous_outpoint: temp_transaction_input.previous_outpoint,
                        signature_script: "",
                        witness: temp_transaction_input.witness.clone(),
                        sequence: temp_sequence,
                    },
                );
        }

        i += 1;
    };

    transaction_copy.transaction_inputs = processed_transaction_input;

    if hash_type_masked == constants::SIG_HASH_NONE {
        transaction_copy.transaction_outputs = ArrayTrait::<EngineTransactionOutput>::new();
    }

    if hash_type_masked == constants::SIG_HASH_SINGLE {
        transaction_copy.transaction_outputs = processed_transaction_output;
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

// Checks if the given script is a Pay-to-Taproot script.
// OP_1 OP_DATA_32 <32-byte-hash>
pub fn is_witness_v1_pub_key_hash(script: @ByteArray) -> bool {
    if script.len() == constants::WITNESS_V1_PUB_KEY_HASH_LEN
        && script[0] == Opcode::OP_1
        && script[1] == Opcode::OP_DATA_32 {
        return true; // remove 2 first bytes ?
    }
    false
}
