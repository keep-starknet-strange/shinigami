use shinigami::opcodes::Opcode;
use shinigami::utils;

// Compiler that takes a Bitcoin Script program and compiles it into a bytecode
#[derive(Destruct)]
pub struct Compiler {
    // Dict containing opcode names to their bytecode representation
    opcodes: Felt252Dict<u8>
}

pub trait CompilerTrait {
    // Create a compiler, initializing the opcode dict
    fn new() -> Compiler;
    // Adds an opcode "OP_XXX" to the opcodes dict under: "OP_XXX" and "XXX"
    fn add_opcode(ref self: Compiler, name: felt252, opcode: u8);
    // Compiles a program like "OP_1 OP_2 OP_ADD" into a bytecode run by the Engine.
    fn compile(self: Compiler, script: ByteArray) -> ByteArray;
}

pub impl CompilerTraitImpl of CompilerTrait {
    fn new() -> Compiler {
        let mut compiler = Compiler { opcodes: Default::default() };
        // Add the opcodes to the dict
        compiler.add_opcode('OP_0', Opcode::OP_0);
        compiler.add_opcode('OP_FALSE', Opcode::OP_0);
        compiler.add_opcode('OP_DATA_1', Opcode::OP_DATA_1);
        compiler.add_opcode('OP_DATA_2', Opcode::OP_DATA_2);
        compiler.add_opcode('OP_DATA_3', Opcode::OP_DATA_3);
        compiler.add_opcode('OP_DATA_4', Opcode::OP_DATA_4);
        compiler.add_opcode('OP_DATA_5', Opcode::OP_DATA_5);
        compiler.add_opcode('OP_DATA_6', Opcode::OP_DATA_6);
        compiler.add_opcode('OP_DATA_7', Opcode::OP_DATA_7);
        compiler.add_opcode('OP_DATA_8', Opcode::OP_DATA_8);
        compiler.add_opcode('OP_DATA_9', Opcode::OP_DATA_9);
        compiler.add_opcode('OP_DATA_10', Opcode::OP_DATA_10);
        compiler.add_opcode('OP_DATA_11', Opcode::OP_DATA_11);
        compiler.add_opcode('OP_DATA_12', Opcode::OP_DATA_12);
        compiler.add_opcode('OP_DATA_13', Opcode::OP_DATA_13);
        compiler.add_opcode('OP_DATA_14', Opcode::OP_DATA_14);
        compiler.add_opcode('OP_DATA_15', Opcode::OP_DATA_15);
        compiler.add_opcode('OP_DATA_16', Opcode::OP_DATA_16);
        compiler.add_opcode('OP_DATA_17', Opcode::OP_DATA_17);
        compiler.add_opcode('OP_DATA_18', Opcode::OP_DATA_18);
        compiler.add_opcode('OP_DATA_19', Opcode::OP_DATA_19);
        compiler.add_opcode('OP_DATA_20', Opcode::OP_DATA_20);
        compiler.add_opcode('OP_DATA_21', Opcode::OP_DATA_21);
        compiler.add_opcode('OP_DATA_22', Opcode::OP_DATA_22);
        compiler.add_opcode('OP_DATA_23', Opcode::OP_DATA_23);
        compiler.add_opcode('OP_DATA_24', Opcode::OP_DATA_24);
        compiler.add_opcode('OP_DATA_25', Opcode::OP_DATA_25);
        compiler.add_opcode('OP_DATA_26', Opcode::OP_DATA_26);
        compiler.add_opcode('OP_DATA_27', Opcode::OP_DATA_27);
        compiler.add_opcode('OP_DATA_28', Opcode::OP_DATA_28);
        compiler.add_opcode('OP_DATA_29', Opcode::OP_DATA_29);
        compiler.add_opcode('OP_DATA_30', Opcode::OP_DATA_30);
        compiler.add_opcode('OP_DATA_31', Opcode::OP_DATA_31);
        compiler.add_opcode('OP_DATA_32', Opcode::OP_DATA_32);
        compiler.add_opcode('OP_DATA_33', Opcode::OP_DATA_33);
        compiler.add_opcode('OP_DATA_34', Opcode::OP_DATA_34);
        compiler.add_opcode('OP_DATA_35', Opcode::OP_DATA_35);
        compiler.add_opcode('OP_DATA_36', Opcode::OP_DATA_36);
        compiler.add_opcode('OP_DATA_37', Opcode::OP_DATA_37);
        compiler.add_opcode('OP_DATA_38', Opcode::OP_DATA_38);
        compiler.add_opcode('OP_DATA_39', Opcode::OP_DATA_39);
        compiler.add_opcode('OP_DATA_40', Opcode::OP_DATA_40);
        compiler.add_opcode('OP_DATA_41', Opcode::OP_DATA_41);
        compiler.add_opcode('OP_DATA_42', Opcode::OP_DATA_42);
        compiler.add_opcode('OP_DATA_43', Opcode::OP_DATA_43);
        compiler.add_opcode('OP_DATA_44', Opcode::OP_DATA_44);
        compiler.add_opcode('OP_DATA_45', Opcode::OP_DATA_45);
        compiler.add_opcode('OP_DATA_46', Opcode::OP_DATA_46);
        compiler.add_opcode('OP_DATA_47', Opcode::OP_DATA_47);
        compiler.add_opcode('OP_DATA_48', Opcode::OP_DATA_48);
        compiler.add_opcode('OP_DATA_49', Opcode::OP_DATA_49);
        compiler.add_opcode('OP_DATA_50', Opcode::OP_DATA_50);
        compiler.add_opcode('OP_DATA_51', Opcode::OP_DATA_51);
        compiler.add_opcode('OP_DATA_52', Opcode::OP_DATA_52);
        compiler.add_opcode('OP_DATA_53', Opcode::OP_DATA_53);
        compiler.add_opcode('OP_DATA_54', Opcode::OP_DATA_54);
        compiler.add_opcode('OP_DATA_55', Opcode::OP_DATA_55);
        compiler.add_opcode('OP_DATA_56', Opcode::OP_DATA_56);
        compiler.add_opcode('OP_DATA_57', Opcode::OP_DATA_57);
        compiler.add_opcode('OP_DATA_58', Opcode::OP_DATA_58);
        compiler.add_opcode('OP_DATA_59', Opcode::OP_DATA_59);
        compiler.add_opcode('OP_DATA_60', Opcode::OP_DATA_60);
        compiler.add_opcode('OP_DATA_61', Opcode::OP_DATA_61);
        compiler.add_opcode('OP_DATA_62', Opcode::OP_DATA_62);
        compiler.add_opcode('OP_DATA_63', Opcode::OP_DATA_63);
        compiler.add_opcode('OP_DATA_64', Opcode::OP_DATA_64);
        compiler.add_opcode('OP_DATA_65', Opcode::OP_DATA_65);
        compiler.add_opcode('OP_DATA_66', Opcode::OP_DATA_66);
        compiler.add_opcode('OP_DATA_67', Opcode::OP_DATA_67);
        compiler.add_opcode('OP_DATA_68', Opcode::OP_DATA_68);
        compiler.add_opcode('OP_DATA_69', Opcode::OP_DATA_69);
        compiler.add_opcode('OP_DATA_70', Opcode::OP_DATA_70);
        compiler.add_opcode('OP_DATA_71', Opcode::OP_DATA_71);
        compiler.add_opcode('OP_DATA_72', Opcode::OP_DATA_72);
        compiler.add_opcode('OP_DATA_73', Opcode::OP_DATA_73);
        compiler.add_opcode('OP_DATA_74', Opcode::OP_DATA_74);
        compiler.add_opcode('OP_DATA_75', Opcode::OP_DATA_75);
        compiler.add_opcode('OP_PUSHDATA1', Opcode::OP_PUSHDATA1);
        compiler.add_opcode('OP_1NEGATE', Opcode::OP_1NEGATE);
        compiler.add_opcode('OP_1', Opcode::OP_1);
        compiler.add_opcode('OP_TRUE', Opcode::OP_TRUE);
        compiler.add_opcode('OP_2', Opcode::OP_2);
        compiler.add_opcode('OP_3', Opcode::OP_3);
        compiler.add_opcode('OP_4', Opcode::OP_4);
        compiler.add_opcode('OP_5', Opcode::OP_5);
        compiler.add_opcode('OP_6', Opcode::OP_6);
        compiler.add_opcode('OP_7', Opcode::OP_7);
        compiler.add_opcode('OP_8', Opcode::OP_8);
        compiler.add_opcode('OP_9', Opcode::OP_9);
        compiler.add_opcode('OP_10', Opcode::OP_10);
        compiler.add_opcode('OP_11', Opcode::OP_11);
        compiler.add_opcode('OP_12', Opcode::OP_12);
        compiler.add_opcode('OP_13', Opcode::OP_13);
        compiler.add_opcode('OP_14', Opcode::OP_14);
        compiler.add_opcode('OP_15', Opcode::OP_15);
        compiler.add_opcode('OP_16', Opcode::OP_16);
        compiler.add_opcode('OP_NOP', Opcode::OP_NOP);
        compiler.add_opcode('OP_IF', Opcode::OP_IF);
        compiler.add_opcode('OP_NOTIF', Opcode::OP_NOTIF);
        compiler.add_opcode('OP_ELSE', Opcode::OP_ELSE);
        compiler.add_opcode('OP_ENDIF', Opcode::OP_ENDIF);
        compiler.add_opcode('OP_VERIFY', Opcode::OP_VERIFY);
        compiler.add_opcode('OP_RETURN', Opcode::OP_RETURN);
        compiler.add_opcode('OP_TOALTSTACK', Opcode::OP_TOALTSTACK);
        compiler.add_opcode('OP_FROMALTSTACK', Opcode::OP_FROMALTSTACK);
        compiler.add_opcode('OP_2DROP', Opcode::OP_2DROP);
        compiler.add_opcode('OP_2DUP', Opcode::OP_2DUP);
        compiler.add_opcode('OP_3DUP', Opcode::OP_3DUP);
        compiler.add_opcode('OP_DROP', Opcode::OP_DROP);
        compiler.add_opcode('OP_DUP', Opcode::OP_DUP);
        compiler.add_opcode('OP_NIP', Opcode::OP_NIP);
        compiler.add_opcode('OP_EQUAL', Opcode::OP_EQUAL);
        compiler.add_opcode('OP_EQUALVERIFY', Opcode::OP_EQUALVERIFY);
        compiler.add_opcode('OP_2ROT', Opcode::OP_2ROT);
        compiler.add_opcode('OP_2SWAP', Opcode::OP_2SWAP);
        compiler.add_opcode('OP_IFDUP', Opcode::OP_IFDUP);
        compiler.add_opcode('OP_DEPTH', Opcode::OP_DEPTH);
        compiler.add_opcode('OP_SIZE', Opcode::OP_SIZE);
        compiler.add_opcode('OP_ROT', Opcode::OP_ROT);
        compiler.add_opcode('OP_SWAP', Opcode::OP_SWAP);
        compiler.add_opcode('OP_1ADD', Opcode::OP_1ADD);
        compiler.add_opcode('OP_1SUB', Opcode::OP_1SUB);
        compiler.add_opcode('OP_NEGATE', Opcode::OP_NEGATE);
        compiler.add_opcode('OP_ABS', Opcode::OP_ABS);
        compiler.add_opcode('OP_NOT', Opcode::OP_NOT);
        compiler.add_opcode('OP_0NOTEQUAL', Opcode::OP_0NOTEQUAL);
        compiler.add_opcode('OP_ADD', Opcode::OP_ADD);
        compiler.add_opcode('OP_SUB', Opcode::OP_SUB);
        compiler.add_opcode('OP_BOOLAND', Opcode::OP_BOOLAND);
        compiler.add_opcode('OP_NUMEQUAL', Opcode::OP_NUMEQUAL);
        compiler.add_opcode('OP_NUMEQUALVERIFY', Opcode::OP_NUMEQUALVERIFY);
        compiler.add_opcode('OP_NUMNOTEQUAL', Opcode::OP_NUMNOTEQUAL);
        compiler.add_opcode('OP_LESSTHAN', Opcode::OP_LESSTHAN);
        compiler.add_opcode('OP_GREATERTHAN', Opcode::OP_GREATERTHAN);
        compiler.add_opcode('OP_LESSTHANOREQUAL', Opcode::OP_LESSTHANOREQUAL);
        compiler.add_opcode('OP_GREATERTHANOREQUAL', Opcode::OP_GREATERTHANOREQUAL);
        compiler.add_opcode('OP_MIN', Opcode::OP_MIN);
        compiler.add_opcode('OP_MAX', Opcode::OP_MAX);
        compiler.add_opcode('OP_WITHIN', Opcode::OP_WITHIN);
        compiler.add_opcode('OP_RESERVED', Opcode::OP_RESERVED);
        compiler.add_opcode('OP_RESERVED1', Opcode::OP_RESERVED1);
        compiler.add_opcode('OP_RESERVED2', Opcode::OP_RESERVED2);
        compiler.add_opcode('OP_VER', Opcode::OP_VER);
        compiler.add_opcode('OP_TUCK', Opcode::OP_TUCK);
        compiler.add_opcode('OP_BOOLOR', Opcode::OP_BOOLOR);
        compiler.add_opcode('OP_CAT', Opcode::OP_CAT);
        compiler.add_opcode('OP_SUBSTR', Opcode::OP_SUBSTR);
        compiler.add_opcode('OP_LEFT', Opcode::OP_LEFT);
        compiler.add_opcode('OP_RIGHT', Opcode::OP_RIGHT);
        compiler.add_opcode('OP_INVERT', Opcode::OP_INVERT);
        compiler.add_opcode('OP_AND', Opcode::OP_AND);
        compiler.add_opcode('OP_OR', Opcode::OP_OR);
        compiler.add_opcode('OP_XOR', Opcode::OP_XOR);
        compiler.add_opcode('OP_2MUL', Opcode::OP_2MUL);
        compiler.add_opcode('OP_2DIV', Opcode::OP_2DIV);
        compiler.add_opcode('OP_MUL', Opcode::OP_MUL);
        compiler.add_opcode('OP_DIV', Opcode::OP_DIV);
        compiler.add_opcode('OP_MOD', Opcode::OP_MOD);
        compiler.add_opcode('OP_LSHIFT', Opcode::OP_LSHIFT);
        compiler.add_opcode('OP_RSHIFT', Opcode::OP_RSHIFT);

        compiler
    }

    fn add_opcode(ref self: Compiler, name: felt252, opcode: u8) {
        // Insert opcode formatted like OP_XXX
        self.opcodes.insert(name, opcode);

        // Remove OP_ prefix and insert opcode XXX
        let nameu256 = name.into();
        let mut name_mask: u256 = 1;
        while name_mask < nameu256 {
            name_mask = name_mask * 256; // Shift left 1 byte
        };
        name_mask = name_mask / 16_777_216; // Shift right 3 bytes
        self.opcodes.insert((nameu256 % name_mask).try_into().unwrap(), opcode);
    }

    // TODO: Why self is mutable?
    fn compile(mut self: Compiler, script: ByteArray) -> ByteArray {
        let mut bytecode = "";
        let seperator = ' ';

        // Split the script into opcodes / data
        let mut split_script: Array<ByteArray> = array![];
        let mut current = "";
        let mut i = 0;
        let script_len = script.len();
        while i < script_len {
            let char = script[i].into();
            if char == seperator {
                if current == "" {
                    i += 1;
                    continue;
                }
                split_script.append(current);
                current = "";
            } else {
                current.append_byte(char);
            }
            i += 1;
        };
        // Handle the last opcode
        if current != "" {
            split_script.append(current);
        }

        // Compile the script into bytecode
        let mut i = 0;
        let script_len = split_script.len();
        while i < script_len {
            let script_item = split_script.at(i);
            if utils::is_hex(script_item) {
                ByteArrayTrait::append(ref bytecode, @utils::hex_to_bytecode(script_item));
            } else {
                // TODO: Check opcode exists
                bytecode.append_byte(self.opcodes.get(utils::byte_array_to_felt252(script_item)));
            }
            i += 1;
        };

        bytecode
    }
}
