use core::traits::TryInto;
use core::byte_array::ByteArrayTrait;
use core::traits::BitAnd;

const TWO_POW_EIGHT: u256 = 0x100;
const SIGN_BIT: u8 = 0x80;


// `int_to_bytes` returns the number serialized as a little endian with a sign bit
pub fn int_to_bytes(mut value: i64) -> ByteArray {
    let mut bytes: ByteArray = "";
    if value == 0 {
        return bytes;
    }

    let is_negative: bool = value < 0;
    if is_negative {
        value = -value;
    }

    let value_felt: felt252 = value.into();
    let mut value_u256: u256 = value_felt.into();
    let mask: u256 = 0xff;

    while value_u256 > 0 {
        let item: u256 = value_u256 & mask;
        let byte: u8 = item.try_into().unwrap();
        bytes.append_byte(byte);

        value_u256 = value_u256 / TWO_POW_EIGHT;
    };

    if bytes.at((bytes.len() - 1)).unwrap() & SIGN_BIT != 0 {
        let mut extra_byte: u8 = 0;
        if is_negative {
            extra_byte = 0x80;
        }
        bytes.append_byte(SIGN_BIT);

        return bytes;
    } else if is_negative {
        let mut last_byte: u8 = bytes.at((bytes.len() - 1)).unwrap();
        last_byte = last_byte | SIGN_BIT;

        let mut new_bytes: ByteArray = "";
        let mut i = 0;
        while i < bytes.len() - 1 {
            new_bytes.append_byte(bytes.at(i).unwrap());
        };

        new_bytes.append_byte(last_byte);

        return new_bytes;
    }

    return bytes;
}
