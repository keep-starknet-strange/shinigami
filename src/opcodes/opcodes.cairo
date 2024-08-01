pub mod Opcode {
    pub const OP_0: u8 = 0;
    pub const OP_1NEGATE: u8 = 79;
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
    pub const OP_NOP: u8 = 97;
    pub const OP_IF: u8 = 99;
    pub const OP_NOTIF: u8 = 100;
    pub const OP_ELSE: u8 = 103;
    pub const OP_ENDIF: u8 = 104;
    pub const OP_FROMALTSTACK: u8 = 108;
    pub const OP_2DROP: u8 = 109;
    pub const OP_2DUP: u8 = 110;
    pub const OP_3DUP: u8 = 111;
    pub const OP_DEPTH: u8 = 116;
    pub const OP_DROP: u8 = 117;
    pub const OP_DUP: u8 = 118;
    pub const OP_EQUAL: u8 = 135;
    pub const OP_1ADD: u8 = 139;
    pub const OP_1SUB: u8 = 140;
    pub const OP_NEGATE: u8 = 143;
    pub const OP_ABS: u8 = 144;
    pub const OP_NOT: u8 = 145;
    pub const OP_ADD: u8 = 147;
    pub const OP_SUB: u8 = 148;
    pub const OP_BOOLAND: u8 = 154;
    pub const OP_NUMNOTEQUAL: u8 = 158;
    pub const OP_LESSTHAN: u8 = 159;
    pub const OP_GREATERTHAN: u8 = 160;
    pub const OP_LESSTHANOREQUAL: u8 = 161;
    pub const OP_GREATERTHANOREQUAL: u8 = 162;
    pub const OP_MIN: u8 = 163;
    pub const OP_MAX: u8 = 164;
    pub const OP_WITHIN: u8 = 165;
    pub const OP_RESERVED1: u8 = 137;
    pub const OP_RESERVED2: u8 = 138;


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
            79 => opcode_1negate(ref engine),
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
            97 => opcode_nop(),
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
            108 => opcode_fromaltstack(ref engine),
            109 => opcode_2drop(ref engine),
            110 => opcode_2dup(ref engine),
            111 => opcode_3dup(ref engine),
            112 => not_implemented(ref engine),
            113 => not_implemented(ref engine),
            114 => not_implemented(ref engine),
            115 => not_implemented(ref engine),
            116 => opcode_depth(ref engine),
            117 => opcode_drop(ref engine),
            118 => opcode_dup(ref engine),
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
            135 => opcode_equal(ref engine),
            136 => not_implemented(ref engine),
            137 => opcode_reserved1(ref engine),
            138 => not_implemented(ref engine),
            139 => opcode_1add(ref engine),
            140 => opcode_1sub(ref engine),
            141 => not_implemented(ref engine),
            142 => not_implemented(ref engine),
            143 => opcode_negate(ref engine),
            144 => opcode_abs(ref engine),
            145 => opcode_not(ref engine),
            146 => not_implemented(ref engine),
            147 => opcode_add(ref engine),
            148 => opcode_sub(ref engine),
            149 => not_implemented(ref engine),
            150 => not_implemented(ref engine),
            151 => not_implemented(ref engine),
            152 => not_implemented(ref engine),
            153 => not_implemented(ref engine),
            154 => opcode_bool_and(ref engine),
            155 => not_implemented(ref engine),
            156 => not_implemented(ref engine),
            157 => not_implemented(ref engine),
            158 => opcode_numnotequal(ref engine),
            159 => opcode_lessthan(ref engine),
            160 => opcode_greater_than(ref engine),
            161 => opcode_less_than_or_equal(ref engine),
            162 => opcode_greater_than_or_equal(ref engine),
            163 => opcode_min(ref engine),
            164 => opcode_max(ref engine),
            165 => opcode_within(ref engine),
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

    fn opcode_negate(ref engine: Engine) {
        let a = engine.dstack.pop_int();
        engine.dstack.push_int(-a);
    }

    fn opcode_abs(ref engine: Engine) {
        let value = engine.dstack.pop_int();
        let abs_value = if value < 0 {
            -value
        } else {
            value
        };
        engine.dstack.push_int(abs_value);
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

    fn opcode_nop() { // NOP do nothing
    }

    fn opcode_add(ref engine: Engine) {
        // TODO: Error handling
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();
        engine.dstack.push_int(a + b);
    }

    fn opcode_less_than_or_equal(ref engine: Engine) {
        let v0 = engine.dstack.pop_int();
        let v1 = engine.dstack.pop_int();

        if v1 <= v0 {
            engine.dstack.push_int(1);
        } else {
            engine.dstack.push_int(0);
        }
    }

    fn opcode_sub(ref engine: Engine) {
        // TODO: Error handling
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();
        engine.dstack.push_int(b - a);
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

    fn opcode_min(ref engine: Engine) {
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();

        engine.dstack.push_int(if a < b {
            a
        } else {
            b
        });
    }

    fn opcode_1sub(ref engine: Engine) {
        let a = engine.dstack.pop_int();
        engine.dstack.push_int(a - 1);
    }

    fn not_implemented(ref engine: Engine) {
        panic!("Opcode not implemented");
    }

    fn opcode_greater_than(ref engine: Engine) {
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();
        engine.dstack.push_int(if b > a {
            1
        } else {
            0
        });
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

    fn opcode_within(ref engine: Engine) {
        let max = engine.dstack.pop_int();
        let min = engine.dstack.pop_int();
        let value = engine.dstack.pop_int();
        engine.dstack.push_int(if value >= min && value < max {
            1
        } else {
            0
        });
    }

    fn opcode_numnotequal(ref engine: Engine) {
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();
        engine.dstack.push_int(if a != b {
            1
        } else {
            0
        });
    }

    fn opcode_bool_and(ref engine: Engine) {
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();
        engine.dstack.push_int(if a != 0 && b != 0 {
            1
        } else {
            0
        });
    }

    fn opcode_lessthan(ref engine: Engine) {
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();
        engine.dstack.push_int(if b < a {
            1
        } else {
            0
        });
    }

    fn opcode_greater_than_or_equal(ref engine: Engine) {
        let v0 = engine.dstack.pop_int();
        let v1 = engine.dstack.pop_int();

        if v1 >= v0 {
            engine.dstack.push_int(1);
        } else {
            engine.dstack.push_int(0);
        }
    }

    fn opcode_fromaltstack(ref engine: Engine) {
        //TODO: Error handling
        let a = engine.astack.pop_byte_array();
        engine.dstack.push_byte_array(a);
    }

    fn opcode_equal(ref engine: Engine) {
        let a = engine.dstack.pop_byte_array();
        let b = engine.dstack.pop_byte_array();
        engine.dstack.push_int(if a == b {
            1
        } else {
            0
        });
    }

    fn opcode_dup(ref engine: Engine) {
        engine.dstack.dup_n(1);
    }

    fn opcode_2dup(ref engine: Engine) {
        engine.dstack.dup_n(2);
    }

    fn opcode_3dup(ref engine: Engine) {
        engine.dstack.dup_n(3);
    }

    fn opcode_2drop(ref engine: Engine) {
        if engine.dstack.len() < 2 {
            panic!("Stack underflow");
        }
        engine.dstack.pop_byte_array();
        engine.dstack.pop_byte_array();
    }

    fn opcode_drop(ref engine: Engine) {
        if engine.dstack.len() == 0 {
            panic!("Stack underflow");
        }
        engine.dstack.pop_byte_array();
    }

    fn opcode_1negate(ref engine: Engine) {
        engine.dstack.push_int(-1);
    }

    fn opcode_reserved1(ref engine: Engine) {
        panic!("attempt to execute reserved opcode 1");
    }
}
