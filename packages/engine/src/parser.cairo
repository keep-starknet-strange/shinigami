use shinigami_utils::byte_array::byte_array_to_felt252_le;
use crate::opcodes::{opcodes::Opcode};
use crate::errors::Error;

// Returns true if the script is a script hash
pub fn is_script_hash(script_pubkey: @ByteArray) -> bool {
    if script_pubkey.len() == 23
        && script_pubkey[0] == Opcode::OP_HASH160
        && script_pubkey[1] == Opcode::OP_DATA_20
        && script_pubkey[22] == Opcode::OP_EQUAL {
        return true;
    }
    return false;
}


// Returns true if the script sig is push only
pub fn is_push_only(script: @ByteArray) -> bool {
    let mut i = 0;
    let mut is_push_only = true;
    let script_len = script.len();
    while i != script_len {
        // TODO: Error handling if i outside bounds
        let opcode = script[i];
        if opcode > Opcode::OP_16 {
            is_push_only = false;
            break;
        }

        // TODO: Error handling
        let data_len = data_len(script, i).unwrap();
        i += data_len + 1;
    };
    return is_push_only;
}

// Returns the data in the script at the given index
pub fn data_at(script: @ByteArray, mut idx: usize, len: usize) -> Result<ByteArray, felt252> {
    let mut data = "";
    let mut end = idx + len;
    if end > script.len() {
        return Result::Err(Error::SCRIPT_INVALID);
    }
    while idx != end {
        data.append_byte(script[idx]);
        idx += 1;
    };
    return Result::Ok(data);
}

// Returns the length of all the data associated with the opcode at the given index
pub fn data_len(script: @ByteArray, idx: usize) -> Result<usize, felt252> {
    let opcode: u8 = script[idx];
    if Opcode::is_data_opcode(opcode) {
        return Result::Ok(opcode.into());
    }
    let mut push_data_len = 0;
    if opcode == Opcode::OP_PUSHDATA1 {
        push_data_len = 1;
    } else if opcode == Opcode::OP_PUSHDATA2 {
        push_data_len = 2;
    } else if opcode == Opcode::OP_PUSHDATA4 {
        push_data_len = 4;
    } else {
        return Result::Ok(0);
    }
    return Result::Ok(
        byte_array_to_felt252_le(@data_at(script, idx + 1, push_data_len)?).try_into().unwrap()
            + push_data_len
    );
}

// Returns the length of the data associated with the push data opcode at the given index
pub fn push_data_len(script: @ByteArray, idx: usize) -> Result<usize, felt252> {
    let mut len = 0;
    let opcode: u8 = script[idx];
    if opcode == Opcode::OP_PUSHDATA1 {
        len = 1;
    } else if opcode == Opcode::OP_PUSHDATA2 {
        len = 2;
    } else if opcode == Opcode::OP_PUSHDATA4 {
        len = 4;
    } else {
        return Result::Err(Error::SCRIPT_INVALID);
    }

    return Result::Ok(
        byte_array_to_felt252_le(@data_at(script, idx + 1, len)?).try_into().unwrap()
    );
}

// Return the next opcode_idx in the script
pub fn next(script: @ByteArray, idx: usize) -> Result<usize, felt252> {
    let data_len = data_len(script, idx)?;
    return Result::Ok(idx + data_len + 1);
}
