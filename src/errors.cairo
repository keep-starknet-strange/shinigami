pub mod Error {
    pub const SCRIPT_FAILED: felt252 = 'Script failed after execute';
    pub const SCRIPT_EMPTY_STACK: felt252 = 'Stack empty after execute';
    pub const STACK_UNDERFLOW: felt252 = 'Stack underflow';
    pub const STACK_OUT_OF_RANGE: felt252 = 'Stack out of range';
    pub const VERIFY_FAILED: felt252 = 'Verify failed';
    pub const OPCODE_RESERVED: felt252 = 'Opcode reserved';
    pub const OPCODE_NOT_IMPLEMENTED: felt252 = 'Opcode not implemented';
    pub const OPCODE_DISABLED: felt252 = 'Opcode is disabled';
}
