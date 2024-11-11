// Big-endian
pub fn byte_array_to_felt252_be(byte_array: @ByteArray) -> felt252 {
    let byte_shift = 256;
    let mut value = 0;
    let mut i = 0;
    let byte_array_len = byte_array.len();
    while i != byte_array_len {
        value = value * byte_shift + byte_array[i].into();
        i += 1;
    };
    value
}

// Little-endian
pub fn byte_array_to_felt252_le(byte_array: @ByteArray) -> felt252 {
    let byte_shift = 256;
    let mut value = 0;
    let byte_array_len = byte_array.len();
    let mut i = byte_array_len - 1;
    while true {
        value = value * byte_shift + byte_array[i].into();
        if i == 0 {
            break;
        }
        i -= 1;
    };
    value
}

pub fn byte_array_value_at_be(byte_array: @ByteArray, ref offset: usize, len: usize) -> felt252 {
    let byte_shift = 256;
    let mut value = 0;
    let mut i = offset;
    let end = offset + len;
    while i != end {
        value = value * byte_shift + byte_array[i].into();
        i += 1;
    };
    offset += len;
    value
}

pub fn byte_array_value_at_le(
    byte_array: @ByteArray, ref offset: usize, len: usize
) -> felt252 { // TODO: Bounds check
    let byte_shift = 256;
    let mut value = 0;
    let mut i = offset + len - 1;
    while true {
        value = value * byte_shift + byte_array[i].into();
        if i == offset {
            break;
        }
        i -= 1;
    };
    offset += len;
    value
}

pub fn sub_byte_array(byte_array: @ByteArray, ref offset: usize, len: usize) -> ByteArray {
    let mut sub_byte_array = "";
    let mut i = offset;
    let end = offset + len;
    while i != end {
        sub_byte_array.append_byte(byte_array[i]);
        i += 1;
    };
    offset += len;
    sub_byte_array
}

// TODO: More efficient way to do this
pub fn felt252_to_byte_array(value: felt252) -> ByteArray {
    let byte_shift = 256;
    let mut byte_array = "";
    let mut valueU256: u256 = value.into();
    while valueU256 != 0 {
        let (value_upper, value_lower) = DivRem::div_rem(valueU256, byte_shift);
        byte_array.append_byte(value_lower.try_into().unwrap());
        valueU256 = value_upper;
    };
    byte_array.rev()
}

pub fn u256_from_byte_array_with_offset(arr: @ByteArray, offset: usize, len: usize) -> u256 {
    let total_bytes = arr.len();
    // Return 0 if offset out of bound or len greater than 32 bytes
    if offset >= total_bytes || len > 33 {
        return u256 { high: 0, low: 0 };
    }

    let mut high: u128 = 0;
    let mut low: u128 = 0;
    let mut i: usize = 0;
    let mut high_bytes: usize = 0;

    let available_bytes = total_bytes - offset;
    let read_bytes = if available_bytes < len {
        available_bytes
    } else {
        len
    };

    if read_bytes > 16 {
        high_bytes = read_bytes - 16;
    }
    while i != high_bytes {
        high = high * 256 + arr[i + offset].into();
        i += 1;
    };
    while i != read_bytes {
        low = low * 256 + arr[i + offset].into();
        i += 1;
    };
    u256 { high, low }
}

pub fn byte_array_to_bool(bytes: @ByteArray) -> bool {
    let mut i = 0;
    let mut ret_bool = false;
    let byte_array_len = bytes.len();
    while i != byte_array_len {
        if bytes.at(i).unwrap() != 0 {
            // Can be negative zero
            if i == bytes.len() - 1 && bytes.at(i).unwrap() == 0x80 {
                ret_bool = false;
                break;
            }
            ret_bool = true;
            break;
        }
        i += 1;
    };
    ret_bool
}
