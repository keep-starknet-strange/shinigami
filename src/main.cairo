use shinigami::compiler::CompilerTraitImpl;
use shinigami::engine::EngineTraitImpl;

fn main() {
  let program = "OP_0 OP_1 OP_ADD";
  println!("Running Bitcoin Script: {}", program);
  let mut compiler = CompilerTraitImpl::new();
  let bytecode = compiler.compile(program);
  let mut engine = EngineTraitImpl::new(bytecode);
  let res = engine.execute();
  if res.is_ok() {
    println!("Execution successful");
  } else {
    println!("Execution failed");
  }
}
