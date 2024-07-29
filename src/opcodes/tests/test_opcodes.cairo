use shinigami::compiler::CompilerTraitImpl;
use shinigami::engine::EngineTraitImpl;
use shinigami::utils::int_to_bytes;

fn test_op_n(value: u8) {
    let program = format!("OP_{}", value);
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");
    let expected_stack = array![int_to_bytes(value.into())];
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
fn test_op_n_all() {
    test_op_n(1);
    test_op_n(2);
    test_op_n(3);
    test_op_n(4);
    test_op_n(5);
    test_op_n(6);
    test_op_n(7);
    test_op_n(8);
    test_op_n(9);
    test_op_n(10);
    test_op_n(11);
    test_op_n(12);
    test_op_n(13);
    test_op_n(14);
    test_op_n(15);
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

    let expected_stack = array!["\x02"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_sub() {
    let program = "OP_1 OP_1 OP_SUB";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of run failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array![""];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");

    let program = "OP_2 OP_1 OP_SUB";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of run failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array!["\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");

    let program = "OP_1 OP_2 OP_SUB";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of run failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack: Array<ByteArray> = array![int_to_bytes(-1)];
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

    let expected_stack = array!["\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

fn test_op_if_false() {
    let program = "OP_0 OP_IF OP_1 OP_ENDIF";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of run failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 0, "Stack length is not 0");

    let expected_stack = array![];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_if_true() {
    let program = "OP_1 OP_IF OP_1 OP_ENDIF";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of run failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array!["\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_notif_false() {
    let program = "OP_0 OP_NOTIF OP_1 OP_ENDIF";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of run failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array!["\x01"];
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

    let expected_stack = array!["\0"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for empty stack");
}

#[test]
fn test_op_not() {
    let program = "OP_1 OP_NOT";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of run failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array![""];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
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

    let expected_stack = array!["\x01", "\x01"];
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
    assert!(res, "Execution of run failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 3, "Stack length is not 3");

    let expected_stack = array!["\x02", "\x01", "\x02"];
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

    let expected_stack = array!["\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_notif_true() {
    let program = "OP_1 OP_NOTIF OP_1 OP_ENDIF";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of run failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 0, "Stack length is not 0");

    let expected_stack = array![];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_else_false() {
    let program = "OP_0 OP_IF OP_0 OP_ELSE OP_1 OP_ENDIF";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of run failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array!["\x01"];
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

    let expected_stack = array!["\x02"];
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

    let expected_stack = array!["\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_else_true() {
    let program = "OP_1 OP_IF OP_0 OP_ELSE OP_1 OP_ENDIF";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of run failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array![""];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

// TODO: No end_if, ...
// TODO: Nested if statements tests

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

    let expected_stack = array!["\x01"];
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

    let expected_stack = array!["\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}
