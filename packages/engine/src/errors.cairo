pub mod Error {
    pub const SCRIPT_FAILED: felt252 = 'Script failed after execute';
    pub const SCRIPT_EMPTY_STACK: felt252 = 'Stack empty after execute';
    pub const SCRIPT_UNBALANCED_CONDITIONAL_STACK: felt252 = 'Unbalanced conditional';
    pub const SCRIPT_TOO_MANY_OPERATIONS: felt252 = 'Too many operations';
    pub const SCRIPT_PUSH_SIZE: felt252 = 'Push value size limit exceeded';
    pub const SCRIPT_NON_CLEAN_STACK: felt252 = 'Non-clean stack after execute';
    pub const SCRIPTNUM_OUT_OF_RANGE: felt252 = 'Scriptnum out of range';
    pub const STACK_OVERFLOW: felt252 = 'Stack overflow';
    pub const STACK_UNDERFLOW: felt252 = 'Stack underflow';
    pub const STACK_OUT_OF_RANGE: felt252 = 'Stack out of range';
    pub const VERIFY_FAILED: felt252 = 'Verify failed';
    pub const OPCODE_RESERVED: felt252 = 'Opcode reserved';
    pub const OPCODE_NOT_IMPLEMENTED: felt252 = 'Opcode not implemented';
    pub const OPCODE_DISABLED: felt252 = 'Opcode is disabled';
    pub const SCRIPT_DISCOURAGE_UPGRADABLE_NOPS: felt252 = 'Upgradable NOPs are discouraged';
    pub const UNSATISFIED_LOCKTIME: felt252 = 'Unsatisfied locktime';
    pub const SCRIPT_STRICT_MULTISIG: felt252 = 'OP_CHECKMULTISIG invalid dummy';
    pub const FINALIZED_TX_CLTV: felt252 = 'Finalized tx in OP_CLTV';
    pub const INVALID_TX_VERSION: felt252 = 'Invalid transaction version';
    pub const SCRIPT_INVALID: felt252 = 'Invalid script data';
    pub const INVALID_COINBASE: felt252 = 'Invalid coinbase transaction';
    pub const SIG_NULLFAIL: felt252 = 'Sig non-zero on failed checksig';
    pub const MINIMAL_DATA: felt252 = 'Opcode represents non-minimal';
    pub const MINIMAL_IF: felt252 = 'If conditional must be 0 or 1';
    pub const DISCOURAGE_UPGRADABLE_WITNESS_PROGRAM: felt252 = 'Upgradable witness program';
    pub const WITNESS_PROGRAM_INVALID: felt252 = 'Invalid witness program';
    pub const SCRIPT_TOO_LARGE: felt252 = 'Script is too large';
    pub const SCRIPT_UNFINISHED: felt252 = 'Script unfinished';
    pub const SCRIPT_ERR_SIG_DER: felt252 = 'Signature DER error';
}

pub fn byte_array_err(err: felt252) -> ByteArray {
    let mut bytes = "";
    let mut word_len = 0;
    let mut byte_shift: u256 = 256;
    while (err.into() / byte_shift) != 0 {
        word_len += 1;
        byte_shift *= 256;
    };
    bytes.append_word(err, word_len);
    bytes
}
