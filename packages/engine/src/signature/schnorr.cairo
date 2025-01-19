use crate::errors::Error;
use crate::signature::{constants, signature};
use starknet::secp256k1::Secp256k1Point;
use starknet::secp256_trait::{Secp256Trait, Signature, Secp256PointTrait};
use starknet::SyscallResultTrait;
use crate::hash_tag::{HashTag, tagged_hash};

const p: u256 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFEFFFFFC2F;

pub fn parse_schnorr_pub_key(pk_bytes: @ByteArray) -> Result<Secp256k1Point, felt252> {
    if pk_bytes.len() == 0 {
        return Result::Err(Error::TAPROOT_EMPTY_PUBKEY);
    }
    if pk_bytes.len() != 32 {
        return Result::Err(Error::TAPROOT_INVALID_PUBKEY_SIZE);
    }

    let mut key_compressed: ByteArray = "\02";
    key_compressed.append(pk_bytes);
    return Result::Ok(signature::parse_pub_key(@key_compressed)?);
}

pub fn parse_schnorr_signature(sig_bytes: @ByteArray) -> Result<Signature, felt252> {
    let sig_len = sig_bytes.len();
    if sig_len != constants::SCHNORR_SIG_SIZE {
        return Result::Err(Error::SCHNORR_INVALID_SIG_SIZE);
    }

    let mut r: u256 = 0;
    let mut s: u256 = 0;
    for i in 0..sig_bytes.len() {
        if i < 32 {
            r *= 256;
            r += sig_bytes[i].into();
        } else {
            s *= 256;
            s += sig_bytes[i].into();
        }
    };
    if r >= constants::SECP256_FIELD_VAL {
        return Result::Err(Error::SCHNORR_INVALID_SIG_R_FIELD);
    }

    return Result::Ok(Signature { r: r, s: s, y_parity: false });
}

// verify_schnorr attempt to verify the signature for the provided hash and secp256k1 public key.
// The algorithm for verifying a BIP-340 signature is reproduced here for reference:
//
// 1. Fail if m is not 32 bytes
// 2. P = lift_x(int(pk)).
// 3. r = int(sig[0:32]); fail is r >= p.
// 4. s = int(sig[32:64]); fail if s >= n.
// 5. e = int(tagged_hash("BIP0340/challenge", bytes(r) || bytes(P) || M)) mod n.
// 6. R = s*G - e*P
// 7. Fail if is_infinite(R)
// 8. Fail if not hash_even_y(R)
// 9. Fail is x(R) != r.
// 10. Return success if failure did not occur before reaching this point.
pub fn verify_schnorr(
    sig: Signature, hash: @ByteArray, pubkey: @ByteArray,
) -> Result<bool, felt252> {
    if hash.len() != 32 {
        return Result::Err(Error::SCHNORR_INVALID_MSG_SIZE);
    }

    let P = parse_schnorr_pub_key(pubkey)?;

    let n = Secp256Trait::<Secp256k1Point>::get_curve_size();
    if sig.r >= p {
        return Result::Err(Error::SCHNORR_INVALID_SIG_R_FIELD);
    } else if sig.s >= n {
        return Result::Err(Error::SCHNORR_INVALID_SIG_SIZE);
    }

    let mut msg: ByteArray = Default::default();
    msg.append_word(sig.r.high.into(), 16);
    msg.append_word(sig.r.low.into(), 16);
    msg.append(pubkey);
    msg.append(hash);
    let e = tagged_hash(HashTag::Bip0340Challenge, @msg);

    let G = Secp256Trait::<Secp256k1Point>::get_generator_point();

    // R = s⋅G - e⋅P
    let p1 = G.mul(sig.s).unwrap_syscall();
    let minus_e = Secp256Trait::<Secp256k1Point>::get_curve_size() - e;
    let p2 = P.mul(minus_e).unwrap_syscall();
    let R = p1.add(p2).unwrap_syscall();

    let (Rx, Ry) = R.get_coordinates().unwrap_syscall();

    // Fail if is_infinite(R) || not has_even_y(R) || x(R) ≠ rx.
    Result::Ok(!(Rx == 0 && Ry == 0) && Ry % 2 == 0 && Rx == sig.r)
}
