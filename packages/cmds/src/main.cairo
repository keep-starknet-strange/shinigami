use compiler::compiler::CompilerImpl;
use engine::engine::EngineInternalImpl;
use engine::transaction::{TransactionImpl, TransactionTrait};
use engine::utxo::UTXO;
use engine::validate;
use engine::scriptflags;
use engine::witness;
use utils::byte_array::felt252_to_byte_array;
use utils::bytecode::hex_to_bytecode;

#[derive(Clone, Drop)]
struct InputData {
    ScriptSig: ByteArray,
    ScriptPubKey: ByteArray
}

#[derive(Clone, Drop)]
struct InputDataWithFlags {
    ScriptSig: ByteArray,
    ScriptPubKey: ByteArray,
    Flags: ByteArray
}

#[derive(Clone, Drop)]
struct InputDataWithWitness {
    ScriptSig: ByteArray,
    ScriptPubKey: ByteArray,
    Flags: ByteArray,
    Witness: ByteArray
}

fn run_with_flags(input: InputDataWithFlags) -> Result<(), felt252> {
    println!(
        "Running Bitcoin Script with ScriptSig: '{}', ScriptPubKey: '{}' and Flags: '{}'",
        input.ScriptSig,
        input.ScriptPubKey,
        input.Flags
    );
    let mut compiler = CompilerImpl::new();
    let script_pubkey = compiler.compile(input.ScriptPubKey);
    let compiler = CompilerImpl::new();
    let script_sig = compiler.compile(input.ScriptSig);
    let tx = TransactionImpl::new_signed(script_sig);
    let flags = scriptflags::parse_flags(input.Flags);
    let mut engine = EngineInternalImpl::new(@script_pubkey, tx, 0, flags, 0)?;
    let _ = engine.execute()?;
    Result::Ok(())
}

fn run_with_witness(input: InputDataWithWitness) -> Result<(), felt252> {
    println!(
        "Running Bitcoin Script with ScriptSig: '{}', ScriptPubKey: '{}', Flags: '{}' and Witness: '{}'",
        input.ScriptSig,
        input.ScriptPubKey,
        input.Flags,
        input.Witness
    );
    let mut compiler = CompilerImpl::new();
    let script_pubkey = compiler.compile(input.ScriptPubKey);
    let compiler = CompilerImpl::new();
    let script_sig = compiler.compile(input.ScriptSig);
    let witness = witness::parse_witness_input(input.Witness);
    let tx = TransactionImpl::new_signed_witness(script_sig, witness);
    let flags = scriptflags::parse_flags(input.Flags);
    let mut engine = EngineInternalImpl::new(@script_pubkey, tx, 0, flags, 0)?;
    let _ = engine.execute()?;
    Result::Ok(())
}

fn run(input: InputData) -> Result<(), felt252> {
    println!(
        "Running Bitcoin Script with ScriptSig: '{}' and ScriptPubKey: '{}'",
        input.ScriptSig,
        input.ScriptPubKey
    );
    let mut compiler = CompilerImpl::new();
    let script_pubkey = compiler.compile(input.ScriptPubKey);
    let compiler = CompilerImpl::new();
    let script_sig = compiler.compile(input.ScriptSig);
    let tx = TransactionImpl::new_signed(script_sig);
    let mut engine = EngineInternalImpl::new(@script_pubkey, tx, 0, 0, 0)?;
    let _ = engine.execute()?;
    Result::Ok(())
}

fn run_with_json(input: InputData) -> Result<(), felt252> {
    println!(
        "Running Bitcoin Script with ScriptSig: '{}' and ScriptPubKey: '{}'",
        input.ScriptSig,
        input.ScriptPubKey
    );
    let mut compiler = CompilerImpl::new();
    let script_pubkey = compiler.compile(input.ScriptPubKey);
    let compiler = CompilerImpl::new();
    let script_sig = compiler.compile(input.ScriptSig);
    let tx = TransactionImpl::new_signed(script_sig);
    let mut engine = EngineInternalImpl::new(@script_pubkey, tx, 0, 0, 0)?;
    let _ = engine.execute()?;
    engine.json();
    Result::Ok(())
}

fn debug(input: InputData) -> Result<bool, felt252> {
    println!(
        "Running Bitcoin Script with ScriptSig: '{}' and ScriptPubKey: '{}'",
        input.ScriptSig,
        input.ScriptPubKey
    );
    let mut compiler = CompilerImpl::new();
    let script_pubkey = compiler.compile(input.ScriptPubKey);
    let compiler = CompilerImpl::new();
    let script_sig = compiler.compile(input.ScriptSig);
    let tx = TransactionImpl::new_signed(script_sig);
    let mut engine = EngineInternalImpl::new(@script_pubkey, tx, 0, 0, 0)?;
    let mut res = Result::Ok(true);
    while true {
        res = engine.step();
        if res.is_err() {
            break;
        }
        if res.unwrap() == false {
            break;
        }
        engine.json();
    };
    res
}

fn main(input: InputDataWithFlags) -> u8 {
    let res = run_with_flags(input);
    match res {
        Result::Ok(_) => {
            println!("Execution successful");
            1
        },
        Result::Err(e) => {
            println!("Execution failed: {}", felt252_to_byte_array(e));
            0
        }
    }
}

fn main_with_witness(input: InputDataWithWitness) -> u8 {
    let res = run_with_witness(input);
    match res {
        Result::Ok(_) => {
            println!("Execution successful");
            1
        },
        Result::Err(e) => {
            println!("Execution failed: {}", felt252_to_byte_array(e));
            0
        }
    }
}

fn backend_run(input: InputData) -> u8 {
    let res = run_with_json(input);
    match res {
        Result::Ok(_) => {
            println!("Execution successful");
            1
        },
        Result::Err(e) => {
            println!("Execution failed: {}", felt252_to_byte_array(e));
            0
        }
    }
}

fn backend_debug(input: InputData) -> u8 {
    let res = debug(input);
    match res {
        Result::Ok(_) => {
            println!("Execution successful");
            1
        },
        Result::Err(e) => {
            println!("Execution failed: {}", felt252_to_byte_array(e));
            0
        }
    }
}

#[derive(Drop)]
struct ValidateRawInput {
    raw_transaction: ByteArray,
    utxo_hints: Array<UTXO>
}

fn run_raw_transaction(input: ValidateRawInput) -> u8 {
    println!("Running Bitcoin Script with raw transaction: '{}'", input.raw_transaction);
    let raw_transaction = hex_to_bytecode(@input.raw_transaction);
    let transaction = TransactionTrait::deserialize(raw_transaction);
    let res = validate::validate_transaction(transaction, 0, input.utxo_hints);
    match res {
        Result::Ok(_) => {
            println!("Execution successful");
            1
        },
        Result::Err(e) => {
            println!("Execution failed: {}", felt252_to_byte_array(e));
            0
        }
    }
}
