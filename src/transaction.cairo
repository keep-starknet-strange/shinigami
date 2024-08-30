use crate::utils;

// Tracks previous transaction outputs
#[derive(Drop, Copy)]
pub struct OutPoint {
    pub hash: u256,
    pub index: u32,
}

#[derive(Drop, Clone)]
pub struct TransactionInput {
    pub previous_outpoint: OutPoint,
    pub signature_script: ByteArray,
    pub witness: Array<ByteArray>,
    pub sequence: u32,
}

#[derive(Drop, Clone)]
pub struct TransactionOutput {
    pub value: i64,
    pub publickey_script: ByteArray,
}

#[derive(Drop, Clone)]
pub struct Transaction {
    pub version: i32,
    pub transaction_inputs: Span<TransactionInput>,
    pub transaction_outputs: Span<TransactionOutput>,
    pub locktime: u32,
}

pub trait TransactionTrait {
    fn new(
        version: i32,
        transaction_inputs: Span<TransactionInput>,
        transaction_outputs: Span<TransactionOutput>,
        locktime: u32
    ) -> Transaction;
    fn new_signed(script_sig: ByteArray) -> Transaction;
    fn btc_encode(self: Transaction, encoding: u32) -> ByteArray;
    fn serialize(self: Transaction) -> ByteArray;
    fn serialize_no_witness(self: Transaction) -> ByteArray;
}

pub const BASE_ENCODING: u32 = 0x01;
pub const WITNESS_ENCODING: u32 = 0x02;

pub impl TransactionImpl of TransactionTrait {
    fn new(
        version: i32,
        transaction_inputs: Span<TransactionInput>,
        transaction_outputs: Span<TransactionOutput>,
        locktime: u32
    ) -> Transaction {
        Transaction {
            version: version,
            transaction_inputs: transaction_inputs,
            transaction_outputs: transaction_outputs,
            locktime: locktime,
        }
    }

    fn new_signed(script_sig: ByteArray) -> Transaction {
        // TODO
        let transaction = Transaction {
            version: 1,
            transaction_inputs: array![
                TransactionInput {
                    previous_outpoint: OutPoint { hash: 0x0, index: 0, },
                    signature_script: script_sig,
                    witness: array![],
                    sequence: 0xffffffff,
                }
            ]
                .span(),
            transaction_outputs: array![].span(),
            locktime: 0,
        };
        transaction
    }

    // Serialize the transaction data for hashing based on encoding used.
    fn btc_encode(self: Transaction, encoding: u32) -> ByteArray {
        let mut bytes = "";
        bytes.append_word_rev(self.version.into(), 4);
        // TODO: Witness encoding

        // Serialize each input in the transaction.
        let input_len: usize = self.transaction_inputs.len();
        bytes.append_word_rev(input_len.into(), utils::int_size_in_bytes(input_len));
        let mut i: usize = 0;
        while i < input_len {
            let input: @TransactionInput = self.transaction_inputs.at(i);
            let input_hash: u256 = *input.previous_outpoint.hash;
            let vout: u32 = *input.previous_outpoint.index;
            let script: @ByteArray = input.signature_script;
            let script_len: usize = script.len();
            let sequence: u32 = *input.sequence;

            bytes.append_word(input_hash.high.into(), 16);
            bytes.append_word(input_hash.low.into(), 16);
            bytes.append_word_rev(vout.into(), 4);
            bytes.append_word_rev(script_len.into(), utils::int_size_in_bytes(script_len));
            bytes.append(script);
            bytes.append_word_rev(sequence.into(), 4);

            i += 1;
        };

        // Serialize each output in the transaction.
        let output_len: usize = self.transaction_outputs.len();
        bytes.append_word_rev(output_len.into(), utils::int_size_in_bytes(output_len));
        i = 0;
        while i < output_len {
            let output: @TransactionOutput = self.transaction_outputs.at(i);
            let value: i64 = *output.value;
            let script: @ByteArray = output.publickey_script;
            let script_len: usize = script.len();

            bytes.append_word_rev(value.into(), 8);
            bytes.append_word_rev(script_len.into(), utils::int_size_in_bytes(script_len));
            bytes.append(script);

            i += 1;
        };

        bytes.append_word_rev(self.locktime.into(), 4);
        bytes
    }

    fn serialize(self: Transaction) -> ByteArray {
        self.btc_encode(WITNESS_ENCODING)
    }

    fn serialize_no_witness(self: Transaction) -> ByteArray {
        self.btc_encode(BASE_ENCODING)
    }
}

impl TransactionDefault of Default<Transaction> {
    fn default() -> Transaction {
        let transaction = Transaction {
            version: 0,
            transaction_inputs: array![].span(),
            transaction_outputs: array![].span(),
            locktime: 0,
        };
        transaction
    }
}
