use crate::byte_array::byte_array_value_at_le;

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
        let (upper_half_byte, lower_half_byte) = DivRem::div_rem(bytecode[i], half_byte_shift);
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

pub fn var_int_size(buf: @ByteArray, mut offset: u32) -> u32 {
    let discriminant = byte_array_value_at_le(buf, ref offset, 1);
    if discriminant == 0xff {
        return 8;
    } else if discriminant == 0xfe {
        return 4;
    } else if discriminant == 0xfd {
        return 2;
    } else {
        return 1;
    }
}

pub fn read_var_int(buf: @ByteArray, ref offset: u32) -> u64 {
    // TODO: Error handling
    let discriminant: u64 = byte_array_value_at_le(buf, ref offset, 1).try_into().unwrap();
    if discriminant == 0xff {
        return byte_array_value_at_le(buf, ref offset, 8).try_into().unwrap();
    } else if discriminant == 0xfe {
        return byte_array_value_at_le(buf, ref offset, 4).try_into().unwrap();
    } else if discriminant == 0xfd {
        return byte_array_value_at_le(buf, ref offset, 2).try_into().unwrap();
    } else {
        return discriminant;
    }
}

pub fn write_var_int(ref buf: ByteArray, value: u64) {
    if value < 0xfd {
        buf.append_byte(value.try_into().unwrap());
    } else if value < 0x10000 {
        buf.append_byte(0xfd);
        buf.append_word_rev(value.into(), 2);
    } else if value < 0x100000000 {
        buf.append_byte(0xfe);
        buf.append_word_rev(value.into(), 4);
    } else {
        buf.append_byte(0xff);
        buf.append_word_rev(value.into(), 8);
    }
}
