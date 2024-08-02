// Wrapper around Bitcoin Script 'sign-magnitude' 4 byte integer.
pub mod ScriptNum {
    const BYTESHIFT: i64 = 256;
    const MAX_BYTE_LEN: usize = 4;

    // Wrap i64 with a maximum size of 4 bytes. Can result in 5 byte array.
    pub fn wrap(mut input: i64) -> ByteArray {
        if input == 0 {
            return "";
        }

        let mut result: ByteArray = Default::default();
        let is_negative = {
            if input < 0 {
                input *= -1;
                true
            } else {
                false
            }
        };
        // Unwrap cannot fail because input is set to positive above.
        let unsigned: u64 = input.try_into().unwrap();
        let bytes_len: usize = integer_bytes_len(unsigned.into());
        if bytes_len > MAX_BYTE_LEN {
            panic!("scriptnum(wrap): number more than {} bytes long", MAX_BYTE_LEN);
        }
        result.append_word_rev(unsigned.into(), bytes_len - 1);
        // Compute 'sign-magnitude' byte.
        let sign_byte: u8 = get_last_byte_of_uint(unsigned);
        if is_negative {
            if (sign_byte > 127) {
                result.append_byte(sign_byte);
                result.append_byte(128);
            } else {
                result.append_byte(sign_byte + 128);
            }
        } else {
            if (sign_byte > 127) {
                result.append_byte(sign_byte);
                result.append_byte(0);
            } else {
                result.append_byte(sign_byte);
            }
        }
        result
    }

    // Unwrap sign-magnitude encoded ByteArray into a 4 byte int maximum.
    pub fn unwrap(input: ByteArray) -> i64 {
        let mut result: i64 = 0;
        let mut i: u32 = 0;
        let mut multiplier: i64 = 1;
        if input.len() == 0 {
            return 0;
        }
        let snap_input = @input;
        while i < snap_input.len() - 1 {
            result += snap_input.at(i).unwrap().into() * multiplier;
            multiplier *= BYTESHIFT;
            i += 1;
        };
        // Recover value and sign from 'sign-magnitude' byte.
        let sign_byte: i64 = input.at(i).unwrap().into();
        if sign_byte >= 128 {
            result = (multiplier * (sign_byte - 128) * -1) - result;
        } else {
            result += sign_byte * multiplier;
        }
        if integer_bytes_len(result.into()) > MAX_BYTE_LEN {
            panic!("scriptnum(unwrap): number more than {} bytes long", MAX_BYTE_LEN);
        }
        result
    }

    // Return the minimal number of byte to represent 'value'.
    fn integer_bytes_len(mut value: i128) -> usize {
        if value < 0 {
            value *= -1;
        }
        let mut power_byte = BYTESHIFT.try_into().unwrap();
        let mut bytes_len: usize = 1;
        while value >= power_byte {
            bytes_len += 1;
            power_byte *= 256;
        };
        bytes_len
    }

    // Return the value of the last byte of 'value'.
    fn get_last_byte_of_uint(mut value: u64) -> u8 {
        let byteshift = BYTESHIFT.try_into().unwrap();
        while value > byteshift {
            value = value / byteshift;
        };
        value.try_into().unwrap()
    }
}
