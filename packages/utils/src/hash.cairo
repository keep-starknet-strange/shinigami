use core::sha256::compute_sha256_byte_array;

pub fn sha256_byte_array(byte: @ByteArray) -> ByteArray {
    let msg_hash = compute_sha256_byte_array(byte);
    let mut hash_value: ByteArray = "";
    for word in msg_hash.span() {
        hash_value.append_word((*word).into(), 4);
    };

    hash_value
}

pub fn double_sha256_bytearray(byte: @ByteArray) -> ByteArray {
    return sha256_byte_array(@sha256_byte_array(byte));
}

pub fn double_sha256(byte: @ByteArray) -> u256 {
    let msg_hash = compute_sha256_byte_array(byte);
    let mut res_bytes = "";
    for word in msg_hash.span() {
        res_bytes.append_word((*word).into(), 4);
    };
    let msg_hash = compute_sha256_byte_array(@res_bytes);
    let mut hash_value: u256 = 0;
    for word in msg_hash
        .span() {
            hash_value *= 0x100000000;
            hash_value = hash_value + (*word).into();
        };

    hash_value
}
