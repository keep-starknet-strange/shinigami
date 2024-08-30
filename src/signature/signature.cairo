use crate::engine::{Engine, EngineImpl};
use crate::utils::{u256_from_byte_array_with_offset};
use crate::signature::{sighash, constants};
use crate::scriptflags::ScriptFlags;
use starknet::SyscallResultTrait;
use starknet::secp256_trait::{Secp256Trait, Signature, is_valid_signature};
use starknet::secp256k1::{Secp256k1Point};

//`BaseSigVerifier` is used to verify ECDSA signatures encoded in DER or BER format (pre-SegWit sig)
#[derive(Drop)]
pub struct BaseSigVerifier {
    // public key as a point on the secp256k1 curve, used to verify the signature
    pub_key: Secp256k1Point,
    // ECDSA signature
    sig: Signature,
    // raw byte array of the signature
    sig_bytes: @ByteArray,
    // raw byte array of the public key
    pk_bytes: @ByteArray,
    // part of the script being verified
    sub_script: ByteArray,
    // specifies how the transaction was hashed for signing
    hash_type: u32,
}

pub trait BaseSigVerifierTrait {
    fn new(
        ref vm: Engine, sig_bytes: @ByteArray, pk_bytes: @ByteArray
    ) -> Result<BaseSigVerifier, felt252>;
    fn verify(ref self: BaseSigVerifier, ref vm: Engine) -> bool;
}

impl BaseSigVerifierImpl of BaseSigVerifierTrait {
    fn new(
        ref vm: Engine, sig_bytes: @ByteArray, pk_bytes: @ByteArray
    ) -> Result<BaseSigVerifier, felt252> {
        let (pub_key, sig, hash_type) = parse_base_sig_and_pk(ref vm, pk_bytes, sig_bytes)?;
        let sub_script = vm.sub_script();
        Result::Ok(BaseSigVerifier { pub_key, sig, sig_bytes, pk_bytes, sub_script, hash_type, })
    }

    // TODO: add signature cache mechanism for optimization
    fn verify(ref self: BaseSigVerifier, ref vm: Engine) -> bool {
        let sub_script: @ByteArray = remove_signature(@self.sub_script, self.sig_bytes);
        let sig_hash: u256 = sighash::calc_signature_hash(
            sub_script, self.hash_type, ref vm.transaction, vm.tx_idx
        );

        is_valid_signature(sig_hash, self.sig.r, self.sig.s, self.pub_key)
    }
}

// Compares a slice of a byte array with the provided signature bytes to check for a match.
//
// @param script The byte array representing the script to be checked.
// @param sig_bytes The byte array containing the signature to compare against.
// @param i The starting index in the script where the comparison begins.
// @param push_data A byte that represents the length of the data segment to compare.
// @return `true` if the slice of the script matches the signature, `false` otherwise.
pub fn compare_data(script: @ByteArray, sig_bytes: @ByteArray, i: u32, push_data: u8) -> bool {
    let mut j: usize = 0;
    let mut len: usize = push_data.into();
    let mut found = true;

    while j < len {
        if script[i + j + 1] != sig_bytes[j] {
            found = false;
            break;
        }
        j += 1;
    };
    found
}

// Check if hash_type obeys scrict encoding requirements.
pub fn check_hash_type_encoding(ref vm: Engine, mut hash_type: u32) -> Result<(), felt252> {
    if !vm.has_flag(ScriptFlags::ScriptVerifyStrictEncoding) {
        return Result::Ok(());
    }

    if hash_type > constants::SIG_HASH_ANYONECANPAY {
        hash_type -= constants::SIG_HASH_ANYONECANPAY;
    }

    if hash_type < constants::SIG_HASH_ALL || hash_type > constants::SIG_HASH_SINGLE {
        return Result::Err('invalid hash type');
    }

    return Result::Ok(());
}

// Check if signature obeys strict encoding requirements.
//
// This function checks the provided signature byte array (`sig_bytes`) against several
// encoding rules, including ASN.1 structure, length constraints, and other strict encoding
// requirements. It ensures the signature is properly formatted according to DER (Distinguished
// Encoding Rules) if required, and also checks the "low S" requirement if applicable.
//
// @param vm A reference to the `Engine` that manages the execution context and provides
//           the necessary script verification flags.
// @param sig_bytes The byte array containing the ECDSA signature that needs to be validated.
pub fn check_signature_encoding(ref vm: Engine, sig_bytes: @ByteArray) -> Result<(), felt252> {
    let strict_encoding = vm.has_flag(ScriptFlags::ScriptVerifyStrictEncoding)
        || vm.has_flag(ScriptFlags::ScriptVerifyDERSignatures);
    let low_s = vm.has_flag(ScriptFlags::ScriptVerifyLowS);

    // ASN.1 identifiers for sequence and integer types.*
    let asn1_sequence_id: u8 = 0x30;
    let asn1_integer_id: u8 = 0x02;
    // Offsets used to parse the signature byte array.
    let sequence_offset: usize = 0;
    let data_len_offset: usize = 1;
    let data_offset: usize = 2;
    let r_type_offset: usize = 2;
    let r_len_offset: usize = 3;
    let r_offset: usize = 4;
    // Length of the signature byte array.
    let sig_bytes_len: usize = sig_bytes.len();
    // Check if the signature is empty.
    if sig_bytes_len == 0 {
        return Result::Err('invalid sig fmt: empty sig');
    }
    // Calculate the actual length of the signature, excluding the hash type.
    let sig_len = sig_bytes_len - constants::HASH_TYPE_LEN;
    // Check if the signature is too short.
    if sig_len < constants::MIN_SIG_LEN {
        return Result::Err('invalid sig fmt: too short');
    }
    // Check if the signature is too long.
    if sig_len > constants::MAX_SIG_LEN {
        return Result::Err('invalid sig fmt: too long');
    }
    // Ensure the signature starts with the correct ASN.1 sequence identifier.
    if sig_bytes[sequence_offset] != asn1_sequence_id {
        return Result::Err('invalid sig fmt: wrong type');
    }
    // Verify that the length field matches the expected length.
    if sig_bytes[data_len_offset] != (sig_len - data_offset).try_into().unwrap() {
        return Result::Err('invalid sig fmt: bad length');
    }
    // Determine the length of the `R` value in the signature.
    let r_len: usize = sig_bytes[r_len_offset].into();
    let s_type_offset = r_offset + r_len;
    let s_len_offset = s_type_offset + 1;
    // Check if the `S` type offset exceeds the length of the signature.
    if s_type_offset > sig_len {
        return Result::Err('invalid sig fmt: S type missing');
    }
    // Check if the `S` length offset exceeds the length of the signature.
    if s_len_offset > sig_len {
        return Result::Err('invalid sig fmt: miss S length');
    }
    // Calculate the offset and length of the `S` value.
    let s_offset = s_len_offset + 1;
    let s_len: usize = sig_bytes[s_len_offset].into();
    // Ensure the `R` value is correctly identified as an ASN.1 integer.
    if sig_bytes[r_type_offset] != asn1_integer_id {
        return Result::Err('invalid sig fmt:R ASN.1');
    }
    // Validate the length of the `R` value.
    if r_len <= 0 || r_len > sig_len - r_offset - 3 {
        return Result::Err('invalid sig fmt:R length');
    }
    // If strict encoding is enforced, check for negative or excessively padded `R` values.
    if strict_encoding {
        if sig_bytes[r_offset] & 0x80 != 0 {
            return Result::Err('invalid sig fmt: negative R');
        }

        if r_len > 1 && sig_bytes[r_offset] == 0 && sig_bytes[r_offset + 1] & 0x80 == 0 {
            return Result::Err('invalid sig fmt: R padding');
        }
    }
    // Ensure the `S` value is correctly identified as an ASN.1 integer.
    if sig_bytes[s_type_offset] != asn1_integer_id {
        return Result::Err('invalid sig fmt:S ASN.1');
    }
    // Validate the length of the `S` value.
    if s_len <= 0 || s_len > sig_len - s_offset {
        return Result::Err('invalid sig fmt:S length');
    }
    // If strict encoding is enforced, check for negative or excessively padded `S` values.
    if strict_encoding {
        if sig_bytes[s_offset] & 0x80 != 0 {
            return Result::Err('invalid sig fmt: negative S');
        }

        if s_len > 1 && sig_bytes[s_offset] == 0 && sig_bytes[s_offset + 1] & 0x80 == 0 {
            return Result::Err('invalid sig fmt: S padding');
        }
    }
    // If the "low S" rule is enforced, check that the `S` value is below the threshold.
    if low_s {
        let s_value = u256_from_byte_array_with_offset(sig_bytes, s_offset, 32);
        let mut half_order = Secp256Trait::<Secp256k1Point>::get_curve_size();

        let carry = half_order.high % 2;
        half_order.low = (half_order.low / 2) + (carry * (constants::MAX_U128 / 2 + 1));
        half_order.high /= 2;

        if s_value > half_order {
            return Result::Err('sig not canonical high S value');
        }
    }

    return Result::Ok(());
}

// Checks if a public key is compressed based on its byte array representation.
// ie: 33 bytes, starts with 0x02 or 0x03, indicating ECP parity of the Y coord.
pub fn is_compressed_pub_key(pk_bytes: @ByteArray) -> bool {
    if pk_bytes.len() == 33 && (pk_bytes[0] == 0x02 || pk_bytes[0] == 0x03) {
        return true;
    }
    return false;
}

fn is_supported_pub_key_type(pk_bytes: @ByteArray) -> bool {
    if is_compressed_pub_key(pk_bytes) {
        return true;
    }

    // Uncompressed pub key
    if pk_bytes.len() == 65 && pk_bytes[0] == 0x04 {
        return true;
    }

    return false;
}

// Checks if a public key adheres to specific encoding rules based on the engine flags.
pub fn check_pub_key_encoding(ref vm: Engine, pk_bytes: @ByteArray) -> Result<(), felt252> {
    // TODO check compressed pubkey post segwit
    // if vm.has_flag(ScriptFlags::ScriptVerifyWitnessPubKeyType) &&
    // vm.is_witness_version_active(BASE_SEGWIT_WITNESS_VERSION) && !is_compressed_pub_key(pk_bytes)
    // {
    // return Result::Err('only compressed keys are accepted post-segwit');
    // }

    if !vm.has_flag(ScriptFlags::ScriptVerifyStrictEncoding) {
        return Result::Ok(());
    }

    if !is_supported_pub_key_type(pk_bytes) {
        return Result::Err('unsupported public key type');
    }

    return Result::Ok(());
}

// Parses a public key byte array into a `Secp256k1Point` on the secp256k1 elliptic curve.
//
// This function processes the provided public key byte array (`pk_bytes`) and converts it into a
// `Secp256k1Point` object, which represents the public key as a point on the secp256k1 elliptic
// curve. Supports both compressed and uncompressed public keys.
//
// @param pk_bytes The byte array representing the public key to be parsed.
// @return A `Secp256k1Point` representing the public key on the secp256k1 elliptic curve.
pub fn parse_pub_key(pk_bytes: @ByteArray) -> Secp256k1Point {
    let mut pk_bytes_uncompressed = pk_bytes.clone();

    if is_compressed_pub_key(pk_bytes) {
        // Extract X coordinate and determine parity from prefix byte.
        let mut parity: bool = false;
        let pub_key: u256 = u256_from_byte_array_with_offset(pk_bytes, 1, 32);

        if pk_bytes[0] == 0x03 {
            parity = true;
        }
        return Secp256Trait::<Secp256k1Point>::secp256_ec_get_point_from_x_syscall(pub_key, parity)
            .unwrap_syscall()
            .expect('Secp256k1Point: Invalid point.');
    } else {
        // Extract X coordinate and determine parity from last byte.
        let pub_key: u256 = u256_from_byte_array_with_offset(@pk_bytes_uncompressed, 1, 32);
        let parity = pk_bytes_uncompressed[64] & 1 == 0;

        return Secp256Trait::<Secp256k1Point>::secp256_ec_get_point_from_x_syscall(pub_key, parity)
            .unwrap_syscall()
            .expect('Secp256k1Point: Invalid point.');
    }
}

// Parses a DER-encoded ECDSA signature byte array into a `Signature` struct.
//
// This function extracts the `r` and `s` values from a DER-encoded ECDSA signature (`sig_bytes`).
// The function performs various checks to ensure the integrity and validity of the signature.
pub fn parse_signature(sig_bytes: @ByteArray) -> Result<Signature, felt252> {
    let sig_len: usize = sig_bytes.len() - constants::HASH_TYPE_LEN;
    let r_len: usize = sig_bytes[3].into();
    let s_len: usize = sig_bytes[r_len + 5].into();
    let r_sig: u256 = u256_from_byte_array_with_offset(sig_bytes, 4, r_len);
    let s_sig: u256 = u256_from_byte_array_with_offset(sig_bytes, 6 + r_len, s_len);
    let order: u256 = Secp256Trait::<Secp256k1Point>::get_curve_size();

    if r_len > 32 {
        return Result::Err('invalid sig: R > 256 bits');
    }

    if r_sig >= order {
        return Result::Err('invalid sig: R >= group order');
    }

    if r_sig == 0 {
        return Result::Err('invalid sig: R is zero');
    }

    if s_len > 32 {
        return Result::Err('invalid sig: S > 256 bits');
    }

    if s_sig >= order {
        return Result::Err('invalid sig: S >= group order');
    }

    if s_sig == 0 {
        return Result::Err('invalid sig: S is zero');
    }

    if sig_len != r_len + s_len + 6 {
        return Result::Err('invalid sig: bad final length');
    }

    return Result::Ok(Signature { r: r_sig, s: s_sig, y_parity: false, });
}

// Parses the public key and signature byte arrays based on consensus rules.
// Returning a tuple containing the parsed public key, signature, and hash type.
pub fn parse_base_sig_and_pk(
    ref vm: Engine, pk_bytes: @ByteArray, sig_bytes: @ByteArray
) -> Result<(Secp256k1Point, Signature, u32), felt252> {
    if sig_bytes.len() == 0 {
        return Result::Err('empty signature');
    }
    // TODO: strct encoding
    let hash_type_offset: usize = sig_bytes.len() - 1;
    let hash_type: u32 = sig_bytes[hash_type_offset].into();

    check_hash_type_encoding(ref vm, hash_type)?;
    check_signature_encoding(ref vm, sig_bytes)?;
    check_pub_key_encoding(ref vm, pk_bytes)?;

    let pub_key = parse_pub_key(pk_bytes);
    let sig = parse_signature(sig_bytes)?;

    Result::Ok((pub_key, sig, hash_type))
}

// Removes the ECDSA signature from a given script.
pub fn remove_signature(script: @ByteArray, sig_bytes: @ByteArray) -> @ByteArray {
    if script.len() == 0 || sig_bytes.len() == 0 {
        return script;
    }

    let mut processed_script: ByteArray = "";
    let mut i: usize = 0;

    while i < script.len() {
        let push_data: u8 = script[i];
        if push_data >= 8 && push_data <= 72 {
            let mut len: usize = push_data.into();
            let mut found: bool = false;

            if len == sig_bytes.len() {
                found = compare_data(script, sig_bytes, i, push_data);
            }

            if i + len <= script.len() {
                i += len;
            } else {
                i += 1;
            }
            if found {
                i += 1;
                continue;
            }
            processed_script.append_byte(push_data);
            while len != 0 && i - len < script.len() {
                processed_script.append_byte(script[i - len + 1]);
                len -= 1;
            };
        } else {
            processed_script.append_byte(push_data);
        }
        i += 1;
    };

    @processed_script
}
