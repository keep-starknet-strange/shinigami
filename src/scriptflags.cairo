#[derive(Copy, Drop)]
pub enum ScriptFlags {
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
            ScriptFlags::ScriptStrictMultiSig => 0x1,
            ScriptFlags::ScriptDiscourageUpgradableNops => 0x2,
            ScriptFlags::ScriptVerifyCheckLockTimeVerify => 0x4,
            ScriptFlags::ScriptVerifyCheckSequenceVerify => 0x8,
            ScriptFlags::ScriptVerifyCleanStack => 0x10,
            ScriptFlags::ScriptVerifyDERSignatures => 0x20,
            ScriptFlags::ScriptVerifyLowS => 0x40,
            ScriptFlags::ScriptVerifyMinimalData => 0x80,
            ScriptFlags::ScriptVerifyNullFail => 0x100,
            ScriptFlags::ScriptVerifySigPushOnly => 0x200,
            ScriptFlags::ScriptVerifyStrictEncoding => 0x400,
            ScriptFlags::ScriptVerifyWitness => 0x800,
            ScriptFlags::ScriptVerifyDiscourageUpgradeableWitnessProgram => 0x1000,
            ScriptFlags::ScriptVerifyMinimalIf => 0x2000,
            ScriptFlags::ScriptVerifyWitnessPubKeyType => 0x4000,
            ScriptFlags::ScriptVerifyTaproot => 0x8000,
            ScriptFlags::ScriptVerifyDiscourageUpgradeableTaprootVersion => 0x10000,
            ScriptFlags::ScriptVerifyDiscourageOpSuccess => 0x20000,
            ScriptFlags::ScriptVerifyDiscourageUpgradeablePubkeyType => 0x40000,
            ScriptFlags::ScriptVerifyConstScriptCode => 0x40000,
        }
    }
}
