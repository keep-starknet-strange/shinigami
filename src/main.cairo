use crate::compiler::CompilerImpl;
use crate::engine::{EngineImpl, Engine, EngineTrait};
use crate::transaction::TransactionImpl;
use crate::utils;

#[derive(Clone, Drop)]
struct InputData {
    ScriptSig: ByteArray,
    ScriptPubKey: ByteArray
}

fn init(input: InputData) -> Engine {
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
    let mut engine = EngineImpl::new(@script_pubkey, tx, 0, 0, 0);
    engine
}

fn main(input: InputData) -> u8 {
    let mut engine = init(input);
    let res = engine.execute();
    match res {
        Result::Ok(_) => {
            println!("Execution successful");
            1
        },
        Result::Err(e) => {
            println!("Execution failed: {}", utils::felt252_to_byte_array(e));
            0
        }
    }
}

fn backend_run(input: InputData) -> u8 {
    let mut engine = init(input);
    let res = engine.execute();
    engine.json();
    match res {
        Result::Ok(_) => {
            println!("Execution successful");
            1
        },
        Result::Err(e) => {
            println!("Execution failed: {}", utils::felt252_to_byte_array(e));
            0
        }
    }
}

fn backend_debug(input: InputData) -> u8 {
    let mut engine = init(input);
    let mut res = Result::Ok(true);
    while true {
        res = engine.step();
        if res.is_err() {
            break;
        }
        engine.json();
        if res.unwrap() == false {
            break;
        }
    };
    match res {
        Result::Ok(_) => {
            println!("Execution successful");
            1
        },
        Result::Err(e) => {
            println!("Execution failed: {}", utils::felt252_to_byte_array(e));
            0
        }
    }
}
