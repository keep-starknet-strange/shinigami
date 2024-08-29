pub mod Error {
    pub const SCRIPT_FAILED: felt252 = 'Script failed after execute';
    pub const SCRIPT_EMPTY_STACK: felt252 = 'Stack empty after execute';
    pub const SCRIPT_UNBALANCED_CONDITIONAL_STACK: felt252 = 'Unbalanced conditional';
    pub const SCRIPTNUM_OUT_OF_RANGE: felt252 = 'Scriptnum out of range';
    pub const STACK_UNDERFLOW: felt252 = 'Stack underflow';
    pub const STACK_OUT_OF_RANGE: felt252 = 'Stack out of range';
    pub const VERIFY_FAILED: felt252 = 'Verify failed';
    pub const OPCODE_RESERVED: felt252 = 'Opcode reserved';
    pub const OPCODE_NOT_IMPLEMENTED: felt252 = 'Opcode not implemented';
    pub const OPCODE_DISABLED: felt252 = 'Opcode is disabled';
    pub const SCRIPT_DISCOURAGE_UPGRADABLE_NOPS: felt252 = 'Upgradable NOPs are discouraged';
    pub const UNSATISFIED_LOCKTIME: felt252 = 'Unsatisfied locktime';
    pub const FINALIZED_TX_CLTV: felt252 = 'Finalized tx in OP_CLTV';
    pub const INVALID_TX_VERSION: felt252 = 'Invalid transaction version';
    pub const SCRIPT_INVALID: felt252 = 'Invalid script data';
    pub const SCRIPT_STACK_SIZE_EXCEEDED: felt252 = 'Script stack size exceeded';
}

pub fn byte_array_err(err: felt252) -> ByteArray {
    let mut bytes = "";
    let mut word_len = 0;
    let mut byte_shift: u256 = 256;
    while (err.into() / byte_shift) > 0 {
        word_len += 1;
        byte_shift *= 256;
    };
    bytes.append_word(err, word_len);
    bytes
}
