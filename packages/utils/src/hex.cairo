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
