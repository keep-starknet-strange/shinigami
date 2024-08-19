use shinigami::engine::{Engine, EngineTraitImpl};
use starknet::SyscallResultTrait;
use starknet::secp256_trait::{Secp256Trait, Secp256PointTrait};
use starknet::secp256k1::{Secp256k1Point};
use starknet::secp256_trait::{Signature, is_valid_signature};
use shinigami::scriptflags::ScriptFlags;
use shinigami::utils::{u256_from_byte_array_with_offset, int_size_in_bytes, hash256 };
use shinigami::transaction::{Transaction, TransactionInput, TransactionOutput, Outpoint};

// Represents the default signature hash type, often treated as `SIG_HASH_ALL`, ensuring that all inputs and outputs of the transaction are signed to provide complete protection against unauthorized modifications. */
const SIG_HASH_DEFAULT: u32 = 0x0;
//Sign all inputs and outputs of the transaction, making it the most secure and commonly used hash type that ensures the entire transaction is covered by the signature, preventing any changes after signing.
const SIG_HASH_ALL: u32 = 0x1;
//Sign all inputs but none of the outputs, allowing outputs to be modified after signing, which is useful in scenarios requiring flexible transaction outputs without invalidating the signature.
const SIG_HASH_NONE: u32 = 0x2;
//Sign only the input being signed and its corresponding output, enabling partial transaction signatures where each input is responsible for its associated output, useful for independent input signing.
const SIG_HASH_SINGLE: u32 = 0x3;
//Allows signing of only one input, leaving others unsigned, often used with other hash types for creating transactions that can be extended with additional inputs by different parties without invalidating the signature.
const SIG_HASH_ANYONECANPAY: u32 = 0x80;
//Mask to isolate the base signature hash type from a combined hash type that might include additional flags like `SIG_HASH_ANYONECANPAY`, ensuring accurate identification and processing of the core hash type.
const SIG_HASH_MASK: u32 = 0x1f;
//Base version number for Segregated Witness (SegWit) transactions, representing the initial version of SegWit that enables more efficient transaction validation by separating signature data from the main transaction body.
const BASE_SEGWIT_WITNESS_VERSION: u32 = 0x0;
//Minimum valid length for a DER-encoded ECDSA signature, ensuring that signatures meet the minimum required length for validity, as shorter signatures could indicate an incomplete or malformed signature.
const MIN_SIG_LEN: usize = 8;
//Maximum valid length for a DER-encoded ECDSA signature, ensuring that signatures do not exceed the expected length, which could indicate corruption or the inclusion of invalid data within the signature.
const MAX_SIG_LEN: usize = 72;
//Length of the byte that specifies the signature hash type in a signature, determining how the transaction was hashed before signing and influencing which parts of the transaction are covered by the signature.
const HASH_TYPE_LEN: usize = 1;
//Length of the witness program for P2WPKH (Pay-to-Witness-Public-Key-Hash) scripts in SegWit, including the version byte and the public key hash, ensuring correct data formatting and inclusion in SegWit transactions.
const WITNESS_V0_PUB_KEY_HASH_LEN: usize = 22;

const MAX_U128: u128 = 0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF;


//`BaseSigVerifier` manages the necessary components for verifying a digital signature
// in a blockchain transaction using the legacy algorithm (pre-SegWit), including the 
// public key, ECDSA signature, and relevant scripts. This verifier is specifically for 
// transactions that do not use the Segregated Witness (SegWit) format
#[derive(Drop)]
pub struct BaseSigVerifier {
	// pk_key is the public key as a point on the secp256k1 curve, used to verify the signature
	pk_key: Secp256k1Point, 
	// sig is the ECDSA signature
	sig: Signature,
	// sig_bytes is the raw byte array of the signature
	sig_bytes: @ByteArray, 
	// pk_bytes is the raw byte array of the public key
	pk_bytes: @ByteArray,
	// sub_script is the part of the script being verified
	sub_script: @ByteArray,
	// hash_type specifies how the transaction was hashed for signing
	hash_type: u32,
}

pub trait BaseSigVerifierTrait {
	fn new(ref vm: Engine, sig_bytes: @ByteArray, pk_bytes: @ByteArray) -> Result<BaseSigVerifier, felt252>;
	fn verify(ref self: BaseSigVerifier, ref vm: Engine) -> bool;
}

impl BaseSigVerifierImpl of BaseSigVerifierTrait {
	fn new(ref vm: Engine, sig_bytes: @ByteArray, pk_bytes: @ByteArray) -> Result<BaseSigVerifier, felt252> {
		let (pk_key, sig, hash_type) = parse_base_sig_and_pk(ref vm, pk_bytes, sig_bytes)?;
		let sub_script = vm.subscript();

		Result::Ok(BaseSigVerifier {
			pk_key,
			sig,
			sig_bytes,
			pk_bytes,
			sub_script,
			hash_type,
		})
	}
	//TODO add signature cache mecanism for optimization
	fn verify(ref self: BaseSigVerifier, ref vm: Engine) -> bool {
		let sub_script: @ByteArray = remove_signature(self.sub_script, self.sig_bytes);
		let sig_hash: u256 = calc_transaction_hash(sub_script, self.hash_type, ref vm.transaction, vm.index);

		is_valid_signature(sig_hash, self.sig.r, self.sig.s, self.pk_key)
	}
}
// Removes the ECDSA signature from a given script.
// 
// This function processes a script and removes any segment that matches the provided signature bytes.
// This ensures that the script is accurately represented during verification without the signature
// itself influencing the hash.
// 
// @param script The byte array representing the script from which the signature should be removed.
// @param sig_bytes The byte array of the signature that needs to be removed from the script.
// @return A new byte array representing the script with the signature removed.
pub fn remove_signature(script: @ByteArray, sig_bytes: @ByteArray) -> @ByteArray {
	if script.len() == 0 || sig_bytes.len() == 0 {
		return script;
	}

	let mut processed_script: ByteArray = "";
	let mut i: usize = 0;

	while i < script.len() {
		let push_data: u8 = script[i];
		if push_data >= 8 && push_data <= 72{
			let mut len: usize = push_data.into();
			let mut found: bool = false;

			if len == sig_bytes.len() {
				found = compare_data(script, sig_bytes, i, push_data);
			}

			if i + len <= script.len(){
				i += len;
			} else {
				i += 1;
			}
			if found {
				i += 1;
				continue;
			}
			processed_script.append_byte(push_data);
			while len != 0 && i - len < script.len(){
				processed_script.append_byte(script[i - len + 1]);
				len -= 1;
			};
		} else {
			processed_script.append_byte(push_data);
		}
		i+=1;
	};

	@processed_script
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

// Validates the encoding of the signature hash type to ensure it meets the expected standards.
// 
// @param vm A reference to the `Engine` that provides the execution context and flags for script verification.
// @param hash_type The signature hash type that needs to be validated and potentially adjusted.
pub fn check_hash_type_encoding(ref vm: Engine, mut hash_type: u32) -> Result<(), felt252> {
	if !vm.has_flag(ScriptFlags::ScriptVerifyStrictEncoding) {
		return Result::Ok(());
	}

	if hash_type > SIG_HASH_ANYONECANPAY {
		hash_type -= SIG_HASH_ANYONECANPAY;
	}

	if hash_type < SIG_HASH_ALL || hash_type > SIG_HASH_SINGLE {
		return Result::Err('Invalid hash type');
	}

	return Result::Ok(());
}

// Validates the encoding of a digital signature to ensure it adheres to strict format rules.
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

    let strict_encoding = vm.has_flag(ScriptFlags::ScriptVerifyStrictEncoding) || vm.has_flag(ScriptFlags::ScriptVerifyDERSignatures);
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
	let sig_len = sig_bytes_len - HASH_TYPE_LEN;
    // Check if the signature is too short.
	if sig_len < MIN_SIG_LEN {
		return Result::Err('invalid sig fmt: too short');
	}
    // Check if the signature is too long.
	if sig_len > MAX_SIG_LEN {
		return Result::Err('invalid sig fmt: too long');
	}
    // Ensure the signature starts with the correct ASN.1 sequence identifier.
	if sig_bytes[sequence_offset] != asn1_sequence_id {
		return Result::Err('invalid sig fmt: wrong type');
	}
    // Verify that the length field matches the expected length.
	if  sig_bytes[data_len_offset] != (sig_len - data_offset).try_into().unwrap() {
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
	if r_len <= 0 || r_len > sig_len - r_offset - 3{
		return Result::Err('invalid sig fmt:R length');
	}
    // If strict encoding is enforced, check for negative or excessively padded `R` values.
    if strict_encoding {
        if sig_bytes[r_offset] & 0x80 != 0 {
            return Result::Err('invalid sig fmt: negative R');
        }

        if r_len > 1 && sig_bytes[r_offset] == 0  && sig_bytes[r_offset + 1] & 0x80 == 0 {
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

        if s_len > 1 && sig_bytes[s_offset] == 0  && sig_bytes[s_offset + 1] & 0x80 == 0 {
            return Result::Err('invalid sig fmt: S padding');
        }
    }
    // If the "low S" rule is enforced, check that the `S` value is below the threshold.
	if low_s {
		let s_value = u256_from_byte_array_with_offset(sig_bytes, s_offset, 32);
		let mut half_order = Secp256Trait::<Secp256k1Point>::get_curve_size();

		let carry = half_order.high % 2;
		half_order.low = (half_order.low / 2) + (carry * (MAX_U128 / 2 + 1));
		half_order.high /= 2;

		if s_value > half_order {
			return Result::Err('sig not canonical high S value');
		}
	}

	return Result::Ok(());

}
// Checks if a public key is in the compressed format.
// 
// This function verifies whether the provided public key byte array (`pk_bytes`) is compressed.
// A compressed public key has a length of 33 bytes and starts with a prefix byte of either `0x02` 
// or `0x03`, indicating the parity of the Y coordinate in the elliptic curve point.
// 
// @param pk_bytes The byte array representing the public key.
// @return `true` if the public key is in the compressed format, `false` otherwise.
fn is_compressed_pub_key(pk_bytes: @ByteArray) -> bool {
	if pk_bytes.len() == 33 && (pk_bytes[0] == 0x02 || pk_bytes[0] == 0x03) {
		return true;
	}
	return false;
}
// Checks if a public key is in a supported format (either compressed or uncompressed).
// 
// This function determines whether the provided public key byte array (`pk_bytes`) is in 
// a supported format, which can be either compressed (33 bytes long with a prefix of `0x02` 
// or `0x03`) or uncompressed (65 bytes long with a prefix of `0x04`).
// 
// @param pk_bytes The byte array representing the public key.
// @return `true` if the public key is in a supported format, `false` otherwise.
fn is_supported_pub_key_type(pk_bytes: @ByteArray) -> bool{
	if is_compressed_pub_key(pk_bytes) {
		return true;
	}
	if pk_bytes.len() == 65 && pk_bytes[0] == 0x04 {
		return true;
	}

	return false;
}
// Validates the encoding of a public key to ensure it meets the requirements for the current transaction context.
// 
// This function checks the provided public key byte array (`pk_bytes`) against specific encoding rules based on the 
// script verification flags set in the virtual machine (`vm`). It ensures that the public key is in a supported format 
// and adheres to the required encoding standards, particularly in the context of Segregated Witness (SegWit) transactions.
// 
// The function performs the following checks:
// 1. If `ScriptVerifyWitnessPubKeyType` is set and SegWit is active, it ensures that the public key is compressed.
// 2. If `ScriptVerifyStrictEncoding` is set, it checks whether the public key is in a supported format (compressed or uncompressed).
// 
// If any of these checks fail, the function return an error.
// 
// @param vm A reference to the `Engine` that provides the execution context and flags for script verification.
// @param pk_bytes The byte array representing the public key to be validated.
pub fn check_pub_key_encoding(ref vm: Engine, pk_bytes: @ByteArray) -> Result<(), felt252>{
	// TODO check compressed pubkey post segwit
	// if vm.has_flag(ScriptFlags::ScriptVerifyWitnessPubKeyType) && vm.is_witness_version_active(BASE_SEGWIT_WITNESS_VERSION) && !is_compressed_pub_key(pk_bytes) {
	// 	return Result::Err('only compressed keys are accepted post-segwit');
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
// `Secp256k1Point` object, which represents the public key as a point on the secp256k1 elliptic curve. 
// The function handles both compressed and uncompressed public keys by first determining the format 
// and then extracting the necessary components to generate the corresponding elliptic curve point.
// 
// The function performs the following steps:
// 1. If the public key is compressed, it extracts the X coordinate and determines the Y parity based on the prefix byte.
// 2. If the public key is uncompressed, it extracts the X coordinate and derives the Y parity from the last byte.
// 
// The function uses a syscall to obtain the full elliptic curve point based on the extracted X coordinate and parity.
// 
// @param pk_bytes The byte array representing the public key to be parsed.
// @return A `Secp256k1Point` representing the public key on the secp256k1 elliptic curve.
pub fn parse_pub_key(pk_bytes: @ByteArray) -> Secp256k1Point{
	let mut pk_bytes_uncompressed = pk_bytes.clone();

	if is_compressed_pub_key(pk_bytes) {
		let mut parity:bool = false;
		let pub_key: u256 = u256_from_byte_array_with_offset(pk_bytes, 1, 32);

		if pk_bytes[0] == 0x03 {
			parity = true;
		}
		return  Secp256Trait::<Secp256k1Point>::secp256_ec_get_point_from_x_syscall(pub_key, parity).unwrap_syscall().expect('Secp256k1Point: Invalid point.');
	} else {
		let pub_key: u256 = u256_from_byte_array_with_offset(@pk_bytes_uncompressed, 1, 32);
		let parity = pk_bytes_uncompressed[64] & 1 == 0;

		return  Secp256Trait::<Secp256k1Point>::secp256_ec_get_point_from_x_syscall(pub_key, parity).unwrap_syscall().expect('Secp256k1Point: Invalid point.');
	}
}
// Parses a DER-encoded ECDSA signature byte array into a `Signature` struct.
// 
// This function extracts the `r` and `s` values from a DER-encoded ECDSA signature byte array (`sig_bytes`) 
// and constructs a `Signature` struct. The function performs various checks to ensure the integrity and validity 
// of the signature, including verifying the lengths of `r` and `s`, checking that they are within the valid range, 
// and ensuring that the overall signature format is correct.
// 
// The function performs the following steps:
// 1. Extracts the lengths and values of `r` and `s` from the signature byte array.
// 2. Validates that `r` and `s` are within the appropriate range (less than the curve order and not zero).
// 3. Ensures that the signature adheres to the expected length and format constraints.
// 4. Constructs and returns a `Signature` struct containing the parsed `r` and `s` values.
// 
// If any of these checks fail, the function will return an error.
// 
// @param sig_bytes The byte array containing the DER-encoded ECDSA signature.
// @return A `Signature` struct containing the parsed `r` and `s` values.
pub fn parse_signature(sig_bytes: @ByteArray) -> Result<Signature, felt252> {
	
	let sig_len: usize = sig_bytes.len() - HASH_TYPE_LEN;
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
	
	return Result::Ok(Signature {
		r: r_sig,
		s: s_sig,
		y_parity: false,
	});
}
// Parses the public key and signature byte arrays and performs necessary validations.
// 
// This function processes the given public key (`pk_bytes`) and signature (`sig_bytes`), 
// extracting and validating them according to the rules set by the script verification flags in the engine (`vm`).

// Key steps include:
// 
// - Check Encoding Rules: Determines if strict encoding is required based on the engine's flags.
// 
// - Extract and Validate Hash Type: Retrieves the hash type from the signature and checks its validity.
// 
// - Validate Signature and Public Key: Ensures both the signature and public key are properly formatted and supported.
// 
// - Parse Components: Converts the byte arrays into a `Secp256k1Point` (for the public key) and a `Signature` struct.
// 
// The function returns a tuple containing the parsed public key, signature, and hash type.
// 
// @param vm A reference to the `Engine` that manages the execution context and provides the necessary script verification flags.
// @param pk_bytes The byte array representing the public key to be parsed and validated.
// @param sig_bytes The byte array containing the signature to be parsed and validated.
// @return A tuple containing the parsed public key (`Secp256k1Point`), signature (`Signature`), and hash type (`u32`).
pub fn parse_base_sig_and_pk(ref vm: Engine, 
	pk_bytes: @ByteArray, 
	sig_bytes: @ByteArray) -> Result<(Secp256k1Point, Signature, u32), felt252>{


	let hash_type_offset: usize = sig_bytes.len() - 1;
	let hash_type: u32 = sig_bytes[hash_type_offset].into();

	check_hash_type_encoding(ref vm, hash_type)?;
	check_signature_encoding(ref vm, sig_bytes)?;
	check_pub_key_encoding(ref vm, pk_bytes)?;

	let pub_key = parse_pub_key(pk_bytes);
	let sig = parse_signature(sig_bytes)?;

	Result::Ok((pub_key, sig, hash_type))
}
// Removes `OP_CODESEPARATOR` opcodes from the script.
// 
// This function processes a given script and removes any instances of the `OP_CODESEPARATOR` 
// (represented by the opcode value `171`). The purpose of `OP_CODESEPARATOR` is to allow dynamic 
// script execution, where parts of the script can be excluded from being hashed during signature verification. 
// By removing this opcode, the script becomes suitable for hashing and signature verification.
// 
// @param script The byte array representing the script from which `OP_CODESEPARATOR` opcodes should be removed.
// @return A new byte array representing the script with all `OP_CODESEPARATOR` opcodes removed.
fn remove_opcodeseparator(script: @ByteArray) -> @ByteArray {
	let mut parsed_script: ByteArray = "";
	let mut i: usize = 0;

	while i < script.len() {
		let value = script[i];
		if value != 171 { parsed_script.append_byte(value); }
		i+=1;
	};

	@parsed_script
}
// Prepares a transaction for signature hashing based on the specified hash type.
// 
// This function processes a transaction by modifying its inputs and outputs according to the hash type,
// which determines which parts of the transaction are included in the signature hash. Depending on the 
// hash type, the function may modify the sequence numbers, remove outputs, or modify inputs to create a 
// copy of the transaction that is ready to be hashed and signed.
// 
// Key operations include:
// 
// - Input Processing: Depending on the hash type, inputs are modified, particularly in the case of 
//   `SIG_HASH_SINGLE` and `SIG_HASH_NONE` where sequence numbers may be set to zero or inputs may be skipped.
// 
// - Output Processing: For `SIG_HASH_SINGLE`, outputs before the current input index are set to invalid, 
//   and for `SIG_HASH_NONE`, all outputs are removed.
// 
// - Handling `SIG_HASH_ANYONECANPAY`: If this flag is set, only the current input is included, and others are ignored.
// 
// The function returns a modified copy of the transaction, ready for signature hashing.
// 
// @param transaction The original transaction to be processed.
// @param index The index of the current input being processed.
// @param signature_script The script that is added to the transaction input during processing.
// @param hash_type The hash type that dictates how the transaction should be modified.
// @return A modified copy of the transaction based on the provided hash type.
fn transaction_procedure(ref transaction: Transaction, index: u32, signature_script: ByteArray, hash_type: u32) -> Transaction{
	let hash_type_masked = hash_type & SIG_HASH_MASK;
	let mut transaction_copy = transaction.clone();
	let mut i: usize = 0;
	let mut transaction_input: Span<TransactionInput> = transaction_copy.transaction_inputs.span();
	let mut processed_transaction_input: Array<TransactionInput> = ArrayTrait::<TransactionInput>::new();
	let mut processed_transaction_output: Array<TransactionOutput> = ArrayTrait::<TransactionOutput>::new();



	while i < transaction_input.len() {
		let mut temp_transaction_input: @TransactionInput = transaction_input.pop_front().unwrap();

		if hash_type_masked == SIG_HASH_SINGLE && i < index{
			processed_transaction_output.append(TransactionOutput {
				value: -1,
				publickey_script: "",
		});
		}
		
		if i == index {
			processed_transaction_input.append(TransactionInput {
				previous_outpoint: *temp_transaction_input.previous_outpoint,
				signature_script: signature_script.clone(),
				witness: temp_transaction_input.witness.clone(),
				sequence: *temp_transaction_input.sequence
		});
		} else {
			if hash_type & SIG_HASH_ANYONECANPAY != 0 {
				continue;
			}
			let mut temp_sequence = *temp_transaction_input.sequence;
			if hash_type_masked == SIG_HASH_NONE || hash_type_masked == SIG_HASH_SINGLE {
				temp_sequence = 0;
			}
			processed_transaction_input.append(TransactionInput {
				previous_outpoint: *temp_transaction_input.previous_outpoint,
				signature_script: "",
				witness: temp_transaction_input.witness.clone(),
				sequence: temp_sequence
		});
		}

		i+=1;
	};

	transaction_copy.transaction_inputs = processed_transaction_input;

	if hash_type_masked == SIG_HASH_NONE {
		transaction_copy.transaction_outputs = ArrayTrait::<TransactionOutput>::new();
	}

	if hash_type_masked == SIG_HASH_SINGLE {
		transaction_copy.transaction_outputs = processed_transaction_output;
	}

	transaction_copy
}
// Calculates the transaction hash for signing based on the provided script, hash type, and transaction data.
// 
// This function generates a hash of the transaction that is used for signature verification. The hash is 
// computed according to the specified `hash_type`, which dictates which parts of the transaction are included 
// in the hash. The process includes removing any `OP_CODESEPARATOR` opcodes from the script, modifying the 
// transaction according to the hash type, and then serializing the transaction data into a byte array for hashing.
// 
// Key operations include:
// 
// - Check for `SIG_HASH_SINGLE` Special Case: If the hash type is `SIG_HASH_SINGLE` and the input index is 
//   greater than the number of outputs, the function returns a predefined value (`0x01`), which is a convention 
//   used to indicate an invalid hash.
// 
// - Remove `OP_CODESEPARATOR`: The function removes any `OP_CODESEPARATOR` opcodes from the subscript to 
//   prepare it for hashing.
// 
// - Transaction Modification: The function creates a modified copy of the transaction using `transaction_procedure`, 
//   adjusting inputs and outputs according to the `hash_type`.
// 
// - Serialization and Hashing: The function serializes the modified transaction into a byte array and appends 
//   the necessary fields (version, inputs, outputs, locktime, and hash type). This byte array is then hashed using 
//   the SHA-256 hashing algorithm twice (hash256) to produce the final transaction hash.
// 
// @param sub_script The subscript of the transaction that is used in the hashing process.
// @param hash_type The hash type that determines which parts of the transaction are included in the hash.
// @param transaction The original transaction to be hashed.
// @param index The index of the input being signed.
// @return The resulting transaction hash as a `u256` value.
pub fn calc_transaction_hash(sub_script: @ByteArray, hash_type: u32, ref transaction: Transaction, index: u32) -> u256 {
	if hash_type & SIG_HASH_MASK == SIG_HASH_SINGLE && index > transaction.transaction_outputs.len().into() {
		return 0x01;
	}
    // Remove any OP_CODESEPARATOR opcodes from the subscript.
	let mut signature_script: @ByteArray = remove_opcodeseparator(sub_script);
    // Create a modified copy of the transaction according to the hash type.
	let mut transaction_copy: Transaction = transaction_procedure(ref transaction, index, signature_script.clone(), hash_type);
	let mut transaction_byte: ByteArray = "";
    // Serialize the transaction's version number.	
	transaction_byte.append_word_rev(transaction_copy.version.into(), 4);
    // Serialize the number of inputs in the transaction.
	let input_len: usize = transaction_copy.transaction_inputs.len();
	transaction_byte.append_word_rev(input_len.into(), int_size_in_bytes(input_len));
    // Serialize each input in the transaction.
	let mut i: usize = 0;
	while i < input_len {
		let input: @TransactionInput = transaction_copy.transaction_inputs.at(i);
		let input_hash: u256 = *input.previous_outpoint.hash;
		let vout: u32 = *input.previous_outpoint.index;
		let script: @ByteArray = input.signature_script;
		let script_len: usize = script.len();
		let sequence: u32 = *input.sequence;

		transaction_byte.append_word(input_hash.high.into(), 16);
		transaction_byte.append_word(input_hash.low.into(), 16);
		transaction_byte.append_word_rev(vout.into(), 4);
		transaction_byte.append_word_rev(script_len.into(), int_size_in_bytes(script_len));
		transaction_byte.append(script);
		transaction_byte.append_word_rev(sequence.into(), 4);

		i+=1;
	};
    // Serialize the number of outputs in the transaction.
	let output_len: usize = transaction_copy.transaction_outputs.len();
	transaction_byte.append_word_rev(output_len.into(), int_size_in_bytes(output_len));
	// Serialize each output in the transaction.
	i = 0;
	while i < output_len {
		let output: @TransactionOutput = transaction_copy.transaction_outputs.at(i);
		let value: i64 = *output.value;
		let script: @ByteArray = output.publickey_script;
		let script_len: usize = script.len();
		
		transaction_byte.append_word_rev(value.into(), 8);
		transaction_byte.append_word_rev(script_len.into(), int_size_in_bytes(script_len));
		transaction_byte.append(script);


		i+=1;
	};
	// Serialize the locktime and hash type.
	transaction_byte.append_word_rev(transaction_copy.locktime.into(), 4);
	transaction_byte.append_word_rev(hash_type.into(), 4);

    // Hash and return the serialized transaction data twice using SHA-256.
	hash256(@transaction_byte)
}
// Checks if the given script is a Pay-to-Witness-Public-Key-Hash (P2WPKH) script.
// 
// This function determines whether the provided script matches the structure of a 
// P2WPKH script, which is commonly used in Segregated Witness (SegWit) transactions.
// A P2WPKH script has a length of 22 bytes and starts with a version byte (`0x00`) 
// followed by a 20-byte public key hash. There are two types of witness version 0 programs:
// 
// 1. **P2WPKH (Pay-to-Witness-Public-Key-Hash)**: This script has the structure mentioned above.
// 2. **P2WSH (Pay-to-Witness-Script-Hash)**: Although not directly checked by this function, 
//    a P2WSH script has a length of 34 bytes and starts with a version byte (`0x00`) followed by 
//    a 32-byte SHA-256 hash of a witness script. 
// 
// This function specifically checks for P2WPKH by verifying the length and structure of the script.
// 
// @param script The byte array representing the script to be checked.
// @return `true` if the script is a valid P2WPKH script, `false` otherwise.
fn is_witness_pub_key_hash(script: @ByteArray) -> bool {
	let mut is_witness_pub_key_hash: bool = false;

	if script.len() == WITNESS_V0_PUB_KEY_HASH_LEN &&
		script[0] == 0 &&
		script[1] == 20 {
			is_witness_pub_key_hash = true;
		}
	is_witness_pub_key_hash
}
// Calculates the transaction hash for a Segregated Witness (SegWit) transaction.
// 
// This function generates a hash of a SegWit transaction that is used for signature 
// verification. The hash is computed according to the specified `hash_type`, which 
// dictates which parts of the transaction are included in the hash. This includes 
// handling witness data and removing any `OP_CODESEPARATOR` opcodes from the script.
// 
// Key operations include:
// 
// - Check for `SIG_HASH_SINGLE` Special Case: If the hash type is `SIG_HASH_SINGLE` 
//   and the input index is greater than the number of outputs, the function returns a 
//   predefined value (`0x01`), which is used to indicate an invalid hash.
// 
// - Remove `OP_CODESEPARATOR`: The function removes any `OP_CODESEPARATOR` opcodes 
//   from the subscript to prepare it for hashing.
// 
// - Input and Output Processing: The function serializes the inputs, outputs, and 
//   other transaction fields into byte arrays, taking into account the `hash_type`. 
// 
// - Serialization and Hashing: The function concatenates the serialized components 
//   and hashes them twice using SHA-256 to produce the final transaction hash.
// 
// @param sub_script The subscript of the transaction that is used in the hashing process.
// @param hash_type The hash type that determines which parts of the transaction are included in the hash.
// @param transaction The original SegWit transaction to be hashed.
// @param index The index of the input being signed.
// @param amount The amount associated with the input being signed, necessary for SegWit transactions.
// @return The resulting transaction hash as a `u256` value.
pub fn calc_witness_transaction_hash(sub_script: @ByteArray, hash_type: u32, ref transaction: Transaction, index: u32, amount: i64) -> u256 {
	if hash_type & SIG_HASH_MASK == SIG_HASH_SINGLE && index > transaction.transaction_outputs.len().into() {
		return 0x01;
	}
	let mut transaction_byte: ByteArray = "";
	let mut input_byte: ByteArray = "";
	let mut output_byte: ByteArray = "";
	let mut sequence_byte: ByteArray = "";
    // Serialize the transaction's version number.	
	transaction_byte.append_word_rev(transaction.version.into(), 4);
    // Serialize each input in the transaction.
	let input_len: usize = transaction.transaction_inputs.len();
	let mut i: usize = 0;
	while i < input_len {
		let input: @TransactionInput = transaction.transaction_inputs.at(i);
		
		let input_hash: u256 = *input.previous_outpoint.hash;
		let vout: u32 = *input.previous_outpoint.index;
		let sequence: u32 = *input.sequence;

		input_byte.append_word(input_hash.high.into(), 16);
		input_byte.append_word(input_hash.low.into(), 16);
		input_byte.append_word_rev(vout.into(), 4);
		sequence_byte.append_word_rev(sequence.into(), 4);

		i+=1;
	};
    // Serialize each output if not using SIG_HASH_SINGLE or SIG_HASH_NONE else serialize only the relevant output.
	if hash_type & SIG_HASH_SINGLE != SIG_HASH_SINGLE && hash_type & SIG_HASH_NONE != SIG_HASH_NONE {
		let output_len: usize = transaction.transaction_outputs.len();

		i = 0;
		while i < output_len {
			let output: @TransactionOutput = transaction.transaction_outputs.at(i);
			let value: i64 = *output.value;
			let script: @ByteArray = output.publickey_script;
			let script_len: usize = script.len();
			
			output_byte.append_word_rev(value.into(), 8);
			output_byte.append_word_rev(script_len.into(), int_size_in_bytes(script_len));
			output_byte.append(script);

			i+=1;
		};
	} else if hash_type & SIG_HASH_SINGLE == SIG_HASH_SINGLE {
		if index < transaction.transaction_outputs.len() {
			let output: @TransactionOutput = transaction.transaction_outputs.at(index);
			let value: i64 = *output.value;
			let script: @ByteArray = output.publickey_script;
			let script_len: usize = script.len();
			
			output_byte.append_word_rev(value.into(), 8);
			output_byte.append_word_rev(script_len.into(), int_size_in_bytes(script_len));
			output_byte.append(script);
		}
	}
	let mut hash_prevouts: u256 = 0;
	if hash_type & SIG_HASH_ANYONECANPAY != SIG_HASH_ANYONECANPAY { 
		hash_prevouts = hash256(@input_byte);
	}

	let mut hash_sequence: u256 = 0;
	if hash_type & SIG_HASH_ANYONECANPAY != SIG_HASH_ANYONECANPAY && hash_type & SIG_HASH_SINGLE != SIG_HASH_SINGLE && hash_type & SIG_HASH_NONE != SIG_HASH_NONE {
		hash_sequence = hash256(@sequence_byte);
	}

	let mut hash_outputs: u256 = 0;
	if hash_type & SIG_HASH_ANYONECANPAY == SIG_HASH_ANYONECANPAY || hash_type & SIG_HASH_SINGLE == SIG_HASH_SINGLE || hash_type & SIG_HASH_ALL == SIG_HASH_ALL {
		hash_sequence = hash256(@output_byte);
	}

	// Append the hashed previous outputs and sequences.
	transaction_byte.append_word_rev(hash_prevouts.high.into(), 16);
	transaction_byte.append_word_rev(hash_prevouts.low.into(), 16);
	transaction_byte.append_word_rev(hash_sequence.high.into(), 16);
	transaction_byte.append_word_rev(hash_sequence.low.into(), 16);
    // Add the input being signed.

	let mut input: @TransactionInput = transaction.transaction_inputs.at(i);
	let input_hash: u256 = *input.previous_outpoint.hash;
	let vout: u32 = *input.previous_outpoint.index;
	let sequence: u32 = *input.sequence;
	transaction_byte.append_word_rev(input_hash.high.into(), 16);
	transaction_byte.append_word_rev(input_hash.low.into(), 16);
	transaction_byte.append_word_rev(vout.into(), 4);
    // Check if the script is a witness pubkey hash and serialize accordingly.
	if is_witness_pub_key_hash(sub_script){
		transaction_byte.append_byte(0x19);
		transaction_byte.append_byte(0x76);
		transaction_byte.append_byte(0xa9);
		transaction_byte.append_byte(0x14);
		i = 2;
		while i < sub_script.len() {
			transaction_byte.append_byte(sub_script[i]);
			i += 1;
		};
		transaction_byte.append_byte(0x88);
		transaction_byte.append_byte(0xac);

	} else {
		transaction_byte.append(sub_script);
	}
    // Serialize the amount and sequence number.
	transaction_byte.append_word_rev(amount.into(), 8);
	transaction_byte.append_word_rev(sequence.into(), 4);
    // Serialize the hashed outputs.
	transaction_byte.append_word_rev(hash_outputs.high.into(), 16);
	transaction_byte.append_word_rev(hash_outputs.low.into(), 16);
    // Serialize the transaction's locktime and hash type.
	transaction_byte.append_word_rev(transaction.locktime.into(), 4);
	transaction_byte.append_word_rev(hash_type.into(), 4);
    // Hash and return the serialized transaction data twice using SHA-256.
	hash256(@transaction_byte)
}