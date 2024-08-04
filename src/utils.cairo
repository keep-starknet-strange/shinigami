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

// TODO: little-endian?
// TODO: if odd number of bytes, prepend 0?
// TODO: Utils functions?
// TODO: Lowercase and letters?
pub fn hex_to_bytecode(script_item: @ByteArray) -> ByteArray {
    let half_byte_shift = 16;
    let zero_string = '0';
    let a_string = 'a';
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
