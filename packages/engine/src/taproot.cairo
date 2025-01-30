use crate::errors::Error;
use crate::transaction::{
    EngineTransactionTrait, EngineTransactionInputTrait, EngineTransactionOutputTrait,
};
use crate::signature::{schnorr, taproot_signature::{TaprootSigVerifierImpl}};
use crate::engine::Engine;
use core::hash::{HashStateTrait, HashStateExTrait, Hash};

use starknet::secp256k1::{Secp256k1Point};


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

pub fn tap_hash(tap_leaf: TapLeaf) -> u256 {
    // TODO: Implement
    return 0;
}
// pub fn tap_hash(tap_leaf: TapBranch) -> u256 {
//     // TODO: Implement
//     return 0;
// }

pub fn serialized_compressed(pub_key: Secp256k1Point) -> ByteArray {
    // TODO: Implement
    return "";
}


// #[derive(Drop, Default, Debug)]
// pub enum TapscriptLeafVersion {
//     #[default]
//     BASE_LEAF_VERSION,
// }

// #[generate_trait()]
// pub impl TapscriptLeafVersionImpl of TapscriptLeafVersionTrait {
//     fn base_leaf_version() -> u8 {
//         return 0xc0;
//     }
// }

#[derive(Drop)]
pub struct TapLeaf {
    leaf_version: @u8,
    script: @ByteArray,
}

#[generate_trait()]
pub impl TapLeafImpl of TapLeafTrait {
    fn new_base_tap_leaf(script: @ByteArray) -> TapLeaf {
        TapLeaf { leaf_version: @BASE_LEAF_VERSION, script: script }
    }

    fn new_tap_leaf(leaf_version: @u8, script: @ByteArray) -> TapLeaf {
        TapLeaf { leaf_version: leaf_version, script: script }
    }
}

// impl TapLeafHash<S, +HashStateTrait<S>, +Drop<S>> of Hash<TapLeaf, S> {
//     fn update_state(state: S, value: TapLeaf) -> S {// TapLeaf { leaf_version:
//     @BASE_LEAF_VERSION, script: @"" }

//     // let state = state.update(value.value.into());
//     // let state = state.update_with(value.pk_script.into());
//     // state
//     }
// }

#[derive(Drop)]
pub struct ControlBlock {
    internal_pubkey: Secp256k1Point,
    output_key_y_is_odd: bool,
    pub leaf_version: u8,
    control_block: @ByteArray,
}

#[generate_trait()]
pub impl ControlBlockImpl of ControlBlockTrait {
    fn new(control_block: @ByteArray) -> Result<ControlBlock, felt252> {
        parse_control_block(control_block)
    }

    // // RootHash calculates the root hash of a tapscript given the revealed script.
    // func (c *ControlBlock) RootHash(revealedScript []byte) []byte {
    // // We'll start by creating a new tapleaf from the revealed script,
    // // this'll serve as the initial hash we'll use to incrementally
    // // reconstruct the merkle root using the control block elements.
    // merkleAccumulator := NewTapLeaf(c.LeafVersion, revealedScript).TapHash()

    // // Now that we have our initial hash, we'll parse the control block one
    // // node at a time to build up our merkle accumulator into the taproot
    // // commitment.
    // //
    // // The control block is a series of nodes that serve as an inclusion
    // // proof as we can start hashing with our leaf, with each internal
    // // branch, until we reach the root.
    // numNodes := len(c.InclusionProof) / ControlBlockNodeSize
    // for nodeOffset := 0; nodeOffset < numNodes; nodeOffset++ {
    // // Extract the new node using our index to serve as a 32-byte
    // // offset.
    // leafOffset := 32 * nodeOffset
    // nextNode := c.InclusionProof[leafOffset : leafOffset+32]

    // merkleAccumulator = tapBranchHash(merkleAccumulator[:], nextNode)
    // }

    // return merkleAccumulator[:]
    // }

    fn root_hash(self: @ControlBlock, script: @ByteArray) -> ByteArray {
        let merkleAccumulator = TapLeafTrait::new_tap_leaf(self.leaf_version, script);
        let script_leaf_hash = tap_hash(merkleAccumulator);
        return "";
    }

    fn verify_taproot_leaf(
        self: @ControlBlock, witness_program: @ByteArray, script: @ByteArray,
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

#[derive(Destruct)]
pub struct TaprootContext {
    pub annex: @ByteArray,
    pub code_sep: u32,
    pub tapleaf_hash: u256,
    sig_ops_budget: i32,
    pub must_succeed: bool,
}

#[generate_trait()]
pub impl TaprootContextImpl of TaprootContextTrait {
    fn new(witness_size: i32) -> TaprootContext {
        TaprootContext {
            annex: @"",
            code_sep: BASE_CODE_SEP,
            tapleaf_hash: 0,
            sig_ops_budget: SIG_OPS_DELTA + witness_size,
            must_succeed: false,
        }
    }

    fn empty() -> TaprootContext {
        TaprootContext {
            annex: @"",
            code_sep: BASE_CODE_SEP,
            tapleaf_hash: 0,
            sig_ops_budget: SIG_OPS_DELTA,
            must_succeed: false,
        }
    }

    fn verify_taproot_spend<
        T,
        I,
        O,
        impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
        impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
        impl IEngineTransactionTrait: EngineTransactionTrait<
            T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait,
        >,
        +Drop<T>,
        +Drop<I>,
        +Drop<O>,
        +Default<T>,
    >(
        ref engine: Engine<T>,
        witness_program: @ByteArray,
        raw_sig: @ByteArray,
        tx: @T,
        tx_idx: u32,
    ) -> Result<(), felt252> {
        let witness: Span<ByteArray> = tx.get_transaction_inputs()[tx_idx].get_witness();
        let mut annex = @"";
        if is_annexed_witness(witness, witness.len()) {
            annex = witness[witness.len() - 1];
        }

        let verifier = TaprootSigVerifierImpl::<
            T,
        >::new(raw_sig, witness_program, annex, ref engine)?;

        let is_valid = verifier.verify(ref engine);
        if is_valid.is_err() {
            return Result::Err(Error::TAPROOT_INVALID_SIG);
        }
        // if verify.sigvalid Ok() else error invalid sig
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
    if control_block_len < CONTROL_BLOCK_BASE_SIZE {
        return Result::Err(Error::TAPROOT_INVALID_CONTROL_BLOCK_TOO_SMALL);
    }
    if control_block_len > CONTROL_BLOCK_MAX_SIZE {
        return Result::Err(Error::TAPROOT_INVALID_CONTROL_BLOCK_MAX_SIZE);
    }

    if (control_block_len - CONTROL_BLOCK_BASE_SIZE) % CONTROL_BLOCK_NODE_SIZE != 0 {
        return Result::Err(Error::TAPROOT_INVALID_CONTROL_BLOCK_SIZE);
    }

    let leaf_version = control_block[0] & TAPROOT_LEAF_MASK;
    let output_key_y_is_odd = (control_block[0] & 0x01) == 0x01;

    let mut raw_pubkey = "";
    for i in 1..CONTROL_BLOCK_BASE_SIZE {
        raw_pubkey.append_byte(control_block[i]);
    };

    let pubkey = schnorr::parse_schnorr_pub_key(@raw_pubkey)?;
    return Result::Ok(
        ControlBlock {
            internal_pubkey: pubkey,
            output_key_y_is_odd: output_key_y_is_odd,
            leaf_version: leaf_version,
            control_block: control_block,
        },
    );
}

pub fn is_annexed_witness(witness: Span<ByteArray>, witness_len: usize) -> bool {
    if witness_len < 2 {
        return false;
    }

    let last_elem = witness[witness_len - 1];
    return last_elem.len() > 0 && last_elem[0] == TAPROOT_ANNEX_TAG;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_perso_1() {
        let test: TapLeaf = TapLeafTrait::new_base_tap_leaf(@"0xabc");
        assert_eq!(test.script, @"0xabc");
        // println!("version : {:x}", TapscriptLeafVersionTrait::base_leaf_version());
        println!("version : {}", test.leaf_version);
        // println!("version : {:x}", test.leaf_version);
    }
}
