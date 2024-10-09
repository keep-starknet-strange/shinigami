use crate::cond_stack::{ConditionalStack, ConditionalStackImpl};
use crate::errors::Error;
use crate::opcodes::{flow, opcodes::Opcode};
use crate::scriptflags::ScriptFlags;
use crate::stack::{ScriptStack, ScriptStackImpl};
use crate::transaction::{
    EngineTransactionInputTrait, EngineTransactionOutputTrait, EngineTransactionTrait
};
use crate::hash_cache::{HashCache, HashCacheTrait};
use crate::witness;
use shinigami_utils::byte_array::{byte_array_to_bool, byte_array_to_felt252_le};
use shinigami_utils::bytecode::hex_to_bytecode;
use shinigami_utils::hash::sha256_byte_array;

pub const MAX_STACK_SIZE: u32 = 1000;
pub const MAX_SCRIPT_SIZE: u32 = 10000;
pub const MAX_OPS_PER_SCRIPT: u32 = 201;
pub const MAX_SCRIPT_ELEMENT_SIZE: u32 = 520;

// Represents the VM that executes Bitcoin scripts
#[derive(Destruct)]
pub struct Engine<T> {
    // Execution behaviour flags
    flags: u32,
    // Is Bip16 p2sh
    bip16: bool,
    // Transaction context being executed
    pub transaction: @T,
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
    // The witness program
    pub witness_program: ByteArray,
    // The witness version
    pub witness_version: i64,
    // Primary data stack
    pub dstack: ScriptStack,
    // Alternate data stack
    pub astack: ScriptStack,
    // Tracks conditonal execution state supporting nested conditionals
    pub cond_stack: ConditionalStack,
    // Position within script of last OP_CODESEPARATOR
    pub last_code_sep: u32,
    // Count number of non-push opcodes
    pub num_ops: u32,
}

// TODO: SigCache
pub trait EngineTrait<
    I,
    O,
    T,
    +EngineTransactionInputTrait<I>,
    +EngineTransactionOutputTrait<O>,
    +EngineTransactionTrait<T, I, O>,
    +HashCacheTrait<I, O, T>
> {
    // Create a new Engine with the given script
    fn new(
        script_pubkey: @ByteArray,
        transaction: @T,
        tx_idx: u32,
        flags: u32,
        amount: i64,
        hash_cache: @HashCache<T>
    ) -> Result<Engine<T>, felt252>;
    // Executes a single step of the script, returning true if more steps are needed
    fn step(ref self: Engine<T>) -> Result<bool, felt252>;
    // Executes the entire script and returns top of stack or error if script fails
    fn execute(ref self: Engine<T>) -> Result<ByteArray, felt252>;
}

pub impl EngineImpl<
    I,
    O,
    T,
    impl IEngineTransactionInput: EngineTransactionInputTrait<I>,
    impl IEngineTransactionOutput: EngineTransactionOutputTrait<O>,
    impl IEngineTransaction: EngineTransactionTrait<
        T, I, O, IEngineTransactionInput, IEngineTransactionOutput
    >,
    +Drop<I>,
    +Drop<O>,
    +Drop<T>,
> of EngineTrait<I, O, T> {
    // Create a new Engine with the given script
    fn new(
        script_pubkey: @ByteArray,
        transaction: @T,
        tx_idx: u32,
        flags: u32,
        amount: i64,
        hash_cache: @HashCache<T>
    ) -> Result<Engine<T>, felt252> {
        let transaction_inputs = transaction.get_transaction_inputs();
        if tx_idx >= transaction_inputs.len() {
            return Result::Err('Engine::new: tx_idx invalid');
        }
        let tx_input = transaction_inputs[tx_idx];
        let script_sig = tx_input.get_signature_script();

        if script_sig.len() == 0 && script_pubkey.len() == 0 {
            return Result::Err(Error::SCRIPT_EMPTY_STACK);
        }

        let witness_len = tx_input.get_witness().len();
        let mut engine = Engine {
            flags: flags,
            bip16: false,
            transaction: transaction,
            tx_idx: tx_idx,
            amount: amount,
            scripts: array![script_sig, script_pubkey],
            script_idx: 0,
            opcode_idx: 0,
            witness_program: "",
            witness_version: 0,
            dstack: ScriptStackImpl::new(),
            astack: ScriptStackImpl::new(),
            cond_stack: ConditionalStackImpl::new(),
            last_code_sep: 0,
            num_ops: 0,
        };

        if engine.has_flag(ScriptFlags::ScriptVerifyCleanStack)
            && (!engine.has_flag(ScriptFlags::ScriptBip16)
                && !engine.has_flag(ScriptFlags::ScriptVerifyWitness)) {
            return Result::Err('Engine::new: invalid flag combo');
        }

        if engine.has_flag(ScriptFlags::ScriptVerifySigPushOnly) && !engine.is_push_only() {
            return Result::Err('Engine::new: not pushonly');
        }

        let mut bip16 = false;
        if engine.has_flag(ScriptFlags::ScriptBip16) && engine.is_script_hash() {
            if !engine.has_flag(ScriptFlags::ScriptVerifySigPushOnly) && !engine.is_push_only() {
                return Result::Err('Engine::new: p2sh not pushonly');
            }
            engine.bip16 = true;
            bip16 = true;
        }

        let mut i = 0;
        let mut valid_sizes = true;
        let scripts_len = engine.scripts.len();
        while i != scripts_len {
            let script = *(engine.scripts[i]);
            if script.len() > MAX_SCRIPT_SIZE {
                valid_sizes = false;
                break;
            }
            // TODO: Check parses?
            i += 1;
        };
        if !valid_sizes {
            return Result::Err('Engine::new: script too large');
        }

        if script_sig.len() == 0 {
            engine.script_idx = 1;
        }

        if engine.has_flag(ScriptFlags::ScriptVerifyMinimalData) {
            engine.dstack.verify_minimal_data = true;
            engine.astack.verify_minimal_data = true;
        }

        if engine.has_flag(ScriptFlags::ScriptVerifyWitness) {
            if !engine.has_flag(ScriptFlags::ScriptBip16) {
                return Result::Err('Engine::new: witness in nonp2sh');
            }

            let mut witness_program: ByteArray = "";
            if witness::is_witness_program(script_pubkey) {
                if script_sig.len() != 0 {
                    return Result::Err('Engine::new: witness w/ sig');
                }
                witness_program = script_pubkey.clone();
            } else if witness_len != 0 && bip16 {
                let sig_clone = engine.scripts[0].clone();
                if sig_clone.len() > 2 {
                    let first_elem = sig_clone[0];
                    let mut remaining = "";
                    let mut i = 1;
                    // TODO: Optimize
                    let sig_len = sig_clone.len();
                    while i != sig_len {
                        remaining.append_byte(sig_clone[i]);
                        i += 1;
                    };
                    if Opcode::is_canonical_push(first_elem, @remaining)
                        && witness::is_witness_program(@remaining) {
                        witness_program = remaining;
                    } else {
                        return Result::Err('Engine::new: sig malleability');
                    }
                } else {
                    return Result::Err('Engine::new: sig malleability');
                }
            }

            if witness_program.len() != 0 {
                let (witness_version, witness_program) = witness::parse_witness_program(
                    @witness_program
                )?;
                engine.witness_version = witness_version;
                engine.witness_program = witness_program;
            } else if engine.witness_program.len() == 0 && witness_len != 0 {
                return Result::Err('Engine::new: witness + no prog');
            }
        }

        return Result::Ok(engine);
    }

    fn step(ref self: Engine<T>) -> Result<bool, felt252> {
        // TODO: Make it match engine.execute after recent changes
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
            if self.dstack.verify_minimal_data {
                self.astack.verify_minimal_data = true;
            }
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
            if Opcode::is_data_opcode(opcode) {
                let opcode_32: u32 = opcode.into();
                self.opcode_idx += opcode_32 + 1;
                return Result::Ok(true);
            } else if Opcode::is_push_opcode(opcode) {
                let res = self.skip_push_data(opcode);
                if res.is_err() {
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

        if self.dstack.verify_minimal_data
            && self.cond_stack.branch_executing()
            && opcode >= 0
            && opcode <= Opcode::OP_PUSHDATA4 {
            self.check_minimal_data_push(opcode)?;
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
            if self.dstack.verify_minimal_data {
                self.astack.verify_minimal_data = true;
            }
            self.opcode_idx = 0;
            self.last_code_sep = 0;
            self.script_idx += 1;
        }
        return Result::Ok(true);
    }

    // Executes the entire script and returns top of stack or error if script fails
    fn execute(ref self: Engine<T>) -> Result<ByteArray, felt252> {
        let mut err = '';
        // TODO: Optimize with != instead of < and check for bounds errors within the loop
        while self.script_idx < self.scripts.len() {
            let script: @ByteArray = *self.scripts[self.script_idx];
            let script_len = script.len();
            while self.opcode_idx < script_len {
                let opcode = script[self.opcode_idx];

                // Check if the opcode is always illegal (reserved).
                let illegal_opcode = Opcode::is_opcode_always_illegal(opcode, ref self);
                if illegal_opcode.is_err() {
                    err = illegal_opcode.unwrap_err();
                    break;
                }

                if opcode > Opcode::OP_16 {
                    self.num_ops += 1;
                    if self.num_ops > MAX_OPS_PER_SCRIPT {
                        err = Error::SCRIPT_TOO_MANY_OPERATIONS;
                        break;
                    }
                } else if Opcode::is_push_opcode(opcode) {
                    let res = self.push_data_len(opcode, self.opcode_idx);
                    if res.is_err() {
                        err = res.unwrap_err();
                        break;
                    }
                    if res.unwrap() > MAX_SCRIPT_ELEMENT_SIZE {
                        err = Error::SCRIPT_PUSH_SIZE;
                        break;
                    }
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

                if self.dstack.verify_minimal_data
                    && self.cond_stack.branch_executing()
                    && opcode >= 0
                    && opcode <= Opcode::OP_PUSHDATA4 {
                    let res = self.check_minimal_data_push(opcode);
                    if res.is_err() {
                        err = res.unwrap_err();
                        break;
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
            if self.dstack.verify_minimal_data {
                self.astack.verify_minimal_data = true;
            }
            self.num_ops = 0;
            self.opcode_idx = 0;
            if (self.script_idx == 1 && self.witness_program.len() != 0)
                || (self.script_idx == 2 && self.witness_program.len() != 0 && self.bip16) {
                self.script_idx += 1;
                let tx_input = self.transaction.get_transaction_inputs()[self.tx_idx];
                let witness = tx_input.get_witness();
                let res = self.verify_witness(witness);
                if res.is_err() {
                    err = res.unwrap_err();
                    break;
                }
            } else {
                self.script_idx += 1;
            }
            self.last_code_sep = 0;
            // TODO: other things
        };
        if err != '' {
            return Result::Err(err);
        }

        return self.check_error_condition();
    }
}

// TODO: Remove functions that can be locally used only
pub trait EngineInternalTrait<
    I,
    O,
    T,
    +EngineTransactionInputTrait<I>,
    +EngineTransactionOutputTrait<O>,
    +EngineTransactionTrait<T, I, O>,
    +HashCacheTrait<I, O, T>,
> {
    // Pulls the next len bytes from the script and advances the program counter
    fn pull_data(ref self: Engine<T>, len: usize) -> Result<ByteArray, felt252>;
    // Return true if the script engine instance has the specified flag set.
    fn has_flag(ref self: Engine<T>, flag: ScriptFlags) -> bool;
    // Pop bool enforcing minimal if
    fn pop_if_bool(ref self: Engine<T>) -> Result<bool, felt252>;
    // Return true if the witness program was active
    fn is_witness_active(ref self: Engine<T>, version: i64) -> bool;
    // Return the script since last OP_CODESEPARATOR
    fn sub_script(ref self: Engine<T>) -> ByteArray;
    // Returns true if the script sig is push only
    fn is_push_only(ref self: Engine<T>) -> bool;
    // Returns true if the script is a script hash
    fn is_script_hash(ref self: Engine<T>) -> bool;
    // Returns the length of the next push data opcode
    fn push_data_len(ref self: Engine<T>, opcode: u8, idx: u32) -> Result<usize, felt252>;
    // Pulls the next len bytes from the script at the given index
    fn pull_data_at(ref self: Engine<T>, idx: usize, len: usize) -> Result<ByteArray, felt252>;
    // Returns the data stack
    fn get_dstack(ref self: Engine<T>) -> Span<ByteArray>;
    // Returns the alt stack
    fn get_astack(ref self: Engine<T>) -> Span<ByteArray>;
    // Ensure the stack size is within limits
    fn check_stack_size(ref self: Engine<T>) -> Result<(), felt252>;
    // Skip the next opcode if it is a push opcode in unexecuted conditional branch
    fn skip_push_data(ref self: Engine<T>, opcode: u8) -> Result<(), felt252>;
    // Check if the next opcode is a minimal push
    fn check_minimal_data_push(ref self: Engine<T>, opcode: u8) -> Result<(), felt252>;
    // Validate witness program using witness input
    fn verify_witness(ref self: Engine<T>, witness: Span<ByteArray>) -> Result<(), felt252>;
    // Check if the script has failed and return an error if it has
    fn check_error_condition(ref self: Engine<T>) -> Result<ByteArray, felt252>;
    // Prints the engine state as json
    fn json(ref self: Engine<T>);
}

pub impl EngineInternalImpl<
    I,
    O,
    T,
    impl IEngineTransactionInput: EngineTransactionInputTrait<I>,
    impl IEngineTransactionOutput: EngineTransactionOutputTrait<O>,
    impl IEngineTransaction: EngineTransactionTrait<
        T, I, O, IEngineTransactionInput, IEngineTransactionOutput
    >,
    +Drop<T>,
> of EngineInternalTrait<I, O, T> {
    fn pull_data(ref self: Engine<T>, len: usize) -> Result<ByteArray, felt252> {
        let mut data = "";
        let mut i = self.opcode_idx + 1;
        let mut end = i + len;
        let script = *(self.scripts[self.script_idx]);
        if end > script.len() {
            return Result::Err(Error::SCRIPT_INVALID);
        }
        while i != end {
            data.append_byte(script[i]);
            i += 1;
        };
        self.opcode_idx = end - 1;
        return Result::Ok(data);
    }

    fn has_flag(ref self: Engine<T>, flag: ScriptFlags) -> bool {
        self.flags & flag.into() == flag.into()
    }

    fn pop_if_bool(ref self: Engine<T>) -> Result<bool, felt252> {
        if !self.is_witness_active(0) || !self.has_flag(ScriptFlags::ScriptVerifyMinimalIf) {
            return self.dstack.pop_bool();
        }
        let top = self.dstack.pop_byte_array()?;
        if top.len() > 1 {
            return Result::Err(Error::MINIMAL_IF);
        }

        if top.len() == 1 && top[0] != 0x01 {
            return Result::Err(Error::MINIMAL_IF);
        }
        return Result::Ok(byte_array_to_bool(@top));
    }

    fn is_witness_active(ref self: Engine<T>, version: i64) -> bool {
        return self.witness_version == version && self.witness_program.len() != 0;
    }

    fn sub_script(ref self: Engine<T>) -> ByteArray {
        let script = *(self.scripts[self.script_idx]);
        if self.last_code_sep == 0 {
            return script.clone();
        }

        let mut sub_script = "";
        let mut i = self.last_code_sep;
        let script_len = script.len();
        while i != script_len {
            sub_script.append_byte(script[i]);
            i += 1;
        };
        return sub_script;
    }

    fn is_push_only(ref self: Engine<T>) -> bool {
        let script: @ByteArray = *(self.scripts[0]);
        let mut i = 0;
        let mut is_push_only = true;
        let script_len = script.len();
        while i != script_len {
            // TODO: Error handling if i outside bounds
            let opcode = script[i];
            if opcode > Opcode::OP_16 {
                is_push_only = false;
                break;
            }

            // TODO: Error handling
            let data_len = Opcode::data_len(i, script).unwrap();
            i += data_len + 1;
        };
        return is_push_only;
    }

    fn is_script_hash(ref self: Engine<T>) -> bool {
        let script_pubkey = *(self.scripts[1]);
        if script_pubkey.len() == 23
            && script_pubkey[0] == Opcode::OP_HASH160
            && script_pubkey[1] == Opcode::OP_DATA_20
            && script_pubkey[22] == Opcode::OP_EQUAL {
            return true;
        }
        return false;
    }

    fn push_data_len(ref self: Engine<T>, opcode: u8, idx: u32) -> Result<usize, felt252> {
        if opcode == Opcode::OP_PUSHDATA1 {
            return Result::Ok(
                byte_array_to_felt252_le(@self.pull_data_at(idx + 1, 1)?).try_into().unwrap()
            );
        } else if opcode == Opcode::OP_PUSHDATA2 {
            return Result::Ok(
                byte_array_to_felt252_le(@self.pull_data_at(idx + 1, 2)?).try_into().unwrap()
            );
        } else if opcode == Opcode::OP_PUSHDATA4 {
            return Result::Ok(
                byte_array_to_felt252_le(@self.pull_data_at(idx + 1, 4)?).try_into().unwrap()
            );
        }
        return Result::Err('Engine::push_data_len: invalid');
    }

    fn pull_data_at(ref self: Engine<T>, idx: usize, len: usize) -> Result<ByteArray, felt252> {
        let mut data = "";
        let mut i = idx;
        let mut end = i + len;
        let script = *(self.scripts[self.script_idx]);
        if end > script.len() {
            return Result::Err(Error::SCRIPT_INVALID);
        }
        while i != end {
            data.append_byte(script[i]);
            i += 1;
        };
        return Result::Ok(data);
    }

    fn get_dstack(ref self: Engine<T>) -> Span<ByteArray> {
        return self.dstack.stack_to_span();
    }

    fn get_astack(ref self: Engine<T>) -> Span<ByteArray> {
        return self.astack.stack_to_span();
    }

    fn skip_push_data(ref self: Engine<T>, opcode: u8) -> Result<(), felt252> {
        if opcode == Opcode::OP_PUSHDATA1 {
            self.opcode_idx += self.push_data_len(opcode, self.opcode_idx)? + 2;
        } else if opcode == Opcode::OP_PUSHDATA2 {
            self.opcode_idx += self.push_data_len(opcode, self.opcode_idx)? + 3;
        } else if opcode == Opcode::OP_PUSHDATA4 {
            self.opcode_idx += self.push_data_len(opcode, self.opcode_idx)? + 5;
        } else {
            return Result::Err(Error::SCRIPT_INVALID);
        }
        Result::Ok(())
    }

    fn check_minimal_data_push(ref self: Engine<T>, opcode: u8) -> Result<(), felt252> {
        if opcode == Opcode::OP_0 {
            return Result::Ok(());
        }
        let script = *(self.scripts[self.script_idx]);
        if opcode == Opcode::OP_DATA_1 {
            let value: u8 = script.at(self.opcode_idx + 1).unwrap();
            if value >= 1 && value <= 16 {
                // Should be OP_1 to OP_16
                return Result::Err(Error::MINIMAL_DATA);
            }
            if value == 0x81 {
                // Should be OP_1NEGATE
                return Result::Err(Error::MINIMAL_DATA);
            }
        }

        // TODO: More checks?
        if !Opcode::is_push_opcode(opcode) {
            return Result::Ok(());
        }

        let len = self.push_data_len(opcode, self.opcode_idx)?;
        if len <= 75 {
            // Should have used OP_DATA_X
            return Result::Err(Error::MINIMAL_DATA);
        } else if len <= 255 && opcode != Opcode::OP_PUSHDATA1 {
            // Should have used OP_PUSHDATA1
            return Result::Err(Error::MINIMAL_DATA);
        } else if len <= 65535 && opcode != Opcode::OP_PUSHDATA2 {
            // Should have used OP_PUSHDATA2
            return Result::Err(Error::MINIMAL_DATA);
        }
        return Result::Ok(());
    }

    fn check_stack_size(ref self: Engine<T>) -> Result<(), felt252> {
        if self.dstack.len() + self.astack.len() > MAX_STACK_SIZE {
            return Result::Err(Error::STACK_OVERFLOW);
        }
        return Result::Ok(());
    }

    fn verify_witness(ref self: Engine<T>, witness: Span<ByteArray>) -> Result<(), felt252> {
        if self.is_witness_active(0) {
            // Verify a base witness (segwit) program, ie P2WSH || P2WPKH
            if self.witness_program.len() == 20 {
                // P2WPKH
                if witness.len() != 2 {
                    return Result::Err(Error::WITNESS_PROGRAM_INVALID);
                }
                // OP_DUP OP_HASH160 OP_DATA_20 <pkhash> OP_EQUALVERIFY OP_CHECKSIG
                let mut pk_script = hex_to_bytecode(@"0x76a914");
                pk_script.append(@self.witness_program);
                pk_script.append(@hex_to_bytecode(@"0x88ac"));

                self.scripts.append(@pk_script);
                self.dstack.set_stack(witness, 0, witness.len());
            } else if self.witness_program.len() == 32 {
                // P2WSH
                if witness.len() == 0 {
                    return Result::Err(Error::WITNESS_PROGRAM_INVALID);
                }
                let witness_script = witness[witness.len() - 1];
                if witness_script.len() > MAX_SCRIPT_SIZE {
                    return Result::Err(Error::SCRIPT_TOO_LARGE);
                }
                let witness_hash = sha256_byte_array(witness_script);
                if witness_hash != self.witness_program {
                    return Result::Err(Error::WITNESS_PROGRAM_INVALID);
                }

                self.scripts.append(witness_script);
                self.dstack.set_stack(witness, 0, witness.len() - 1);
            } else {
                return Result::Err(Error::WITNESS_PROGRAM_INVALID);
            }
            // Sanity checks
            let mut err = '';
            for w in self
                .dstack
                .stack_to_span() {
                    if w.len() > MAX_SCRIPT_ELEMENT_SIZE {
                        err = Error::SCRIPT_PUSH_SIZE;
                        break;
                    }
                };
            if err != '' {
                return Result::Err(err);
            }
        } else if self.is_witness_active(1) {
            // Verify a taproot witness program
            // TODO: Implement
            return Result::Err('Taproot not implemented');
        } else if self.has_flag(ScriptFlags::ScriptVerifyDiscourageUpgradeableWitnessProgram) {
            return Result::Err(Error::DISCOURAGE_UPGRADABLE_WITNESS_PROGRAM);
        } else {
            self.witness_program = "";
        }

        return Result::Ok(());
    }

    fn check_error_condition(ref self: Engine<T>) -> Result<ByteArray, felt252> {
        // Check if execution is actually done
        if self.script_idx < self.scripts.len() {
            return Result::Err(Error::SCRIPT_UNFINISHED);
        }

        // Check if witness stack is clean
        if self.is_witness_active(0) && self.dstack.len() != 1 { // TODO: Hardcoded 0
            return Result::Err(Error::SCRIPT_NON_CLEAN_STACK);
        }
        if self.has_flag(ScriptFlags::ScriptVerifyCleanStack) && self.dstack.len() != 1 {
            return Result::Err(Error::SCRIPT_NON_CLEAN_STACK);
        }

        // Check if stack has at least one item
        if self.dstack.len() < 1 {
            return Result::Err(Error::SCRIPT_EMPTY_STACK);
        } else {
            // Check the final stack value
            let is_ok = self.dstack.peek_bool(0)?;
            if is_ok {
                return Result::Ok(self.dstack.peek_byte_array(0)?);
            } else {
                return Result::Err(Error::SCRIPT_FAILED);
            }
        }
    }

    fn json(ref self: Engine<T>) {
        self.dstack.json();
    }
}
