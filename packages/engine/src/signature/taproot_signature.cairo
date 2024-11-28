use crate::engine::{Engine, EngineInternalImpl};
use crate::transaction::{
    EngineTransactionInputTrait, EngineTransactionOutputTrait, EngineTransactionTrait
};
use starknet::SyscallResultTrait;
use starknet::secp256_trait::{Secp256Trait, Signature, is_valid_signature};
use starknet::secp256k1::{Secp256k1Point};
use crate::flags::ScriptFlags;
use crate::hash_cache::{SigHashMidstateTrait, TaprootSigHashMidState};
use shinigami_utils::byte_array::u256_from_byte_array_with_offset;
use crate::signature::{sighash, constants, signature::parse_pub_key};
use crate::errors::Error;
use shinigami_utils::byte_array::{sub_byte_array};
use crate::parser;
use crate::transaction::{EngineTransaction, EngineTransactionInput, EngineTransactionOutput};

pub const SCHNORR_SIGNATURE_LEN: usize = 64;

pub fn parse_schnorr_pub_key(pk_bytes: @ByteArray) -> Result<Secp256k1Point, felt252> {
    if pk_bytes.len() == 0 || pk_bytes.len() != 32 {
        return Result::Err('Invalid schnorr pubkey length');
    }

    let mut key_compressed: ByteArray = "\02";
    key_compressed.append(pk_bytes);
    return parse_pub_key(@key_compressed);
}

pub fn schnorr_parse_signature(sig_bytes: @ByteArray) -> Result<(Signature, u32), felt252> {
    let sig_bytes_len = sig_bytes.len();
    let mut hash_type: u32 = 0;
    if sig_bytes_len == SCHNORR_SIGNATURE_LEN {
        hash_type = constants::SIG_HASH_DEFAULT;
    } else if sig_bytes_len == SCHNORR_SIGNATURE_LEN + 1 && sig_bytes[64] != 0 {
        hash_type = sig_bytes[64].into();
    } else {
        return Result::Err('Invalid taproot signature len');
    }
    Result::Ok(
        (
            Signature {
                r: u256_from_byte_array_with_offset(sig_bytes, 0, 32),
                s: u256_from_byte_array_with_offset(sig_bytes, 32, 32),
                y_parity: false, // Schnorr signatures don't use y_parity
            },
            hash_type
        )
    )
}


#[derive(Drop)]
pub struct TaprootSigVerifier<T> {
    // public key as a point on the secp256k1 curve, used to verify the signature
    pub_key: Secp256k1Point,
    // ECDSA signature
    sig: Signature,
    // raw byte array of the signature
    sig_bytes: @ByteArray,
    // raw byte array of the public key
    pk_bytes: @ByteArray,
    // specifies how the transaction was hashed for signing
    hash_type: u32,
    // transaction being verified
    tx: @T,
    // index of the input being verified
    inputIndex: u32,
    // output being spent
    prevOuts: EngineTransactionOutput,
    //
    // sigCache: SigCache TODO?
    //
    // hashCache: TaprootSigHashMidState,
    // annex data used for taproot verification
    annex: @ByteArray,
}

pub impl TaprootSigVerifierDefault<
    T,
    +Drop<T>,
    +Default<T>,
    // I,
    // +Default<I>,
    // +Drop<I>,
    // impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
    // O,
    // +Drop<O>,
    // +Default<O>,
    // impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
    // impl IEngineTransactionTrait: EngineTransactionTrait<
    //     T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait
    // >
> of Default<TaprootSigVerifier<T>> {
    fn default() -> TaprootSigVerifier<T> {
        TaprootSigVerifier {
            pub_key: Secp256Trait::<Secp256k1Point>::get_generator_point(),
            sig: Signature { r: 0, s: 0, y_parity: false },
            sig_bytes: @"",
            pk_bytes: @"",
            hash_type: 0,
            tx: @Default::<T>::default(),
            inputIndex: 0,
            prevOuts: Default::<EngineTransactionOutput>::default(),
            // hashCache: Default::<TaprootSigHashMidState>::default(),
            annex: @""
        }
    }
}

pub trait TaprootSigVerifierTrait<
    T,
    +Drop<T>,
    +Default<T>,
    I,
    +Drop<I>,
    +Default<I>,
    impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
    O,
    +Drop<O>,
    +Default<O>,
    impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
    impl IEngineTransactionTrait: EngineTransactionTrait<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait
    >
> {
    fn new(
        sig_bytes: @ByteArray, pk_bytes: @ByteArray, annex: @ByteArray, ref engine: Engine<T>
    ) -> Result<TaprootSigVerifier<T>, felt252>;
    fn new_base(
        sig_bytes: @ByteArray, pk_bytes: @ByteArray, ref engine: Engine<T>
    ) -> Result<TaprootSigVerifier<T>, felt252>;
    fn verify(ref self: TaprootSigVerifier<T>) -> bool;
    fn verify_base(ref self: TaprootSigVerifier<T>) -> bool;
}

pub impl TaprootSigVerifierImpl<
    T,
    +Drop<T>,
    +Default<T>,
    I,
    +Drop<I>,
    +Default<I>,
    impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
    O,
    +Drop<O>,
    +Default<O>,
    impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
    impl IEngineTransactionTrait: EngineTransactionTrait<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait
    >
> of TaprootSigVerifierTrait<T, I, O> {
    fn new(
        sig_bytes: @ByteArray, pk_bytes: @ByteArray, annex: @ByteArray, ref engine: Engine<T>
    ) -> Result<TaprootSigVerifier<T>, felt252> {
        let pub_key = parse_schnorr_pub_key(pk_bytes)?;
        let (sig, hash_type) = schnorr_parse_signature(sig_bytes)?;

        // let prevOutput = EngineTransactionOutput {
        //     value: engine.amount, publickey_script: engine.scripts[1],
        // };

        let prevOutput = EngineTransactionOutput {
            value: engine.amount, publickey_script: (*engine.scripts[1]).clone(),
        };

        Result::Ok(
            TaprootSigVerifier {
                pub_key,
                sig,
                sig_bytes,
                pk_bytes,
                hash_type,
                tx: engine.transaction,
                inputIndex: engine.tx_idx,
                prevOuts: prevOutput,
                // hashCache: engine.hash_cache,
                annex
            }
        )
    }

    fn new_base(
        sig_bytes: @ByteArray, pk_bytes: @ByteArray, ref engine: Engine<T>
    ) -> Result<TaprootSigVerifier<T>, felt252> {
        let pk_bytes_len = pk_bytes.len();
        if pk_bytes_len == 0 {
            return Result::Err('Taproot empty public key');
        } else if pk_bytes_len == 32 {
            return Self::new(sig_bytes, pk_bytes, engine.taproot_context.annex, ref engine);
        } else {
            if engine.has_flag(ScriptFlags::ScriptVerifyDiscourageUpgradeablePubkeyType) {
                return Result::Err('Unknown pub key type');
            }
            return Result::Ok(Default::<TaprootSigVerifier<T>>::default());
        }
    }

    fn verify(ref self: TaprootSigVerifier<T>) -> bool {
        // TODO: implement taproot verification
        return false;
    }

    fn verify_base(ref self: TaprootSigVerifier<T>) -> bool {
        // TODO: implement taproot verification
        return false;
    }
}
