pub mod Opcode {
    pub const OP_0: u8 = 0;
    pub const OP_1: u8 = 81;
    pub const OP_IF: u8 = 99;
    pub const OP_NOTIF: u8 = 100;
    pub const OP_ELSE: u8 = 103;
    pub const OP_ENDIF: u8 = 104;
    pub const OP_ADD: u8 = 147;

    use shinigami::engine::{Engine, EngineTrait};
    use shinigami::stack::ScriptStackTrait;
    use shinigami::cond_stack::ConditionalStackTrait;
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
            82 => not_implemented(ref engine),
            83 => not_implemented(ref engine),
            84 => not_implemented(ref engine),
            85 => not_implemented(ref engine),
            86 => not_implemented(ref engine),
            87 => not_implemented(ref engine),
            88 => not_implemented(ref engine),
            89 => not_implemented(ref engine),
            90 => not_implemented(ref engine),
            91 => not_implemented(ref engine),
            92 => not_implemented(ref engine),
            93 => not_implemented(ref engine),
            94 => not_implemented(ref engine),
            95 => not_implemented(ref engine),
            96 => not_implemented(ref engine),
            97 => not_implemented(ref engine),
            98 => not_implemented(ref engine),
            99 => opcode_if(ref engine),
            100 => opcode_notif(ref engine),
            101 => not_implemented(ref engine),
            102 => not_implemented(ref engine),
            103 => opcode_else(ref engine),
            104 => opcode_endif(ref engine),
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
            116 => not_implemented(ref engine),
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
            139 => not_implemented(ref engine),
            140 => not_implemented(ref engine),
            141 => not_implemented(ref engine),
            142 => not_implemented(ref engine),
            143 => not_implemented(ref engine),
            144 => not_implemented(ref engine),
            145 => not_implemented(ref engine),
            146 => not_implemented(ref engine),
            147 => opcode_add(ref engine),
            _ => not_implemented(ref engine)
        }
    }

    pub fn is_branching_opcode(opcode: u8) -> bool {
        if opcode == OP_IF || opcode == OP_NOTIF || opcode == OP_ELSE || opcode == OP_ENDIF {
            return true;
        }
        return false;
    }

    fn opcode_false(ref engine: Engine) {
        engine.dstack.push_byte_array("");
    }

    fn opcode_n(n: i64, ref engine: Engine) {
        engine.dstack.push_int(n);
    }

    // TODO: MOve to cond_stack
    const op_cond_false: u8 = 0;
    const op_cond_true: u8 = 1;
    const op_cond_skip: u8 = 2;
    fn opcode_if(ref engine: Engine) {
        let mut cond = op_cond_false;
        // TODO: Pop if bool
        if engine.cond_stack.branch_executing() {
            let ok = engine.dstack.pop_bool();
            if ok {
                cond = op_cond_true;
            }
        } else {
            cond = op_cond_skip;
        }
        engine.cond_stack.push(cond);
    }

    fn opcode_notif(ref engine: Engine) {
        let mut cond = op_cond_false;
        if engine.cond_stack.branch_executing() {
            let ok = engine.dstack.pop_bool();
            if !ok {
                cond = op_cond_true;
            }
        } else {
            cond = op_cond_skip;
        }
        engine.cond_stack.push(cond);
    }

    fn opcode_else(ref engine: Engine) {
        if engine.cond_stack.len() == 0 {
            panic!("No matching if");
        }

        engine.cond_stack.swap_condition();
    }

    fn opcode_endif(ref engine: Engine) {
        if engine.cond_stack.len() == 0 {
            panic!("No matching if");
        }

        engine.cond_stack.pop();
    }

    fn opcode_add(ref engine: Engine) {
        // TODO: Error handling
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();
        engine.dstack.push_int(a + b);
    }

    fn not_implemented(ref engine: Engine) {
        panic!("Opcode not implemented");
    }
}
