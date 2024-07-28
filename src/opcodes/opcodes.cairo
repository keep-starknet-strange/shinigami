pub mod Opcode {
    pub const OP_0: u8 = 0;
    pub const OP_1: u8 = 81;
    pub const OP_TRUE: u8 = 81;
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
    pub const OP_DEPTH: u8 = 116;
    pub const OP_1ADD: u8 = 139;
    pub const OP_ADD: u8 = 147;
    pub const OP_MAX: u8 = 164;

    pub const OP_NOT: u8 = 145;


    use shinigami::engine::Engine;
    use shinigami::stack::ScriptStackTrait;
    pub fn execute(opcode: u8, ref engine: Engine) {
        match opcode {
            0 => opcode_false(ref engine),
            1 => not_implemented(ref engine),
            2 => not_implemented(ref engine),
            3 => not_implemented(ref engine),
            4 => not_implemented(ref engine),
            5 => not_implemented(ref engine),
            6 => not_implemented(ref engine),
            7 => not_implemented(ref engine),
            8 => not_implemented(ref engine),
            9 => not_implemented(ref engine),
            10 => not_implemented(ref engine),
            11 => not_implemented(ref engine),
            12 => not_implemented(ref engine),
            13 => not_implemented(ref engine),
            14 => not_implemented(ref engine),
            15 => not_implemented(ref engine),
            16 => not_implemented(ref engine),
            17 => not_implemented(ref engine),
            18 => not_implemented(ref engine),
            19 => not_implemented(ref engine),
            20 => not_implemented(ref engine),
            21 => not_implemented(ref engine),
            22 => not_implemented(ref engine),
            23 => not_implemented(ref engine),
            24 => not_implemented(ref engine),
            25 => not_implemented(ref engine),
            26 => not_implemented(ref engine),
            27 => not_implemented(ref engine),
            28 => not_implemented(ref engine),
            29 => not_implemented(ref engine),
            30 => not_implemented(ref engine),
            31 => not_implemented(ref engine),
            32 => not_implemented(ref engine),
            33 => not_implemented(ref engine),
            34 => not_implemented(ref engine),
            35 => not_implemented(ref engine),
            36 => not_implemented(ref engine),
            37 => not_implemented(ref engine),
            38 => not_implemented(ref engine),
            39 => not_implemented(ref engine),
            40 => not_implemented(ref engine),
            41 => not_implemented(ref engine),
            42 => not_implemented(ref engine),
            43 => not_implemented(ref engine),
            44 => not_implemented(ref engine),
            45 => not_implemented(ref engine),
            46 => not_implemented(ref engine),
            47 => not_implemented(ref engine),
            48 => not_implemented(ref engine),
            49 => not_implemented(ref engine),
            50 => not_implemented(ref engine),
            51 => not_implemented(ref engine),
            52 => not_implemented(ref engine),
            53 => not_implemented(ref engine),
            54 => not_implemented(ref engine),
            55 => not_implemented(ref engine),
            56 => not_implemented(ref engine),
            57 => not_implemented(ref engine),
            58 => not_implemented(ref engine),
            59 => not_implemented(ref engine),
            60 => not_implemented(ref engine),
            61 => not_implemented(ref engine),
            62 => not_implemented(ref engine),
            63 => not_implemented(ref engine),
            64 => not_implemented(ref engine),
            65 => not_implemented(ref engine),
            66 => not_implemented(ref engine),
            67 => not_implemented(ref engine),
            68 => not_implemented(ref engine),
            69 => not_implemented(ref engine),
            70 => not_implemented(ref engine),
            71 => not_implemented(ref engine),
            72 => not_implemented(ref engine),
            73 => not_implemented(ref engine),
            74 => not_implemented(ref engine),
            75 => not_implemented(ref engine),
            76 => not_implemented(ref engine),
            77 => not_implemented(ref engine),
            78 => not_implemented(ref engine),
            79 => not_implemented(ref engine),
            80 => not_implemented(ref engine),
            81 => opcode_n(1, ref engine),
            82 => opcode_n(2, ref engine),
            83 => opcode_n(3, ref engine),
            84 => opcode_n(4, ref engine),
            85 => opcode_n(5, ref engine),
            86 => opcode_n(6, ref engine),
            87 => opcode_n(7, ref engine),
            88 => opcode_n(8, ref engine),
            89 => opcode_n(9, ref engine),
            90 => opcode_n(10, ref engine),
            91 => opcode_n(11, ref engine),
            92 => opcode_n(12, ref engine),
            93 => opcode_n(13, ref engine),
            94 => opcode_n(14, ref engine),
            95 => opcode_n(15, ref engine),
            96 => opcode_n(16, ref engine),
            97 => not_implemented(ref engine),
            98 => not_implemented(ref engine),
            99 => not_implemented(ref engine),
            100 => not_implemented(ref engine),
            101 => not_implemented(ref engine),
            102 => not_implemented(ref engine),
            103 => not_implemented(ref engine),
            104 => not_implemented(ref engine),
            105 => not_implemented(ref engine),
            106 => not_implemented(ref engine),
            107 => not_implemented(ref engine),
            108 => not_implemented(ref engine),
            109 => not_implemented(ref engine),
            110 => not_implemented(ref engine),
            111 => not_implemented(ref engine),
            112 => not_implemented(ref engine),
            113 => not_implemented(ref engine),
            114 => not_implemented(ref engine),
            115 => not_implemented(ref engine),
            116 => opcode_depth(ref engine),
            117 => not_implemented(ref engine),
            118 => not_implemented(ref engine),
            119 => not_implemented(ref engine),
            120 => not_implemented(ref engine),
            121 => not_implemented(ref engine),
            122 => not_implemented(ref engine),
            123 => not_implemented(ref engine),
            124 => not_implemented(ref engine),
            125 => not_implemented(ref engine),
            126 => not_implemented(ref engine),
            127 => not_implemented(ref engine),
            128 => not_implemented(ref engine),
            129 => not_implemented(ref engine),
            130 => not_implemented(ref engine),
            131 => not_implemented(ref engine),
            132 => not_implemented(ref engine),
            133 => not_implemented(ref engine),
            134 => not_implemented(ref engine),
            135 => not_implemented(ref engine),
            136 => not_implemented(ref engine),
            137 => not_implemented(ref engine),
            138 => not_implemented(ref engine),
            139 => opcode_1add(ref engine),
            140 => not_implemented(ref engine),
            141 => not_implemented(ref engine),
            142 => not_implemented(ref engine),
            143 => not_implemented(ref engine),
            144 => not_implemented(ref engine),
            145 => opcode_not(ref engine),
            146 => not_implemented(ref engine),
            147 => opcode_add(ref engine),
            148 => not_implemented(ref engine),
            149 => not_implemented(ref engine),
            150 => not_implemented(ref engine),
            151 => not_implemented(ref engine),
            152 => not_implemented(ref engine),
            153 => not_implemented(ref engine),
            154 => not_implemented(ref engine),
            155 => not_implemented(ref engine),
            156 => not_implemented(ref engine),
            157 => not_implemented(ref engine),
            158 => not_implemented(ref engine),
            159 => not_implemented(ref engine),
            160 => not_implemented(ref engine),
            161 => not_implemented(ref engine),
            162 => not_implemented(ref engine),
            163 => not_implemented(ref engine),
            164 => opcode_max(ref engine),
            _ => not_implemented(ref engine)
        }
    }

    fn opcode_false(ref engine: Engine) {
        engine.dstack.push_byte_array("");
    }

    fn opcode_n(n: i64, ref engine: Engine) {
        engine.dstack.push_int(n);
    }

    fn opcode_add(ref engine: Engine) {
        // TODO: Error handling
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();
        engine.dstack.push_int(a + b);
    }


    fn opcode_depth(ref engine: Engine) {
        let depth: i64 = engine.dstack.len().into();
        engine.dstack.push_int(depth);
    }

    fn opcode_1add(ref engine: Engine) {
        let value = engine.dstack.pop_int();
        let result = value + 1;
        engine.dstack.push_int(result);
  }
    fn opcode_not(ref engine: Engine) {
        let m = engine.dstack.pop_int();
        if m == 0 {
            engine.dstack.push_int(1);
        } else {
            engine.dstack.push_int(0);
        }
    }

    fn not_implemented(ref engine: Engine) {
        panic!("Opcode not implemented");
    }

    fn opcode_max(ref engine: Engine) {
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();
        engine.dstack.push_int(if a > b {
            a
        } else {
            b
        });
    }
}
