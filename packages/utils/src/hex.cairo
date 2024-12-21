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
