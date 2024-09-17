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
    while i != script_item_len {
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
    while i != bytecode_len {
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

pub fn int_size_in_bytes(u_32: u32) -> u32 {
    let mut value: u32 = u_32;
    let mut size = 0;

    while value != 0 {
        size += 1;
        value /= 256;
    };
    if size == 0 {
        size = 1;
    }
    size
}
