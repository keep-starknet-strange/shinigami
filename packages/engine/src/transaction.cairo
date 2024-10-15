use crate::errors::Error;
use shinigami_utils::byte_array::{byte_array_value_at_le, byte_array_value_at_be, sub_byte_array};
use shinigami_utils::bytecode::int_size_in_bytes;
use shinigami_utils::bit_shifts::shr;

// Tracks previous transaction outputs
#[derive(Drop, Copy)]
pub struct OutPoint {
    pub txid: u256,
    pub vout: u32,
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
    pub transaction_inputs: Array<TransactionInput>,
    pub transaction_outputs: Array<TransactionOutput>,
    pub locktime: u32,
}

pub trait TransactionTrait {
    fn new(
        version: i32,
        transaction_inputs: Array<TransactionInput>,
        transaction_outputs: Array<TransactionOutput>,
        locktime: u32
    ) -> Transaction;
    fn new_signed(script_sig: ByteArray) -> Transaction;
    fn new_signed_witness(script_sig: ByteArray, witness: Array<ByteArray>) -> Transaction;
    fn btc_decode(raw: ByteArray, encoding: u32) -> Transaction;
    fn deserialize(raw: ByteArray) -> Transaction;
    fn deserialize_no_witness(raw: ByteArray) -> Transaction;
    fn btc_encode(self: Transaction, encoding: u32) -> ByteArray;
    fn serialize(self: Transaction) -> ByteArray;
    fn serialize_no_witness(self: Transaction) -> ByteArray;
    fn calculate_block_subsidy(block_height: u32) -> i64;
    fn is_coinbase(self: @Transaction) -> bool;
    fn validate_coinbase(
        self: Transaction, block_height: u32, total_fees: i64
    ) -> Result<(), felt252>;
}

pub const BASE_ENCODING: u32 = 0x01;
pub const WITNESS_ENCODING: u32 = 0x02;

pub impl TransactionImpl of TransactionTrait {
    fn new(
        version: i32,
        transaction_inputs: Array<TransactionInput>,
        transaction_outputs: Array<TransactionOutput>,
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
                    previous_outpoint: OutPoint { txid: 0x0, vout: 0, },
                    signature_script: script_sig,
                    witness: array![],
                    sequence: 0xffffffff,
                }
            ],
            transaction_outputs: array![],
            locktime: 0,
        };
        transaction
    }

    fn new_signed_witness(script_sig: ByteArray, witness: Array<ByteArray>) -> Transaction {
        // TODO
        let transaction = Transaction {
            version: 1,
            transaction_inputs: array![
                TransactionInput {
                    previous_outpoint: OutPoint { txid: 0x0, vout: 0, },
                    signature_script: script_sig,
                    witness: witness,
                    sequence: 0xffffffff,
                }
            ],
            transaction_outputs: array![],
            locktime: 0,
        };
        transaction
    }

    // Deserialize a transaction from a byte array.
    fn btc_decode(raw: ByteArray, encoding: u32) -> Transaction {
        let mut offset: usize = 0;
        let version: i32 = byte_array_value_at_le(@raw, ref offset, 4).try_into().unwrap();
        if encoding == WITNESS_ENCODING {
            // consume flags
            offset += 2;
        }
        // TODO: ReadVerIntBuf
        let input_len: u8 = byte_array_value_at_le(@raw, ref offset, 1).try_into().unwrap();
        // TODO: Error handling and bounds checks
        // TODO: Byte orderings
        let mut i = 0;
        let mut inputs: Array<TransactionInput> = array![];
        while i != input_len {
            let tx_id = u256 {
                high: byte_array_value_at_be(@raw, ref offset, 16).try_into().unwrap(),
                low: byte_array_value_at_be(@raw, ref offset, 16).try_into().unwrap(),
            };
            let vout: u32 = byte_array_value_at_le(@raw, ref offset, 4).try_into().unwrap();
            let script_len = byte_array_value_at_le(@raw, ref offset, 1).try_into().unwrap();
            let script = sub_byte_array(@raw, ref offset, script_len);
            let sequence: u32 = byte_array_value_at_le(@raw, ref offset, 4).try_into().unwrap();
            let input = TransactionInput {
                previous_outpoint: OutPoint { txid: tx_id, vout: vout },
                signature_script: script,
                witness: array![],
                sequence: sequence,
            };
            inputs.append(input);
            i += 1;
        };

        let output_len: u8 = byte_array_value_at_le(@raw, ref offset, 1).try_into().unwrap();
        let mut i = 0;
        let mut outputs: Array<TransactionOutput> = array![];
        while i != output_len {
            // TODO: negative values
            let value: i64 = byte_array_value_at_le(@raw, ref offset, 8).try_into().unwrap();
            let script_len = byte_array_value_at_le(@raw, ref offset, 1).try_into().unwrap();
            let script = sub_byte_array(@raw, ref offset, script_len);
            let output = TransactionOutput { value: value, publickey_script: script, };
            outputs.append(output);
            i += 1;
        };

        let mut inputs_with_witness: Array<TransactionInput> = array![];

        if encoding == WITNESS_ENCODING {
            // one witness for each input
            i = 0;
            while i != input_len {
                let witness_count: u8 = byte_array_value_at_le(@raw, ref offset, 1)
                    .try_into()
                    .unwrap();
                let mut j = 0;
                let mut witness: Array<ByteArray> = array![];
                while j != witness_count {
                    let script_len = byte_array_value_at_le(@raw, ref offset, 1)
                        .try_into()
                        .unwrap();
                    let script = sub_byte_array(@raw, ref offset, script_len);
                    witness.append(script);
                    j += 1;
                };
                // update Transaction Input
                let input = inputs.at(i.into());
                let mut input_with_witness = input.clone();
                input_with_witness.witness = witness;
                inputs_with_witness.append(input_with_witness);
                i += 1;
            };
        }
        let locktime: u32 = byte_array_value_at_le(@raw, ref offset, 4).try_into().unwrap();
        if encoding == WITNESS_ENCODING {
            Transaction {
                version: version,
                transaction_inputs: inputs_with_witness,
                transaction_outputs: outputs,
                locktime: locktime,
            }
        } else {
            Transaction {
                version: version,
                transaction_inputs: inputs,
                transaction_outputs: outputs,
                locktime: locktime,
            }
        }
    }

    fn deserialize(raw: ByteArray) -> Transaction {
        let mut offset: usize = 0;
        let _version: i32 = byte_array_value_at_le(@raw, ref offset, 4).try_into().unwrap();
        let flags: u16 = byte_array_value_at_le(@raw, ref offset, 2).try_into().unwrap();
        if flags == 0x100 {
            Self::btc_decode(raw, WITNESS_ENCODING)
        } else {
            Self::btc_decode(raw, BASE_ENCODING)
        }
    }

    fn deserialize_no_witness(raw: ByteArray) -> Transaction {
        Self::btc_decode(raw, BASE_ENCODING)
    }

    // Serialize the transaction data for hashing based on encoding used.
    fn btc_encode(self: Transaction, encoding: u32) -> ByteArray {
        let mut bytes = "";
        bytes.append_word_rev(self.version.into(), 4);
        // TODO: Witness encoding

        // Serialize each input in the transaction.
        let input_len: usize = self.transaction_inputs.len();
        bytes.append_word_rev(input_len.into(), int_size_in_bytes(input_len));
        let mut i: usize = 0;
        while i != input_len {
            let input: @TransactionInput = self.transaction_inputs.at(i);
            let input_txid: u256 = *input.previous_outpoint.txid;
            let vout: u32 = *input.previous_outpoint.vout;
            let script: @ByteArray = input.signature_script;
            let script_len: usize = script.len();
            let sequence: u32 = *input.sequence;

            bytes.append_word(input_txid.high.into(), 16);
            bytes.append_word(input_txid.low.into(), 16);
            bytes.append_word_rev(vout.into(), 4);
            bytes.append_word_rev(script_len.into(), int_size_in_bytes(script_len));
            bytes.append(script);
            bytes.append_word_rev(sequence.into(), 4);

            i += 1;
        };

        // Serialize each output in the transaction.
        let output_len: usize = self.transaction_outputs.len();
        bytes.append_word_rev(output_len.into(), int_size_in_bytes(output_len));
        i = 0;
        while i != output_len {
            let output: @TransactionOutput = self.transaction_outputs.at(i);
            let value: i64 = *output.value;
            let script: @ByteArray = output.publickey_script;
            let script_len: usize = script.len();

            bytes.append_word_rev(value.into(), 8);
            bytes.append_word_rev(script_len.into(), int_size_in_bytes(script_len));
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

    fn calculate_block_subsidy(block_height: u32) -> i64 {
        let halvings = block_height / 210000;
        shr::<i64, u32>(5000000000, halvings)
    }

    fn is_coinbase(self: @Transaction) -> bool {
        if self.transaction_inputs.len() != 1 {
            return false;
        }

        let input = self.transaction_inputs.at(0);
        if input.previous_outpoint.txid != @0 || input.previous_outpoint.vout != @0xFFFFFFFF {
            return false;
        }

        true
    }

    fn validate_coinbase(
        self: Transaction, block_height: u32, total_fees: i64
    ) -> Result<(), felt252> {
        if !self.is_coinbase() {
            return Result::Err(Error::INVALID_COINBASE);
        }

        let input = self.transaction_inputs.at(0);
        let script_len = input.signature_script.len();
        if script_len < 2 || script_len > 100 {
            return Result::Err(Error::INVALID_COINBASE);
        }

        let subsidy = Self::calculate_block_subsidy(block_height);
        let mut total_out: i64 = 0;
        let output_len = self.transaction_outputs.len();
        let mut i = 0;
        while i != output_len {
            let output = self.transaction_outputs.at(i);
            total_out += *output.value;
            i += 1;
        };
        if total_out > total_fees + subsidy {
            return Result::Err(Error::INVALID_COINBASE);
        }

        // TODO: BIP34 checks for block height?

        Result::Ok(())
    }
}

impl TransactionDefault of Default<Transaction> {
    fn default() -> Transaction {
        let default_txin = TransactionInput {
            previous_outpoint: OutPoint { txid: 0, vout: 0, },
            signature_script: "",
            witness: array![],
            sequence: 0xffffffff,
        };
        let transaction = Transaction {
            version: 0,
            transaction_inputs: array![default_txin],
            transaction_outputs: array![],
            locktime: 0,
        };
        transaction
    }
}

pub trait EngineTransactionInputTrait<I> {
    fn get_prevout_txid(self: @I) -> u256;
    fn get_prevout_vout(self: @I) -> u32;
    fn get_signature_script(self: @I) -> @ByteArray;
    fn get_witness(self: @I) -> Span<ByteArray>;
    fn get_sequence(self: @I) -> u32;
}

pub impl EngineTransactionInputTraitInternalImpl of EngineTransactionInputTrait<TransactionInput> {
    fn get_prevout_txid(self: @TransactionInput) -> u256 {
        *self.previous_outpoint.txid
    }

    fn get_prevout_vout(self: @TransactionInput) -> u32 {
        *self.previous_outpoint.vout
    }

    fn get_signature_script(self: @TransactionInput) -> @ByteArray {
        self.signature_script
    }

    fn get_witness(self: @TransactionInput) -> Span<ByteArray> {
        self.witness.span()
    }

    fn get_sequence(self: @TransactionInput) -> u32 {
        *self.sequence
    }
}

pub trait EngineTransactionOutputTrait<O> {
    fn get_publickey_script(self: @O) -> @ByteArray;
    fn get_value(self: @O) -> i64;
}

pub impl EngineTransactionOutputTraitInternalImpl of EngineTransactionOutputTrait<
    TransactionOutput
> {
    fn get_publickey_script(self: @TransactionOutput) -> @ByteArray {
        self.publickey_script
    }

    fn get_value(self: @TransactionOutput) -> i64 {
        *self.value
    }
}

pub trait EngineTransactionTrait<
    T, I, O, +EngineTransactionInputTrait<I>, +EngineTransactionOutputTrait<O>
> {
    fn get_version(self: @T) -> i32;
    fn get_transaction_inputs(self: @T) -> Span<I>;
    fn get_transaction_outputs(self: @T) -> Span<O>;
    fn get_locktime(self: @T) -> u32;
}

pub impl EngineTransactionTraitInternalImpl of EngineTransactionTrait<
    Transaction,
    TransactionInput,
    TransactionOutput,
    EngineTransactionInputTraitInternalImpl,
    EngineTransactionOutputTraitInternalImpl
> {
    fn get_version(self: @Transaction) -> i32 {
        *self.version
    }

    fn get_transaction_inputs(self: @Transaction) -> Span<TransactionInput> {
        self.transaction_inputs.span()
    }

    fn get_transaction_outputs(self: @Transaction) -> Span<TransactionOutput> {
        self.transaction_outputs.span()
    }

    fn get_locktime(self: @Transaction) -> u32 {
        *self.locktime
    }
}
