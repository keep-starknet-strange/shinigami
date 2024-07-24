use shinigami::compiler::CompilerTraitImpl;
use shinigami::engine::EngineTraitImpl;

#[test]
fn execution_test() {
  let program = "OP_0 OP_1 OP_ADD";
  let mut compiler = CompilerTraitImpl::new();
  let bytecode = compiler.compile(program);
  let mut engine = EngineTraitImpl::new(bytecode);
  let res = engine.execute();
  assert!(res.is_ok(), "Execution failed");
}
