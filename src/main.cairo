use shinigami::compiler::CompilerImpl;
use shinigami::engine::EngineImpl;
use shinigami::transaction::TransactionImpl;
use shinigami::utils;

#[derive(Clone, Drop)]
struct InputData {
    ScriptSig: ByteArray,
    ScriptPubKey: ByteArray
}

fn main(input: InputData) -> u8 {
    println!("Running Bitcoin Script with ScriptSig: '{}' and ScriptPubKey: '{}'", input.ScriptSig, input.ScriptPubKey);
    let mut compiler = CompilerImpl::new();
    let script_pubkey = compiler.compile(input.ScriptPubKey);
    let compiler = CompilerImpl::new();
    let script_sig = compiler.compile(input.ScriptSig);
    let tx = TransactionImpl::new_signed(script_sig);
    let mut engine = EngineImpl::new(@script_pubkey, tx, 0, 0, 0);
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
