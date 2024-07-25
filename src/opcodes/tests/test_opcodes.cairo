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
fn test_op_less_than_or_equal_true_for_less_than() {
    let program = "OP_2 OP_3 OP_LESSTHANOREQUAL";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    engine.step();
    engine.step();

    let res = engine.step();
    assert!(res, "Execution of OP_LESSTHANOREQUAL failed for 2 <= 3");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1 for 2 <= 3");

    let expected_stack = array!["\0\0\0\0\0\0\0\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for 2 <= 3");
}

#[test]
fn test_op_less_than_or_equal_true_for_equal() {
    let program = "OP_2 OP_2 OP_LESSTHANOREQUAL";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    engine.step();
    engine.step();

    let res = engine.step();
    assert!(res, "Execution of OP_LESSTHANOREQUAL failed for 2 <= 2");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1 for 2 <= 2");

    let expected_stack = array!["\0\0\0\0\0\0\0\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for 2 <= 2");
}

#[test]
fn test_op_less_than_or_equal_false_for_greater_than() {
    let program = "OP_3 OP_2 OP_LESSTHANOREQUAL";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    engine.step();
    engine.step();

    let res = engine.step();
    assert!(res, "Execution of OP_LESSTHANOREQUAL failed for 3 <= 2");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1 for 3 <= 2");

    let expected_stack = array!["\0\0\0\0\0\0\0\x00"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for 3 <= 2");
}
