use shinigami::stack::{ScriptStack, ScriptStackImpl};
use shinigami::cond_stack::{ConditionalStack, ConditionalStackImpl};
use shinigami::opcodes::opcodes::Opcode::{execute, is_branching_opcode};

// Represents the VM that executes Bitcoin scripts
#[derive(Destruct)]
pub struct Engine {
    // The script to execute
    script: @ByteArray,
    // Program counter within the current script
    opcode_idx: usize,
    // Primary data stack
    pub dstack: ScriptStack,
    // Alternate data stack
    pub astack: ScriptStack,
    // Tracks conditonal execution state supporting nested conditionals
    pub cond_stack: ConditionalStack,
    // TODO
// ...
}

pub trait EngineTrait {
    // Create a new Engine with the given script
    fn new(script: ByteArray) -> Engine;
    fn get_dstack(ref self: Engine) -> Span<ByteArray>;
    fn get_astack(ref self: Engine) -> Span<ByteArray>;
    // Executes the next instruction in the script
    fn step(ref self: Engine) -> bool; // TODO return type w/ error handling
    // Executes the entire script and returns top of stack or error if script fails
    fn execute(ref self: Engine) -> Result<ByteArray, felt252>;
}

pub impl EngineTraitImpl of EngineTrait {
    fn new(script: ByteArray) -> Engine {
        Engine {
            script: @script,
            opcode_idx: 0,
            dstack: ScriptStackImpl::new(),
            astack: ScriptStackImpl::new(),
            cond_stack: ConditionalStackImpl::new(),
        }
    }

    fn get_dstack(ref self: Engine) -> Span<ByteArray> {
        return self.dstack.stack_to_span();
    }

    fn get_astack(ref self: Engine) -> Span<ByteArray> {
        return self.astack.stack_to_span();
    }

    fn step(ref self: Engine) -> bool {
        if self.opcode_idx >= self.script.len() {
            return false;
        }

        if !self.cond_stack.branch_executing()
            && !is_branching_opcode(self.script[self.opcode_idx]) {
            self.opcode_idx += 1;
            return true;
        }

        let opcode = self.script[self.opcode_idx];
        execute(opcode, ref self);
        self.opcode_idx += 1;
        return true;
    }

    fn execute(ref self: Engine) -> Result<ByteArray, felt252> {
        while self.opcode_idx < self.script.len() {
            if !self.cond_stack.branch_executing()
                && !is_branching_opcode(self.script[self.opcode_idx]) {
                self.opcode_idx += 1;
                continue;
            }
            let opcode = self.script[self.opcode_idx];
            execute(opcode, ref self);
            self.opcode_idx += 1;
            // TODO: remove debug
        // self.dstack.print();
        // println!("==================");
        };

        // TODO: CheckErrorCondition
        if self.dstack.len() < 1 {
            return Result::Err('Stack empty at end of script');
        } else if self.dstack.len() > 1 {
            return Result::Err('Stack must contain item');
        } else {
            // TODO: pop bool
            let top_stack = self.dstack.pop_byte_array();
            let ret_val = top_stack.clone();
            let mut is_ok = false;
            let mut i = 0;
            while i < top_stack.len() {
                if top_stack[i] != 0 {
                    is_ok = true;
                    break;
                }
                i += 1;
            };
            if is_ok {
                return Result::Ok(ret_val);
            } else {
                return Result::Err('Script failed');
            }
        }
    }
}
