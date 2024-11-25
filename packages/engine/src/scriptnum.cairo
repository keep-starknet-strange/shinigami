// Wrapper around Bitcoin Script 'sign-magnitude' 4 byte integer.
pub mod ScriptNum {
    use crate::errors::Error;

    const BYTESHIFT: i64 = 256;
    const MAX_INT32: i32 = 2147483647;
    const MIN_INT32: i32 = -2147483647;

    fn check_minimal_data(input: @ByteArray) -> Result<(), felt252> {
        if input.len() == 0 {
            return Result::Ok(());
        }

        let last_element = input.at(input.len() - 1).unwrap();
        if last_element & 0x7F == 0 {
            if input.len() == 1 || input.at(input.len() - 2).unwrap() & 0x80 == 0 {
                return Result::Err(Error::MINIMAL_DATA);
            }
        }

        return Result::Ok(());
    }

    // Wrap i64 with a maximum size of 4 bytes. Can result in 5 byte array.
    pub fn wrap(mut input: i64) -> ByteArray {
        if input == 0 {
            return "";
        }

        // TODO
        // if input > MAX_INT32.into() || input < MIN_INT32.into() {
        //     return Result::Err(Error::SCRIPTNUM_OUT_OF_RANGE);
        // }

        let mut result: ByteArray = Default::default();
        let is_negative = {
            if input < 0 {
                input *= -1;
                true
            } else {
                false
            }
        };
        let unsigned: u64 = input.try_into().unwrap();
        let bytes_len: usize = integer_bytes_len(input.into());
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
    pub fn try_into_num(input: ByteArray, minimal_required: bool) -> Result<i64, felt252> {
        let mut result: i64 = 0;
        let mut i: u32 = 0;
        let mut multiplier: i64 = 1;
        if minimal_required {
            check_minimal_data(@input)?;
        }

        if input.len() == 0 {
            return Result::Ok(0);
        }
        let snap_input = @input;
        let end = snap_input.len() - 1;
        while i != end {
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
        if result > MAX_INT32.into() || result < MIN_INT32.into() {
            return Result::Err(Error::SCRIPTNUM_OUT_OF_RANGE);
        }
        Result::Ok(result)
    }

    pub fn into_num(input: ByteArray) -> i64 {
        try_into_num(input, false).unwrap()
    }

    pub fn unwrap(input: ByteArray) -> i64 {
        try_into_num(input, false).unwrap()
    }

    // Unwrap 'n' byte of sign-magnitude encoded ByteArray.
    pub fn try_into_num_n_bytes(
        input: ByteArray, n: usize, minimal_required: bool
    ) -> Result<i64, felt252> {
        let mut result: i64 = 0;
        let mut i: u32 = 0;
        let mut multiplier: i64 = 1;
        if minimal_required {
            check_minimal_data(@input)?;
        }
        if input.len() == 0 {
            return Result::Ok(0);
        }
        let snap_input = @input;
        let end = snap_input.len() - 1;
        while i != end {
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
        if integer_bytes_len(result.into()) > n {
            return Result::Err(Error::SCRIPTNUM_OUT_OF_RANGE);
        }
        return Result::Ok(result);
    }

    pub fn into_num_n_bytes(input: ByteArray, n: usize) -> i64 {
        try_into_num_n_bytes(input, n, false).unwrap()
    }

    pub fn unwrap_n(input: ByteArray, n: usize) -> i64 {
        try_into_num_n_bytes(input, n, false).unwrap()
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

    // Return i64 as an i32 within range [-2^31, 2^31 - 1].
    pub fn to_int32(mut n: i64) -> i32 {
        if n > MAX_INT32.into() {
            return MAX_INT32;
        }

        if n < MIN_INT32.into() {
            return MIN_INT32;
        }

        return n.try_into().unwrap();
    }
}
