use crate::signature::schnorr::verify_schnorr;
use crate::errors::Error;
use starknet::secp256_trait::Signature;
use shinigami_utils::byte_array::U256IntoByteArray;

// Test data adapted from: https://github.com/bitcoin/bips/blob/master/bip-0340/test-vectors.csv

#[test]
fn test_schnorr_verify_0() {
    let sig = Signature {
        r: 0xe907831f80848d1069a5371b402410364bdf1c5f8307b0084c55f1ce2dca8215,
        s: 0x25f66a4a85ea8b71e482a74f382d2ce5ebeee8fdb2172f477df4900d310536c0,
        y_parity: false,
    };
    let pk: u256 = 0xf9308a019258c31049344f85f89d5229b531c845836f99b08601f113bce036f9;
    let m: u256 = 0x0;
    assert!(verify_schnorr(sig, m.into(), pk.into()).unwrap());
}

#[test]
fn test_schnorr_verify_1() {
    let sig = Signature {
        r: 0x6896bd60eeae296db48a229ff71dfe071bde413e6d43f917dc8dcf8c78de3341,
        s: 0x8906d11ac976abccb20b091292bff4ea897efcb639ea871cfa95f6de339e4b0a,
        y_parity: false,
    };
    let pk: u256 = 0xdff1d77f2a671c5f36183726db2341be58feae1da2deced843240f7b502ba659;
    let m: u256 = 0x243f6a8885a308d313198a2e03707344a4093822299f31d0082efa98ec4e6c89;
    assert!(verify_schnorr(sig, m.into(), pk.into()).unwrap());
}

#[test]
fn test_schnorr_verify_2() {
    let sig = Signature {
        r: 0x5831aaeed7b44bb74e5eab94ba9d4294c49bcf2a60728d8b4c200f50dd313c1b,
        s: 0xab745879a5ad954a72c45a91c3a51d3c7adea98d82f8481e0e1e03674a6f3fb7,
        y_parity: false,
    };
    let pk: u256 = 0xdd308afec5777e13121fa72b9cc1b7cc0139715309b086c960e18fd969774eb8;
    let m: u256 = 0x7e2d58d8b3bcdf1abadec7829054f90dda9805aab56c77333024b9d0a508b75c;
    assert!(verify_schnorr(sig, m.into(), pk.into()).unwrap());
}

#[test]
fn test_schnorr_verify_3() {
    let sig = Signature {
        r: 0x7eb0509757e246f19449885651611cb965ecc1a187dd51b64fda1edc9637d5ec,
        s: 0x97582b9cb13db3933705b32ba982af5af25fd78881ebb32771fc5922efc66ea3,
        y_parity: false,
    };
    let pk: u256 = 0x25d1dff95105f5253c4022f628a996ad3a0d95fbf21d468a1b33f8c160d8f517;
    let m: u256 = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff;
    assert!(verify_schnorr(sig, m.into(), pk.into()).unwrap());
}

#[test]
fn test_schnorr_verify_4() {
    let sig = Signature {
        r: 0x3b78ce563f89a0ed9414f5aa28ad0d96d6795f9c63,
        s: 0x76afb1548af603b3eb45c9f8207dee1060cb71c04e80f593060b07d28308d7f4,
        y_parity: false,
    };
    let pk: u256 = 0xd69c3509bb99e412e68b0fe8544e72837dfa30746d8be2aa65975f29d22dc7b9;
    let m: u256 = 0x4df3c3f68fcc83b27e9d42c90431a72499f17875c81a599b566c9889b9696703;
    assert!(verify_schnorr(sig, m.into(), pk.into()).unwrap());
}

#[test]
#[should_panic] // Because 'unwrap_syscall()' panics on error, so the error is unrecoverable
fn test_schnorr_verify_5() {
    // Public key not on the curve
    let sig = Signature {
        r: 0x6cff5c3ba86c69ea4b7376f31a9bcb4f74c1976089b2d9963da2e5543e177769,
        s: 0x69e89b4c5564d00349106b8497785dd7d1d713a8ae82b32fa79d5f7fc407d39b,
        y_parity: false,
    };
    let pk: u256 = 0xeefdea4cdb677750a420fee807eacf21eb9898ae79b9768766e4faa04a2d4a34;
    let m: u256 = 0x243f6a8885a308d313198a2e03707344a4093822299f31d0082efa98ec4e6c89;
    verify_schnorr(sig, m.into(), pk.into()).unwrap_err();
}

#[test]
fn test_schnorr_verify_6() {
    // Has_even_y(R) is false
    let sig = Signature {
        r: 0xfff97bd5755eeea420453a14355235d382f6472f8568a18b2f057a1460297556,
        s: 0x3cc27944640ac607cd107ae10923d9ef7a73c643e166be5ebeafa34b1ac553e2,
        y_parity: false,
    };
    let pk: u256 = 0xdff1d77f2a671c5f36183726db2341be58feae1da2deced843240f7b502ba659;
    let m: u256 = 0x243f6a8885a308d313198a2e03707344a4093822299f31d0082efa98ec4e6c89;
    assert_eq!(verify_schnorr(sig, m.into(), pk.into()).unwrap(), false);
}

#[test]
fn test_schnorr_verify_7() {
    // Negated message
    let sig = Signature {
        r: 0x1fa62e331edbc21c394792d2ab1100a7b432b013df3f6ff4f99fcb33e0e1515f,
        s: 0x28890b3edb6e7189b630448b515ce4f8622a954cfe545735aaea5134fccdb2bd,
        y_parity: false,
    };
    let pk: u256 = 0xdff1d77f2a671c5f36183726db2341be58feae1da2deced843240f7b502ba659;
    let m: u256 = 0x243f6a8885a308d313198a2e03707344a4093822299f31d0082efa98ec4e6c89;
    assert_eq!(verify_schnorr(sig, m.into(), pk.into()).unwrap(), false);
}

#[test]
fn test_schnorr_verify_8() {
    // Negated s value
    let sig = Signature {
        r: 0x6cff5c3ba86c69ea4b7376f31a9bcb4f74c1976089b2d9963da2e5543e177769,
        s: 0x961764b3aa9b2ffcb6ef947b6887a226e8d7c93e00c5ed0c1834ff0d0c2e6da6,
        y_parity: false,
    };
    let pk: u256 = 0xdff1d77f2a671c5f36183726db2341be58feae1da2deced843240f7b502ba659;
    let m: u256 = 0x243f6a8885a308d313198a2e03707344a4093822299f31d0082efa98ec4e6c89;
    assert_eq!(verify_schnorr(sig, m.into(), pk.into()).unwrap(), false);
}

#[test]
fn test_schnorr_verify_9() {
    // sG - eP is infinite. Test fails in single verification if has_even_y(inf) is defined as
    // true and x(inf) as 0
    let sig = Signature {
        r: 0x0,
        s: 0x123dda8328af9c23a94c1feecfd123ba4fb73476f0d594dcb65c6425bd186051,
        y_parity: false,
    };
    let pk: u256 = 0xdff1d77f2a671c5f36183726db2341be58feae1da2deced843240f7b502ba659;
    let m: u256 = 0x243f6a8885a308d313198a2e03707344a4093822299f31d0082efa98ec4e6c89;
    assert_eq!(verify_schnorr(sig, m.into(), pk.into()).unwrap(), false);
}

#[test]
fn test_schnorr_verify_10() {
    // sG - eP is infinite. Test fails in single verification if has_even_y(inf) is defined as
    // true and x(inf) as 1
    let sig = Signature {
        r: 0x1,
        s: 0x7615fbaf5ae28864013c099742deadb4dba87f11ac6754f93780d5a1837cf197,
        y_parity: false,
    };
    let pk: u256 = 0xdff1d77f2a671c5f36183726db2341be58feae1da2deced843240f7b502ba659;
    let m: u256 = 0x243f6a8885a308d313198a2e03707344a4093822299f31d0082efa98ec4e6c89;
    assert_eq!(verify_schnorr(sig, m.into(), pk.into()).unwrap(), false);
}

#[test]
fn test_schnorr_verify_11() {
    // sig[0:32] is not an X coordinate on the curve
    let sig = Signature {
        r: 0x4a298dacae57395a15d0795ddbfd1dcb564da82b0f269bc70a74f8220429ba1d,
        s: 0x69e89b4c5564d00349106b8497785dd7d1d713a8ae82b32fa79d5f7fc407d39b,
        y_parity: false,
    };
    let pk: u256 = 0xdff1d77f2a671c5f36183726db2341be58feae1da2deced843240f7b502ba659;
    let m: u256 = 0x243f6a8885a308d313198a2e03707344a4093822299f31d0082efa98ec4e6c89;
    assert_eq!(verify_schnorr(sig, m.into(), pk.into()).unwrap(), false);
}

#[test]
fn test_schnorr_verify_12() {
    // sig[0:32] is equal to field size
    let sig = Signature {
        r: 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc2f,
        s: 0x69e89b4c5564d00349106b8497785dd7d1d713a8ae82b32fa79d5f7fc407d39b,
        y_parity: false,
    };
    let pk: u256 = 0xdff1d77f2a671c5f36183726db2341be58feae1da2deced843240f7b502ba659;
    let m: u256 = 0x243f6a8885a308d313198a2e03707344a4093822299f31d0082efa98ec4e6c89;
    let result = verify_schnorr(sig, m.into(), pk.into()).unwrap_err();
    let expected = Error::SCHNORR_INVALID_SIG_R_FIELD;
    assert_eq!(result, expected);
}

#[test]
fn test_schnorr_verify_13() {
    // sig[32:64] is equal to curve order
    let sig = Signature {
        r: 0x6cff5c3ba86c69ea4b7376f31a9bcb4f74c1976089b2d9963da2e5543e177769,
        s: 0xfffffffffffffffffffffffffffffffebaaedce6af48a03bbfd25e8cd0364141,
        y_parity: false,
    };
    let pk: u256 = 0xdff1d77f2a671c5f36183726db2341be58feae1da2deced843240f7b502ba659;
    let m: u256 = 0x243f6a8885a308d313198a2e03707344a4093822299f31d0082efa98ec4e6c89;
    let result = verify_schnorr(sig, m.into(), pk.into()).unwrap_err();
    let expected = Error::SCHNORR_INVALID_SIG_SIZE;
    assert_eq!(result, expected);
}

#[test]
#[should_panic] // Because 'unwrap_syscall()' panics on error, so the error is unrecoverable
fn test_schnorr_verify_14() {
    // Public key is not a valid X coordinate because it exceeds the field size
    let sig = Signature {
        r: 0x6cff5c3ba86c69ea4b7376f31a9bcb4f74c1976089b2d9963da2e5543e177769,
        s: 0x69e89b4c5564d00349106b8497785dd7d1d713a8ae82b32fa79d5f7fc407d39b,
        y_parity: false,
    };
    let pk: u256 = 0xfffffffffffffffffffffffffffffffffffffffffffffffffffffffefffffc30;
    let m: u256 = 0x243f6a8885a308d313198a2e03707344a4093822299f31d0082efa98ec4e6c89;
    verify_schnorr(sig, m.into(), pk.into()).unwrap_err();
}