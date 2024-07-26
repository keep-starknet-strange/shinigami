use shinigami::compiler::CompilerTraitImpl;
use shinigami::engine::EngineTraitImpl;

#[test]
fn test_op_0() {
    let program = "OP_0";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array![""];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_1() {
    let program = "OP_1";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    // TODO: Is this the correct representation of 1?
    let expected_stack = array!["\0\0\0\0\0\0\0\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_add() {
    let program = "OP_1 OP_1 OP_ADD";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of run failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array!["\0\0\0\0\0\0\0\x02"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_max() {
    let program = "OP_1 OP_0 OP_MAX";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of run failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array!["\0\0\0\0\0\0\0\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

fn test_op_depth_empty_stack() {
    let program = "OP_DEPTH";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array!["\0\0\0\0\0\0\0\0"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for empty stack");
}

#[test]
fn test_op_depth_one_item() {
    let program = "OP_1 OP_DEPTH";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 2, "Stack length is not 2");

    let expected_stack = array!["\0\0\0\0\0\0\0\x01", "\0\0\0\0\0\0\0\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for one item");
}

#[test]
fn test_op_depth_multiple_items() {
    let program = "OP_1 OP_1 OP_ADD OP_1 OP_DEPTH";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 3, "Stack length is not 3");

    let expected_stack = array!["\0\0\0\0\0\0\0\x02", "\0\0\0\0\0\0\0\x01", "\0\0\0\0\0\0\0\x02"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for multiple items");
}
