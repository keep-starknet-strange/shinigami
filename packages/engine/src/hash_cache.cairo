use crate::transaction::{
    EngineTransactionInputTrait, EngineTransactionOutputTrait, EngineTransactionTrait,
};
use crate::flags::ScriptFlags;

use shinigami_utils::{bytecode::{write_var_int}, hash::{hash_to_u256, sha256_u256, simple_sha256}};
use core::sha256::compute_sha256_byte_array;
use crate::signature::utils::is_witness_v1_pub_key_hash;

// SegwitSigHashMidstate is the sighash midstate used in the base segwit
// sighash calculation as defined in BIP 143.
#[derive(Clone, Copy, Drop, Default)]
pub struct SegwitSigHashMidstate {
    pub hash_prevouts_v0: u256,
    pub hash_sequence_v0: u256,
    pub hash_outputs_v0: u256,
}

// TaprootSigHashMidState is the sighash midstate used to compute taproot and
// tapscript signatures as defined in BIP 341.
#[derive(Clone, Copy, Drop, Default)]
pub struct TaprootSigHashMidState {
    pub hash_prevouts_v1: u256,
    pub hash_sequence_v1: u256,
    pub hash_outputs_v1: u256,
    pub hash_input_scripts_v1: u256,
    pub hash_input_amounts_v1: u256,
}

pub trait SigHashMidstateTrait<T> {
    fn new(transaction: @T) -> @TxSigHashes;
    fn calc_hash_inputs_amount(transaction: @T) -> u256;
    fn calc_hash_input_scripts(transaction: @T) -> u256;
}

// TxSigHashes houses the partial set of sighashes introduced within BIP0143.
pub impl SigHashMidstateImpl<
    I,
    O,
    T,
    impl IEngineTransactionInput: EngineTransactionInputTrait<I>,
    impl IEngineTransactionOutput: EngineTransactionOutputTrait<O>,
    impl IEngineTransaction: EngineTransactionTrait<
        T, I, O, IEngineTransactionInput, IEngineTransactionOutput,
    >,
> of SigHashMidstateTrait<T> {
    fn new(transaction: @T) -> @TxSigHashes {
        let mut hasV0Inputs = false;
        let mut hasV1Inputs = false;

        for i in 0..transaction.get_transaction_inputs().len() {
            let input = transaction.get_transaction_inputs()[i];
            let input_txid = input.get_prevout_txid();
            let input_vout = input.get_prevout_vout();

            if (input_vout == 0xFFFFFFFF && input_txid == 0) {
                hasV0Inputs = true;
                continue;
            }

            let utxo = transaction.get_input_utxo(i);
            if is_witness_v1_pub_key_hash(utxo.get_publickey_script()) {
                hasV1Inputs = true;
            } else {
                hasV0Inputs = true;
            }

            if hasV0Inputs && hasV1Inputs {
                break;
            }
        };

        let mut prevouts_v0_bytes: ByteArray = "";
        let inputs = transaction.get_transaction_inputs();
        for input in inputs {
            let txid = input.get_prevout_txid();
            prevouts_v0_bytes.append_word(txid.high.into(), 16);
            prevouts_v0_bytes.append_word(txid.low.into(), 16);
            prevouts_v0_bytes.append_word_rev(input.get_prevout_vout().into(), 4);
        };
        let mut sequence_v0_bytes: ByteArray = "";
        for input in inputs {
            sequence_v0_bytes.append_word_rev(input.get_sequence().into(), 4);
        };
        let mut outputs_v0_bytes: ByteArray = "";
        let outputs = transaction.get_transaction_outputs();
        for output in outputs {
            outputs_v0_bytes.append_word_rev(output.get_value().into(), 8);
            write_var_int(ref outputs_v0_bytes, output.get_publickey_script().len().into());
            outputs_v0_bytes.append(output.get_publickey_script());
        };

        let hashPrevOutsV1: [u32; 8] = compute_sha256_byte_array(@prevouts_v0_bytes);
        let hashSequenceV1: [u32; 8] = compute_sha256_byte_array(@sequence_v0_bytes);
        let hashOutputsV1: [u32; 8] = compute_sha256_byte_array(@outputs_v0_bytes);

        let mut txSigHashes: TxSigHashes = Default::default();
        if hasV0Inputs {
            txSigHashes
                .set_v0_sighash(
                    @SegwitSigHashMidstate {
                        hash_prevouts_v0: sha256_u256(hashPrevOutsV1),
                        hash_sequence_v0: sha256_u256(hashSequenceV1),
                        hash_outputs_v0: sha256_u256(hashOutputsV1),
                    },
                );
        }
        if hasV1Inputs {
            let hash_input_amounts_v1 = Self::calc_hash_inputs_amount(transaction);
            let hash_input_scripts_v1 = Self::calc_hash_input_scripts(transaction);

            txSigHashes
                .set_v1_sighash(
                    @TaprootSigHashMidState {
                        hash_prevouts_v1: hash_to_u256(hashPrevOutsV1),
                        hash_sequence_v1: hash_to_u256(hashSequenceV1),
                        hash_outputs_v1: hash_to_u256(hashOutputsV1),
                        hash_input_scripts_v1: hash_input_scripts_v1,
                        hash_input_amounts_v1: hash_input_amounts_v1,
                    },
                );
        }
        @txSigHashes
    }

    // calcHashInputAmounts computes a hash digest of the input amounts of all
    // inputs referenced in the passed transaction.
    fn calc_hash_inputs_amount(transaction: @T) -> u256 {
        let mut buffer: ByteArray = "";
        for i in 0..transaction.get_transaction_inputs().len() {
            let value = transaction.get_input_utxo(i).get_value();
            buffer.append_word_rev(value.into(), 8);
        };
        return simple_sha256(@buffer);
    }

    // calcHashInputScript computes the hash digest of all the previous input scripts
    // referenced by the passed transaction.
    fn calc_hash_input_scripts(transaction: @T) -> u256 {
        let mut buffer: ByteArray = "";
        for i in 0..transaction.get_transaction_inputs().len() {
            let script = transaction.get_input_utxo(i).get_publickey_script();
            write_var_int(ref buffer, script.len().into());
            buffer.append(script);
        };

        return simple_sha256(@buffer);
    }
}

// SigCache implements an Schnorr+ECDSA signature verification cache. Only valid signatures will be
// added to the cache.
pub trait SigCacheTrait<S> {
    // Returns true if sig cache contains sig_hash corresponding to signature and public key
    fn exists(sig_hash: u256, signature: ByteArray, pub_key: ByteArray) -> bool;
    // Adds a signature to the cache
    fn add(sig_hash: u256, signature: ByteArray, pub_key: ByteArray);
}
#[derive(Drop, Default, Copy)]
pub struct TxSigHashes {
    pub segwit: SegwitSigHashMidstate,
    pub taproot: TaprootSigHashMidState,
}

#[generate_trait]
pub impl TxSigHashesImpl of TxSigHashesTrait {
    fn new() -> TxSigHashes {
        TxSigHashes { segwit: Default::default(), taproot: Default::default() }
    }

    fn set_v0_sighash(ref self: TxSigHashes, sighash: @SegwitSigHashMidstate) {
        self.segwit = *sighash;
    }

    fn set_v1_sighash(ref self: TxSigHashes, sighash: @TaprootSigHashMidState) {
        self.taproot = *sighash;
    }

    fn get_hash_prevouts_v0(self: @TxSigHashes) -> u256 {
        *self.segwit.hash_prevouts_v0
    }

    fn get_hash_sequence_v0(self: @TxSigHashes) -> u256 {
        *self.segwit.hash_sequence_v0
    }

    fn get_hash_outputs_v0(self: @TxSigHashes) -> u256 {
        *self.segwit.hash_outputs_v0
    }

    fn get_hash_prevouts_v1(self: @TxSigHashes) -> u256 {
        *self.taproot.hash_prevouts_v1
    }

    fn get_hash_sequence_v1(self: @TxSigHashes) -> u256 {
        *self.taproot.hash_sequence_v1
    }

    fn get_hash_outputs_v1(self: @TxSigHashes) -> u256 {
        *self.taproot.hash_outputs_v1
    }

    fn get_hash_input_amounts_v1(self: @TxSigHashes) -> u256 {
        *self.taproot.hash_input_amounts_v1
    }

    fn get_hash_input_scripts_v1(self: @TxSigHashes) -> u256 {
        *self.taproot.hash_input_scripts_v1
    }
}

#[derive(Drop, Default)]
pub struct HashCache<T> {
    pub sigHashes: Option<@TxSigHashes>,
}

pub trait HashCacheTrait<
    I,
    O,
    T,
    impl IEngineTransactionInput: EngineTransactionInputTrait<I>,
    impl IEngineTransactionOutput: EngineTransactionOutputTrait<O>,
    impl IEngineTransaction: EngineTransactionTrait<
        T, I, O, IEngineTransactionInput, IEngineTransactionOutput,
    >,
> {
    fn new(tx: @T, flags: u32) -> HashCache<T>;
    fn get_sig_hashes(self: @HashCache<T>) -> Option<@TxSigHashes>;
    fn get_hash_prevouts_v0(self: @HashCache<T>) -> u256;
    fn get_hash_sequence_v0(self: @HashCache<T>) -> u256;
    fn get_hash_outputs_v0(self: @HashCache<T>) -> u256;
    fn get_hash_prevouts_v1(self: @HashCache<T>) -> u256;
    fn get_hash_sequence_v1(self: @HashCache<T>) -> u256;
    fn get_hash_outputs_v1(self: @HashCache<T>) -> u256;
    fn get_hash_input_amounts_v1(self: @HashCache<T>) -> u256;
    fn get_hash_input_scripts_v1(self: @HashCache<T>) -> u256;
}

pub impl HashCacheImpl<
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
> of HashCacheTrait<I, O, T> {
    fn new(tx: @T, flags: u32) -> HashCache<T> {
        let segwit_active = flags
            & ScriptFlags::ScriptVerifyWitness.into() == ScriptFlags::ScriptVerifyWitness.into();

        let mut has_witness = false;
        for input in tx.get_transaction_inputs() {
            if input.get_witness().len() != 0 {
                has_witness = true;
                break;
            }
        };

        if (segwit_active && has_witness) {
            return HashCache { sigHashes: Option::Some(SigHashMidstateTrait::new(tx)) };
        }
        return HashCache { sigHashes: Default::default() };
    }

    fn get_sig_hashes(self: @HashCache<T>) -> Option<@TxSigHashes> {
        *self.sigHashes
    }

    fn get_hash_prevouts_v0(self: @HashCache<T>) -> u256 {
        self.get_sig_hashes().unwrap().get_hash_prevouts_v0()
    }

    fn get_hash_sequence_v0(self: @HashCache<T>) -> u256 {
        self.get_sig_hashes().unwrap().get_hash_sequence_v0()
    }

    fn get_hash_outputs_v0(self: @HashCache<T>) -> u256 {
        self.get_sig_hashes().unwrap().get_hash_outputs_v0()
    }

    fn get_hash_prevouts_v1(self: @HashCache<T>) -> u256 {
        self.get_sig_hashes().unwrap().get_hash_prevouts_v1()
    }

    fn get_hash_sequence_v1(self: @HashCache<T>) -> u256 {
        self.get_sig_hashes().unwrap().get_hash_sequence_v1()
    }

    fn get_hash_outputs_v1(self: @HashCache<T>) -> u256 {
        self.get_sig_hashes().unwrap().get_hash_outputs_v1()
    }

    fn get_hash_input_amounts_v1(self: @HashCache<T>) -> u256 {
        self.get_sig_hashes().unwrap().get_hash_input_amounts_v1()
    }

    fn get_hash_input_scripts_v1(self: @HashCache<T>) -> u256 {
        self.get_sig_hashes().unwrap().get_hash_input_scripts_v1()
    }
}
