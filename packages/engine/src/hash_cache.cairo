use crate::transaction::{
    EngineTransactionInputTrait, EngineTransactionOutputTrait, EngineTransactionTrait
};
use shinigami_utils::{bytecode::{write_var_int}, hash::{hash_to_u256, sha256_u256, simple_sha256},};
use core::sha256::compute_sha256_byte_array;
use crate::signature::utils::is_witness_v1_pub_key_hash;
use core::dict::Felt252Dict;

// SegwitSigHashMidstate is the sighash midstate used in the base segwit
// sighash calculation as defined in BIP 143.
#[derive(Clone, Copy, Drop, Default)]
pub struct SegwitSigHashMidstate {
    pub hash_prevouts_v0: u256,
    pub hash_sequence_v0: u256,
    pub hash_outputs_v0: u256
}

// TaprootSigHashMidState is the sighash midstate used to compute taproot and
// tapscript signatures as defined in BIP 341.
#[derive(Clone, Copy, Drop, Default)]
pub struct TaprootSigHashMidState {
    pub hash_prevouts_v1: u256,
    pub hash_sequence_v1: u256,
    pub hash_outputs_v1: u256,
    pub hash_input_scripts_v1: u256,
    pub hash_input_amounts_v1: u256
}

pub trait SigHashMidstateTrait<
    I,
    O,
    T,
    +EngineTransactionInputTrait<I>,
    +EngineTransactionOutputTrait<O>,
    +EngineTransactionTrait<T, I, O>
> {
    fn new(transaction: @T) -> TxSigHashes;
    fn calc_hash_inputs_amount(transaction: @T) -> u256;
    fn calc_hash_input_scripts(transaction: @T) -> u256;
}

// TxSigHashes houses the partial set of sighashes introduced within BIP0143.
#[derive(Drop, Default)]
pub enum TxSigHashes {
    Segwit: @SegwitSigHashMidstate,
    #[default] // make sense ? for TaprootSigVerifierTrait::empty()
    Taproot: @TaprootSigHashMidState
}

pub impl SigHashMidstateImpl<
    I,
    O,
    T,
    impl IEngineTransactionInput: EngineTransactionInputTrait<I>,
    impl IEngineTransactionOutput: EngineTransactionOutputTrait<O>,
    impl IEngineTransaction: EngineTransactionTrait<
        T, I, O, IEngineTransactionInput, IEngineTransactionOutput
    >
> of SigHashMidstateTrait<I, O, T> {
    fn new(transaction: @T) -> TxSigHashes {
        let mut hasV0Inputs = false;
        let mut hasV1Inputs = false;

        let prevout: ByteArray = Default::default();
        for _ in transaction
            .get_transaction_inputs() {
                if is_witness_v1_pub_key_hash(@prevout) {
                    hasV1Inputs = true;
                } else {
                    hasV0Inputs = true;
                }

                if hasV0Inputs && hasV1Inputs {
                    break;
                }
            };

        // compute v0 hash midstate
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

        if hasV0Inputs {
            return TxSigHashes::Segwit(
                @SegwitSigHashMidstate {
                    hash_prevouts_v0: sha256_u256(hashPrevOutsV1),
                    hash_sequence_v0: sha256_u256(hashSequenceV1),
                    hash_outputs_v0: sha256_u256(hashOutputsV1)
                }
            );
        } else {
            let hash_input_amounts_v1 = Self::calc_hash_inputs_amount(transaction);
            let hash_input_scripts_v1 = Self::calc_hash_input_scripts(transaction);

            return TxSigHashes::Taproot(
                @TaprootSigHashMidState {
                    hash_prevouts_v1: hash_to_u256(hashPrevOutsV1),
                    hash_sequence_v1: hash_to_u256(hashSequenceV1),
                    hash_outputs_v1: hash_to_u256(hashOutputsV1),
                    hash_input_scripts_v1: hash_input_scripts_v1,
                    hash_input_amounts_v1: hash_input_amounts_v1
                }
            );
        }
    }

    fn calc_hash_inputs_amount(transaction: @T) -> u256 {
        let mut buffer: ByteArray = "";
        let inputs = transaction.get_transaction_inputs();

        // TODO: need prevoutput amount from cache;
        for _input in inputs {};

        return simple_sha256(@buffer);
    }

    fn calc_hash_input_scripts(transaction: @T) -> u256 {
        let mut buffer: ByteArray = "";
        let inputs = transaction.get_transaction_inputs();

        // TODO need prevoutput script from cache
        for _input in inputs {};

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


// TODO
#[derive(Destruct, Default)]
pub struct HashCache<T> {
    // use dict ? index = hash = u256 != felt
    sigHashes: Felt252Dict<Nullable<TxSigHashes>>
}

// HashCache caches the midstate of segwit v0 and v1 sighashes
pub trait HashCacheTrait<
    I,
    O,
    T,
    +EngineTransactionInputTrait<I>,
    +EngineTransactionOutputTrait<O>,
    +EngineTransactionTrait<T, I, O>
> {
    fn new(transaction: @T) -> HashCache<T>;
    // fn addSigHashes?

    // v0 represents sighash midstate used in the base segwit signatures BIP-143
    fn get_hash_prevouts_v0(self: @HashCache<T>) -> u256;
    fn get_hash_sequence_v0(self: @HashCache<T>) -> u256;
    fn get_hash_outputs_v0(self: @HashCache<T>) -> u256;

    // v1 represents sighash midstate used to compute taproot signatures BIP-341
    fn get_hash_prevouts_v1(self: @HashCache<T>) -> u256;
    fn get_hash_sequence_v1(self: @HashCache<T>) -> u256;
    fn get_hash_outputs_v1(self: @HashCache<T>) -> u256;
    fn get_hash_input_scripts_v1(self: @HashCache<T>) -> u256;
}

pub impl HashCacheImpl<
    I,
    O,
    T,
    impl IEngineTransactionInput: EngineTransactionInputTrait<I>,
    impl IEngineTransactionOutput: EngineTransactionOutputTrait<O>,
    impl IEngineTransaction: EngineTransactionTrait<
        T, I, O, IEngineTransactionInput, IEngineTransactionOutput
    >
> of HashCacheTrait<I, O, T> {
    fn new(transaction: @T) -> HashCache<T> {
        HashCache { sigHashes: Default::default() }
    }

    fn get_hash_prevouts_v0(self: @HashCache<T>) -> u256 {
        0
    }

    fn get_hash_sequence_v0(self: @HashCache<T>) -> u256 {
        0
    }

    fn get_hash_outputs_v0(self: @HashCache<T>) -> u256 {
        0
    }

    fn get_hash_prevouts_v1(self: @HashCache<T>) -> u256 {
        0
    }

    fn get_hash_sequence_v1(self: @HashCache<T>) -> u256 {
        0
    }

    fn get_hash_outputs_v1(self: @HashCache<T>) -> u256 {
        0
    }

    fn get_hash_input_scripts_v1(self: @HashCache<T>) -> u256 {
        0
    }
}
