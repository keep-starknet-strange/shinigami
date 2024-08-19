use shinigami::stack::{ScriptStack, ScriptStackImpl};
use shinigami::cond_stack::{ConditionalStack, ConditionalStackImpl};
use shinigami::opcodes::opcodes::Opcode;
use shinigami::opcodes::flow;
use shinigami::errors::Error;
use shinigami::scriptflags::ScriptFlags;
use shinigami::transaction::{Transaction, TransactionImpl};

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
    // Execution behaviour flags
	flags: u32,

    pub transaction: Transaction,
    
    pub index: u32,

    pub last_code_sep: u32,

    pub is_codeseparator: bool,
    
// TODO
// ...
}

pub trait EngineTrait {
    // Create a new Engine with the given script
    fn new(script: ByteArray, transaction: Option<Transaction>, index: Option<u32>) -> Engine;
    // Pulls the next len bytes from the script and advances the program counter
    fn pull_data(ref self: Engine, len: usize) -> ByteArray;
    fn get_dstack(ref self: Engine) -> Span<ByteArray>;
    fn get_astack(ref self: Engine) -> Span<ByteArray>;
    // Executes the next instruction in the script
    fn step(ref self: Engine) -> Result<bool, felt252>;
    // Executes the entire script and returns top of stack or error if script fails
    fn execute(ref self: Engine) -> Result<ByteArray, felt252>;
    // Add the specified flag to the script engine instance.
	fn add_flag(ref self: Engine, flag: ScriptFlags);
	// Return true if the script engine instance has the specified flag set.
	fn has_flag(ref self: Engine, flag: ScriptFlags) -> bool;

    fn subscript(ref self: Engine) -> @ByteArray;

    fn has_codeseparator(script: @ByteArray) -> bool;
}

pub impl EngineTraitImpl of EngineTrait {
    fn new(script: ByteArray, transaction: Option<Transaction>, index: Option<u32>) -> Engine {
        Engine {
            script: @script,
            opcode_idx: 0,
            dstack: ScriptStackImpl::new(),
            astack: ScriptStackImpl::new(),
            cond_stack: ConditionalStackImpl::new(),
            flags: 0,
            transaction: TransactionImpl::get_transaction(transaction),
            index: TransactionImpl::get_index(index),
            last_code_sep: 0,
            is_codeseparator: Self::has_codeseparator(@script)
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
                let non_ex_opcode = self.script[self.opcode_idx];
                let res = Opcode::is_opcode_disabled(non_ex_opcode, ref self);
                if res.is_err() {
                    err = res.unwrap_err();
                    break;
                }
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

    fn add_flag(ref self: Engine, flag: ScriptFlags){
		self.flags = self.flags | flag.into();
	}

	fn has_flag(ref self: Engine, flag: ScriptFlags) -> bool {
		self.flags & flag.into() == flag.into()
	}

    fn subscript(ref self: Engine) -> @ByteArray {
        if self.is_codeseparator == false  || self.last_code_sep == 0 {
            return self.script;
        }

        let mut sub_script : ByteArray = "";
        let mut i : usize = 0;
        let mut code_sep_index = 0;
        let script_len = self.script.len();

        while i < script_len {
            let opcode = self.script[i];
            if opcode == 171 {
                code_sep_index += 1;
                continue;
            }

            if code_sep_index >= self.last_code_sep {
                sub_script.append_byte(opcode);
            } 
            i+=1;
        };
        @sub_script
    }

    fn has_codeseparator(script: @ByteArray) -> bool {
        let mut i: usize = 0;
        let mut found: bool = false;
        let len: usize = script.len();

        while i < len {
            if script[i] == 171 {
                found = true;
                break;
            }
            i+=1;
        };

        found
    }
}
