use crate::cond_stack::{ConditionalStack, ConditionalStackImpl};
use crate::errors::Error;
use crate::opcodes::{flow, opcodes::Opcode};
use crate::scriptflags::ScriptFlags;
use crate::stack::{ScriptStack, ScriptStackImpl};
use crate::transaction::Transaction;
use crate::utils;

// Represents the VM that executes Bitcoin scripts
#[derive(Destruct)]
pub struct Engine {
    // Execution behaviour flags
    flags: u32,
    // Transaction context being executed
    pub transaction: Transaction,
    // Input index within the tx containing signature script being executed
    pub tx_idx: u32,
    // Amount of the input being spent
    pub amount: i64,
    // The script to execute
    scripts: Array<@ByteArray>,
    // Index of the current script being executed
    script_idx: usize,
    // Program counter within the current script
    pub opcode_idx: usize,
    // Primary data stack
    pub dstack: ScriptStack,
    // Alternate data stack
    pub astack: ScriptStack,
    // Tracks conditonal execution state supporting nested conditionals
    pub cond_stack: ConditionalStack,
    // Position within script of last OP_CODESEPARATOR
    pub last_code_sep: u32,
}

pub trait EngineTrait {
    // Create a new Engine with the given script
    fn new(
        script_pubkey: @ByteArray, transaction: Transaction, tx_idx: u32, flags: u32, amount: i64
    ) -> Engine;
    // Pulls the next len bytes from the script and advances the program counter
    fn pull_data(ref self: Engine, len: usize) -> Result<ByteArray, felt252>;
    fn get_dstack(ref self: Engine) -> Span<ByteArray>;
    fn get_astack(ref self: Engine) -> Span<ByteArray>;
    // Skip the next opcode if it is a push opcode in unexecuted conditional branch
    fn skip_push_data(ref self: Engine, opcode: u8) -> Result<(), felt252>;
    // Executes the next instruction in the script
    fn step(ref self: Engine) -> Result<bool, felt252>;
    // Executes the entire script and returns top of stack or error if script fails
    fn execute(ref self: Engine) -> Result<ByteArray, felt252>;
    // Return true if the script engine instance has the specified flag set.
    fn has_flag(ref self: Engine, flag: ScriptFlags) -> bool;
    // Return the script since last OP_CODESEPARATOR
    fn sub_script(ref self: Engine) -> ByteArray;
    // Ensure the stack size is within limits
    fn check_stack_size(ref self: Engine) -> Result<(), felt252>;
    // Print engine data as a JSON object
    fn json(ref self: Engine);
}

pub const MAX_STACK_SIZE: u32 = 1000;

pub impl EngineImpl of EngineTrait {
    fn new(
        script_pubkey: @ByteArray, transaction: Transaction, tx_idx: u32, flags: u32, amount: i64
    ) -> Engine {
        let mut script_sig: @ByteArray = @"";
        if tx_idx < transaction.transaction_inputs.len() {
            script_sig = transaction.transaction_inputs[tx_idx].signature_script;
        }
        Engine {
            flags: flags,
            transaction: transaction,
            tx_idx: tx_idx,
            amount: amount,
            scripts: array![script_sig, script_pubkey],
            script_idx: 0,
            opcode_idx: 0,
            dstack: ScriptStackImpl::new(),
            astack: ScriptStackImpl::new(),
            cond_stack: ConditionalStackImpl::new(),
            last_code_sep: 0,
        }
    }

    fn pull_data(ref self: Engine, len: usize) -> Result<ByteArray, felt252> {
        let mut data = "";
        let mut i = self.opcode_idx + 1;
        let mut end = i + len;
        let script = *(self.scripts[self.script_idx]);
        if end > script.len() {
            return Result::Err(Error::SCRIPT_INVALID);
        }
        while i < end {
            data.append_byte(script[i]);
            i += 1;
        };
        self.opcode_idx = end - 1;
        return Result::Ok(data);
    }

    fn get_dstack(ref self: Engine) -> Span<ByteArray> {
        return self.dstack.stack_to_span();
    }

    fn get_astack(ref self: Engine) -> Span<ByteArray> {
        return self.astack.stack_to_span();
    }

    fn skip_push_data(ref self: Engine, opcode: u8) -> Result<(), felt252> {
      if opcode == Opcode::OP_PUSHDATA1 {
          let data_len: usize = utils::byte_array_to_felt252_le(@self.pull_data(1)?)
              .try_into()
              .unwrap();
          self.opcode_idx += data_len + 1;
      } else if opcode == Opcode::OP_PUSHDATA2 {
          let data_len: usize = utils::byte_array_to_felt252_le(@self.pull_data(2)?)
              .try_into()
              .unwrap();
          self.opcode_idx += data_len + 1;
      } else if opcode == Opcode::OP_PUSHDATA4 {
          let data_len: usize = utils::byte_array_to_felt252_le(@self.pull_data(4)?)
              .try_into()
              .unwrap();
          self.opcode_idx += data_len + 1;
      }
      Result::Ok(())
    }

    fn step(ref self: Engine) -> Result<bool, felt252> {
        if self.script_idx >= self.scripts.len() {
            return Result::Ok(false);
        }
        let script = *(self.scripts[self.script_idx]);
        if self.opcode_idx >= script.len() {
            // Empty script skip
            if self.cond_stack.len() > 0 {
                return Result::Err(Error::SCRIPT_UNBALANCED_CONDITIONAL_STACK);
            }
            self.astack = ScriptStackImpl::new();
            self.opcode_idx = 0;
            self.last_code_sep = 0;
            self.script_idx += 1;
            return self.step();
        }
        let opcode = script[self.opcode_idx];

        let illegal_opcode = Opcode::is_opcode_always_illegal(opcode, ref self);
        if illegal_opcode.is_err() {
            return Result::Err(illegal_opcode.unwrap_err());
        }

        if !self.cond_stack.branch_executing() && !flow::is_branching_opcode(opcode) {
            let mut err = '';
            if Opcode::is_data_opcode(opcode) {
                let opcode_32: u32 = opcode.into();
                self.opcode_idx += opcode_32 + 1;
                return Result::Ok(true);
            } else if Opcode::is_push_opcode(opcode) {
                let res = self.skip_push_data(opcode);
                if res.is_err() {
                    err = res.unwrap_err();
                    return Result::Err(res.unwrap_err());
                }
                return Result::Ok(true);
            } else {
                let res = Opcode::is_opcode_disabled(opcode, ref self);
                if res.is_err() {
                    return Result::Err(res.unwrap_err());
                }
                self.opcode_idx += 1;
                return Result::Ok(true);
            }
        }

        let res = Opcode::execute(opcode, ref self);
        if res.is_err() {
            return Result::Err(res.unwrap_err());
        }
        self.check_stack_size()?;
        self.opcode_idx += 1;
        if self.opcode_idx >= script.len() {
            if self.cond_stack.len() > 0 {
                return Result::Err(Error::SCRIPT_UNBALANCED_CONDITIONAL_STACK);
            }
            self.astack = ScriptStackImpl::new();
            self.opcode_idx = 0;
            self.last_code_sep = 0;
            self.script_idx += 1;
        }
        return Result::Ok(true);
    }

    fn execute(ref self: Engine) -> Result<ByteArray, felt252> {
        let mut err = '';
        while self.script_idx < self.scripts.len() {
            let script: @ByteArray = *self.scripts[self.script_idx];
            while self.opcode_idx < script.len() {
                let opcode = script[self.opcode_idx];

                // Check if the opcode is always illegal (reserved).
                let illegal_opcode = Opcode::is_opcode_always_illegal(opcode, ref self);
                if illegal_opcode.is_err() {
                    err = illegal_opcode.unwrap_err();
                    break;
                }

                if !self.cond_stack.branch_executing() && !flow::is_branching_opcode(opcode) {
                    if Opcode::is_data_opcode(opcode) {
                        let opcode_32: u32 = opcode.into();
                        self.opcode_idx += opcode_32 + 1;
                        continue;
                    } else if Opcode::is_push_opcode(opcode) {
                        let res = self.skip_push_data(opcode);
                        if res.is_err() {
                            err = res.unwrap_err();
                            break;
                        }
                        continue;
                    } else {
                        let res = Opcode::is_opcode_disabled(opcode, ref self);
                        if res.is_err() {
                            err = res.unwrap_err();
                            break;
                        }
                        self.opcode_idx += 1;
                        continue;
                    }
                }
                let res = Opcode::execute(opcode, ref self);
                if res.is_err() {
                    err = res.unwrap_err();
                    break;
                }
                let res = self.check_stack_size();
                if res.is_err() {
                    err = res.unwrap_err();
                    break;
                }
                self.opcode_idx += 1;
            };
            if err != '' {
                break;
            }
            if self.cond_stack.len() > 0 {
                err = Error::SCRIPT_UNBALANCED_CONDITIONAL_STACK;
                break;
            }
            self.astack = ScriptStackImpl::new();
            self.opcode_idx = 0;
            self.last_code_sep = 0;
            self.script_idx += 1;
            // TODO: other things
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

    fn has_flag(ref self: Engine, flag: ScriptFlags) -> bool {
        self.flags & flag.into() == flag.into()
    }

    fn sub_script(ref self: Engine) -> ByteArray {
        let script = *(self.scripts[self.script_idx]);
        if self.last_code_sep == 0 {
            return script.clone();
        }

        let mut sub_script = "";
        let mut i = self.last_code_sep;
        while i < script.len() {
            sub_script.append_byte(script[i]);
            i += 1;
        };
        return sub_script;
    }

    fn check_stack_size(ref self: Engine) -> Result<(), felt252> {
        if self.dstack.len() + self.astack.len() > MAX_STACK_SIZE {
            return Result::Err(Error::SCRIPT_STACK_SIZE_EXCEEDED);
        }
        return Result::Ok(());
    }

    fn json(ref self: Engine) {
        self.dstack.json();
    }
}
