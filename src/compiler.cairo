use shinigami::opcodes::Opcode;

// Compiler that takes a Bitcoin Script program and compiles it into a bytecode
#[derive(Destruct)]
pub struct Compiler {
    // Dict containing opcode names to their bytecode representation
    opcodes: Felt252Dict<u8>
}

pub trait CompilerTrait {
    // Create a compiler, initializing the opcode dict
    fn new() -> Compiler;
    // Compiles a program like "OP_1 OP_2 OP_ADD" into a bytecode run by the Engine.
    fn compile(self: Compiler, script: ByteArray) -> ByteArray;
}

pub impl CompilerTraitImpl of CompilerTrait {
    fn new() -> Compiler {
        let mut opcodes = Default::default();
        // Add the opcodes to the dict
        opcodes.insert('OP_0', Opcode::OP_0);
        opcodes.insert('OP_1', Opcode::OP_1);
        opcodes.insert('OP_TRUE', Opcode::OP_TRUE);
        opcodes.insert('OP_2', Opcode::OP_2);
        opcodes.insert('OP_3', Opcode::OP_3);
        opcodes.insert('OP_4', Opcode::OP_4);
        opcodes.insert('OP_5', Opcode::OP_5);
        opcodes.insert('OP_6', Opcode::OP_6);
        opcodes.insert('OP_7', Opcode::OP_7);
        opcodes.insert('OP_8', Opcode::OP_8);
        opcodes.insert('OP_9', Opcode::OP_9);
        opcodes.insert('OP_10', Opcode::OP_10);
        opcodes.insert('OP_11', Opcode::OP_11);
        opcodes.insert('OP_12', Opcode::OP_12);
        opcodes.insert('OP_13', Opcode::OP_13);
        opcodes.insert('OP_14', Opcode::OP_14);
        opcodes.insert('OP_15', Opcode::OP_15);
        opcodes.insert('OP_16', Opcode::OP_16);
        opcodes.insert('OP_IF', Opcode::OP_IF);
        opcodes.insert('OP_NOTIF', Opcode::OP_NOTIF);
        opcodes.insert('OP_ELSE', Opcode::OP_ELSE);
        opcodes.insert('OP_ENDIF', Opcode::OP_ENDIF);
        opcodes.insert('OP_FROMALTSTACK', Opcode::OP_FROMALTSTACK);
        opcodes.insert('OP_DEPTH', Opcode::OP_DEPTH);
        opcodes.insert('OP_1ADD', Opcode::OP_1ADD);
        opcodes.insert('OP_1SUB', Opcode::OP_1SUB);
        opcodes.insert('OP_NEGATE', Opcode::OP_NEGATE);
        opcodes.insert('OP_NOT', Opcode::OP_NOT);
        opcodes.insert('OP_ADD', Opcode::OP_ADD);
        opcodes.insert('OP_SUB', Opcode::OP_SUB);
        opcodes.insert('OP_NUMNOTEQUAL', Opcode::OP_NUMNOTEQUAL);
        opcodes.insert('OP_LESSTHAN', Opcode::OP_LESSTHAN);
        opcodes.insert('OP_GREATERTHAN', Opcode::OP_GREATERTHAN);
        opcodes.insert('OP_LESSTHANOREQUAL', Opcode::OP_LESSTHANOREQUAL);
        opcodes.insert('OP_MIN', Opcode::OP_MIN);
        opcodes.insert('OP_MAX', Opcode::OP_MAX);
        opcodes.insert('OP_WITHIN', Opcode::OP_WITHIN);

        Compiler { opcodes }
    }

    // TODO: Why self is mutable?
    fn compile(mut self: Compiler, script: ByteArray) -> ByteArray {
        let mut bytecode = "";
        let seperator = ' ';
        let byte_shift = 256;
        let max_word_size = 31;
        let mut current: felt252 = '';
        let mut i = 0;
        let mut word_len = 0;
        let mut current_word: felt252 = '';
        while i < script
            .len() {
                let char = script[i].into();
                if char == seperator {
                    let opcode = self.opcodes.get(current);
                    current_word = current_word * byte_shift + opcode.into();
                    word_len += 1;
                    if word_len >= max_word_size {
                        // Add the current word to the bytecode representation
                        bytecode.append_word(current_word, max_word_size);
                        word_len = 0;
                    }
                    current = '';
                } else {
                    // Add the char to the bytecode representation
                    current = current * byte_shift + char;
                }
                i += 1;
            };
        // Handle the last opcode
        if current != '' {
            let opcode = self.opcodes.get(current);
            current_word = current_word * byte_shift + opcode.into();
            word_len += 1;
            if word_len >= max_word_size {
                // Add the current word to the bytecode representation
                bytecode.append_word(current_word, max_word_size);
                word_len = 0;
            }
        }
        if word_len > 0 {
            // Add the current word to the bytecode representation
            bytecode.append_word(current_word, word_len);
        }

        bytecode
    }
}
