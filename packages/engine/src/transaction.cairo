use crate::errors::Error;
use shinigami_utils::byte_array::{byte_array_value_at_le, byte_array_value_at_be, sub_byte_array};
use shinigami_utils::bytecode::{bytecode_to_hex, read_var_int, write_var_int};
use shinigami_utils::bit_shifts::shr;
use shinigami_utils::hash::double_sha256;

#[derive(Debug, Drop, Clone, Default)]
pub struct UTXO {
    pub amount: i64,
    pub pubkey_script: ByteArray,
    pub block_height: u32,
    // TODO: flags?
}

// Tracks previous transaction outputs
#[derive(Drop, Copy, Default)]
pub struct EngineOutPoint {
    pub txid: u256,
    pub vout: u32,
}

#[derive(Drop, Clone, Default)]
pub struct EngineTransactionInput {
    pub previous_outpoint: EngineOutPoint,
    pub signature_script: ByteArray,
    pub witness: Array<ByteArray>,
    pub sequence: u32,
}

#[derive(Drop, Clone, Default)]
pub struct EngineTransactionOutput {
    pub value: i64,
    pub publickey_script: ByteArray,
}

// TODO: Move these EngineTransaction structs to the testing dir after
// signature::transaction_procedure cleanup
#[derive(Drop, Clone)]
pub struct EngineTransaction {
    pub version: i32,
    pub transaction_inputs: Array<EngineTransactionInput>,
    pub transaction_outputs: Array<EngineTransactionOutput>,
    pub locktime: u32,
    // TODO replace UTXO by EngineTransactionOutput
    pub utxos: Array<UTXO>,
}

pub trait EngineInternalTransactionTrait {
    fn new(
        version: i32,
        transaction_inputs: Array<EngineTransactionInput>,
        transaction_outputs: Array<EngineTransactionOutput>,
        locktime: u32,
        utxos: Array<UTXO>,
    ) -> EngineTransaction;
    fn new_signed(
        script_sig: ByteArray, pubkey_script: ByteArray, utxos: Array<UTXO>,
    ) -> EngineTransaction;
    fn new_signed_witness(
        script_sig: ByteArray,
        pubkey_script: ByteArray,
        witness: Array<ByteArray>,
        value: i64,
        utxos: Array<UTXO>,
    ) -> EngineTransaction;
    fn btc_decode(raw: ByteArray, encoding: u32, utxos: Array<UTXO>) -> EngineTransaction;
    fn deserialize(raw: ByteArray, utxos: Array<UTXO>) -> EngineTransaction;
    fn deserialize_no_witness(raw: ByteArray, utxos: Array<UTXO>) -> EngineTransaction;
    fn btc_encode(self: EngineTransaction, encoding: u32) -> ByteArray;
    fn serialize(self: EngineTransaction) -> ByteArray;
    fn serialize_no_witness(self: EngineTransaction) -> ByteArray;
    fn calculate_block_subsidy(block_height: u32) -> i64;
    fn is_coinbase(self: @EngineTransaction) -> bool;
    fn validate_coinbase(
        self: EngineTransaction, block_height: u32, total_fees: i64,
    ) -> Result<(), felt252>;
    fn print(self: @EngineTransaction);
}

pub const BASE_ENCODING: u32 = 0x01;
pub const WITNESS_ENCODING: u32 = 0x02;

pub impl EngineInternalTransactionImpl of EngineInternalTransactionTrait {
    fn new(
        version: i32,
        transaction_inputs: Array<EngineTransactionInput>,
        transaction_outputs: Array<EngineTransactionOutput>,
        locktime: u32,
        utxos: Array<UTXO>,
    ) -> EngineTransaction {
        EngineTransaction {
            version: version,
            transaction_inputs: transaction_inputs,
            transaction_outputs: transaction_outputs,
            locktime: locktime,
            utxos: utxos,
        }
    }

    fn new_signed(
        script_sig: ByteArray, pubkey_script: ByteArray, utxos: Array<UTXO>,
    ) -> EngineTransaction {
        let coinbase_tx_inputs = array![
            EngineTransactionInput {
                previous_outpoint: EngineOutPoint { txid: 0x0, vout: 0xffffffff },
                signature_script: "\x00\x00",
                witness: array![],
                sequence: 0xffffffff,
            },
        ];
        let coinbase_tx_outputs = array![
            EngineTransactionOutput { value: 0, publickey_script: pubkey_script },
        ];
        let coinbase_tx = EngineTransaction {
            version: 1,
            transaction_inputs: coinbase_tx_inputs,
            transaction_outputs: coinbase_tx_outputs,
            locktime: 0,
            utxos: Default::default(),
        };
        let coinbase_bytes = coinbase_tx.serialize_no_witness();
        let coinbase_txid = double_sha256(@coinbase_bytes);
        let transaction = EngineTransaction {
            version: 1,
            transaction_inputs: array![
                EngineTransactionInput {
                    previous_outpoint: EngineOutPoint { txid: coinbase_txid, vout: 0 },
                    signature_script: script_sig,
                    witness: array![],
                    sequence: 0xffffffff,
                },
            ],
            transaction_outputs: array![EngineTransactionOutput { value: 0, publickey_script: "" }],
            locktime: 0,
            utxos: utxos,
        };
        // let transaction = EngineTransaction {
        //     version: 1,
        //     transaction_inputs: array![
        //         EngineTransactionInput {
        //             previous_outpoint: EngineOutPoint { txid: 0x0, vout: 0, },
        //             signature_script: script_sig,
        //             witness: array![],
        //             sequence: 0xffffffff,
        //         }
        //     ],
        //     transaction_outputs: array![],
        //     locktime: 0,
        // };
        transaction
    }

    fn new_signed_witness(
        script_sig: ByteArray,
        pubkey_script: ByteArray,
        witness: Array<ByteArray>,
        value: i64,
        utxos: Array<UTXO>,
    ) -> EngineTransaction {
        let coinbase_tx_inputs = array![
            EngineTransactionInput {
                previous_outpoint: EngineOutPoint { txid: 0x0, vout: 0xffffffff },
                signature_script: "\x00\x00",
                witness: array![],
                sequence: 0xffffffff,
            },
        ];
        let coinbase_tx_outputs = array![
            EngineTransactionOutput { value: value, publickey_script: pubkey_script },
        ];
        let coinbase_tx = EngineTransaction {
            version: 1,
            transaction_inputs: coinbase_tx_inputs,
            transaction_outputs: coinbase_tx_outputs,
            locktime: 0,
            utxos: Default::default(),
        };
        let coinbase_bytes = coinbase_tx.serialize_no_witness();
        let coinbase_txid = double_sha256(@coinbase_bytes);
        let transaction = EngineTransaction {
            version: 1,
            transaction_inputs: array![
                EngineTransactionInput {
                    previous_outpoint: EngineOutPoint { txid: coinbase_txid, vout: 0 },
                    signature_script: script_sig,
                    witness: witness,
                    sequence: 0xffffffff,
                },
            ],
            transaction_outputs: array![
                EngineTransactionOutput { value: value, publickey_script: "" },
            ],
            locktime: 0,
            utxos: utxos,
        };
        transaction
    }

    // Deserialize a transaction from a byte array.
    fn btc_decode(raw: ByteArray, encoding: u32, utxos: Array<UTXO>) -> EngineTransaction {
        let mut offset: usize = 0;
        let version: i32 = byte_array_value_at_le(@raw, ref offset, 4).try_into().unwrap();
        if encoding == WITNESS_ENCODING {
            // consume flags
            offset += 2;
        }
        let input_len = read_var_int(@raw, ref offset);
        // TODO: Error handling and bounds checks
        // TODO: Byte orderings
        let mut i = 0;
        let mut inputs: Array<EngineTransactionInput> = array![];
        while i != input_len {
            let tx_id = u256 {
                high: byte_array_value_at_be(@raw, ref offset, 16).try_into().unwrap(),
                low: byte_array_value_at_be(@raw, ref offset, 16).try_into().unwrap(),
            };
            let vout: u32 = byte_array_value_at_le(@raw, ref offset, 4).try_into().unwrap();
            let script_len = read_var_int(@raw, ref offset).try_into().unwrap();
            let script = sub_byte_array(@raw, ref offset, script_len);
            let sequence: u32 = byte_array_value_at_le(@raw, ref offset, 4).try_into().unwrap();
            let input = EngineTransactionInput {
                previous_outpoint: EngineOutPoint { txid: tx_id, vout: vout },
                signature_script: script,
                witness: array![],
                sequence: sequence,
            };
            inputs.append(input);
            i += 1;
        };

        let output_len = read_var_int(@raw, ref offset);
        let mut i = 0;
        let mut outputs: Array<EngineTransactionOutput> = array![];
        while i != output_len {
            // TODO: negative values
            let value: i64 = byte_array_value_at_le(@raw, ref offset, 8).try_into().unwrap();
            let script_len = read_var_int(@raw, ref offset).try_into().unwrap();
            let script = sub_byte_array(@raw, ref offset, script_len);
            let output = EngineTransactionOutput { value: value, publickey_script: script };
            outputs.append(output);
            i += 1;
        };

        let mut inputs_with_witness: Array<EngineTransactionInput> = array![];

        if encoding == WITNESS_ENCODING {
            // one witness for each input
            i = 0;
            while i != input_len {
                let witness_count = read_var_int(@raw, ref offset);
                let mut j = 0;
                let mut witness: Array<ByteArray> = array![];
                while j != witness_count {
                    let script_len = read_var_int(@raw, ref offset).try_into().unwrap();
                    let script = sub_byte_array(@raw, ref offset, script_len);
                    witness.append(script);
                    j += 1;
                };
                // update Transaction Input
                let input = inputs.at(i.try_into().unwrap());
                let mut input_with_witness = input.clone();
                input_with_witness.witness = witness;
                inputs_with_witness.append(input_with_witness);
                i += 1;
            };
        }
        let locktime: u32 = byte_array_value_at_le(@raw, ref offset, 4).try_into().unwrap();

        if encoding == WITNESS_ENCODING {
            EngineTransaction {
                version: version,
                transaction_inputs: inputs_with_witness,
                transaction_outputs: outputs,
                locktime: locktime,
                utxos: utxos,
            }
        } else {
            EngineTransaction {
                version: version,
                transaction_inputs: inputs,
                transaction_outputs: outputs,
                locktime: locktime,
                utxos: utxos,
            }
        }
    }

    fn deserialize(raw: ByteArray, utxos: Array<UTXO>) -> EngineTransaction {
        let mut offset: usize = 0;
        let _version: i32 = byte_array_value_at_le(@raw, ref offset, 4).try_into().unwrap();
        let flags: u16 = byte_array_value_at_le(@raw, ref offset, 2).try_into().unwrap();
        if flags == 0x100 {
            Self::btc_decode(raw, WITNESS_ENCODING, utxos)
        } else {
            Self::btc_decode(raw, BASE_ENCODING, utxos)
        }
    }

    fn deserialize_no_witness(raw: ByteArray, utxos: Array<UTXO>) -> EngineTransaction {
        Self::btc_decode(raw, BASE_ENCODING, utxos)
    }

    // Serialize the transaction data for hashing based on encoding used.
    fn btc_encode(self: EngineTransaction, encoding: u32) -> ByteArray {
        let mut bytes = "";
        bytes.append_word_rev(self.version.into(), 4);
        // TODO: Witness encoding

        // Serialize each input in the transaction.
        let input_len: usize = self.transaction_inputs.len();
        write_var_int(ref bytes, input_len.into());
        let mut i: usize = 0;
        while i != input_len {
            let input: @EngineTransactionInput = self.transaction_inputs.at(i);
            let input_txid: u256 = *input.previous_outpoint.txid;
            let vout: u32 = *input.previous_outpoint.vout;
            let script: @ByteArray = input.signature_script;
            let script_len: usize = script.len();
            let sequence: u32 = *input.sequence;

            bytes.append_word(input_txid.high.into(), 16);
            bytes.append_word(input_txid.low.into(), 16);
            bytes.append_word_rev(vout.into(), 4);
            write_var_int(ref bytes, script_len.into());
            bytes.append(script);
            bytes.append_word_rev(sequence.into(), 4);

            i += 1;
        };

        // Serialize each output in the transaction.
        let output_len: usize = self.transaction_outputs.len();
        write_var_int(ref bytes, output_len.into());
        i = 0;
        while i != output_len {
            let output: @EngineTransactionOutput = self.transaction_outputs.at(i);
            let value: i64 = *output.value;
            let script: @ByteArray = output.publickey_script;
            let script_len: usize = script.len();

            bytes.append_word_rev(value.into(), 8);
            write_var_int(ref bytes, script_len.into());
            bytes.append(script);

            i += 1;
        };

        bytes.append_word_rev(self.locktime.into(), 4);
        bytes
    }

    fn serialize(self: EngineTransaction) -> ByteArray {
        self.btc_encode(WITNESS_ENCODING)
    }

    fn serialize_no_witness(self: EngineTransaction) -> ByteArray {
        self.btc_encode(BASE_ENCODING)
    }

    fn calculate_block_subsidy(block_height: u32) -> i64 {
        let halvings = block_height / 210000;
        shr::<i64, u32>(5000000000, halvings)
    }

    fn is_coinbase(self: @EngineTransaction) -> bool {
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
        self: EngineTransaction, block_height: u32, total_fees: i64,
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

    fn print(self: @EngineTransaction) {
        println!("Version: {}", self.version);
        println!("Locktime: {}", self.locktime);
        println!("Inputs: {}", self.transaction_inputs.len());
        let mut i = 0;
        while i != self.transaction_inputs.len() {
            let input = self.transaction_inputs.at(i);
            println!(
                "  Input {}: {} {}", i, input.previous_outpoint.txid, input.previous_outpoint.vout,
            );
            println!("    Txid: {}", input.previous_outpoint.txid);
            println!("    Vout: {}", input.previous_outpoint.vout);
            println!("    Script: {}", bytecode_to_hex(input.signature_script));
            println!("    Sequence: {}", input.sequence);
            println!("    Witness: {}", input.witness.len());
            let mut j = 0;
            while j != input.witness.len() {
                println!("      Witness {}: {}", j, bytecode_to_hex(input.witness.at(j)));
                j += 1;
            };
            i += 1;
        };
        println!("Outputs: {}", self.transaction_outputs.len());
        i = 0;
        while i != self.transaction_outputs.len() {
            let output = self.transaction_outputs.at(i);
            println!("  Output {}: {}", i, output.value);
            println!("    Script: {}", bytecode_to_hex(output.publickey_script));
            println!("    Value: {}", output.value);
            i += 1;
        };
    }
}

impl TransactionDefault of Default<EngineTransaction> {
    fn default() -> EngineTransaction {
        let default_txin = EngineTransactionInput {
            previous_outpoint: EngineOutPoint { txid: 0, vout: 0 },
            signature_script: "",
            witness: array![],
            sequence: 0xffffffff,
        };
        let transaction = EngineTransaction {
            version: 0,
            transaction_inputs: array![default_txin],
            transaction_outputs: array![],
            locktime: 0,
            utxos: Default::default(),
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

pub impl EngineTransactionInputTraitInternalImpl of EngineTransactionInputTrait<
    EngineTransactionInput,
> {
    fn get_prevout_txid(self: @EngineTransactionInput) -> u256 {
        *self.previous_outpoint.txid
    }

    fn get_prevout_vout(self: @EngineTransactionInput) -> u32 {
        *self.previous_outpoint.vout
    }

    fn get_signature_script(self: @EngineTransactionInput) -> @ByteArray {
        self.signature_script
    }

    fn get_witness(self: @EngineTransactionInput) -> Span<ByteArray> {
        self.witness.span()
    }

    fn get_sequence(self: @EngineTransactionInput) -> u32 {
        *self.sequence
    }
}

pub trait EngineTransactionOutputTrait<O> {
    fn get_publickey_script(self: @O) -> @ByteArray;
    fn get_value(self: @O) -> i64;
}

pub impl EngineTransactionOutputTraitInternalImpl of EngineTransactionOutputTrait<
    EngineTransactionOutput,
> {
    fn get_publickey_script(self: @EngineTransactionOutput) -> @ByteArray {
        self.publickey_script
    }

    fn get_value(self: @EngineTransactionOutput) -> i64 {
        *self.value
    }
}

pub trait EngineTransactionTrait<
    T, I, O, +EngineTransactionInputTrait<I>, +EngineTransactionOutputTrait<O>,
> {
    fn get_version(self: @T) -> i32;
    fn get_transaction_inputs(self: @T) -> Span<I>;
    fn get_transaction_outputs(self: @T) -> Span<O>;
    fn get_locktime(self: @T) -> u32;
    fn get_transaction_utxos(self: @T) -> Array<UTXO>; //Span?
    fn get_input_utxo(self: @T, input_index: u32) -> UTXO;
}

pub impl EngineTransactionTraitInternalImpl of EngineTransactionTrait<
    EngineTransaction,
    EngineTransactionInput,
    EngineTransactionOutput,
    EngineTransactionInputTraitInternalImpl,
    EngineTransactionOutputTraitInternalImpl,
> {
    fn get_version(self: @EngineTransaction) -> i32 {
        *self.version
    }

    fn get_transaction_inputs(self: @EngineTransaction) -> Span<EngineTransactionInput> {
        self.transaction_inputs.span()
    }

    fn get_transaction_outputs(self: @EngineTransaction) -> Span<EngineTransactionOutput> {
        self.transaction_outputs.span()
    }

    fn get_locktime(self: @EngineTransaction) -> u32 {
        *self.locktime
    }

    fn get_transaction_utxos(self: @EngineTransaction) -> Array<UTXO> {
        self.utxos.clone()
    }

    fn get_input_utxo(self: @EngineTransaction, input_index: u32) -> UTXO {
        self.get_transaction_utxos().at(input_index).clone()
    }
}
