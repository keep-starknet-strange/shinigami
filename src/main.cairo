use shinigami::compiler::CompilerTraitImpl;
use shinigami::engine::EngineTraitImpl;
use shinigami::utils;

#[derive(Clone, Drop)]
struct InputData {
    ScriptSig: ByteArray,
    ScriptPubKey: ByteArray
}

fn main(input: InputData) -> u8 {
    let mut program = input.ScriptSig.clone();
    program.append(@" ");
    program.append(@input.ScriptPubKey.clone());
    println!("Running Bitcoin Script: '{}'", program);
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
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
