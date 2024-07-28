use shinigami::compiler::CompilerTraitImpl;
use shinigami::engine::EngineTraitImpl;

fn test_op_n(value: u8) {
    let program = format!("OP_{}", value);
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");
    let mut byte = "";
    byte.append_byte(value);
    let stack_value = format!("\0\0\0\0\0\0\0{}", byte);
    let expected_stack = array![stack_value];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

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
fn test_op_2() {
    test_op_n(2);
}

#[test]
fn test_op_3() {
    test_op_n(3);
}

#[test]
fn test_op_4() {
    test_op_n(4);
}

#[test]
fn test_op_5() {
    test_op_n(5);
}

#[test]
fn test_op_6() {
    test_op_n(6);
}

#[test]
fn test_op_7() {
    test_op_n(7);
}

#[test]
fn test_op_8() {
    test_op_n(8);
}

#[test]
fn test_op_9() {
    test_op_n(9);
}

#[test]
fn test_op_10() {
    test_op_n(10);
}

#[test]
fn test_op_11() {
    test_op_n(11);
}

#[test]
fn test_op_12() {
    test_op_n(12);
}

#[test]
fn test_op_13() {
    test_op_n(13);
}

#[test]
fn test_op_14() {
    test_op_n(14);
}

#[test]
fn test_op_15() {
    test_op_n(15);
}

#[test]
fn test_op_16() {
    test_op_n(16);
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

#[test]
fn test_op_TRUE() {
    let program = "OP_TRUE";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array!["\0\0\0\0\0\0\0\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

fn test_op_1add() {
    let program = "OP_1 OP_1ADD";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    engine.step();

    let res = engine.step();
    assert!(res, "Execution of OP_1ADD failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array!["\0\0\0\0\0\0\0\x02"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

fn test_op_min_min_first() {
    let program = "OP_1 OP_2 OP_MIN";
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

#[test]
fn test_op_min_min_second() {
    let program = "OP_2 OP_1 OP_MIN";
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

#[test]
fn test_op_min_same_value() {
    let program = "OP_1 OP_1 OP_MIN";
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
