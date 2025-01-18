use crate::transaction::{
    EngineTransactionInputTrait, EngineTransactionOutputTrait, EngineTransactionTrait,
};
use shinigami_utils::{bytecode::{write_var_int}, hash::{hash_to_u256, sha256_u256, simple_sha256}};
use core::sha256::compute_sha256_byte_array;
use crate::signature::utils::is_witness_v1_pub_key_hash;
use core::dict::Felt252Dict;

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

pub trait SigHashMidstateTrait<
    I,
    O,
    T,
    +EngineTransactionInputTrait<I>,
    +EngineTransactionOutputTrait<O>,
    +EngineTransactionTrait<T, I, O>,
> {
    fn new(transaction: @T, tx_idx: u32) -> TxSigHashes;
    fn calc_hash_inputs_amount(transaction: @T) -> u256;
    fn calc_hash_input_scripts(transaction: @T) -> u256;
}

// TxSigHashes houses the partial set of sighashes introduced within BIP0143.
#[derive(Drop, Default)]
pub enum TxSigHashes {
    Segwit: @SegwitSigHashMidstate,
    #[default] // make sense ? for TaprootSigVerifierTrait::empty()
    Taproot: @TaprootSigHashMidState,
}

pub impl SigHashMidstateImpl<
    I,
    O,
    T,
    impl IEngineTransactionInput: EngineTransactionInputTrait<I>,
    impl IEngineTransactionOutput: EngineTransactionOutputTrait<O>,
    impl IEngineTransaction: EngineTransactionTrait<
        T, I, O, IEngineTransactionInput, IEngineTransactionOutput,
    >,
> of SigHashMidstateTrait<I, O, T> {
    fn new(transaction: @T, tx_idx: u32) -> TxSigHashes {
        let mut hasV0Inputs = false;
        let mut hasV1Inputs = false;

        let prevout: ByteArray = transaction.get_input_utxo(tx_idx).pubkey_script;
        for _ in transaction.get_transaction_inputs() {
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
                    hash_outputs_v0: sha256_u256(hashOutputsV1),
                },
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
                    hash_input_amounts_v1: hash_input_amounts_v1,
                },
            );
        }
    }

    // calcHashInputAmounts computes a hash digest of the input amounts of all
    // inputs referenced in the passed transaction.
    fn calc_hash_inputs_amount(transaction: @T) -> u256 {
        let mut buffer: ByteArray = "";
        for utxo in transaction.get_transaction_utxos() {
            buffer.append_word_rev(utxo.amount.into(), 8);
        };
        return simple_sha256(@buffer);
    }

    // calcHashInputScript computes the hash digest of all the previous input scripts
    // referenced by the passed transaction.
    fn calc_hash_input_scripts(transaction: @T) -> u256 {
        let mut buffer: ByteArray = "";
        for utxo in transaction.get_transaction_utxos() {
            write_var_int(ref buffer, utxo.pubkey_script.len().into());
            buffer.append(@utxo.pubkey_script);
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


// TODO
#[derive(Destruct, Default)]
pub struct HashCache<T> {
    // use dict ? index = hash = u256 != felt
    sigHashes: Felt252Dict<Nullable<TxSigHashes>>,
}

// HashCache caches the midstate of segwit v0 and v1 sighashes
pub trait HashCacheTrait<
    I,
    O,
    T,
    +EngineTransactionInputTrait<I>,
    +EngineTransactionOutputTrait<O>,
    +EngineTransactionTrait<T, I, O>,
> {
    fn new(transaction: @T) -> HashCache<T>;
    // fn add_sig_hashes(ref self: HashCache<T>, tx: @T);
    // fn get_sig_hashes(ref self: HashCache<T>, tx_hash: felt252) -> Option<TxSigHashes>;

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
        T, I, O, IEngineTransactionInput, IEngineTransactionOutput,
    >,
> of HashCacheTrait<I, O, T> {
    fn new(transaction: @T) -> HashCache<T> {
        HashCache { sigHashes: Default::default() }
    }

    // Add sighashes for a transaction
    // fn add_sig_hashes(ref self: HashCache<T>, tx: @T) {
    //     self
    //         .sigHashes
    //         .insert(tx.get_prevout_txid(), NullableTrait::new(SigHashMidstateTrait::new(tx)));
    // }

    // Get sighashes for a transaction
    // fn get_sig_hashes(ref self: HashCache, tx_hash: felt252) -> Option<TxSigHashes> {
    //     self.sig_hashes.get(tx_hash)
    // }

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

#[cfg(test)]
mod tests {
    use super::{SigHashMidstateTrait, TxSigHashes};
    use crate::transaction::{
        EngineTransactionOutput, EngineTransaction, EngineTransactionInput, EngineOutPoint,
    };
    use shinigami_engine::utxo::{UTXO};
    use shinigami_utils::bytecode::hex_to_bytecode;
    use shinigami_utils::byte_array::{U256IntoByteArray};

    // TODO replace UTXO by EngineTransactionOutput

    #[test]
    fn test_new_sigHashMidstate() {
        // https://github.com/bitcoin/bips/blob/master/bip-0341/wallet-test-vectors.json#l227
        println!("test_new_sigHashMidstate2");
        let transaction = EngineTransaction {
            version: 2,
            transaction_inputs: array![
                EngineTransactionInput {
                    previous_outpoint: EngineOutPoint {
                        txid: 0x7de20cbff686da83a54981d2b9bab3586f4ca7e48f57f5b55963115f3b334e9c_u256,
                        vout: 1,
                    },
                    signature_script: Default::default(),
                    sequence: 0x0,
                    witness: array![],
                },
                EngineTransactionInput {
                    previous_outpoint: EngineOutPoint {
                        txid: 0xd7b7cab57b1393ace2d064f4d4a2cb8af6def61273e127517d44759b6dafdd99_u256,
                        vout: 0,
                    },
                    signature_script: Default::default(),
                    sequence: 0xffffffff,
                    witness: array![],
                },
                EngineTransactionInput {
                    previous_outpoint: EngineOutPoint {
                        txid: 0xf8e1f583384333689228c5d28eac13366be082dc57441760d957275419a41842_u256,
                        vout: 0,
                    },
                    signature_script: Default::default(),
                    sequence: 0xffffffff,
                    witness: array![],
                },
                EngineTransactionInput {
                    previous_outpoint: EngineOutPoint {
                        txid: 0xf0689180aa63b30cb162a73c6d2a38b7eeda2a83ece74310fda0843ad604853b_u256,
                        vout: 1,
                    },
                    signature_script: Default::default(),
                    sequence: 0xfffffffe,
                    witness: array![],
                },
                EngineTransactionInput {
                    previous_outpoint: EngineOutPoint {
                        txid: 0xaa5202bdf6d8ccd2ee0f0202afbbb7461d9264a25e5bfd3c5a52ee1239e0ba6c_u256,
                        vout: 0,
                    },
                    signature_script: Default::default(),
                    sequence: 0xfffffffe,
                    witness: array![],
                },
                EngineTransactionInput {
                    previous_outpoint: EngineOutPoint {
                        txid: 0x956149bdc66faa968eb2be2d2faa29718acbfe3941215893a2a3446d32acd050_u256,
                        vout: 0,
                    },
                    signature_script: Default::default(),
                    sequence: 0x0,
                    witness: array![],
                },
                EngineTransactionInput {
                    previous_outpoint: EngineOutPoint {
                        txid: 0xe664b9773b88c09c32cb70a2a3e4da0ced63b7ba3b22f848531bbb1d5d5f4c94_u256,
                        vout: 1,
                    },
                    signature_script: Default::default(),
                    sequence: 0x0,
                    witness: array![],
                },
                EngineTransactionInput {
                    previous_outpoint: EngineOutPoint {
                        txid: 0xe9aa6b8e6c9de67619e6a3924ae25696bb7b694bb677a632a74ef7eadfd4eabf_u256,
                        vout: 0,
                    },
                    signature_script: Default::default(),
                    sequence: 0xffffffff,
                    witness: array![],
                },
                EngineTransactionInput {
                    previous_outpoint: EngineOutPoint {
                        txid: 0xa778eb6a263dc090464cd125c466b5a99667720b1c110468831d058aa1b82af1_u256,
                        vout: 1,
                    },
                    signature_script: Default::default(),
                    sequence: 0xffffffff,
                    witness: array![],
                },
            ],
            transaction_outputs: array![
                EngineTransactionOutput {
                    value: 0x000000003B9ACA00, // 10_00000000
                    publickey_script: hex_to_bytecode(
                        @"0x76a91406afd46bcdfd22ef94ac122aa11f241244a37ecc88ac",
                    ),
                },
                EngineTransactionOutput {
                    value: 0x00000000CB407880, //  34_10000000
                    publickey_script: hex_to_bytecode(
                        @"0xac9a87f5594be208f8532db38cff670c450ed2fea8fcdefcc9a663f78bab962b",
                    ),
                },
            ],
            locktime: 0x1DCD6500, //le
            utxos: array![
                UTXO {
                    amount: 420000000,
                    pubkey_script: hex_to_bytecode(
                        @"0x512053a1f6e454df1aa2776a2814a721372d6258050de330b3c6d10ee8f4e0dda343",
                    ),
                    block_height: Default::default(),
                },
                UTXO {
                    amount: 462000000,
                    pubkey_script: hex_to_bytecode(
                        @"0x5120147c9c57132f6e7ecddba9800bb0c4449251c92a1e60371ee77557b6620f3ea3",
                    ),
                    block_height: Default::default(),
                },
                UTXO {
                    amount: 294000000,
                    pubkey_script: hex_to_bytecode(
                        @"0x76a914751e76e8199196d454941c45d1b3a323f1433bd688ac",
                    ),
                    block_height: Default::default(),
                },
                UTXO {
                    amount: 504000000,
                    pubkey_script: hex_to_bytecode(
                        @"0x5120e4d810fd50586274face62b8a807eb9719cef49c04177cc6b76a9a4251d5450e",
                    ),
                    block_height: Default::default(),
                },
                UTXO {
                    amount: 630000000,
                    pubkey_script: hex_to_bytecode(
                        @"0x512091b64d5324723a985170e4dc5a0f84c041804f2cd12660fa5dec09fc21783605",
                    ),
                    block_height: Default::default(),
                },
                UTXO {
                    amount: 378000000,
                    pubkey_script: hex_to_bytecode(
                        @"0x00147dd65592d0ab2fe0d0257d571abf032cd9db93dc",
                    ),
                    block_height: Default::default(),
                },
                UTXO {
                    amount: 672000000,
                    pubkey_script: hex_to_bytecode(
                        @"0x512075169f4001aa68f15bbed28b218df1d0a62cbbcf1188c6665110c293c907b831",
                    ),
                    block_height: Default::default(),
                },
                UTXO {
                    amount: 546000000,
                    pubkey_script: hex_to_bytecode(
                        @"0x5120712447206d7a5238acc7ff53fbe94a3b64539ad291c7cdbc490b7577e4b17df5",
                    ),
                    block_height: Default::default(),
                },
                UTXO {
                    amount: 588000000,
                    pubkey_script: hex_to_bytecode(
                        @"0x512077e30a5522dd9f894c3f8b8bd4c4b2cf82ca7da8a3ea6a239655c39c050ab220",
                    ),
                    block_height: Default::default(),
                },
            ],
        };
        let tx_idx = 0;
        let sig_hash = SigHashMidstateTrait::new(@transaction, tx_idx);

        let expected_hash_prevouts =
            @0xe3b33bb4ef3a52ad1fffb555c0d82828eb22737036eaeb02a235d82b909c4c3f_u256;
        let expected_hash_sequence =
            @0x18959c7221ab5ce9e26c3cd67b22c24f8baa54bac281d8e6b05e400e6c3a957e_u256;
        let expected_hash_outputs =
            @0xa2e6dab7c1f0dcd297c8d61647fd17d821541ea69c3cc37dcbad7f90d4eb4bc5_u256;

        let exepected_hash_amount =
            @0x58a6964a4f5f8f0b642ded0a8a553be7622a719da71d1f5befcefcdee8e0fde6_u256;
        let expected_hash_script_pubkeys =
            @0x23ad0f61ad2bca5ba6a7693f50fce988e17c3780bf2b1e720cfbb38fbdd52e21_u256;

        match sig_hash {
            TxSigHashes::Taproot(sig_hash) => {
                assert_eq!(sig_hash.hash_prevouts_v1, expected_hash_prevouts);
                assert_eq!(sig_hash.hash_sequence_v1, expected_hash_sequence);
                assert_eq!(sig_hash.hash_outputs_v1, expected_hash_outputs);

                assert_eq!(sig_hash.hash_input_scripts_v1, expected_hash_script_pubkeys);
                assert_eq!(sig_hash.hash_input_amounts_v1, exepected_hash_amount);
            },
            _ => panic!("unexpected sighash type midstate"),
        }
    }
}
