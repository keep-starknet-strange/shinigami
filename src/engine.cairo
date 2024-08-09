use shinigami::stack::{ScriptStack, ScriptStackImpl};
use shinigami::cond_stack::{ConditionalStack, ConditionalStackImpl};
use shinigami::opcodes::opcodes::Opcode;
use shinigami::opcodes::flow;
use shinigami::errors::Error;

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
    // Pulls the next len bytes from the script and advances the program counter
    fn pull_data(ref self: Engine, len: usize) -> ByteArray;
    fn get_dstack(ref self: Engine) -> Span<ByteArray>;
    fn get_astack(ref self: Engine) -> Span<ByteArray>;
    // Executes the next instruction in the script
    fn step(ref self: Engine) -> Result<bool, felt252>;
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

    // TODO: Test multiple of these in a row
    // TODO: Pull data version for numbers
    fn pull_data(ref self: Engine, len: usize) -> ByteArray {
        // TODO: optimize
        // TODO: check bounds with error handling
        let mut data = "";
        let mut i = self.opcode_idx + 1;
        let mut end = i + len;
        if end > self.script.len() {
            end = self.script.len();
        }
        while i < end {
            data.append_byte(self.script[i]);
            i += 1;
        };
        self.opcode_idx = end - 1;
        return data;
    }

    fn get_dstack(ref self: Engine) -> Span<ByteArray> {
        return self.dstack.stack_to_span();
    }

    fn get_astack(ref self: Engine) -> Span<ByteArray> {
        return self.astack.stack_to_span();
    }

    fn step(ref self: Engine) -> Result<bool, felt252> {
        if self.opcode_idx >= self.script.len() {
            return Result::Ok(false);
        }

        if !self.cond_stack.branch_executing()
            && !flow::is_branching_opcode(self.script[self.opcode_idx]) {
            self.opcode_idx += 1;
            return Result::Ok(true);
        }

        let opcode = self.script[self.opcode_idx];
        Opcode::execute(opcode, ref self)?;
        self.opcode_idx += 1;
        return Result::Ok(true);
    }

    fn execute(ref self: Engine) -> Result<ByteArray, felt252> {
        let mut err = '';
        while self.opcode_idx < self.script.len() {
            if !self.cond_stack.branch_executing()
                && !flow::is_branching_opcode(self.script[self.opcode_idx]) {
                self.opcode_idx += 1;
                continue;
            }
            let opcode = self.script[self.opcode_idx];
            let res = Opcode::execute(opcode, ref self);
            if res.is_err() {
                err = res.unwrap_err();
                break;
            }
            self.opcode_idx += 1;
        };
        if err != '' {
            return Result::Err(err);
        }

        // TODO: CheckErrorCondition
        if self.dstack.len() < 1 {
            return Result::Err(Error::SCRIPT_EMPTY_STACK);
        } else {
            // TODO: pop bool?
            let top_stack = self.dstack.peek_byte_array(0)?;
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
                return Result::Err(Error::SCRIPT_FAILED);
            }
        }
    }
}
