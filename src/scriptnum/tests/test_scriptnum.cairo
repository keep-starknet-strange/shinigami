use crate::scriptnum::ScriptNum;

#[test]
fn test_scriptnum_wrap_unwrap() {
    let mut int = 0;
    let mut returned_int = ScriptNum::unwrap(ScriptNum::wrap(int));
    assert!(int == returned_int, "Wrap/unwrap 0 not equal");

    int = 1;
    returned_int = ScriptNum::unwrap(ScriptNum::wrap(int));
    assert!(int == returned_int, "Wrap/unwrap 1 not equal");

    int = -1;
    returned_int = ScriptNum::unwrap(ScriptNum::wrap(int));
    assert!(int == returned_int, "Wrap/unwrap -1 not equal");

    int = 32767;
    returned_int = ScriptNum::unwrap(ScriptNum::wrap(int));
    assert!(int == returned_int, "Wrap/unwrap 32767 not equal");

    int = -452354;
    returned_int = ScriptNum::unwrap(ScriptNum::wrap(int));
    assert!(int == returned_int, "Wrap/unwrap 32767 not equal");

    int = 2147483647; // 0x7FFFFFFF
    returned_int = ScriptNum::unwrap(ScriptNum::wrap(int));
    assert!(int == returned_int, "Wrap/unwrap 2147483647 not equal");

    int = -2147483648; // 0x80000000
    returned_int = ScriptNum::unwrap(ScriptNum::wrap(int));
    assert!(int == returned_int, "Wrap/unwrap -2147483648 not equal");
}

#[test]
fn test_scriptnum_bytes_wrap() {
    let mut bytes: ByteArray = Default::default();
    bytes.append_byte(42); // 0x2A
    let mut returned_int = ScriptNum::unwrap(bytes);
    assert!(returned_int == 42, "Unwrap 0x2A not equal to 42");

    let mut bytes: ByteArray = "";
    returned_int = ScriptNum::unwrap(bytes);
    assert!(returned_int == 0, "Unwrap empty bytes not equal to 0");

    let mut bytes: ByteArray = Default::default();
    bytes.append_byte(129); // 0x81
    bytes.append_byte(128); // 0x80
    returned_int = ScriptNum::unwrap(bytes);
    assert!(returned_int == -129, "Unwrap 0x8180 not equal to -129");

    let mut bytes: ByteArray = Default::default();
    bytes.append_byte(255); // 0xFF
    bytes.append_byte(127); // 0x7F
    returned_int = ScriptNum::unwrap(bytes);
    assert!(returned_int == 32767, "0xFF7F not equal to 32767");

    let mut bytes: ByteArray = Default::default();
    bytes.append_byte(0); // 0x00
    bytes.append_byte(128); // 0x80
    bytes.append_byte(128); // 0x80
    returned_int = ScriptNum::unwrap(bytes);
    assert!(returned_int == -32768, "0x008080 not equal to -32768");
}

#[test]
#[should_panic]
fn test_scriptnum_too_big_unwrap_panic() {
    let mut bytes: ByteArray = Default::default();
    bytes.append_word_rev(2147483647 + 1, 5);
    ScriptNum::unwrap(bytes);
}
