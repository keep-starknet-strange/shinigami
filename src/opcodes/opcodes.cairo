pub mod Opcode {
    pub const OP_0: u8 = 0;
    pub const OP_DATA_1: u8 = 1;
    pub const OP_DATA_2: u8 = 2;
    pub const OP_DATA_3: u8 = 3;
    pub const OP_DATA_4: u8 = 4;
    pub const OP_DATA_5: u8 = 5;
    pub const OP_DATA_6: u8 = 6;
    pub const OP_PUSHDATA1: u8 = 76;
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
    pub const OP_2SWAP: u8 = 114;
    pub const OP_DEPTH: u8 = 116;
    pub const OP_DROP: u8 = 117;
    pub const OP_DUP: u8 = 118;
    pub const OP_SWAP: u8 = 124;
    pub const OP_TUCK: u8 = 125;
    pub const OP_SIZE: u8 = 130;
    pub const OP_EQUAL: u8 = 135;
    pub const OP_EQUALVERIFY: u8 = 136;
    pub const OP_RESERVED1: u8 = 137;
    pub const OP_RESERVED2: u8 = 138;
    pub const OP_1ADD: u8 = 139;
    pub const OP_1SUB: u8 = 140;
    pub const OP_NEGATE: u8 = 143;
    pub const OP_ABS: u8 = 144;
    pub const OP_NOT: u8 = 145;
    pub const OP_ADD: u8 = 147;
    pub const OP_SUB: u8 = 148;
    pub const OP_BOOLAND: u8 = 154;
    pub const OP_BOOLOR: u8 = 155;
    pub const OP_NUMEQUAL: u8 = 156;
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
            80 => utils::not_implemented(ref engine),
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
            113 => utils::not_implemented(ref engine),
            114 => stack::opcode_2swap(ref engine),
            115 => utils::not_implemented(ref engine),
            116 => stack::opcode_depth(ref engine),
            117 => stack::opcode_drop(ref engine),
            118 => stack::opcode_dup(ref engine),
            119 => utils::not_implemented(ref engine),
            120 => utils::not_implemented(ref engine),
            121 => utils::not_implemented(ref engine),
            122 => utils::not_implemented(ref engine),
            123 => utils::not_implemented(ref engine),
            124 => stack::opcode_swap(ref engine),
            125 => stack::opcode_tuck(ref engine),
            126 => utils::not_implemented(ref engine),
            127 => utils::not_implemented(ref engine),
            128 => utils::not_implemented(ref engine),
            129 => utils::not_implemented(ref engine),
            130 => splice::opcode_size(ref engine),
            131 => utils::not_implemented(ref engine),
            132 => utils::not_implemented(ref engine),
            133 => utils::not_implemented(ref engine),
            134 => utils::not_implemented(ref engine),
            135 => bitwise::opcode_equal(ref engine),
            136 => bitwise::opcode_equal_verify(ref engine),
            137 => utils::opcode_reserved("reserved1", ref engine),
            138 => utils::opcode_reserved("reserved2", ref engine),
            139 => arithmetic::opcode_1add(ref engine),
            140 => arithmetic::opcode_1sub(ref engine),
            141 => utils::not_implemented(ref engine),
            142 => utils::not_implemented(ref engine),
            143 => arithmetic::opcode_negate(ref engine),
            144 => arithmetic::opcode_abs(ref engine),
            145 => arithmetic::opcode_not(ref engine),
            146 => utils::not_implemented(ref engine),
            147 => arithmetic::opcode_add(ref engine),
            148 => arithmetic::opcode_sub(ref engine),
            149 => utils::not_implemented(ref engine),
            150 => utils::not_implemented(ref engine),
            151 => utils::not_implemented(ref engine),
            152 => utils::not_implemented(ref engine),
            153 => utils::not_implemented(ref engine),
            154 => arithmetic::opcode_bool_and(ref engine),
            155 => arithmetic::opcode_bool_or(ref engine),
            156 => arithmetic::opcode_numequal(ref engine),
            157 => utils::not_implemented(ref engine),
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

    fn opcode_verify(ref engine: Engine) {
        if engine.dstack.len() < 1 {
            panic!("Invalid stack operation")
        }

        let verified = engine.dstack.pop_bool();
        if !verified {
            panic!("Verify failed")
        }
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
            engine.dstack.push_bool(true);
        } else {
            engine.dstack.push_bool(false);
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

    fn opcode_size(ref engine: Engine) {
        let size = engine.dstack.peek_byte_array(0).len().into();
        engine.dstack.push_int(size);
    }

    fn opcode_swap(ref engine: Engine) {
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();
        engine.dstack.push_int(a);
        engine.dstack.push_int(b);
    }

    fn opcode_2swap(ref engine: Engine) {
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();
        let c = engine.dstack.pop_int();
        let d = engine.dstack.pop_int();
        engine.dstack.push_int(b);
        engine.dstack.push_int(a);
        engine.dstack.push_int(d);
        engine.dstack.push_int(c);
    }

    fn opcode_1add(ref engine: Engine) {
        let value = engine.dstack.pop_int();
        let result = value + 1;
        engine.dstack.push_int(result);
    }

    fn opcode_not(ref engine: Engine) {
        let m = engine.dstack.pop_int();
        if m == 0 {
            engine.dstack.push_bool(true);
        } else {
            engine.dstack.push_bool(false);
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
        engine.dstack.push_bool(if b > a {
            true
        } else {
            false
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
        engine.dstack.push_bool(if value >= min && value < max {
            true
        } else {
            false
        });
    }

    fn opcode_numequal(ref engine: Engine) {
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();
        engine.dstack.push_bool(if a == b {
            true
        } else {
            false
        });
    }

    fn opcode_numnotequal(ref engine: Engine) {
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();
        engine.dstack.push_bool(if a != b {
            true
        } else {
            false
        });
    }

    fn opcode_bool_and(ref engine: Engine) {
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();
        engine.dstack.push_bool(if a != 0 && b != 0 {
            true
        } else {
            false
        });
    }

    fn opcode_lessthan(ref engine: Engine) {
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();
        engine.dstack.push_bool(if b < a {
            true
        } else {
            false
        });
    }

    fn opcode_greater_than_or_equal(ref engine: Engine) {
        let v0 = engine.dstack.pop_int();
        let v1 = engine.dstack.pop_int();

        if v1 >= v0 {
            engine.dstack.push_bool(true);
        } else {
            engine.dstack.push_bool(false);
        }
    }

    fn opcode_toaltstack(ref engine: Engine) {
        if engine.dstack.len() == 0 {
            panic!("Stack underflow");
        }
        let value = engine.dstack.pop_byte_array();
        engine.astack.push_byte_array(value);
    }

    fn opcode_fromaltstack(ref engine: Engine) {
        //TODO: Error handling
        let a = engine.astack.pop_byte_array();
        engine.dstack.push_byte_array(a);
    }

    fn opcode_equal(ref engine: Engine) {
        let a = engine.dstack.pop_byte_array();
        let b = engine.dstack.pop_byte_array();
        engine.dstack.push_bool(if a == b {
            true
        } else {
            false
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

    fn opcode_reserved2(ref engine: Engine) {
        panic!("attempt to execute reserved opcode 2");
    }

    fn opcode_ver(ref engine: Engine) {
        panic!("attempt to execute reserved opcode ver");
    }

    fn opcode_tuck(ref engine: Engine) {
        engine.dstack.tuck();
    }

    fn opcode_bool_or(ref engine: Engine) {
        let a = engine.dstack.pop_int();
        let b = engine.dstack.pop_int();

        engine.dstack.push_bool(if a != 0 || b != 0 {
            true
        } else {
            false
        });
    }
}
