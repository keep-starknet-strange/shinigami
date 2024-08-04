use shinigami::compiler::CompilerTraitImpl;
use shinigami::engine::EngineTraitImpl;

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
    if res.is_ok() {
        println!("Execution successful");
        1
    } else {
        println!("Execution failed");
        0
    }
}
