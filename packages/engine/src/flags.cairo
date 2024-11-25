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

fn flag_from_string(flag: ByteArray) -> u32 {
    // TODO: To map and remaining flags
    if flag == "P2SH" {
        return ScriptFlags::ScriptBip16.into();
    } else if flag == "STRICTENC" {
        return ScriptFlags::ScriptVerifyStrictEncoding.into();
    } else if flag == "MINIMALDATA" {
        return ScriptFlags::ScriptVerifyMinimalData.into();
    } else if flag == "DISCOURAGE_UPGRADABLE_NOPS" {
        return ScriptFlags::ScriptDiscourageUpgradableNops.into();
    } else if flag == "DERSIG" {
        return ScriptFlags::ScriptVerifyDERSignatures.into();
    } else if flag == "WITNESS" {
        return ScriptFlags::ScriptVerifyWitness.into();
    } else if flag == "LOW_S" {
        return ScriptFlags::ScriptVerifyLowS.into();
    } else if flag == "NULLDUMMY" {
        // TODO: Double check this
        return ScriptFlags::ScriptStrictMultiSig.into();
    } else if flag == "NULLFAIL" {
        return ScriptFlags::ScriptVerifyNullFail.into();
    } else if flag == "SIGPUSHONLY" {
        return ScriptFlags::ScriptVerifySigPushOnly.into();
    } else if flag == "CLEANSTACK" {
        return ScriptFlags::ScriptVerifyCleanStack.into();
    } else if flag == "DISCOURAGE_UPGRADABLE_WITNESS_PROGRAM" {
        return ScriptFlags::ScriptVerifyDiscourageUpgradeableWitnessProgram.into();
    } else if flag == "WITNESS_PUBKEYTYPE" {
        return ScriptFlags::ScriptVerifyWitnessPubKeyType.into();
    } else if flag == "MINIMALIF" {
        return ScriptFlags::ScriptVerifyMinimalIf.into();
    } else if flag == "CHECKSEQUENCEVERIFY" {
        return ScriptFlags::ScriptVerifyCheckSequenceVerify.into();
    } else {
        return 0;
    }
}

pub fn parse_flags(flags: ByteArray) -> u32 {
    let mut script_flags: u32 = 0;

    // Split the flags string by commas.
    let seperator = ',';
    let mut split_flags: Array<ByteArray> = array![];
    let mut current = "";
    let mut i = 0;
    let flags_len = flags.len();
    while i != flags_len {
        let char = flags[i].into();
        if char == seperator {
            if current == "" {
                i += 1;
                continue;
            }
            split_flags.append(current);
            current = "";
        } else {
            current.append_byte(char);
        }
        i += 1;
    };
    // Handle the last flag.
    if current != "" {
        split_flags.append(current);
    }

    // Compile the flags into a single integer.
    let mut i = 0;
    let flags_len = split_flags.len();
    while i != flags_len {
        let flag = split_flags.at(i);
        let flag_value = flag_from_string(flag.clone());
        script_flags += flag_value;
        i += 1;
    };

    script_flags
}
