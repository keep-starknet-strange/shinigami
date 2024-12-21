use shinigami_utils::bytecode::hex_to_bytecode;
use shinigami_utils::hash::{simple_sha256, sha256_byte_array};

#[derive(Drop)]
pub enum HashTag {
    // BIP0340Challenge is the BIP-0340 tag for challenges.
    Bip0340Challenge,
    // BIP0340Aux is the BIP-0340 tag for aux data.
    Bip0340Aux,
    // BIP0340Nonce is the BIP-0340 tag for nonces.
    Bip0340Nonce,
    // TapSighash is the tag used by BIP 341 to generate the sighash
    // flags.
    TapSighash,
    // TagTapLeaf is the message tag prefix used to compute the hash
    // digest of a tapscript leaf.
    TapLeaf,
    // TapBranch is the message tag prefix used to compute the
    // hash digest of two tap leaves into a taproot branch node.
    TapBranch,
    // TapTweak is the message tag prefix used to compute the hash tweak
    // used to enable a public key to commit to the taproot branch root
    // for the witness program.
    TapTweak,
    // Unknown tag.
    Other: ByteArray,
}

// TaggedHash implements the tagged hash scheme described in BIP-340. We use
// sha-256 to bind a message hash to a specific context using a tag:
// sha256(sha256(tag) || sha256(tag) || msg).
pub fn tagged_hash(tag: HashTag, msg: @ByteArray) -> u256 {
    // Check if we have precomputed tag to avoid an extra sha256
    let mut sha_tag: ByteArray = "";
    match tag {
        HashTag::Bip0340Challenge => sha_tag
            .append(
                @hex_to_bytecode(
                    @"0x7bb52d7a9fef58323eb1bf7a407db382d2f3f2d81bb1224f49fe518f6d48d37c",
                ),
            ),
        HashTag::Bip0340Aux => sha_tag
            .append(
                @hex_to_bytecode(
                    @"0xf1ef4e5ec063cada6d94cafa9d987ea069265839ecc11f972d77a52ed8c1cc90",
                ),
            ),
        HashTag::Bip0340Nonce => sha_tag
            .append(
                @hex_to_bytecode(
                    @"0x07497734a79bcb355b9b8c7d034f121cf434d73ef72dda19870061fb52bfeb2f",
                ),
            ),
        HashTag::TapSighash => sha_tag
            .append(
                @hex_to_bytecode(
                    @"0xf40a48df4b2a70c8b4924bf2654661ed3d95fd66a313eb87237597c628e4a031",
                ),
            ),
        HashTag::TapLeaf => sha_tag
            .append(
                @hex_to_bytecode(
                    @"0xaeea8fdc4208983105734b58081d1e2638d35f1cb54008d4d357ca03be78e9ee",
                ),
            ),
        HashTag::TapBranch => sha_tag
            .append(
                @hex_to_bytecode(
                    @"0x1941a1f2e56eb95fa2a9f194be5c01f7216f33ed82b091463490d05bf516a015",
                ),
            ),
        HashTag::TapTweak => sha_tag
            .append(
                @hex_to_bytecode(
                    @"0xe80fe1639c9ca050e3af1b39c143c63e429cbceb15d940fbb5c5a1f4af57c5e9",
                ),
            ),
        HashTag::Other(bytes) => sha_tag.append(@sha256_byte_array(@bytes)),
    };

    // h = sha256(sha256(tag) || sha256(tag) || msg)
    let mut h: ByteArray = sha_tag.clone();
    h.append(@sha_tag);
    h.append(msg);
    return simple_sha256(@h);
}
