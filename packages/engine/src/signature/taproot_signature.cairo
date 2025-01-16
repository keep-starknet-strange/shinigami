use crate::engine::{Engine, EngineInternalImpl};
use crate::transaction::{
    EngineTransactionOutput, EngineTransactionInputTrait, EngineTransactionOutputTrait,
    EngineTransactionTrait,
};
use crate::flags::ScriptFlags;
use crate::signature::{constants, schnorr, sighash, sighash::{TaprootSighashOptionsTrait}};
use crate::hash_cache::{TxSigHashes, SigHashMidstateTrait};
use crate::errors::Error;

use shinigami_utils::byte_array::{U256IntoByteArray, u256_from_byte_array_with_offset};
use starknet::SyscallResultTrait;
use starknet::secp256_trait::{Secp256Trait, Signature};
use starknet::secp256k1::{Secp256k1Point};

pub const SCHNORR_SIGNATURE_LEN: usize = 64;

// Parses the public key and signature for taproot spend.
// Returning a tuple containing the parsed public key, signature, and hash type.
pub fn parse_taproot_sig_and_pk<
    T,
    +Drop<T>,
    I,
    +Drop<I>,
    impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
    O,
    +Drop<O>,
    impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
    impl IEngineTransactionTrait: EngineTransactionTrait<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait,
    >,
>(
    ref vm: Engine<T>, pk_bytes: @ByteArray, sig_bytes: @ByteArray,
) -> Result<(Secp256k1Point, Signature, u32), felt252> {
    // Parse schnorr public key
    let pk = schnorr::parse_schnorr_pub_key(pk_bytes)?;

    // Check the size of the signature and if the `sighash byte` is set.
    let sig_len = sig_bytes.len();
    let (sig, sighash_type) = if sig_len == constants::SCHNORR_SIG_SIZE {
        // Parse signature, `sighash_type` has default value
        (schnorr::parse_schnorr_signature(sig_bytes)?, constants::SIG_HASH_DEFAULT)
    } else if sig_len == constants::SCHNORR_SIG_SIZE + 1 && sig_bytes[64] != 0 {
        // Extract `sighash_byte` and parse signature
        let sighash_type = sig_bytes[64];
        let mut sig_bytes_truncate: ByteArray = "";
        for i in 0..constants::SCHNORR_SIG_SIZE {
            sig_bytes_truncate.append_byte(sig_bytes[i]);
        };
        (schnorr::parse_schnorr_signature(@sig_bytes_truncate)?, sighash_type.into())
    } else {
        // Error on invalid signature size.
        return Result::Err(Error::SCHNORR_INVALID_SIG_SIZE);
    };

    return Result::Ok((pk, sig, sighash_type));
}

#[derive(Drop)]
pub struct TaprootSigVerifier<T> {
    // public key as a point on the secp256k1 curve, used to verify the signature
    pub pub_key: Secp256k1Point,
    // ECDSA signature
    pub sig: Signature,
    // raw byte array of the signature
    pub sig_bytes: @ByteArray,
    // raw byte array of the public key
    pub pk_bytes: @ByteArray,
    // specifies how the transaction was hashed for signing
    pub hash_type: u32,
    // transaction being verified
    pub tx: @T,
    // index of the input being verified
    pub inputIndex: u32,
    // output being spent
    pub prevOuts: EngineTransactionOutput,
    //
    // sigCache: SigCache TODO?
    //
    pub hashCache: TxSigHashes,
    // annex data used for taproot verification
    pub annex: @ByteArray,
}

pub trait TaprootSigVerifierTrait<
    I,
    O,
    T,
    +EngineTransactionInputTrait<I>,
    +EngineTransactionOutputTrait<O>,
    +EngineTransactionTrait<T, I, O>,
> {
    fn empty() -> TaprootSigVerifier<T>;
    fn new(
        sig_bytes: @ByteArray, pk_bytes: @ByteArray, annex: @ByteArray, ref engine: Engine<T>,
    ) -> Result<TaprootSigVerifier<T>, felt252>;
    fn new_base(
        sig_bytes: @ByteArray, pk_bytes: @ByteArray, ref engine: Engine<T>,
    ) -> Result<TaprootSigVerifier<T>, felt252>;
    fn verify(self: TaprootSigVerifier<T>) -> Result<(), felt252>;
    fn verify_base(ref self: TaprootSigVerifier<T>) -> bool;
}

pub impl TaprootSigVerifierImpl<
    T,
    +Drop<T>,
    +Default<T>,
    I,
    +Drop<I>,
    impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
    O,
    +Drop<O>,
    impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
    impl IEngineTransactionTrait: EngineTransactionTrait<
        T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait,
    >,
> of TaprootSigVerifierTrait<I, O, T> {
    fn empty() -> TaprootSigVerifier<T> {
        TaprootSigVerifier {
            pub_key: Secp256Trait::<Secp256k1Point>::get_generator_point(),
            sig: Signature { r: 0, s: 0, y_parity: false },
            sig_bytes: @"",
            pk_bytes: @"",
            hash_type: 0,
            tx: @Default::default(),
            inputIndex: 0,
            prevOuts: Default::<EngineTransactionOutput>::default(),
            hashCache: Default::default(),
            annex: @"",
        }
    }

    fn new(
        sig_bytes: @ByteArray, pk_bytes: @ByteArray, annex: @ByteArray, ref engine: Engine<T>,
    ) -> Result<TaprootSigVerifier<T>, felt252> {
        let (pub_key, sig, hash_type) = parse_taproot_sig_and_pk(ref engine, pk_bytes, sig_bytes)?;
        let sig_hashes = SigHashMidstateTrait::new(engine.transaction, engine.tx_idx);
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
                hashCache: sig_hashes,
                annex,
            },
        )
    }

    fn new_base(
        sig_bytes: @ByteArray, pk_bytes: @ByteArray, ref engine: Engine<T>,
    ) -> Result<TaprootSigVerifier<T>, felt252> {
        let pk_bytes_len = pk_bytes.len();

        // Fail immediately if public key length is zero
        if pk_bytes_len == 0 {
            return Result::Err(Error::TAPROOT_EMPTY_PUBKEY);
        } // If key is 32 byte, parse as normal
        else if pk_bytes_len == 32 {
            return Self::new(sig_bytes, pk_bytes, engine.taproot_context.annex, ref engine);
            // Otherwise, this is an unknown public key, assuming sig is valid
        } else {
            // However, return an error if the flags preventinf usage of unknown key type is set
            if engine.has_flag(ScriptFlags::ScriptVerifyDiscourageUpgradeablePubkeyType) {
                return Result::Err(Error::DISCOURAGE_UPGRADABLE_PUBKEY_TYPE);
            }
            let pub_key: u256 = u256_from_byte_array_with_offset(pk_bytes, 0, 32);
            let pk = Secp256Trait::<
                Secp256k1Point,
            >::secp256_ec_get_point_from_x_syscall(pub_key, false)
                .unwrap_syscall()
                .expect(Error::SECP256K1_INVALID_POINT);

            return (Result::Ok(
                TaprootSigVerifier {
                    pub_key: pk,
                    sig: Signature { r: 0, s: 0, y_parity: false },
                    sig_bytes,
                    pk_bytes,
                    hash_type: constants::SIG_HASH_DEFAULT,
                    tx: @Default::default(),
                    inputIndex: 0,
                    prevOuts: Default::<EngineTransactionOutput>::default(),
                    hashCache: Default::default(),
                    annex: @"",
                },
            ));
            // return Result::Ok(Self::empty());
        }
    }

    fn verify(self: TaprootSigVerifier<T>) -> Result<(), felt252> {
        let mut opts = TaprootSighashOptionsTrait::new_with_annex(self.annex);
        let sig_hash = sighash::calc_taproot_signature_hash::<
            T,
        >(self.hashCache, self.hash_type, self.tx, self.inputIndex, self.prevOuts, ref opts)?;

        let is_valid_sig = schnorr::verify_schnorr(self.sig, @sig_hash.into(), self.pk_bytes)
            .is_ok();
        if !is_valid_sig {
            return Result::Err(Error::TAPROOT_INVALID_SIG);
        }
        Result::Ok(())
    }

    fn verify_base(ref self: TaprootSigVerifier<T>) -> bool {
        // TODO: implement taproot verification
        return false;
    }
}

