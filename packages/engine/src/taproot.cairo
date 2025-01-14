use crate::errors::Error;
use crate::transaction::{
    EngineTransactionTrait, EngineTransactionInputTrait, EngineTransactionOutputTrait
};
use crate::engine::Engine;
use crate::signature::schnorr;
use crate::signature::signature::{TaprootSigVerifierImpl};
use starknet::secp256k1::{Secp256k1Point};

#[derive(Destruct)]
pub struct TaprootContext {
    pub annex: @ByteArray,
    pub code_sep: u32,
    pub tapleaf_hash: u256,
    sig_ops_budget: i32,
    pub must_succeed: bool
}

#[derive(Drop)]
pub struct ControlBlock {
    internal_pubkey: Secp256k1Point,
    output_key_y_is_odd: bool,
    pub leaf_version: u8,
    control_block: @ByteArray
}

pub fn serialize_pub_key(pub_key: Secp256k1Point) -> @ByteArray {
    // TODO: Check this is valid
    let mut output_arr = array![];
    pub_key.serialize(ref output_arr);
    let mut result = "";
    let mut i = 0;
    let output_arr_len = output_arr.len();
    while i != output_arr_len {
        result.append_word(*output_arr[i], 31);
        i += 1;
    };
    return @result;
}

pub fn serialize_schnorr_pub_key(pub_key: Secp256k1Point) -> @ByteArray {
    let pub_key_bytes: @ByteArray = serialize_pub_key(pub_key);
    let mut result = "";
    let mut i = 1;
    let pub_key_bytes_len = pub_key_bytes.len();
    while i != pub_key_bytes_len {
        result.append_byte(pub_key_bytes[i]);
        i += 1;
    };
    return @result;
}

pub fn compute_taproot_output_key(pubkey: @Secp256k1Point, script: @ByteArray) -> Secp256k1Point {
    // TODO: Implement
    return pubkey.clone();
}

pub fn tap_hash(sript: @ByteArray, version: u8) -> u256 {
    // TODO: Implement
    return 0;
}

pub fn serialized_compressed(pub_key: Secp256k1Point) -> ByteArray {
    // TODO: Implement
    return "";
}

#[generate_trait()]
pub impl ControlBlockImpl of ControlBlockTrait {
    // TODO: From parse
    fn new(
        internal_pubkey: Secp256k1Point,
        output_key_y_is_odd: bool,
        leaf_version: u8,
        control_block: @ByteArray
    ) -> ControlBlock {
        ControlBlock {
            internal_pubkey: internal_pubkey,
            output_key_y_is_odd: output_key_y_is_odd,
            leaf_version: leaf_version,
            control_block: control_block
        }
    }

    fn root_hash(self: @ControlBlock, script: @ByteArray) -> ByteArray {
        // TODO: Implement
        return "";
    }

    fn verify_taproot_leaf(
        self: @ControlBlock, witness_program: @ByteArray, script: @ByteArray
    ) -> Result<(), felt252> {
        let root_hash = self.root_hash(script);
        let taproot_key = compute_taproot_output_key(self.internal_pubkey, @root_hash);
        let expected_witness_program = serialize_pub_key(taproot_key);
        if witness_program != expected_witness_program {
            return Result::Err(Error::TAPROOT_INVALID_MERKLE_PROOF);
        }

        let y_is_odd = serialized_compressed(taproot_key)[0] == 0x03;
        if self.output_key_y_is_odd != @y_is_odd {
            return Result::Err(Error::TAPROOT_PARITY_MISMATCH);
        }

        return Result::Ok(());
    }
}

const CONTROL_BLOCK_BASE_SIZE: u32 = 33;
const CONTROL_BLOCK_NODE_SIZE: u32 = 32;
const CONTROL_BLOCK_MAX_NODE_COUNT: u32 = 128;
const CONTROL_BLOCK_MAX_SIZE: u32 = CONTROL_BLOCK_BASE_SIZE
    + (CONTROL_BLOCK_MAX_NODE_COUNT * CONTROL_BLOCK_NODE_SIZE);

const SIG_OPS_DELTA: i32 = 50;
const BASE_CODE_SEP: u32 = 0xFFFFFFFF;
const TAPROOT_ANNEX_TAG: u8 = 0x50;
const TAPROOT_LEAF_MASK: u8 = 0xFE;
pub const BASE_LEAF_VERSION: u8 = 0xc0;

#[generate_trait()]
pub impl TaprootContextImpl of TaprootContextTrait {
    fn new(witness_size: i32) -> TaprootContext {
        TaprootContext {
            annex: @"",
            code_sep: BASE_CODE_SEP,
            tapleaf_hash: 0,
            sig_ops_budget: SIG_OPS_DELTA + witness_size,
            must_succeed: false
        }
    }

    fn empty() -> TaprootContext {
        TaprootContext {
            annex: @"",
            code_sep: BASE_CODE_SEP,
            tapleaf_hash: 0,
            sig_ops_budget: SIG_OPS_DELTA,
            must_succeed: false
        }
    }

    fn verify_taproot_spend<
        T,
        I,
        O,
        impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
        impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
        impl IEngineTransactionTrait: EngineTransactionTrait<
            T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait
        >,
        +Drop<T>,
        +Drop<I>,
        +Drop<O>,
    >(
        ref vm: Engine<T>, witness_program: @ByteArray, raw_sig: @ByteArray, tx: @T, tx_idx: u32
    ) -> Result<(), felt252> {
        let witness: Span<ByteArray> = tx.get_transaction_inputs()[tx_idx].get_witness();
        let mut annex = @"";
        if is_annexed_witness(witness, witness.len()) {
            annex = witness[witness.len() - 1];
        }

        let mut verifier = TaprootSigVerifierImpl::<I, O, T>::new(ref vm, raw_sig, witness_program, annex)?;
        let is_valid = TaprootSigVerifierImpl::<I, O, T>::verify(ref verifier);
        if !is_valid {
            return Result::Err(Error::TAPROOT_INVALID_SIG);
        }
        Result::Ok(())
    }

    fn use_ops_budget(ref self: TaprootContext) -> Result<(), felt252> {
        self.sig_ops_budget -= SIG_OPS_DELTA;

        if self.sig_ops_budget < 0 {
            return Result::Err(Error::TAPROOT_SIGOPS_EXCEEDED);
        }
        return Result::Ok(());
    }
}

pub fn parse_control_block(control_block: @ByteArray) -> Result<ControlBlock, felt252> {
    let control_block_len = control_block.len();
    if control_block_len < CONTROL_BLOCK_BASE_SIZE || control_block_len > CONTROL_BLOCK_MAX_SIZE {
        return Result::Err(Error::TAPROOT_INVALID_CONTROL_BLOCK);
    }
    if (control_block_len - CONTROL_BLOCK_BASE_SIZE) % CONTROL_BLOCK_NODE_SIZE != 0 {
        return Result::Err(Error::TAPROOT_INVALID_CONTROL_BLOCK);
    }

    let leaf_version = control_block[0] & TAPROOT_LEAF_MASK;
    let output_key_y_is_odd = (control_block[0] & 0x01) == 0x01;

    let mut raw_pubkey = "";
    let pubkey_end = 33;
    let mut i = 1;
    while i != pubkey_end {
        raw_pubkey.append_byte(control_block[i]);
        i += 1;
    };
    let pubkey = schnorr::parse_schnorr_pub_key(@raw_pubkey)?;
    return Result::Ok(
        ControlBlock {
            internal_pubkey: pubkey,
            output_key_y_is_odd: output_key_y_is_odd,
            leaf_version: leaf_version,
            control_block: control_block
        }
    );
}

pub fn is_annexed_witness(witness: Span<ByteArray>, witness_len: usize) -> bool {
    if witness_len < 2 {
        return false;
    }

    let last_elem = witness[witness_len - 1];
    return last_elem.len() > 0 && last_elem[0] == TAPROOT_ANNEX_TAG;
}
