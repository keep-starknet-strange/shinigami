use crate::digest::Digest;

pub fn int_to_hex(value: u8) -> felt252 {
    let half_byte_shift = 16;
    let byte_shift = 256;

    let (upper_half_value, lower_half_value) = DivRem::div_rem(value, half_byte_shift);
    let upper_half: u8 = if upper_half_value < 10 {
        upper_half_value + '0'
    } else {
        upper_half_value - 10 + 'a'
    };
    let lower_half: u8 = if lower_half_value < 10 {
        lower_half_value + '0'
    } else {
        lower_half_value - 10 + 'a'
    };

    upper_half.into() * byte_shift.into() + lower_half.into()
}

/// Converts bytes to hex (base16).
pub fn to_hex(data: @ByteArray) -> ByteArray {
    let alphabet: @ByteArray = @"0123456789abcdef";
    let mut result: ByteArray = Default::default();

    let mut i = 0;
    while i != data.len() {
        let value: u32 = data[i].into();
        let (l, r) = core::traits::DivRem::div_rem(value, 16);
        result.append_byte(alphabet.at(l).unwrap());
        result.append_byte(alphabet.at(r).unwrap());
        i += 1;
    };

    result
}

// Gets `Digest` from reversed `ByteArray`.
pub fn hex_to_hash_rev(hex_string: ByteArray) -> Digest {
    let mut result: Array<u32> = array![];
    let mut i = 0;
    let mut unit: u32 = 0;
    let len = hex_string.len();
    while i != len {
        if (i != 0 && i % 8 == 0) {
            result.append(unit);
            unit = 0;
        }
        let hi = hex_char_to_nibble(hex_string[len - i - 2]);
        let lo = hex_char_to_nibble(hex_string[len - i - 1]);
        unit = (unit * 256) + (hi * 16 + lo).into();
        i += 2;
    };
    result.append(unit);

    Digest {
        value: [
            *result[0], *result[1], *result[2], *result[3], *result[4], *result[5], *result[6],
            *result[7],
        ],
    }
}


pub fn hex_char_to_nibble(hex_char: u8) -> u8 {
    if hex_char >= 48 && hex_char <= 57 {
        // 0-9
        hex_char - 48
    } else if hex_char >= 65 && hex_char <= 70 {
        // A-F
        hex_char - 55
    } else if hex_char >= 97 && hex_char <= 102 {
        // a-f
        hex_char - 87
    } else {
        panic!("Invalid hex character: {hex_char}");
        0
    }
}
