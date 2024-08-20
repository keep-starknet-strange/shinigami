use shinigami::compiler::CompilerTraitImpl;
use shinigami::engine::EngineTraitImpl;
//use shinigami::signature::signature;
use shinigami::scriptflags::ScriptFlags;
use shinigami::signature::signature::{
    check_pub_key_encoding, check_hash_type_encoding, check_signature_encoding, parse_pub_key,
    parse_signature, remove_signature, calc_transaction_hash
};
use shinigami::utils::u256_from_byte_array_with_offset;
use starknet::SyscallResultTrait;
use starknet::secp256_trait::{Secp256Trait, Secp256PointTrait};
use starknet::secp256k1::{Secp256k1Point};
use starknet::secp256_trait::Signature;
use shinigami::transaction::TransactionTrait;
// #[test]
// fn test_byte_array_to_u256_conversion() {
//     let mut signature: ByteArray = "";

//     let r: u256 = 0x08f4f37e2d8f74e18c1b8fde2374d5f28402fb8ab7fd1cc5b786aa40851a70cb;
//     // let r: u256 = 0x08080808080808080808080808080808;

//     signature.append_word(r.high.into(), 16);
//     signature.append_word(r.low.into(), 16);

//     let res: u256 = u256_from_byte_array_with_offset(@signature, 0, 32);
//     assert!(res == 0x08f4f37e2d8f74e18c1b8fde2374d5f28402fb8ab7fd1cc5b786aa40851a70cb, "wrong
//     conversion");
// }

// #[test]
// fn test_engine_flags() {
//     let mut bytecode: ByteArray = "";
//     let mut engine = EngineTraitImpl::new(bytecode, Option::None, Option::None);
//     assert!(!engine.has_flag(ScriptFlags::ScriptVerifyLowS), "Flag should not be set");
//     engine.add_flag(ScriptFlags::ScriptVerifyLowS);
//     assert!(engine.has_flag(ScriptFlags::ScriptVerifyLowS), "Flag hasn't been set");
// }

// #[test]
// #[should_panic]
// fn test_check_invalid_hash_type() {
//     let mut bytecode: ByteArray = "";
//     let mut engine = EngineTraitImpl::new(bytecode, Option::None, Option::None);
//     let mut hash_type: u32 = 0x10;

//     engine.add_flag(ScriptFlags::ScriptVerifyStrictEncoding);
//     check_hash_type_encoding(ref engine, hash_type);
// }

// #[test]
// fn test_check_valid_hash_type() {
//     let mut bytecode: ByteArray = "";
//     let mut engine = EngineTraitImpl::new(bytecode, Option::None, Option::None);
//     let mut hash_type: u32 = 0x81;

//     engine.add_flag(ScriptFlags::ScriptVerifyStrictEncoding);
//     check_hash_type_encoding(ref engine, hash_type);
// }

// #[test]
// fn test_check_valid_signature() {
//     let mut bytecode: ByteArray = "";
//     let mut signature: ByteArray = "";
//     let mut engine = EngineTraitImpl::new(bytecode, Option::None, Option::None);

//     let r: u256 = 0x08f4f37e2d8f74e18c1b8fde2374d5f28402fb8ab7fd1cc5b786aa40851a70cb;
//     let s: u256 = 0x32b1374d1a0f125eae4f69d1bc0b7f896c964cfdba329f38a952426cf427484c;

//     signature.append_byte(0x30);
//     signature.append_byte(0x44);
//     signature.append_byte(0x02);
//     signature.append_byte(0x20);
//     signature.append_word(r.high.into(), 16);
//     signature.append_word(r.low.into(), 16);
//     signature.append_byte(0x02);
//     signature.append_byte(0x20);
//     signature.append_word(s.high.into(), 16);
//     signature.append_word(s.low.into(), 16);
//     signature.append_byte(0x01);

//     check_signature_encoding(ref engine, @signature);
// }

// #[test]
// #[should_panic(expected: "invalid signature format: negative R")]
// fn test_check_strict_encoding_signature() {
//     let mut bytecode: ByteArray = "";
//     let mut signature: ByteArray = "";
//     let mut engine = EngineTraitImpl::new(bytecode, Option::None, Option::None);

//     let r: u256 = 0x91f4f37e2d8f74e18c1b8fde2374d5f28402fb8ab7fd1cc5b786aa40851a7091;
//     let s: u256 = 0x32b1374d1a0f125eae4f69d1bc0b7f896c964cfdba329f38a952426cf427484c;

//     signature.append_byte(0x30);
//     signature.append_byte(0x44);
//     signature.append_byte(0x02);
//     signature.append_byte(0x20);
//     signature.append_word(r.high.into(), 16);
//     signature.append_word(r.low.into(), 16);
//     signature.append_byte(0x02);
//     signature.append_byte(0x20);
//     signature.append_word(s.high.into(), 16);
//     signature.append_word(s.low.into(), 16);
//     signature.append_byte(0x01);

//     engine.add_flag(ScriptFlags::ScriptVerifyStrictEncoding);
//     check_signature_encoding(ref engine, @signature);
// }

// #[test]
// #[should_panic(expected: "signature is not canonical due to unnecessarily high S value")]
// fn test_check_low_s_signature() {
//     let mut bytecode: ByteArray = "";
//     let mut signature: ByteArray = "";
//     let mut engine = EngineTraitImpl::new(bytecode, Option::None, Option::None);

//     let r: u256 = 0x08f4f37e2d8f74e18c1b8fde2374d5f28402fb8ab7fd1cc5b786aa40851a7008;
//     let s: u256 = 92863333202977815382282085201442505678068635860713199033093816967938834364661;

//     signature.append_byte(0x30);
//     signature.append_byte(0x44);
//     signature.append_byte(0x02);
//     signature.append_byte(0x20);
//     signature.append_word(r.high.into(), 16);
//     signature.append_word(r.low.into(), 16);
//     signature.append_byte(0x02);
//     signature.append_byte(0x20);
//     signature.append_word(s.high.into(), 16);
//     signature.append_word(s.low.into(), 16);
//     signature.append_byte(0x01);

//     engine.add_flag(ScriptFlags::ScriptVerifyLowS);
//     check_signature_encoding(ref engine, @signature);
// }

// #[test]
// #[should_panic(expected: "invalid signature format: empty signature")]
// fn test_check_empty_signature() {
//     let mut bytecode: ByteArray = "";
//     let mut signature: ByteArray = "";
//     let mut engine = EngineTraitImpl::new(bytecode, Option::None, Option::None);

//     check_signature_encoding(ref engine, @signature);
// }

// #[test]
// #[should_panic(expected: "invalid signature format: too short")]
// fn test_check_short_signature() {
//     let mut bytecode: ByteArray = "";
//     let mut signature: ByteArray = "0";
//     let mut engine = EngineTraitImpl::new(bytecode, Option::None, Option::None);

//     check_signature_encoding(ref engine, @signature);
// }

// #[test]
// #[should_panic(expected: "invalid signature format: too long")]
// fn test_check_long_signature() {
//     let mut bytecode: ByteArray = "";
//     let mut signature: ByteArray =
//     "00000000000000000000000000000000000000000000000000000000000000000000000000";
//     let mut engine = EngineTraitImpl::new(bytecode, Option::None, Option::None);

//     check_signature_encoding(ref engine, @signature);
// }

// #[test]
// #[should_panic(expected: "invalid signature format: wrong type")]
// fn test_check_wrong_type_signature() {
//     let mut bytecode: ByteArray = "";
//     let mut signature: ByteArray = "";
//     signature.append_byte(0);
//     signature.append_byte(8);
//     signature.append_word_rev(10580746335774456114284867618, 9);

//     let mut engine = EngineTraitImpl::new(bytecode, Option::None, Option::None);

//     check_signature_encoding(ref engine, @signature);
// }

// #[test]
// #[should_panic(expected: "invalid signature format: bad length")]
// fn test_check_wrong_data_length_signature() {
//     let mut bytecode: ByteArray = "";
//     let mut signature: ByteArray = "";
//     signature.append_byte(0x30);
//     signature.append_byte(9);
//     signature.append_word_rev(10580746335774456114284867618, 9);

//     let mut engine = EngineTraitImpl::new(bytecode, Option::None, Option::None);

//     check_signature_encoding(ref engine, @signature);
// }

// #[test]
// fn test_valid_pub_key() {
//     let mut bytecode: ByteArray = "";
//     let mut pub_key: ByteArray = "";
//     let r: u256 = 0x08f4f37e2d8f74e18c1b8fde2374d5f28402fb8ab7fd1cc5b786aa40851a7008;

//     pub_key.append_byte(0x02);
//     pub_key.append_word(r.high.into(), 16);
//     pub_key.append_word(r.low.into(), 16);

//     let mut engine = EngineTraitImpl::new(bytecode, Option::None, Option::None);

//     check_pub_key_encoding(ref engine, @pub_key);
// }

// #[test]
// fn test_parse_pub_key() {
//     let mut pub_key: ByteArray = "";
//     let r: u256 = 0x79BE667EF9DCBBAC55A06295CE870B07029BFCDB2DCE28D959F2815B16F81798 ;

//     pub_key.append_byte(0x02);
//     pub_key.append_word(r.high.into(), 16);
//     pub_key.append_word(r.low.into(), 16);

//     let pub_key_point= parse_pub_key(@pub_key);
//     let point_from_pub_key =
//     Secp256Trait::<Secp256k1Point>::secp256_ec_get_point_from_x_syscall(r,
//     false).unwrap_syscall().expect('Secp256k1Point: Invalid point.');
//     assert!(pub_key_point.get_coordinates() == point_from_pub_key.get_coordinates(), "Wrong
//     pub_key coordinates");
// }

// #[test]
// fn test_parse_signature() {
//     let mut signature: ByteArray = "";

//     let r: u256 = 0x08f4f37e2d8f74e18c1b8fde2374d5f28402fb8ab7fd1cc5b786aa40851a70cb;
//     let s: u256 = 0x32b1374d1a0f125eae4f69d1bc0b7f896c964cfdba329f38a952426cf427484c;

//     signature.append_byte(0x30);
//     signature.append_byte(0x44);
//     signature.append_byte(0x02);
//     signature.append_byte(0x20);
//     signature.append_word(r.high.into(), 16);
//     signature.append_word(r.low.into(), 16);
//     signature.append_byte(0x02);
//     signature.append_byte(0x20);
//     signature.append_word(s.high.into(), 16);
//     signature.append_word(s.low.into(), 16);
//     signature.append_byte(0x01);

//     let sig= parse_signature(@signature);
//     assert!(sig.r == 0x08f4f37e2d8f74e18c1b8fde2374d5f28402fb8ab7fd1cc5b786aa40851a70cb, "Wrong
//     signature R");
//     assert!(sig.s == 0x32b1374d1a0f125eae4f69d1bc0b7f896c964cfdba329f38a952426cf427484c, "Wrong
//     signature S");
// }

// #[test]
// fn test_temp() {
//     let mut byte: ByteArray = "";

//     // let v: u32 = 0x01;

//     // byte.append_word(v.into(), 4);

//     assert!(byte.len() == 0, "error");
// }

// #[test]
// fn test_remove_signature() {
//     let mut byte: ByteArray = "";
//     let mut sig_byte: ByteArray = "";
//     let mut v1: u256 = 0x483045022100c219a522e65ca8500ebe05a70d5a49d840ccc15f2afa4ee9df78;
//     let mut v2: u256 = 0x3f06b2a322310220489a46c37feb33f52c586da25c70113b8eea41216440eb84;
//     let mut v3: u256 = 0x771cb67a67fdb68c0176a9144299ff317fcd12ef19047df66d72454691797bfc;
//     let mut v7: u32 = 0x88ac;

//     let mut v4: u256 = 0x3045022100c219a522e65ca8500ebe05a70d5a49d840ccc15f2afa4ee9df783f;
//     let mut v5: u256 = 0x06b2a322310220489a46c37feb33f52c586da25c70113b8eea41216440eb8477;
//     let mut v6: u256 = 0x1cb67a67fdb68c01;

//     byte.append_word(v1.high.into(), 16);
//     byte.append_word(v1.low.into(), 16);
//     byte.append_word(v2.high.into(), 16);
//     byte.append_word(v2.low.into(), 16);
//     byte.append_word(v3.high.into(), 16);
//     byte.append_word(v3.low.into(), 16);
//     byte.append_word(v7.into(), 2);

//     sig_byte.append_word(v4.high.into(), 16);
//     sig_byte.append_word(v4.low.into(), 16);
//     sig_byte.append_word(v5.high.into(), 16);
//     sig_byte.append_word(v5.low.into(), 16);
//     sig_byte.append_word(v6.low.into(), 8);

//     let script_byte = remove_signature(@byte, @sig_byte);
//     let mut transaction = TransactionTrait::mock_transaction();

// let mut count = 0;

//     println!("");
//     println!("");
// while count != script_byte.len() {
//     print!("{} ", script_byte[count]);
//     count += 1;
// };
//     println!("");
//     println!("");

//     let tx_hash = calc_transaction_hash(script_byte, 0x01,ref transaction, 0);

// println!("////////////////////////mdr{}", script_byte.len());

//     assert!(script_byte[0] == 0x76, "error");
//     assert!(script_byte[24] == 0xac, "error2");
// }

// #[test]
// fn test_witness_signature() {
//     let mut byte: ByteArray = "";
//     let mut sig_byte: ByteArray = "";
//     let mut v7: u256 = 0x76a914ce72abfd0e6d9354a660c18f2825eb392f060fdc88ac;

//     byte.append_word(v7.high.into(), 9);
//     byte.append_word(v7.low.into(), 16);

//     let mut transaction = TransactionTrait::mock_witness_transaction();

// let mut count = 0;

//     println!("");
//     println!("");
//     while count != byte.len() {
//         print!("{} ", byte[count]);
//         count += 1;
//     };
//     println!("");
//     println!("");

//     //let tx_hash = calc_witness_transaction_hash(byte, 0x01,ref transaction, 0);
// }

