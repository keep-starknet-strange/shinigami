use crate::opcodes::Opcode;
use crate::parser;
use shinigami_utils::bytecode::hex_to_bytecode;

fn byte_to_smallint(byte: u8) -> Result<i64, felt252> {
    if byte == Opcode::OP_0 {
        return Result::Ok(0);
    }
    if byte >= Opcode::OP_1 && byte <= Opcode::OP_16 {
        return Result::Ok((byte - Opcode::OP_1 + 1).into());
    }
    Result::Err('Invalid small int')
}

pub fn parse_witness_program(witness: @ByteArray) -> Result<(i64, ByteArray), felt252> {
    if witness.len() < 4 || witness.len() > 42 {
        return Result::Err('Invalid witness program length');
    }

    let version: i64 = byte_to_smallint(witness[0])?;
    let data_len = parser::data_len(witness, 1)?;
    let program: ByteArray = parser::data_at(witness, 2, data_len)?;
    if !Opcode::is_canonical_push(witness[1], @program) {
        return Result::Err('Non-canonical witness program');
    }

    return Result::Ok((version, program));
}

pub fn is_witness_program(program: @ByteArray) -> bool {
    return parse_witness_program(program).is_ok();
}

pub fn parse_witness_input(input: ByteArray) -> Array<ByteArray> {
    // Comma seperated list of witness data as hex strings
    let mut witness_data: Array<ByteArray> = array![];
    let mut i = 0;
    let mut temp_witness: ByteArray = "";
    let witness_input_len = input.len();
    while i != witness_input_len {
        let char = input[i].into();
        if char == ',' {
            let witness_bytes = hex_to_bytecode(@temp_witness);
            witness_data.append(witness_bytes);
            temp_witness = "";
        } else {
            temp_witness.append_byte(char);
        }
        i += 1;
    };
    // Handle the last witness data
    let witness_bytes = hex_to_bytecode(@temp_witness);
    witness_data.append(witness_bytes);

    // TODO: Empty witness?

    witness_data
}

pub fn serialized_int_size(val: u64) -> i32 {
    if val < 0xfd {
        return 1;
    }
    if val <= 0xFFFF {
        return 3;
    }
    if val <= 0xFFFFFFFF {
        return 5;
    }
    return 9;
}

pub fn serialized_witness_size(witness: Span<ByteArray>) -> i32 {
    let mut size = serialized_int_size(witness.len().into());
    for w in witness {
        size += serialized_int_size(w.len().into());
        size += w.len().try_into().unwrap();
    };
    size
}
