#[derive(Copy, Drop)]
pub enum ScriptFlags {
    // ScriptBip16, allows P2SH transactions.
    ScriptBip16,
    // ScriptStrictMultiSig, CHECKMULTISIG stack item must be zero length.
    ScriptStrictMultiSig,
    // ScriptDiscourageUpgradableNops, reserves NOP1-NOP10.
    ScriptDiscourageUpgradableNops,
    // ScriptVerifyCheckLockTimeVerify, enforces locktime (BIP0065).
    ScriptVerifyCheckLockTimeVerify,
    // ScriptVerifyCheckSequenceVerify, restricts by output age (BIP0112).
    ScriptVerifyCheckSequenceVerify,
    // ScriptVerifyCleanStack, ensures one true element on stack.
    ScriptVerifyCleanStack,
    // ScriptVerifyDERSignatures, requires DER-formatted signatures.
    ScriptVerifyDERSignatures,
    // ScriptVerifyLowS, requires S <= order / 2.
    ScriptVerifyLowS,
    // ScriptVerifyMinimalData, uses minimal data pushes.
    ScriptVerifyMinimalData,
    // ScriptVerifyNullFail, requires empty signatures on failure.
    ScriptVerifyNullFail,
    // ScriptVerifySigPushOnly, allows only pushed data.
    ScriptVerifySigPushOnly,
    // ScriptVerifyStrictEncoding, enforces strict encoding.
    ScriptVerifyStrictEncoding,
    // ScriptVerifyWitness, verifies with witness programs.
    ScriptVerifyWitness,
    // ScriptVerifyDiscourageUpgradeableWitnessProgram, non-standard witness versions 2-16.
    ScriptVerifyDiscourageUpgradeableWitnessProgram,
    // ScriptVerifyMinimalIf, requires empty vector or [0x01] for OP_IF/OP_NOTIF.
    ScriptVerifyMinimalIf,
    // ScriptVerifyWitnessPubKeyType, requires compressed public keys.
    ScriptVerifyWitnessPubKeyType,
    // ScriptVerifyTaproot, verifies using taproot rules.
    ScriptVerifyTaproot,
    // ScriptVerifyDiscourageUpgradeableTaprootVersion, non-standard unknown taproot versions.
    ScriptVerifyDiscourageUpgradeableTaprootVersion,
    // ScriptVerifyDiscourageOpSuccess, non-standard OP_SUCCESS codes.
    ScriptVerifyDiscourageOpSuccess,
    // ScriptVerifyDiscourageUpgradeablePubkeyType, non-standard unknown pubkey versions.
    ScriptVerifyDiscourageUpgradeablePubkeyType,
    // ScriptVerifyConstScriptCode, fails if signature match in script code.
    ScriptVerifyConstScriptCode,
}

impl ScriptFlagsIntoU32 of Into<ScriptFlags, u32> {
    fn into(self: ScriptFlags) -> u32 {
        match self {
            ScriptFlags::ScriptBip16 => 0x1,
            ScriptFlags::ScriptStrictMultiSig => 0x2,
            ScriptFlags::ScriptDiscourageUpgradableNops => 0x4,
            ScriptFlags::ScriptVerifyCheckLockTimeVerify => 0x8,
            ScriptFlags::ScriptVerifyCheckSequenceVerify => 0x10,
            ScriptFlags::ScriptVerifyCleanStack => 0x20,
            ScriptFlags::ScriptVerifyDERSignatures => 0x40,
            ScriptFlags::ScriptVerifyLowS => 0x80,
            ScriptFlags::ScriptVerifyMinimalData => 0x100,
            ScriptFlags::ScriptVerifyNullFail => 0x200,
            ScriptFlags::ScriptVerifySigPushOnly => 0x400,
            ScriptFlags::ScriptVerifyStrictEncoding => 0x800,
            ScriptFlags::ScriptVerifyWitness => 0x1000,
            ScriptFlags::ScriptVerifyDiscourageUpgradeableWitnessProgram => 0x2000,
            ScriptFlags::ScriptVerifyMinimalIf => 0x4000,
            ScriptFlags::ScriptVerifyWitnessPubKeyType => 0x8000,
            ScriptFlags::ScriptVerifyTaproot => 0x10000,
            ScriptFlags::ScriptVerifyDiscourageUpgradeableTaprootVersion => 0x20000,
            ScriptFlags::ScriptVerifyDiscourageOpSuccess => 0x40000,
            ScriptFlags::ScriptVerifyDiscourageUpgradeablePubkeyType => 0x80000,
            ScriptFlags::ScriptVerifyConstScriptCode => 0x100000,
        }
    }
}
