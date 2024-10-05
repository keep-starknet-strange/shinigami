use crate::transaction::{
    EngineTransactionInputTrait, EngineTransactionOutputTrait, EngineTransactionTrait
};

// SigCache implements an Schnorr+ECDSA signature verification cache. Only valid signatures will be
// added to the cache.
pub trait SigCacheTrait<S> {
    // Returns true if sig cache contains sig_hash corresponding to signature and public key
    fn exists(sig_hash: u256, signature: ByteArray, pub_key: ByteArray) -> bool;
    // Adds a signature to the cache
    fn add(sig_hash: u256, signature: ByteArray, pub_key: ByteArray);
}

// TODO
#[derive(Drop)]
pub struct HashCache<T> { }

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
    impl IEngineTransaction: EngineTransactionTrait<T, I, O, IEngineTransactionInput, IEngineTransactionOutput>
> of HashCacheTrait<I, O, T> {
    fn new(transaction: @T) -> HashCache<T> {
        HashCache { }
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
