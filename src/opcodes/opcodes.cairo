pub mod Opcode {
    use core::result::ResultTrait;
    pub const OP_0: u8 = 0;
    pub const OP_DATA_1: u8 = 1;
    pub const OP_DATA_2: u8 = 2;
    pub const OP_DATA_3: u8 = 3;
    pub const OP_DATA_4: u8 = 4;
    pub const OP_DATA_5: u8 = 5;
    pub const OP_DATA_6: u8 = 6;
    pub const OP_PUSHDATA1: u8 = 76;
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
    pub const OP_ELSE: u8 = 103;
    pub const OP_ENDIF: u8 = 104;
    pub const OP_VERIFY: u8 = 105;
    pub const OP_RETURN: u8 = 106;
    pub const OP_TOALTSTACK: u8 = 107;
    pub const OP_FROMALTSTACK: u8 = 108;
    pub const OP_2DROP: u8 = 109;
    pub const OP_2DUP: u8 = 110;
    pub const OP_3DUP: u8 = 111;
    pub const OP_2ROT: u8 = 113;
    pub const OP_2SWAP: u8 = 114;
    pub const OP_IFDUP: u8 = 115;
    pub const OP_DEPTH: u8 = 116;
    pub const OP_DROP: u8 = 117;
    pub const OP_DUP: u8 = 118;
    pub const OP_NIP: u8 = 119;
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


    use shinigami::engine::{Engine, EngineTrait};
    use shinigami::opcodes::{constants, flow, stack, splice, bitwise, arithmetic, utils};
    pub fn execute(opcode: u8, ref engine: Engine) -> Result<(), felt252> {
        match opcode {
            0 => constants::opcode_false(ref engine),
            1 => constants::opcode_push_data(1, ref engine),
            2 => constants::opcode_push_data(2, ref engine),
            3 => constants::opcode_push_data(3, ref engine),
            4 => constants::opcode_push_data(4, ref engine),
            5 => constants::opcode_push_data(5, ref engine),
            6 => constants::opcode_push_data(6, ref engine),
            7 => utils::not_implemented(ref engine),
            8 => utils::not_implemented(ref engine),
            9 => utils::not_implemented(ref engine),
            10 => utils::not_implemented(ref engine),
            11 => utils::not_implemented(ref engine),
            12 => utils::not_implemented(ref engine),
            13 => utils::not_implemented(ref engine),
            14 => utils::not_implemented(ref engine),
            15 => utils::not_implemented(ref engine),
            16 => utils::not_implemented(ref engine),
            17 => utils::not_implemented(ref engine),
            18 => utils::not_implemented(ref engine),
            19 => utils::not_implemented(ref engine),
            20 => utils::not_implemented(ref engine),
            21 => utils::not_implemented(ref engine),
            22 => utils::not_implemented(ref engine),
            23 => utils::not_implemented(ref engine),
            24 => utils::not_implemented(ref engine),
            25 => utils::not_implemented(ref engine),
            26 => utils::not_implemented(ref engine),
            27 => utils::not_implemented(ref engine),
            28 => utils::not_implemented(ref engine),
            29 => utils::not_implemented(ref engine),
            30 => utils::not_implemented(ref engine),
            31 => utils::not_implemented(ref engine),
            32 => utils::not_implemented(ref engine),
            33 => utils::not_implemented(ref engine),
            34 => utils::not_implemented(ref engine),
            35 => utils::not_implemented(ref engine),
            36 => utils::not_implemented(ref engine),
            37 => utils::not_implemented(ref engine),
            38 => utils::not_implemented(ref engine),
            39 => utils::not_implemented(ref engine),
            40 => utils::not_implemented(ref engine),
            41 => utils::not_implemented(ref engine),
            42 => utils::not_implemented(ref engine),
            43 => utils::not_implemented(ref engine),
            44 => utils::not_implemented(ref engine),
            45 => utils::not_implemented(ref engine),
            46 => utils::not_implemented(ref engine),
            47 => utils::not_implemented(ref engine),
            48 => utils::not_implemented(ref engine),
            49 => utils::not_implemented(ref engine),
            50 => utils::not_implemented(ref engine),
            51 => utils::not_implemented(ref engine),
            52 => utils::not_implemented(ref engine),
            53 => utils::not_implemented(ref engine),
            54 => utils::not_implemented(ref engine),
            55 => utils::not_implemented(ref engine),
            56 => utils::not_implemented(ref engine),
            57 => utils::not_implemented(ref engine),
            58 => utils::not_implemented(ref engine),
            59 => utils::not_implemented(ref engine),
            60 => utils::not_implemented(ref engine),
            61 => utils::not_implemented(ref engine),
            62 => utils::not_implemented(ref engine),
            63 => utils::not_implemented(ref engine),
            64 => utils::not_implemented(ref engine),
            65 => utils::not_implemented(ref engine),
            66 => utils::not_implemented(ref engine),
            67 => utils::not_implemented(ref engine),
            68 => utils::not_implemented(ref engine),
            69 => utils::not_implemented(ref engine),
            70 => utils::not_implemented(ref engine),
            71 => utils::not_implemented(ref engine),
            72 => utils::not_implemented(ref engine),
            73 => utils::not_implemented(ref engine),
            74 => utils::not_implemented(ref engine),
            75 => utils::not_implemented(ref engine),
            76 => constants::opcode_push_data_x(1, ref engine),
            77 => utils::not_implemented(ref engine),
            78 => utils::not_implemented(ref engine),
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
            97 => flow::opcode_nop(),
            98 => utils::opcode_reserved("ver", ref engine),
            99 => flow::opcode_if(ref engine),
            100 => flow::opcode_notif(ref engine),
            101 => utils::not_implemented(ref engine),
            102 => utils::not_implemented(ref engine),
            103 => flow::opcode_else(ref engine),
            104 => flow::opcode_endif(ref engine),
            105 => flow::opcode_verify(ref engine),
            106 => flow::opcode_return(ref engine),
            107 => stack::opcode_toaltstack(ref engine),
            108 => stack::opcode_fromaltstack(ref engine),
            109 => stack::opcode_2drop(ref engine),
            110 => stack::opcode_2dup(ref engine),
            111 => stack::opcode_3dup(ref engine),
            112 => utils::not_implemented(ref engine),
            113 => stack::opcode_2rot(ref engine),
            114 => stack::opcode_2swap(ref engine),
            115 => stack::opcode_ifdup(ref engine),
            116 => stack::opcode_depth(ref engine),
            117 => stack::opcode_drop(ref engine),
            118 => stack::opcode_dup(ref engine),
            119 => stack::opcode_nip(ref engine),
            120 => utils::not_implemented(ref engine),
            121 => utils::not_implemented(ref engine),
            122 => utils::not_implemented(ref engine),
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
            _ => utils::not_implemented(ref engine)
        }
    }

    pub fn check_opcode(opcode: u8, ref engine: Engine) -> Result<(), felt252> {
        match opcode {
            0 => Result::Ok(()),
            1 => Result::Ok(()),
            2 => Result::Ok(()),
            3 => Result::Ok(()),
            4 => Result::Ok(()),
            5 => Result::Ok(()),
            6 => Result::Ok(()),
            7 => utils::not_implemented(ref engine),
            8 => utils::not_implemented(ref engine),
            9 => utils::not_implemented(ref engine),
            10 => utils::not_implemented(ref engine),
            11 => utils::not_implemented(ref engine),
            12 => utils::not_implemented(ref engine),
            13 => utils::not_implemented(ref engine),
            14 => utils::not_implemented(ref engine),
            15 => utils::not_implemented(ref engine),
            16 => utils::not_implemented(ref engine),
            17 => utils::not_implemented(ref engine),
            18 => utils::not_implemented(ref engine),
            19 => utils::not_implemented(ref engine),
            20 => utils::not_implemented(ref engine),
            21 => utils::not_implemented(ref engine),
            22 => utils::not_implemented(ref engine),
            23 => utils::not_implemented(ref engine),
            24 => utils::not_implemented(ref engine),
            25 => utils::not_implemented(ref engine),
            26 => utils::not_implemented(ref engine),
            27 => utils::not_implemented(ref engine),
            28 => utils::not_implemented(ref engine),
            29 => utils::not_implemented(ref engine),
            30 => utils::not_implemented(ref engine),
            31 => utils::not_implemented(ref engine),
            32 => utils::not_implemented(ref engine),
            33 => utils::not_implemented(ref engine),
            34 => utils::not_implemented(ref engine),
            35 => utils::not_implemented(ref engine),
            36 => utils::not_implemented(ref engine),
            37 => utils::not_implemented(ref engine),
            38 => utils::not_implemented(ref engine),
            39 => utils::not_implemented(ref engine),
            40 => utils::not_implemented(ref engine),
            41 => utils::not_implemented(ref engine),
            42 => utils::not_implemented(ref engine),
            43 => utils::not_implemented(ref engine),
            44 => utils::not_implemented(ref engine),
            45 => utils::not_implemented(ref engine),
            46 => utils::not_implemented(ref engine),
            47 => utils::not_implemented(ref engine),
            48 => utils::not_implemented(ref engine),
            49 => utils::not_implemented(ref engine),
            50 => utils::not_implemented(ref engine),
            51 => utils::not_implemented(ref engine),
            52 => utils::not_implemented(ref engine),
            53 => utils::not_implemented(ref engine),
            54 => utils::not_implemented(ref engine),
            55 => utils::not_implemented(ref engine),
            56 => utils::not_implemented(ref engine),
            57 => utils::not_implemented(ref engine),
            58 => utils::not_implemented(ref engine),
            59 => utils::not_implemented(ref engine),
            60 => utils::not_implemented(ref engine),
            61 => utils::not_implemented(ref engine),
            62 => utils::not_implemented(ref engine),
            63 => utils::not_implemented(ref engine),
            64 => utils::not_implemented(ref engine),
            65 => utils::not_implemented(ref engine),
            66 => utils::not_implemented(ref engine),
            67 => utils::not_implemented(ref engine),
            68 => utils::not_implemented(ref engine),
            69 => utils::not_implemented(ref engine),
            70 => utils::not_implemented(ref engine),
            71 => utils::not_implemented(ref engine),
            72 => utils::not_implemented(ref engine),
            73 => utils::not_implemented(ref engine),
            74 => utils::not_implemented(ref engine),
            75 => utils::not_implemented(ref engine),
            76 => Result::Ok(()),
            77 => utils::not_implemented(ref engine),
            78 => utils::not_implemented(ref engine),
            79 => Result::Ok(()),
            80 => Result::Ok(()),
            81 => Result::Ok(()),
            82 => Result::Ok(()),
            83 => Result::Ok(()),
            84 => Result::Ok(()),
            85 => Result::Ok(()),
            86 => Result::Ok(()),
            87 => Result::Ok(()),
            88 => Result::Ok(()),
            89 => Result::Ok(()),
            90 => Result::Ok(()),
            91 => Result::Ok(()),
            92 => Result::Ok(()),
            93 => Result::Ok(()),
            94 => Result::Ok(()),
            95 => Result::Ok(()),
            96 => Result::Ok(()),
            97 => Result::Ok(()),
            98 => Result::Ok(()),
            99 => Result::Ok(()),
            100 => Result::Ok(()),
            101 => utils::not_implemented(ref engine),
            102 => utils::not_implemented(ref engine),
            103 => Result::Ok(()),
            104 => Result::Ok(()),
            105 => Result::Ok(()),
            106 => Result::Ok(()),
            107 => Result::Ok(()),
            108 => Result::Ok(()),
            109 => Result::Ok(()),
            110 => Result::Ok(()),
            111 => Result::Ok(()),
            112 => utils::not_implemented(ref engine),
            113 => Result::Ok(()),
            114 => Result::Ok(()),
            115 => Result::Ok(()),
            116 => Result::Ok(()),
            117 => Result::Ok(()),
            118 => Result::Ok(()),
            119 => Result::Ok(()),
            120 => utils::not_implemented(ref engine),
            121 => utils::not_implemented(ref engine),
            122 => utils::not_implemented(ref engine),
            123 => Result::Ok(()),
            124 => Result::Ok(()),
            125 => Result::Ok(()),
            126 => utils::opcode_disabled(ref engine),
            127 => utils::opcode_disabled(ref engine),
            128 => utils::opcode_disabled(ref engine),
            129 => utils::opcode_disabled(ref engine),
            130 => Result::Ok(()),
            131 => utils::opcode_disabled(ref engine),
            132 => utils::opcode_disabled(ref engine),
            133 => utils::opcode_disabled(ref engine),
            134 => utils::opcode_disabled(ref engine),
            135 => Result::Ok(()),
            136 => Result::Ok(()),
            137 => Result::Ok(()),
            138 => Result::Ok(()),
            139 => Result::Ok(()),
            140 => Result::Ok(()),
            141 => utils::opcode_disabled(ref engine),
            142 => utils::opcode_disabled(ref engine),
            143 => Result::Ok(()),
            144 => Result::Ok(()),
            145 => Result::Ok(()),
            146 => Result::Ok(()),
            147 => Result::Ok(()),
            148 => Result::Ok(()),
            149 => utils::opcode_disabled(ref engine),
            150 => utils::opcode_disabled(ref engine),
            151 => utils::opcode_disabled(ref engine),
            152 => utils::opcode_disabled(ref engine),
            153 => utils::opcode_disabled(ref engine),
            154 => Result::Ok(()),
            155 => Result::Ok(()),
            156 => Result::Ok(()),
            157 => Result::Ok(()),
            158 => Result::Ok(()),
            159 => Result::Ok(()),
            160 => Result::Ok(()),
            161 => Result::Ok(()),
            162 => Result::Ok(()),
            163 => Result::Ok(()),
            164 => Result::Ok(()),
            165 => Result::Ok(()),
            _ => utils::not_implemented(ref engine)
        }
    }
}
