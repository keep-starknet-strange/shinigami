use crate::errors::Error;
use crate::transaction::{
    EngineTransactionTrait, EngineTransactionInputTrait, EngineTransactionOutputTrait,
};
use crate::signature::{schnorr::{parse_schnorr_pub_key}, taproot_signature::TaprootSigVerifierImpl};
use crate::engine::Engine;
use crate::hash_tag::{HashTag, tagged_hash_digest};
use shinigami_utils::hash::{hash_to_u256};
use shinigami_utils::bytecode::write_var_int;
use shinigami_utils::byte_array::{U256IntoByteArray, ByteArrayLexicoParialOrder};
use shinigami_utils::digest::{Digest, DigestIntoByteArray, DigestIntoSnapByteArray};

use starknet::secp256k1::Secp256k1Point;
use starknet::secp256_trait::{Secp256Trait, Secp256PointTrait};
use starknet::SyscallResultTrait;

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

// SerializePubKey serializes a public key in the 32-byte format.
pub fn serialize_pub_key(pub_key: Secp256k1Point) -> @ByteArray {
    let pub_key_bytes: ByteArray = serialized_compressed(pub_key);
    let mut result = "";
    for i in 1..pub_key_bytes.len() {
        result.append_byte(pub_key_bytes[i]);
    };

    return @result;
}

// SerializeCompressed serializes a public key in the 33-byte compressed format.
pub fn serialized_compressed(pub_key: Secp256k1Point) -> ByteArray {
    let mut format = 0x02;
    let (x, y) = pub_key.get_coordinates().unwrap();
    if y & 1 == 1 {
        format = 0x03
    }

    // 0x02 or 0x03 || 32-byte x coordinate
    let mut result = "";
    result.append_byte(format);
    result.append(@x.into());

    result
}

pub fn compute_tweak_hash(pubkey: Secp256k1Point, script_root: @Digest) -> Digest {
    // This routine only operates on x-only public keys where the public
    // key always has an even y coordinate, so we'll re-parse it as such.
    // TODO check pertinence
    let serialized_pub_key: @ByteArray = serialize_pub_key(pubkey);
    let internal_pubkey: Secp256k1Point = parse_schnorr_pub_key(serialized_pub_key).unwrap();
    let serialize_pub_key2: @ByteArray = serialize_pub_key(internal_pubkey);

    // compute the tap tweak hash that commits to the internal key and the merkle script root.
    let mut msg: ByteArray = "";
    msg.append(serialize_pub_key2);
    msg.append(script_root.into());
    tagged_hash_digest(HashTag::TapTweak, @msg)
}

pub fn compute_taproot_output_key(pubkey: Secp256k1Point, script_root: @Digest) -> Secp256k1Point {
    let tap_tweak_hash: Digest = compute_tweak_hash(pubkey, script_root);

    let G = Secp256Trait::<Secp256k1Point>::get_generator_point();
    let tweak_point: Secp256k1Point = G.mul(hash_to_u256(tap_tweak_hash.value)).unwrap_syscall();
    let tweaked_pubkey: Secp256k1Point = tweak_point.add(pubkey).unwrap_syscall();

    let (x, y) = tweaked_pubkey.get_coordinates().unwrap_syscall();
    let parity = y & 1 == 1;

    let tweak_public_key = Secp256Trait::<
        Secp256k1Point,
    >::secp256_ec_get_point_from_x_syscall(x, parity)
        .unwrap_syscall()
        .unwrap();

    tweak_public_key
}

pub fn tap_branch_hash(left: @ByteArray, right: @ByteArray) -> Digest {
    // compare lexicographically left and right
    let mut left_is_smaller = ByteArrayLexicoParialOrder::lt(left, right);

    // compute message order to hash
    let mut result: ByteArray = Default::default();
    if left_is_smaller {
        result.append(left);
        result.append(right);
    } else {
        result.append(right);
        result.append(left);
    };

    return tagged_hash_digest(HashTag::TapBranch, @result);
}


#[derive(Drop, Copy, Default, Debug)]
pub struct TapNode {
    tap_hash: Digest,
    left: Option<TapNode>,
    right: Option<TapNode>,
}

#[generate_trait()]
pub impl TapNodeImpl of TapNodeTrait {
    fn new(tap_hash: Digest, left: Option<TapNode>, right: Option<TapNode>) -> TapNode {
        TapNode { tap_hash: tap_hash, left: left, right: right }
    }

    fn get_tap_hash(self: @TapNode) -> Digest {
        self.tap_hash.clone()
    }

    fn get_left(self: @TapNode) -> @Option<TapNode> {
        self.left
    }

    fn get_right(self: @TapNode) -> @Option<TapNode> {
        self.right
    }
}

#[derive(Drop)]
pub struct TapBranch {
    left_node: TapNode,
    right_node: TapNode,
}

#[generate_trait()]
pub impl TapBranchImpl of TapBranchTrait {
    // fn new(left_node: TapNode, right_node: TapNode) -> TapBranch {
    //     TapBranch { left_node: left_node, right_node: right_node }
    // }

    fn get_left(self: @TapBranch) -> TapNode {
        self.left_node.clone()
    }

    fn get_right(self: @TapBranch) -> TapNode {
        self.right_node.clone()
    }

    fn tap_hash(self: @TapBranch) -> Digest {
        let left_hash: ByteArray = self.get_left().get_tap_hash().into();
        let right_hash: ByteArray = self.get_right().get_tap_hash().into();
        tap_branch_hash(@left_hash, @right_hash)
    }
}

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

    fn tap_hash(self: TapLeaf) -> Digest {
        let mut leaf_encoding: ByteArray = Default::default();
        leaf_encoding.append_byte(*self.leaf_version);
        write_var_int(ref leaf_encoding, self.script.len().into());
        leaf_encoding.append(self.script);

        tagged_hash_digest(HashTag::TapLeaf, @leaf_encoding)
    }
}

#[derive(Drop)]
pub struct ControlBlock {
    // Internal public key in the taproot commitment.
    pub internal_pubkey: Secp256k1Point,
    // Denotes if the y coordinate of the output key
    pub output_key_y_is_odd: bool,
    // Leaf version of the tapscript leaf that the inclusion_proof below is based off of.
    pub leaf_version: u8,
    // Series of merkle branches that when hashed pairwise, starting with the revealed script, will
    // yield the taproot commitment root.
    pub inclusion_proof: ByteArray,
}

// TODO impl into ControlBLock -> ByteArray

#[generate_trait()]
pub impl ControlBlockImpl of ControlBlockTrait {
    fn new(control_block: @ByteArray) -> Result<ControlBlock, felt252> {
        parse_control_block(control_block)
    }

    fn root_hash(self: @ControlBlock, revealed_script: @ByteArray) -> Digest {
        // initial hash we'll use to incrementally reconstruct the merkle root using the control
        // block elements.
        let mut merkleAccumulator = TapLeafTrait::new_tap_leaf(self.leaf_version, revealed_script)
            .tap_hash();

        let num_nodes = self.inclusion_proof.len() / CONTROL_BLOCK_NODE_SIZE;
        for node_offset in 0..num_nodes {
            let mut leaf_offset = 32 * node_offset;
            let mut next_node = "";
            // let mut next_node = sub_byte_array(self.inclusion_proof, ref leaf_offset, 32);

            for i in leaf_offset..leaf_offset + 32 {
                next_node.append_byte(self.inclusion_proof[i]);
            };

            merkleAccumulator = tap_branch_hash(@merkleAccumulator.into(), @next_node);
        };

        return merkleAccumulator;
    }

    fn verify_taproot_leaf(
        self: @ControlBlock, witness_program: @ByteArray, script: @ByteArray,
    ) -> Result<(), felt252> {
        let root_hash = self.root_hash(script);
        let taproot_key = compute_taproot_output_key(*self.internal_pubkey, @root_hash);
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

#[derive(Destruct)]
pub struct TaprootContext {
    pub annex: @ByteArray,
    pub code_sep: u32,
    pub tapleaf_hash: Digest,
    sig_ops_budget: i32,
    pub must_succeed: bool,
}

#[generate_trait()]
pub impl TaprootContextImpl of TaprootContextTrait {
    fn new(witness_size: i32) -> TaprootContext {
        TaprootContext {
            annex: @"",
            code_sep: BASE_CODE_SEP,
            tapleaf_hash: Default::default(),
            sig_ops_budget: SIG_OPS_DELTA + witness_size,
            must_succeed: false,
        }
    }

    fn empty() -> TaprootContext {
        TaprootContext {
            annex: @"",
            code_sep: BASE_CODE_SEP,
            tapleaf_hash: Default::default(),
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

        let verify_result = verifier.verify(ref engine)?;
        if verify_result.sig_valid {
            return Result::Ok(());
        }
        Result::Err(Error::TAPROOT_INVALID_SIG)
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

    let mut inclusion_proof = "";
    for i in CONTROL_BLOCK_BASE_SIZE..control_block_len {
        inclusion_proof.append_byte(control_block[i]);
    };

    let pubkey = parse_schnorr_pub_key(@raw_pubkey)?;
    return Result::Ok(
        ControlBlock {
            internal_pubkey: pubkey,
            output_key_y_is_odd: output_key_y_is_odd,
            leaf_version: leaf_version,
            inclusion_proof: inclusion_proof,
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
