// Represents the default signature hash type, often treated as `SIG_HASH_ALL`, ensuring that all
// inputs and outputs of the transaction are signed to provide complete protection against
// unauthorized modifications.
pub const SIG_HASH_DEFAULT: u32 = 0x0;
//Sign all inputs and outputs of the transaction, making it the most secure and commonly used hash
//type that ensures the entire transaction is covered by the signature, preventing any changes after
//signing.
pub const SIG_HASH_ALL: u32 = 0x1;
//Sign all inputs but none of the outputs, allowing outputs to be modified after signing, which is
//useful in scenarios requiring flexible transaction outputs without invalidating the signature.
pub const SIG_HASH_NONE: u32 = 0x2;
//Sign only the input being signed and its corresponding output, enabling partial transaction
//signatures where each input is responsible for its associated output, useful for independent input
//signing.
pub const SIG_HASH_SINGLE: u32 = 0x3;
//Allows signing of only one input, leaving others unsigned, often used with other hash types for
//creating transactions that can be extended with additional inputs by different parties without
//invalidating the signature.
pub const SIG_HASH_ANYONECANPAY: u32 = 0x80;
//Mask to isolate the base signature hash type from a combined hash type that might include
//additional flags like `SIG_HASH_ANYONECANPAY`, ensuring accurate identification and processing of
//the core hash type.
pub const SIG_HASH_MASK: u32 = 0x1f;
//Base version number for Segregated Witness (SegWit) transactions, representing the initial version
//of SegWit that enables more efficient transaction validation by separating signature data from the
//main transaction body.
pub const BASE_SEGWIT_WITNESS_VERSION: u32 = 0x0;
//Minimum valid length for a DER-encoded ECDSA signature, ensuring that signatures meet the minimum
//required length for validity, as shorter signatures could indicate an incomplete or malformed
//signature.
pub const MIN_SIG_LEN: usize = 8;
//Maximum valid length for a DER-encoded ECDSA signature, ensuring that signatures do not exceed the
//expected length, which could indicate corruption or the inclusion of invalid data within the
//signature.
pub const MAX_SIG_LEN: usize = 72;
//Length of the byte that specifies the signature hash type in a signature, determining how the
//transaction was hashed before signing and influencing which parts of the transaction are covered
//by the signature.
pub const HASH_TYPE_LEN: usize = 1;
//Length of the witness program for P2WPKH (Pay-to-Witness-Public-Key-Hash) scripts in SegWit,
//including the version byte and the public key hash, ensuring correct data formatting and inclusion
//in SegWit transactions.
pub const WITNESS_V0_PUB_KEY_HASH_LEN: usize = 22;
//SignatureSize is the size of an encoded Schnorr signature.
pub const SCHNORR_SIG_SIZE: usize = 64;
//Secp256 field value.
pub const SECP256_FIELD_VAL: u256 =
    0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f;

pub const MAX_U128: u128 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;
pub const MAX_U32: u32 = 0xFFFFFFFF;
