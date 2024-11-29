use crate::transaction::{
    EngineTransactionInputTrait, EngineTransactionOutputTrait, EngineTransactionTrait
};
use shinigami_utils::bytecode::write_var_int;
use shinigami_utils::hash::double_sha256;

#[derive(Clone, Copy, Drop, Default)]
pub struct SegwitSigHashMidstate {
    pub hash_prevouts_v0: u256,
    pub hash_sequence_v0: u256,
    pub hash_outputs_v0: u256
}

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
    // fn new_taproot(transaction: @T) -> TaprootSigHashMidState;
}

#[derive(Drop)]
pub enum TxSigHashes {
    Segwit: @SegwitSigHashMidstate,
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
        return TxSigHashes::Segwit(
            @SegwitSigHashMidstate {
                hash_prevouts_v0: double_sha256(@prevouts_v0_bytes),
                hash_sequence_v0: double_sha256(@sequence_v0_bytes),
                hash_outputs_v0: double_sha256(@outputs_v0_bytes)
            }
        );
    }
    // fn new_taproot(transaction: @T) -> TaprootSigHashMidState {
//     let mut prevouts_v1_bytes: ByteArray = "";
//     let inputs = transaction.get_transaction_inputs();
//     for input in inputs {
//         let txid = input.get_prevout_txid();
//         prevouts_v1_bytes.append_word(txid.high.into(), 16);
//         prevouts_v1_bytes.append_word(txid.low.into(), 16);
//         prevouts_v1_bytes.append_word_rev(input.get_prevout_vout().into(), 4);
//     };
//     let mut sequence_v1_bytes: ByteArray = "";
//     for input in inputs {
//         sequence_v1_bytes.append_word_rev(input.get_sequence().into(), 4);
//     };
//     let mut outputs_v1_bytes: ByteArray = "";
//     let outputs = transaction.get_transaction_outputs();
//     for output in outputs {
//         outputs_v1_bytes.append_word_rev(output.get_value().into(), 8);
//         write_var_int(ref outputs_v1_bytes, output.get_publickey_script().len().into());
//         outputs_v1_bytes.append(output.get_publickey_script());
//     };
//     let mut input_scripts_v1_bytes: ByteArray = "";
//     for input in inputs {
//         write_var_int(ref input_scripts_v1_bytes, input.get_script().len().into());
//         input_scripts_v1_bytes.append(input.get_script());
//     };
//     let mut input_amounts_v1_bytes: ByteArray = "";
//     for input in inputs {
//         input_amounts_v1_bytes.append_word_rev(input.get_amount().into(), 8);
//     };
//     TaprootSigHashMidState {
//         hash_prevouts_v1: double_sha256(@prevouts_v1_bytes),
//         hash_sequence_v1: double_sha256(@sequence_v1_bytes),
//         hash_outputs_v1: double_sha256(@outputs_v1_bytes),
//         hash_input_scripts_v1: double_sha256(@input_scripts_v1_bytes),
//         hash_input_amounts_v1: double_sha256(@input_amounts_v1_bytes)
//     }
// }
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
#[derive(Drop, Default)]
pub struct HashCache<T> {}

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
        HashCache {}
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
