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
    pub const WITNESS_PROGRAM_MISMATCH: felt252 = 'Witness program mismatch';
    pub const WITNESS_UNEXPECTED: felt252 = 'Unexpected witness data';
    pub const WITNESS_MALLEATED: felt252 = 'Witness program with sig script';
    pub const WITNESS_MALLEATED_P2SH: felt252 = 'Signature script for p2sh wit';
    pub const WITNESS_PUBKEYTYPE: felt252 = 'Non-compressed key post-segwit';
    pub const WITNESS_PROGRAM_WRONG_LENGTH: felt252 = 'Witness program wrong length';
    pub const WITNESS_PROGRAM_EMPTY: felt252 = 'Empty witness program';
    pub const SCRIPT_TOO_LARGE: felt252 = 'Script is too large';
    pub const CODESEPARATOR_NON_SEGWIT: felt252 = 'CODESEPARATOR in non-segwit';
    pub const TAPROOT_MULTISIG: felt252 = 'Multisig in taproot script';
    pub const TAPROOT_EMPTY_PUBKEY: felt252 = 'Empty pubkey in taproot script';
    pub const TAPROOT_INVALID_CONTROL_BLOCK: felt252 = 'Invalid control block';
    pub const TAPROOT_INVALID_SIG: felt252 = 'Invalid signature in tap script';
    pub const TAPROOT_PARITY_MISMATCH: felt252 = 'Parity mismatch in tap script';
    pub const TAPROOT_INVALID_MERKLE_PROOF: felt252 = 'Invalid taproot merkle proof';
    pub const DISCOURAGE_OP_SUCCESS: felt252 = 'OP_SUCCESS is discouraged';
    pub const DISCOURAGE_UPGRADABLE_TAPROOT_VERSION: felt252 = 'Upgradable taproot version';
    pub const TAPROOT_SIGOPS_EXCEEDED: felt252 = 'Taproot sigops exceeded';
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
