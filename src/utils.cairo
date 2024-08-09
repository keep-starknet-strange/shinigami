use shinigami::opcodes::Opcode;
use shinigami::scriptnum::ScriptNum;

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
    first >= zero && first <= nine
}

// TODO: little-endian?
// TODO: if odd number of bytes, prepend 0?
// TODO: Utils functions?
// TODO: Lowercase and letters?
pub fn hex_to_bytecode(script_item: @ByteArray) -> ByteArray {
    let half_byte_shift = 16;
    let zero_string = '0';
    let a_string = 'A';
    let mut i = 2;
    let mut bytecode = "";
    let script_item_len = script_item.len();
    while i < script_item_len {
        let mut upper_half_byte = 0;
        let mut lower_half_byte = 0;
        if script_item[i] >= a_string {
            upper_half_byte = (script_item[i].into() - a_string + 10) * half_byte_shift;
        } else {
            upper_half_byte = (script_item[i].into() - zero_string) * half_byte_shift;
        }
        if script_item[i + 1] >= a_string {
            lower_half_byte = script_item[i + 1].into() - a_string + 10;
        } else {
            lower_half_byte = script_item[i + 1].into() - zero_string;
        }
        let byte = upper_half_byte + lower_half_byte;
        bytecode.append_byte(byte);
        i += 2;
    };
    bytecode
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
    while i < bytes
        .len() {
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
