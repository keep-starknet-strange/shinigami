use shinigami::compiler::CompilerTraitImpl;
use shinigami::engine::{Engine, EngineTraitImpl};

pub fn test_compile_and_run(program: ByteArray) -> Engine {
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let res = engine.execute();
    assert!(res.is_ok(), "Execution of the program failed");
    engine
}

pub fn test_compile_and_run_err(program: ByteArray, expected_err: felt252) -> Engine {
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let res = engine.execute();
    assert!(res.is_err(), "Execution of the program did not fail as expected");
    let err = res.unwrap_err();
    assert_eq!(err, expected_err, "Program did not return the expected error");
    engine
}

pub fn check_dstack_size(ref engine: Engine, expected_size: usize) {
    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), expected_size, "Dstack size is not as expected");
}

pub fn check_astack_size(ref engine: Engine, expected_size: usize) {
    let astack = engine.get_astack();
    assert_eq!(astack.len(), expected_size, "Astack size is not as expected");
}

pub fn check_expected_dstack(ref engine: Engine, expected: Span<ByteArray>) {
    let dstack = engine.get_dstack();
    assert_eq!(dstack, expected, "Dstack is not as expected");
}

pub fn check_expected_astack(ref engine: Engine, expected: Span<ByteArray>) {
    let astack = engine.get_astack();
    assert_eq!(astack, expected, "Astack is not as expected");
}
