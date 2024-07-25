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
        opcodes.insert('OP_NEGATE', Opcode::OP_NEGATE);
        opcodes.insert('OP_ADD', Opcode::OP_ADD);
        opcodes.insert('OP_GREATERTHAN', Opcode::OP_GREATERTHAN);
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
