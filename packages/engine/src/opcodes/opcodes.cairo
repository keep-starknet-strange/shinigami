pub mod Opcode {
    pub const OP_0: u8 = 0;
    pub const OP_FALSE: u8 = 0;
    pub const OP_DATA_1: u8 = 1;
    pub const OP_DATA_2: u8 = 2;
    pub const OP_DATA_3: u8 = 3;
    pub const OP_DATA_4: u8 = 4;
    pub const OP_DATA_5: u8 = 5;
    pub const OP_DATA_6: u8 = 6;
    pub const OP_DATA_7: u8 = 7;
    pub const OP_DATA_8: u8 = 8;
    pub const OP_DATA_9: u8 = 9;
    pub const OP_DATA_10: u8 = 10;
    pub const OP_DATA_11: u8 = 11;
    pub const OP_DATA_12: u8 = 12;
    pub const OP_DATA_13: u8 = 13;
    pub const OP_DATA_14: u8 = 14;
    pub const OP_DATA_15: u8 = 15;
    pub const OP_DATA_16: u8 = 16;
    pub const OP_DATA_17: u8 = 17;
    pub const OP_DATA_18: u8 = 18;
    pub const OP_DATA_19: u8 = 19;
    pub const OP_DATA_20: u8 = 20;
    pub const OP_DATA_21: u8 = 21;
    pub const OP_DATA_22: u8 = 22;
    pub const OP_DATA_23: u8 = 23;
    pub const OP_DATA_24: u8 = 24;
    pub const OP_DATA_25: u8 = 25;
    pub const OP_DATA_26: u8 = 26;
    pub const OP_DATA_27: u8 = 27;
    pub const OP_DATA_28: u8 = 28;
    pub const OP_DATA_29: u8 = 29;
    pub const OP_DATA_30: u8 = 30;
    pub const OP_DATA_31: u8 = 31;
    pub const OP_DATA_32: u8 = 32;
    pub const OP_DATA_33: u8 = 33;
    pub const OP_DATA_34: u8 = 34;
    pub const OP_DATA_35: u8 = 35;
    pub const OP_DATA_36: u8 = 36;
    pub const OP_DATA_37: u8 = 37;
    pub const OP_DATA_38: u8 = 38;
    pub const OP_DATA_39: u8 = 39;
    pub const OP_DATA_40: u8 = 40;
    pub const OP_DATA_41: u8 = 41;
    pub const OP_DATA_42: u8 = 42;
    pub const OP_DATA_43: u8 = 43;
    pub const OP_DATA_44: u8 = 44;
    pub const OP_DATA_45: u8 = 45;
    pub const OP_DATA_46: u8 = 46;
    pub const OP_DATA_47: u8 = 47;
    pub const OP_DATA_48: u8 = 48;
    pub const OP_DATA_49: u8 = 49;
    pub const OP_DATA_50: u8 = 50;
    pub const OP_DATA_51: u8 = 51;
    pub const OP_DATA_52: u8 = 52;
    pub const OP_DATA_53: u8 = 53;
    pub const OP_DATA_54: u8 = 54;
    pub const OP_DATA_55: u8 = 55;
    pub const OP_DATA_56: u8 = 56;
    pub const OP_DATA_57: u8 = 57;
    pub const OP_DATA_58: u8 = 58;
    pub const OP_DATA_59: u8 = 59;
    pub const OP_DATA_60: u8 = 60;
    pub const OP_DATA_61: u8 = 61;
    pub const OP_DATA_62: u8 = 62;
    pub const OP_DATA_63: u8 = 63;
    pub const OP_DATA_64: u8 = 64;
    pub const OP_DATA_65: u8 = 65;
    pub const OP_DATA_66: u8 = 66;
    pub const OP_DATA_67: u8 = 67;
    pub const OP_DATA_68: u8 = 68;
    pub const OP_DATA_69: u8 = 69;
    pub const OP_DATA_70: u8 = 70;
    pub const OP_DATA_71: u8 = 71;
    pub const OP_DATA_72: u8 = 72;
    pub const OP_DATA_73: u8 = 73;
    pub const OP_DATA_74: u8 = 74;
    pub const OP_DATA_75: u8 = 75;
    pub const OP_PUSHDATA1: u8 = 76;
    pub const OP_PUSHDATA2: u8 = 77;
    pub const OP_PUSHDATA4: u8 = 78;
    pub const OP_1NEGATE: u8 = 79;
    pub const OP_RESERVED: u8 = 80;
    pub const OP_TRUE: u8 = 81;
    pub const OP_1: u8 = 81;
    pub const OP_2: u8 = 82;
    pub const OP_3: u8 = 83;
    pub const OP_4: u8 = 84;
    pub const OP_5: u8 = 85;
    pub const OP_6: u8 = 86;
    pub const OP_7: u8 = 87;
    pub const OP_8: u8 = 88;
    pub const OP_9: u8 = 89;
    pub const OP_10: u8 = 90;
    pub const OP_11: u8 = 91;
    pub const OP_12: u8 = 92;
    pub const OP_13: u8 = 93;
    pub const OP_14: u8 = 94;
    pub const OP_15: u8 = 95;
    pub const OP_16: u8 = 96;
    pub const OP_NOP: u8 = 97;
    pub const OP_VER: u8 = 98;
    pub const OP_IF: u8 = 99;
    pub const OP_NOTIF: u8 = 100;
    pub const OP_VERIF: u8 = 101;
    pub const OP_VERNOTIF: u8 = 102;
    pub const OP_ELSE: u8 = 103;
    pub const OP_ENDIF: u8 = 104;
    pub const OP_VERIFY: u8 = 105;
    pub const OP_RETURN: u8 = 106;
    pub const OP_TOALTSTACK: u8 = 107;
    pub const OP_FROMALTSTACK: u8 = 108;
    pub const OP_2DROP: u8 = 109;
    pub const OP_2DUP: u8 = 110;
    pub const OP_3DUP: u8 = 111;
    pub const OP_2OVER: u8 = 112;
    pub const OP_2ROT: u8 = 113;
    pub const OP_2SWAP: u8 = 114;
    pub const OP_IFDUP: u8 = 115;
    pub const OP_DEPTH: u8 = 116;
    pub const OP_DROP: u8 = 117;
    pub const OP_DUP: u8 = 118;
    pub const OP_NIP: u8 = 119;
    pub const OP_OVER: u8 = 120;
    pub const OP_PICK: u8 = 121;
    pub const OP_ROLL: u8 = 122;
    pub const OP_ROT: u8 = 123;
    pub const OP_SWAP: u8 = 124;
    pub const OP_TUCK: u8 = 125;
    pub const OP_CAT: u8 = 126;
    pub const OP_SUBSTR: u8 = 127;
    pub const OP_LEFT: u8 = 128;
    pub const OP_RIGHT: u8 = 129;
    pub const OP_SIZE: u8 = 130;
    pub const OP_INVERT: u8 = 131;
    pub const OP_AND: u8 = 132;
    pub const OP_OR: u8 = 133;
    pub const OP_XOR: u8 = 134;
    pub const OP_EQUAL: u8 = 135;
    pub const OP_EQUALVERIFY: u8 = 136;
    pub const OP_RESERVED1: u8 = 137;
    pub const OP_RESERVED2: u8 = 138;
    pub const OP_1ADD: u8 = 139;
    pub const OP_1SUB: u8 = 140;
    pub const OP_2MUL: u8 = 141;
    pub const OP_2DIV: u8 = 142;
    pub const OP_NEGATE: u8 = 143;
    pub const OP_ABS: u8 = 144;
    pub const OP_NOT: u8 = 145;
    pub const OP_0NOTEQUAL: u8 = 146;
    pub const OP_ADD: u8 = 147;
    pub const OP_SUB: u8 = 148;
    pub const OP_MUL: u8 = 149;
    pub const OP_DIV: u8 = 150;
    pub const OP_MOD: u8 = 151;
    pub const OP_LSHIFT: u8 = 152;
    pub const OP_RSHIFT: u8 = 153;
    pub const OP_BOOLAND: u8 = 154;
    pub const OP_BOOLOR: u8 = 155;
    pub const OP_NUMEQUAL: u8 = 156;
    pub const OP_NUMEQUALVERIFY: u8 = 157;
    pub const OP_NUMNOTEQUAL: u8 = 158;
    pub const OP_LESSTHAN: u8 = 159;
    pub const OP_GREATERTHAN: u8 = 160;
    pub const OP_LESSTHANOREQUAL: u8 = 161;
    pub const OP_GREATERTHANOREQUAL: u8 = 162;
    pub const OP_MIN: u8 = 163;
    pub const OP_MAX: u8 = 164;
    pub const OP_WITHIN: u8 = 165;
    pub const OP_RIPEMD160: u8 = 166;
    pub const OP_SHA1: u8 = 167;
    pub const OP_SHA256: u8 = 168;
    pub const OP_HASH160: u8 = 169;
    pub const OP_HASH256: u8 = 170;
    pub const OP_CODESEPARATOR: u8 = 171;
    pub const OP_CHECKSIG: u8 = 172;
    pub const OP_CHECKSIGVERIFY: u8 = 173;
    pub const OP_CHECKMULTISIG: u8 = 174;
    pub const OP_CHECKMULTISIGVERIFY: u8 = 175;
    pub const OP_NOP1: u8 = 176;
    pub const OP_NOP2: u8 = 177;
    pub const OP_CHECKLOCKTIMEVERIFY: u8 = 177;
    pub const OP_NOP3: u8 = 178;
    pub const OP_CHECKSEQUENCEVERIFY: u8 = 178;
    pub const OP_NOP4: u8 = 179;
    pub const OP_NOP5: u8 = 180;
    pub const OP_NOP6: u8 = 181;
    pub const OP_NOP7: u8 = 182;
    pub const OP_NOP8: u8 = 183;
    pub const OP_NOP9: u8 = 184;
    pub const OP_NOP10: u8 = 185;

    use crate::engine::Engine;
    use crate::transaction::{
        EngineTransactionTrait, EngineTransactionInputTrait, EngineTransactionOutputTrait
    };
    use crate::opcodes::{
        constants, flow, stack, splice, bitwise, arithmetic, crypto, locktime, utils
    };
    use crate::parser::data_len;

    pub fn execute<
        T,
        +Drop<T>,
        I,
        +Drop<I>,
        impl IEngineTransactionInputTrait: EngineTransactionInputTrait<I>,
        O,
        +Drop<O>,
        impl IEngineTransactionOutputTrait: EngineTransactionOutputTrait<O>,
        impl IEngineTransactionTrait: EngineTransactionTrait<
            T, I, O, IEngineTransactionInputTrait, IEngineTransactionOutputTrait
        >
    >(
        opcode: u8, ref engine: Engine<T>
    ) -> Result<(), felt252> {
        match opcode {
            0 => constants::opcode_false(ref engine),
            1 => constants::opcode_push_data(1, ref engine),
            2 => constants::opcode_push_data(2, ref engine),
            3 => constants::opcode_push_data(3, ref engine),
            4 => constants::opcode_push_data(4, ref engine),
            5 => constants::opcode_push_data(5, ref engine),
            6 => constants::opcode_push_data(6, ref engine),
            7 => constants::opcode_push_data(7, ref engine),
            8 => constants::opcode_push_data(8, ref engine),
            9 => constants::opcode_push_data(9, ref engine),
            10 => constants::opcode_push_data(10, ref engine),
            11 => constants::opcode_push_data(11, ref engine),
            12 => constants::opcode_push_data(12, ref engine),
            13 => constants::opcode_push_data(13, ref engine),
            14 => constants::opcode_push_data(14, ref engine),
            15 => constants::opcode_push_data(15, ref engine),
            16 => constants::opcode_push_data(16, ref engine),
            17 => constants::opcode_push_data(17, ref engine),
            18 => constants::opcode_push_data(18, ref engine),
            19 => constants::opcode_push_data(19, ref engine),
            20 => constants::opcode_push_data(20, ref engine),
            21 => constants::opcode_push_data(21, ref engine),
            22 => constants::opcode_push_data(22, ref engine),
            23 => constants::opcode_push_data(23, ref engine),
            24 => constants::opcode_push_data(24, ref engine),
            25 => constants::opcode_push_data(25, ref engine),
            26 => constants::opcode_push_data(26, ref engine),
            27 => constants::opcode_push_data(27, ref engine),
            28 => constants::opcode_push_data(28, ref engine),
            29 => constants::opcode_push_data(29, ref engine),
            30 => constants::opcode_push_data(30, ref engine),
            31 => constants::opcode_push_data(31, ref engine),
            32 => constants::opcode_push_data(32, ref engine),
            33 => constants::opcode_push_data(33, ref engine),
            34 => constants::opcode_push_data(34, ref engine),
            35 => constants::opcode_push_data(35, ref engine),
            36 => constants::opcode_push_data(36, ref engine),
            37 => constants::opcode_push_data(37, ref engine),
            38 => constants::opcode_push_data(38, ref engine),
            39 => constants::opcode_push_data(39, ref engine),
            40 => constants::opcode_push_data(40, ref engine),
            41 => constants::opcode_push_data(41, ref engine),
            42 => constants::opcode_push_data(42, ref engine),
            43 => constants::opcode_push_data(43, ref engine),
            44 => constants::opcode_push_data(44, ref engine),
            45 => constants::opcode_push_data(45, ref engine),
            46 => constants::opcode_push_data(46, ref engine),
            47 => constants::opcode_push_data(47, ref engine),
            48 => constants::opcode_push_data(48, ref engine),
            49 => constants::opcode_push_data(49, ref engine),
            50 => constants::opcode_push_data(50, ref engine),
            51 => constants::opcode_push_data(51, ref engine),
            52 => constants::opcode_push_data(52, ref engine),
            53 => constants::opcode_push_data(53, ref engine),
            54 => constants::opcode_push_data(54, ref engine),
            55 => constants::opcode_push_data(55, ref engine),
            56 => constants::opcode_push_data(56, ref engine),
            57 => constants::opcode_push_data(57, ref engine),
            58 => constants::opcode_push_data(58, ref engine),
            59 => constants::opcode_push_data(59, ref engine),
            60 => constants::opcode_push_data(60, ref engine),
            61 => constants::opcode_push_data(61, ref engine),
            62 => constants::opcode_push_data(62, ref engine),
            63 => constants::opcode_push_data(63, ref engine),
            64 => constants::opcode_push_data(64, ref engine),
            65 => constants::opcode_push_data(65, ref engine),
            66 => constants::opcode_push_data(66, ref engine),
            67 => constants::opcode_push_data(67, ref engine),
            68 => constants::opcode_push_data(68, ref engine),
            69 => constants::opcode_push_data(69, ref engine),
            70 => constants::opcode_push_data(70, ref engine),
            71 => constants::opcode_push_data(71, ref engine),
            72 => constants::opcode_push_data(72, ref engine),
            73 => constants::opcode_push_data(73, ref engine),
            74 => constants::opcode_push_data(74, ref engine),
            75 => constants::opcode_push_data(75, ref engine),
            76 => constants::opcode_push_data_x(1, ref engine),
            77 => constants::opcode_push_data_x(2, ref engine),
            78 => constants::opcode_push_data_x(4, ref engine),
            79 => constants::opcode_1negate(ref engine),
            80 => utils::opcode_reserved("reserved", ref engine),
            81 => constants::opcode_n(1, ref engine),
            82 => constants::opcode_n(2, ref engine),
            83 => constants::opcode_n(3, ref engine),
            84 => constants::opcode_n(4, ref engine),
            85 => constants::opcode_n(5, ref engine),
            86 => constants::opcode_n(6, ref engine),
            87 => constants::opcode_n(7, ref engine),
            88 => constants::opcode_n(8, ref engine),
            89 => constants::opcode_n(9, ref engine),
            90 => constants::opcode_n(10, ref engine),
            91 => constants::opcode_n(11, ref engine),
            92 => constants::opcode_n(12, ref engine),
            93 => constants::opcode_n(13, ref engine),
            94 => constants::opcode_n(14, ref engine),
            95 => constants::opcode_n(15, ref engine),
            96 => constants::opcode_n(16, ref engine),
            97 => flow::opcode_nop(ref engine, 97),
            98 => utils::opcode_reserved("ver", ref engine),
            99 => flow::opcode_if(ref engine),
            100 => flow::opcode_notif(ref engine),
            101 => utils::opcode_reserved("verif", ref engine),
            102 => utils::opcode_reserved("vernotif", ref engine),
            103 => flow::opcode_else(ref engine),
            104 => flow::opcode_endif(ref engine),
            105 => flow::opcode_verify(ref engine),
            106 => flow::opcode_return(ref engine),
            107 => stack::opcode_toaltstack(ref engine),
            108 => stack::opcode_fromaltstack(ref engine),
            109 => stack::opcode_2drop(ref engine),
            110 => stack::opcode_2dup(ref engine),
            111 => stack::opcode_3dup(ref engine),
            112 => stack::opcode_2over(ref engine),
            113 => stack::opcode_2rot(ref engine),
            114 => stack::opcode_2swap(ref engine),
            115 => stack::opcode_ifdup(ref engine),
            116 => stack::opcode_depth(ref engine),
            117 => stack::opcode_drop(ref engine),
            118 => stack::opcode_dup(ref engine),
            119 => stack::opcode_nip(ref engine),
            120 => stack::opcode_over(ref engine),
            121 => stack::opcode_pick(ref engine),
            122 => stack::opcode_roll(ref engine),
            123 => stack::opcode_rot(ref engine),
            124 => stack::opcode_swap(ref engine),
            125 => stack::opcode_tuck(ref engine),
            126 => utils::opcode_disabled(ref engine),
            127 => utils::opcode_disabled(ref engine),
            128 => utils::opcode_disabled(ref engine),
            129 => utils::opcode_disabled(ref engine),
            130 => splice::opcode_size(ref engine),
            131 => utils::opcode_disabled(ref engine),
            132 => utils::opcode_disabled(ref engine),
            133 => utils::opcode_disabled(ref engine),
            134 => utils::opcode_disabled(ref engine),
            135 => bitwise::opcode_equal(ref engine),
            136 => bitwise::opcode_equal_verify(ref engine),
            137 => utils::opcode_reserved("reserved1", ref engine),
            138 => utils::opcode_reserved("reserved2", ref engine),
            139 => arithmetic::opcode_1add(ref engine),
            140 => arithmetic::opcode_1sub(ref engine),
            141 => utils::opcode_disabled(ref engine),
            142 => utils::opcode_disabled(ref engine),
            143 => arithmetic::opcode_negate(ref engine),
            144 => arithmetic::opcode_abs(ref engine),
            145 => arithmetic::opcode_not(ref engine),
            146 => arithmetic::opcode_0_not_equal(ref engine),
            147 => arithmetic::opcode_add(ref engine),
            148 => arithmetic::opcode_sub(ref engine),
            149 => utils::opcode_disabled(ref engine),
            150 => utils::opcode_disabled(ref engine),
            151 => utils::opcode_disabled(ref engine),
            152 => utils::opcode_disabled(ref engine),
            153 => utils::opcode_disabled(ref engine),
            154 => arithmetic::opcode_bool_and(ref engine),
            155 => arithmetic::opcode_bool_or(ref engine),
            156 => arithmetic::opcode_numequal(ref engine),
            157 => arithmetic::opcode_numequalverify(ref engine),
            158 => arithmetic::opcode_numnotequal(ref engine),
            159 => arithmetic::opcode_lessthan(ref engine),
            160 => arithmetic::opcode_greater_than(ref engine),
            161 => arithmetic::opcode_less_than_or_equal(ref engine),
            162 => arithmetic::opcode_greater_than_or_equal(ref engine),
            163 => arithmetic::opcode_min(ref engine),
            164 => arithmetic::opcode_max(ref engine),
            165 => arithmetic::opcode_within(ref engine),
            166 => crypto::opcode_ripemd160(ref engine),
            167 => crypto::opcode_sha1(ref engine),
            168 => crypto::opcode_sha256(ref engine),
            169 => crypto::opcode_hash160(ref engine),
            170 => crypto::opcode_hash256(ref engine),
            171 => crypto::opcode_codeseparator(ref engine),
            172 => crypto::opcode_checksig(ref engine),
            173 => crypto::opcode_checksigverify(ref engine),
            174 => crypto::opcode_checkmultisig(ref engine),
            175 => crypto::opcode_checkmultisigverify(ref engine),
            176 => flow::opcode_nop(ref engine, 176),
            177 => locktime::opcode_checklocktimeverify(ref engine),
            178 => locktime::opcode_checksequenceverify(ref engine),
            179 => flow::opcode_nop(ref engine, 179),
            180 => flow::opcode_nop(ref engine, 180),
            181 => flow::opcode_nop(ref engine, 181),
            182 => flow::opcode_nop(ref engine, 182),
            183 => flow::opcode_nop(ref engine, 183),
            184 => flow::opcode_nop(ref engine, 184),
            185 => flow::opcode_nop(ref engine, 185),
            _ => utils::not_implemented(ref engine)
        }
    }

    pub fn is_opcode_disabled<T, +Drop<T>>(
        opcode: u8, ref engine: Engine<T>
    ) -> Result<(), felt252> {
        if opcode == OP_CAT
            || opcode == OP_SUBSTR
            || opcode == OP_LEFT
            || opcode == OP_RIGHT
            || opcode == OP_INVERT
            || opcode == OP_AND
            || opcode == OP_OR
            || opcode == OP_XOR
            || opcode == OP_2MUL
            || opcode == OP_2DIV
            || opcode == OP_MUL
            || opcode == OP_DIV
            || opcode == OP_MOD
            || opcode == OP_LSHIFT
            || opcode == OP_RSHIFT {
            return utils::opcode_disabled(ref engine);
        } else {
            return Result::Ok(());
        }
    }

    pub fn is_opcode_always_illegal<T, +Drop<T>>(
        opcode: u8, ref engine: Engine<T>
    ) -> Result<(), felt252> {
        if opcode == OP_VERIF {
            return utils::opcode_reserved("verif", ref engine);
        } else if opcode == OP_VERNOTIF {
            return utils::opcode_reserved("vernotif", ref engine);
        } else {
            return Result::Ok(());
        }
    }

    pub fn is_data_opcode(opcode: u8) -> bool {
        return (opcode >= OP_DATA_1 && opcode <= OP_DATA_75);
    }

    pub fn is_push_opcode(opcode: u8) -> bool {
        return (opcode == OP_PUSHDATA1 || opcode == OP_PUSHDATA2 || opcode == OP_PUSHDATA4);
    }

    pub fn is_canonical_push(opcode: u8, data: @ByteArray) -> bool {
        let data_len = data.len();
        if opcode > OP_16 {
            return true;
        }

        if opcode < OP_PUSHDATA1 && opcode > OP_0 && data_len == 1 && data[0] <= 16 {
            // Could have used OP_N
            return false;
        } else if opcode == OP_PUSHDATA1 && data_len < OP_PUSHDATA1.into() {
            // Could have used OP_DATA_N
            return false;
        } else if opcode == OP_PUSHDATA2 && data_len <= 0xFF {
            // Could have used OP_PUSHDATA1
            return false;
        } else if opcode == OP_PUSHDATA4 && data_len <= 0xFFFF {
            // Could have used OP_PUSHDATA2
            return false;
        }

        return true;
    }

    pub fn is_branching_opcode(opcode: u8) -> bool {
        if opcode == OP_IF || opcode == OP_NOTIF || opcode == OP_ELSE || opcode == OP_ENDIF {
            return true;
        }
        return false;
    }

    pub fn is_success_opcode(opcode: u8) -> bool {
        // TODO: To map
        if opcode > 186 {
            // OP_UNKNOWNX
            return true;
        }
        if opcode == OP_RESERVED
            || opcode == OP_VER
            || opcode == OP_CAT
            || opcode == OP_SUBSTR
            || opcode == OP_LEFT
            || opcode == OP_RIGHT
            || opcode == OP_INVERT
            || opcode == OP_AND
            || opcode == OP_OR
            || opcode == OP_XOR
            || opcode == OP_RESERVED1
            || opcode == OP_RESERVED2
            || opcode == OP_2MUL
            || opcode == OP_2DIV
            || opcode == OP_MUL
            || opcode == OP_DIV
            || opcode == OP_MOD
            || opcode == OP_LSHIFT
            || opcode == OP_RSHIFT {
            return true;
        }
        return false;
    }

    pub fn has_success_opcode(script: @ByteArray) -> bool {
        let mut i: usize = 0;
        let mut result = false;

        while i < script.len() {
            let opcode = script[i];
            if is_success_opcode(opcode) {
                result = true;
                break;
            }
            let data_len = data_len(script, i).unwrap();
            i += data_len + 1;
        };
        return result;
    }
}
