use core::sha256::{compute_sha256_byte_array};
use crate::opcodes::Opcode;
use crate::scriptnum::ScriptNum;

// Checks if item starts with 0x
// TODO: Check validity of hex?
pub fn is_hex(script_item: @ByteArray) -> bool {
    if script_item.len() < 2 {
        return false;
    }
    let byte_shift = 256;
    let first_two = script_item[0].into() * byte_shift + script_item[1].into();
    first_two == '0x'
}

// Checks if item surrounded with a single or double quote
pub fn is_string(script_item: @ByteArray) -> bool {
    if script_item.len() < 2 {
        return false;
    }
    let single_quote = '\'';
    let double_quote = '"';
    let first = script_item[0];
    let last = script_item[script_item.len() - 1];
    (first == single_quote && last == single_quote)
        || (first == double_quote && last == double_quote)
}

// Check if item is a number (starts with 0-9 or -)
pub fn is_number(script_item: @ByteArray) -> bool {
    if script_item.len() == 0 {
        return false;
    }
    let zero = '0';
    let nine = '9';
    let minus = '-';
    let first = script_item[0];
    if first == minus {
        return script_item.len() > 1;
    }
    if script_item.len() > 1 {
        let second = script_item[1];
        // Some opcodes start with a number; like 2ROT
        return first >= zero && first <= nine && second >= zero && second <= nine;
    }
    first >= zero && first <= nine
}

// TODO: little-endian?
// TODO: if odd number of bytes, prepend 0?
pub fn hex_to_bytecode(script_item: @ByteArray) -> ByteArray {
    let half_byte_shift = 16;
    let zero_string = '0';
    let a_string_lower = 'a';
    let a_string_capital = 'A';
    let mut i = 2;
    let mut bytecode = "";
    let script_item_len = script_item.len();
    while i < script_item_len {
        let mut upper_half_byte = 0;
        let mut lower_half_byte = 0;
        if script_item[i] >= a_string_lower {
            upper_half_byte = (script_item[i].into() - a_string_lower + 10) * half_byte_shift;
        } else if script_item[i] >= a_string_capital {
            upper_half_byte = (script_item[i].into() - a_string_capital + 10) * half_byte_shift;
        } else {
            upper_half_byte = (script_item[i].into() - zero_string) * half_byte_shift;
        }
        if script_item[i + 1] >= a_string_lower {
            lower_half_byte = script_item[i + 1].into() - a_string_lower + 10;
        } else if script_item[i + 1] >= a_string_capital {
            lower_half_byte = script_item[i + 1].into() - a_string_capital + 10;
        } else {
            lower_half_byte = script_item[i + 1].into() - zero_string;
        }
        let byte = upper_half_byte + lower_half_byte;
        bytecode.append_byte(byte);
        i += 2;
    };
    bytecode
}

pub fn bytecode_to_hex(bytecode: @ByteArray) -> ByteArray {
    let half_byte_shift = 16;
    let zero = '0';
    let a = 'a';
    let mut hex = "0x";
    let mut i = 0;
    let bytecode_len = bytecode.len();
    if bytecode_len == 0 {
        return "0x00";
    }
    while i < bytecode_len {
        let upper_half_byte = bytecode[i] / half_byte_shift;
        let lower_half_byte = bytecode[i] % half_byte_shift;
        let upper_half: u8 = if upper_half_byte < 10 {
            upper_half_byte + zero
        } else {
            upper_half_byte - 10 + a
        };
        let lower_half: u8 = if lower_half_byte < 10 {
            lower_half_byte + zero
        } else {
            lower_half_byte - 10 + a
        };
        hex.append_byte(upper_half);
        hex.append_byte(lower_half);
        i += 1;
    };
    hex
}

// Remove the surrounding quotes and add the corrent append opcodes to the front
// https://github.com/btcsuite/btcd/blob/b161cd6a199b4e35acec66afc5aad221f05fe1e3/txscript/scriptbuilder.go#L159
pub fn string_to_bytecode(script_item: @ByteArray) -> ByteArray {
    let mut bytecode = "";
    let mut i = 1;
    let word_len = script_item.len() - 2;
    let end = script_item.len() - 1;
    if word_len == 0 || (word_len == 1 && script_item[1] == 0) {
        bytecode.append_byte(Opcode::OP_0);
        return bytecode;
    } else if word_len == 1 && script_item[1] <= 16 {
        bytecode.append_byte(Opcode::OP_1 - 1 + script_item[1]);
        return bytecode;
    } else if word_len == 1 && script_item[1] == 0x81 {
        bytecode.append_byte(Opcode::OP_1NEGATE);
        return bytecode;
    }

    if word_len < Opcode::OP_PUSHDATA1.into() {
        bytecode.append_byte(Opcode::OP_DATA_1 - 1 + word_len.try_into().unwrap());
    } else if word_len < 0x100 {
        bytecode.append_byte(Opcode::OP_PUSHDATA1);
        bytecode.append_byte(word_len.try_into().unwrap());
    } else if word_len < 0x10000 {
        bytecode.append_byte(Opcode::OP_PUSHDATA2);
        // TODO: Little-endian?
        bytecode.append(@ScriptNum::wrap(word_len.into()));
    } else {
        bytecode.append_byte(Opcode::OP_PUSHDATA4);
        bytecode.append(@ScriptNum::wrap(word_len.into()));
    }
    while i < end {
        bytecode.append_byte(script_item[i]);
        i += 1;
    };
    bytecode
}

// Convert a number to bytecode
pub fn number_to_bytecode(script_item: @ByteArray) -> ByteArray {
    let mut bytecode = "";
    let mut i = 0;
    let script_item_len = script_item.len();
    let zero = '0';
    let negative = '-';
    let mut is_negative = false;
    if script_item[0] == negative {
        is_negative = true;
        i += 1;
    }
    let mut value: i64 = 0;
    while i < script_item_len {
        value = value * 10 + script_item[i].into() - zero;
        i += 1;
    };
    if is_negative {
        value = -value;
    }
    if value == -1 {
        bytecode.append_byte(Opcode::OP_1NEGATE);
    } else if value > 0 && value <= 16 {
        bytecode.append_byte(Opcode::OP_1 - 1 + value.try_into().unwrap());
    } else if value == 0 {
        bytecode.append_byte(Opcode::OP_0);
    } else {
        // TODO: always script num?
        let script_num = ScriptNum::wrap(value);
        let script_num_len = script_num.len();
        if script_num_len < Opcode::OP_PUSHDATA1.into() {
            bytecode.append_byte(Opcode::OP_DATA_1 - 1 + script_num_len.try_into().unwrap());
        } else if script_num_len < 0x100 {
            bytecode.append_byte(Opcode::OP_PUSHDATA1);
            bytecode.append_byte(script_num_len.try_into().unwrap());
        }
        bytecode.append(@script_num);
    }
    bytecode
}

// TODO: Endian
pub fn byte_array_to_felt252(byte_array: @ByteArray) -> felt252 {
    let byte_shift = 256;
    let mut value = 0;
    let mut i = 0;
    let byte_array_len = byte_array.len();
    while i < byte_array_len {
        value = value * byte_shift + byte_array[i].into();
        i += 1;
    };
    value
}

pub fn byte_array_to_felt252_endian(byte_array: @ByteArray) -> felt252 {
    let mut byte_shift = 1;
    let mut value = 0;
    let mut i = 0;
    let byte_array_len = byte_array.len();
    while i < byte_array_len {
        value += byte_shift * byte_array[i].into();
        byte_shift *= 256;
        i += 1;
    };
    value
}

// TODO: More efficient way to do this
pub fn felt252_to_byte_array(value: felt252) -> ByteArray {
    let byte_shift = 256;
    let mut byte_array = "";
    let mut valueU256: u256 = value.into();
    while valueU256 > 0 {
        byte_array.append_byte((valueU256 % byte_shift).try_into().unwrap());
        valueU256 /= byte_shift;
    };
    byte_array.rev()
}

pub fn int_to_hex(value: u8) -> felt252 {
    let half_byte_shift = 16;
    let byte_shift = 256;
    let upper_half_value = value / half_byte_shift;
    let lower_half_value = value % half_byte_shift;

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

pub fn byte_array_to_bool(bytes: @ByteArray) -> bool {
    let mut i = 0;
    let mut ret_bool = false;
    while i < bytes.len() {
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

pub fn u256_from_byte_array_with_offset(arr: @ByteArray, offset: usize, len: usize) -> u256 {
    let total_bytes = arr.len();
    // Return 0 if offset out of bound or len greater than 32 bytes
    if offset >= total_bytes || len > 32 {
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
    while i < high_bytes {
        high = high * 256 + arr[i + offset].into();
        i += 1;
    };
    while i < read_bytes {
        low = low * 256 + arr[i + offset].into();
        i += 1;
    };
    u256 { high, low }
}

pub fn int_size_in_bytes(u_32: u32) -> u32 {
    let mut value: u32 = u_32;
    let mut size = 0;

    while value > 0 {
        size += 1;
        value /= 256;
    };
    if size == 0 {
        size = 1;
    }
    size
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
