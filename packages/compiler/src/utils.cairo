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
