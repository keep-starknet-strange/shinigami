use crate::errors::Error;
use crate::transaction::{
    EngineTransactionTrait, EngineTransactionInputTrait, EngineTransactionOutputTrait,
};
use crate::signature::{schnorr, taproot_signature::{TaprootSigVerifierImpl}};
use crate::engine::Engine;
// use core::hash::{HashStateTrait, HashStateExTrait, Hash};
use shinigami_utils::bytecode::write_var_int;
use shinigami_utils::byte_array::ByteArrayLexicoParialOrder;
use shinigami_utils::digest::{Digest, DigestIntoByteArray};
// DigestIntoByteArrayImpl};
use crate::hash_tag::{HashTag, tagged_hash_digest};
// use crate::hash_tag::{HashTag, tagged_hash, tagged_hash_digest};
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

pub fn compute_taproot_output_key(pubkey: @Secp256k1Point, script: @Digest) -> Secp256k1Point {
    // TODO: Implement
    return pubkey.clone();
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

pub fn serialized_compressed(pub_key: Secp256k1Point) -> ByteArray {
    // TODO: Implement
    return "";
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
    internal_pubkey: Secp256k1Point,
    // Denotes if the y coordinate of the output key
    output_key_y_is_odd: bool,
    // Leaf version of the tapscript leaf that the inclusion_proof below is based off of.
    pub leaf_version: u8,
    // Series of merkle branches that when hashed pairwise, starting with the revealed script, will
    // yield the taproot commitment root.
    inclusion_proof: ByteArray,
}

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

    let mut inclusion_proof = "";
    for i in CONTROL_BLOCK_BASE_SIZE..control_block_len {
        inclusion_proof.append_byte(control_block[i]);
    };

    let pubkey = schnorr::parse_schnorr_pub_key(@raw_pubkey)?;
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

#[cfg(test)]
mod tests {
    use super::{
        TapLeaf, tap_branch_hash, ControlBlock, parse_control_block, ControlBlockTrait,
        TapLeafTrait // TapLeaf, TapLeafTrait, TapBranch, TapBranchTrait, TapNodeTrait, TapNode, tap_branch_hash,
    };
    use shinigami_utils::hex::{to_hex};
    use shinigami_utils::bytecode::hex_to_bytecode;
    use shinigami_utils::digest::{Digest};
    // use crate::hash_tag::{HashTag, tagged_hash, tagged_hash_digest};
    use shinigami_engine::transaction::{UTXO, EngineInternalTransactionTrait};
    // use crate::validate;
    use shinigami_utils::digest::{DigestIntoByteArray, DigestIntoByteArrayImpl};

    use crate::transaction::{
        EngineTransactionTrait, EngineTransactionInputTrait, EngineTransactionOutputTrait,
        EngineTransactionInput,
    };
    #[test]
    fn test_leaf_hash0() {
        // https://learnmeabitcoin.com/explorer/tx/797505b104b5fb840931c115ea35d445eb1f64c9279bf23aa5bb4c3d779da0c2#input-0
        let script: ByteArray = hex_to_bytecode(
            @"0x206d4ddc0e47d2e8f82cbe2fc2d0d749e7bd3338112cecdc76d8f831ae6620dbe0ac",
        );
        let leaf: TapLeaf = TapLeafTrait::new_base_tap_leaf(@script);
        let leaf_hash: Digest = leaf.tap_hash();

        assert_eq!(
            leaf_hash.into(),
            hex_to_bytecode(@"0x858dfe26a3dd48a2c1fcee1d631f0aadf6a61135fc51f75758e945bca534ef16"),
        );
    }

    #[test]
    fn test_leaf_hash1() {
        let script: ByteArray = hex_to_bytecode(@"0x5187");
        let leaf: TapLeaf = TapLeafTrait::new_base_tap_leaf(@script);
        let leaf_hash: Digest = leaf.tap_hash();

        assert_eq!(
            leaf_hash.into(),
            hex_to_bytecode(@"0x6b13becdaf0eee497e2f304adcfa1c0c9e84561c9989b7f2b5fc39f5f90a60f6"),
        );
    }

    #[test]
    fn test_leaf_hash2() {
        let script: ByteArray = hex_to_bytecode(@"0x5287");
        let leaf: TapLeaf = TapLeafTrait::new_base_tap_leaf(@script);
        let leaf_hash: Digest = leaf.tap_hash();

        assert_eq!(
            leaf_hash.into(),
            hex_to_bytecode(@"0xed5af8352e2a54cce8d3ea326beb7907efa850bdfe3711cef9060c7bb5bcf59e"),
        );
    }

    #[test]
    fn test_leaf_hash3() {
        let script: ByteArray = hex_to_bytecode(@"0x5387");
        let leaf: TapLeaf = TapLeafTrait::new_base_tap_leaf(@script);
        let leaf_hash: Digest = leaf.tap_hash();

        assert_eq!(
            leaf_hash.into(),
            hex_to_bytecode(@"0x160bd30406f8d5333be044e6d2d14624470495da8a3f91242ce338599b233931"),
        );
    }

    #[test]
    fn test_all_leaf_hash() {
        /// test tap_leaf_hash
        let leaf_hash1: Digest = TapLeafTrait::new_base_tap_leaf(@hex_to_bytecode(@"0x5187"))
            .tap_hash();
        let leaf_hash2: Digest = TapLeafTrait::new_base_tap_leaf(@hex_to_bytecode(@"0x5287"))
            .tap_hash();
        let leaf_hash3: Digest = TapLeafTrait::new_base_tap_leaf(@hex_to_bytecode(@"0x5387"))
            .tap_hash();
        let leaf_hash4: Digest = TapLeafTrait::new_base_tap_leaf(@hex_to_bytecode(@"0x5487"))
            .tap_hash();
        let leaf_hash5: Digest = TapLeafTrait::new_base_tap_leaf(@hex_to_bytecode(@"0x5587"))
            .tap_hash();

        assert_eq!(
            leaf_hash1.into(),
            hex_to_bytecode(@"0x6b13becdaf0eee497e2f304adcfa1c0c9e84561c9989b7f2b5fc39f5f90a60f6"),
        );

        assert_eq!(
            leaf_hash2.into(),
            hex_to_bytecode(@"0xed5af8352e2a54cce8d3ea326beb7907efa850bdfe3711cef9060c7bb5bcf59e"),
        );

        assert_eq!(
            leaf_hash3.into(),
            hex_to_bytecode(@"0x160bd30406f8d5333be044e6d2d14624470495da8a3f91242ce338599b233931"),
        );

        assert_eq!(
            leaf_hash4.into(),
            hex_to_bytecode(@"0xbf2c4bf1ca72f7b8538e9df9bdfd3ba4c305ad11587f12bbfafa00d58ad6051d"),
        );

        assert_eq!(
            leaf_hash5.into(),
            hex_to_bytecode(@"0x54962df196af2827a86f4bde3cf7d7c1a9dcb6e17f660badefbc892309bb145f"),
        );

        /// Test tap_branch_hash
        let branch1_hash: Digest = tap_branch_hash(@leaf_hash1.into(), @leaf_hash2.into());
        assert_eq!(
            branch1_hash.into(),
            hex_to_bytecode(@"0x1324300a84045033ec539f60c70d582c48b9acf04150da091694d83171b44ec9"),
        );

        let branch2_hash: Digest = tap_branch_hash(@branch1_hash.into(), @leaf_hash3.into());
        assert_eq!(
            branch2_hash.into(),
            hex_to_bytecode(@"0xbeec0122bddd26f642140bcd922e0264ce1e2be5808a41ae58d82e829bc913d7"),
        );

        let branch2_unordered: Digest = tap_branch_hash(@leaf_hash3.into(), @branch1_hash.into());
        assert_eq!(
            branch2_unordered.into(),
            hex_to_bytecode(@"0xbeec0122bddd26f642140bcd922e0264ce1e2be5808a41ae58d82e829bc913d7"),
        );

        let branch3_hash: Digest = tap_branch_hash(@branch2_hash.into(), @leaf_hash4.into());
        assert_eq!(
            branch3_hash.into(),
            hex_to_bytecode(@"0xa4e0d9cc12ce2f32069e98247581d5eb9ca0a4cf175771a8df2c53a93dcb0ebd"),
        );

        let branch3_unordered: Digest = tap_branch_hash(@leaf_hash4.into(), @branch2_hash.into());
        assert_eq!(
            branch3_unordered.into(),
            hex_to_bytecode(@"0xa4e0d9cc12ce2f32069e98247581d5eb9ca0a4cf175771a8df2c53a93dcb0ebd"),
        );

        let branch4_hash: Digest = tap_branch_hash(@leaf_hash5.into(), @branch3_hash.into());
        assert_eq!(
            branch4_hash.into(),
            hex_to_bytecode(@"0xb5b72eea07b3e338962944a752a98772bbe1f1b6550e6fb6ab8c6e6adb152e7c"),
        );
    }

    #[test]
    fn test_merkle_root_hash() {
        //https://learnmeabitcoin.com/explorer/tx/fa7eb13f6d854ed32ef284983c620f74050dd6d119dc9e91ad09c083b0267f8f#input-1
        let raw_transaction_hex =
            "0x02000000000102c343d8dff98f817e9c2bd6d951e5ebc401ae0c6f60bb47e52e24846ae961e2f80000000000ffffffff20575041a5431f83a3d99f40816df85191a21a55155d1b862124e4c7447604880100000000ffffffff01801a00000000000022512021ecac4e3b7a2414b7c0718b80dccdc169c3caf3f2cc7727084e4c4fd2d3179602210249a825dd1e0c90daf615859baf41e34148f5c69b085408a294f0f277246223a70c093006020104020104017cac03010302538781c1a2fc329a085d8cfc4fa28795993d7b666cee024e94c40115141b8e9be4a29fa41324300a84045033ec539f60c70d582c48b9acf04150da091694d83171b44ec9bf2c4bf1ca72f7b8538e9df9bdfd3ba4c305ad11587f12bbfafa00d58ad6051d54962df196af2827a86f4bde3cf7d7c1a9dcb6e17f660badefbc892309bb145f00000000";
        let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
        let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, array![]);

        let witness_input_1: @Array<ByteArray> = transaction.get_transaction_inputs()[1].witness;
        let revealed_script_input_1: @ByteArray = witness_input_1[1];
        let control_block_input1: ControlBlock = parse_control_block(witness_input_1[2]).unwrap();

        let merkle_root: Digest = control_block_input1.root_hash(revealed_script_input_1);

        assert_eq!(
            merkle_root.into(),
            hex_to_bytecode(@"0xb5b72eea07b3e338962944a752a98772bbe1f1b6550e6fb6ab8c6e6adb152e7c"),
        );
    }
}
