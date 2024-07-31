use shinigami::compiler::CompilerTraitImpl;
use shinigami::engine::EngineTraitImpl;
use shinigami::scriptnum::ScriptNum;

fn test_op_n(value: u8) {
    let program = format!("OP_{}", value);
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");
    let expected_stack = array![ScriptNum::wrap(value.into())];
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
fn test_op_nop() {
    let program = "OP_NOP";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 0, "Stack length is not 0");
}

#[test]
fn test_op_nop_with_add() {
    let program = "OP_1 OP_1 OP_ADD OP_NOP";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let prev_dstack = engine.get_dstack();
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), prev_dstack.len(), "Stack length have changed");

    assert_eq!(dstack, prev_dstack, "Stack have changed");
}

#[test]
fn test_op_1sub() {
    let program = "OP_1 OP_1SUB";
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
fn test_op_negate_1() {
    let program = "OP_1 OP_NEGATE";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of run failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array![ScriptNum::wrap(-1)];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_negate_0() {
    let program = "OP_0 OP_NEGATE";
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
fn test_op_negate_negative() {
    let program = "OP_1 OP_2 OP_SUB OP_NEGATE";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let res = engine.step();
    assert!(res, "Execution of run failed");
    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");
    let expected_stack = array![ScriptNum::wrap(1)];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_abs_positive() {
    let program = "OP_2 OP_ABS";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of OP_ABS failed for positive number");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");
    let expected_stack = array!["\x02"];
    assert_eq!(dstack, expected_stack.span(), "Result is not [2]");
}

#[test]
fn test_op_abs_negative() {
    let program = "OP_0 OP_1SUB OP_ABS";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of OP_ABS failed for negative number");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");
    let expected_stack = array![ScriptNum::wrap(1)];
    assert_eq!(dstack, expected_stack.span(), "Result is not [2]");
}

#[test]
fn test_op_abs_zero() {
    let program = "OP_0 OP_ABS";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of OP_ABS failed for zero");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");
    let expected_stack = array![""];
    assert_eq!(dstack, expected_stack.span(), "Result is not [0]");
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

    let expected_stack: Array<ByteArray> = array![ScriptNum::wrap(-1)];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_greater_than_true() {
    let program = "OP_1 OP_0 OP_GREATERTHAN";
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
fn test_op_greater_than_false() {
    let program = "OP_0 OP_1 OP_GREATERTHAN";
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
}

#[test]
fn test_op_greater_than_equal_false() {
    let program = "OP_1 OP_1 OP_GREATERTHAN";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of run failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack: Array<ByteArray> = array![""];
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

#[test]
fn test_op_within_true() {
    let program = "OP_1 OP_0 OP_3 OP_WITHIN";
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
fn test_op_within_false() {
    let program = "OP_2 OP_0 OP_1 OP_WITHIN";
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

    let expected_stack = array![""];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_depth_empty_stack() {
    let program = "OP_DEPTH";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array![""];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for empty stack");
}

#[test]
fn test_op_swap() {
    let program = "OP_1 OP_2 OP_3 OP_SWAP";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 3, "Stack length is not 1");

    let expected_stack = array!["\x02", "\x03", "\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_swap_mid() {
    let program = "OP_1 OP_2 OP_3 OP_SWAP OP_4 OP_5";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 5, "Stack length is not 1");

    let expected_stack = array!["\x05", "\x04", "\x02", "\x03", "\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}


#[test]
fn test_op_2swap() {
    let program = "OP_1 OP_2 OP_3 OP_4 OP_2SWAP";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step(); //push 1
    let _ = engine.step(); //push 2
    let _ = engine.step(); //push 3
    let _ = engine.step(); //push 4
    let dstack = engine.get_dstack();
    let expected_stack = array!["\x04", "\x03", "\x02", "\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");

    let res = engine.step(); //execute op_2swap
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 4, "Stack length is not 1");

    let expected_stack = array!["\x02", "\x01", "\x04", "\x03"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_2swap_mid() {
    let program = "OP_1 OP_2 OP_3 OP_4 OP_2SWAP OP_5 OP_6";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step(); //push 1
    let _ = engine.step(); //push 2
    let _ = engine.step(); //push 3
    let _ = engine.step(); //push 4
    let _ = engine.step(); //execute op_2swap
    let _ = engine.step(); //push 5
    let res = engine.step(); //push 6
    let dstack = engine.get_dstack();

    assert!(res, "Execution of step failed");
    assert_eq!(dstack.len(), 6, "Stack length is not 1");

    let expected_stack = array!["\x06", "\x05", "\x02", "\x01", "\x04", "\x03"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
#[should_panic]
fn test_op_2swap_underflow() {
    let program = "OP_1 OP_2 OP_3 OP_2SWAP";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step(); //push 1
    let _ = engine.step(); //push 2
    let _ = engine.step(); //push 3
    let res = engine.step(); //OP_2SWAP

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
fn test_op_true() {
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

#[test]
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

#[test]
fn test_bool_and_one() {
    let program = "OP_1 OP_3 OP_BOOLAND";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of OP_BOOLAND failed for 1 and 3");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1 for 1 and 3");

    let expected_stack = array!["\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for 1 and 3");
}

#[test]
fn test_bool_and_zero() {
    let program = "OP_0 OP_4 OP_BOOLAND";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of OP_BOOLAND failed for 0 and 4");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1 for 0 and 4");

    let expected_stack = array![""];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for 0 and 4");
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

    let expected_stack = array!["\x01"];
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

    let expected_stack = array!["\x01"];
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

    let expected_stack = array![""];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for 3 <= 2");
}

#[test]
fn test_op_numnotequal_true() {
    let program = "OP_2 OP_3 OP_NUMNOTEQUAL";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of OP_NUMNOTEQUAL failed for 2 != 3");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1 for 2 != 3");

    let expected_stack = array!["\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for 1 != 2");
}

#[test]
fn test_op_numnotequal_false() {
    let program = "OP_3 OP_3 OP_NUMNOTEQUAL";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of OP_NUMNOTEQUAL failed for 3 != 3");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1 for 3 != 3");

    let expected_stack = array![""];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for 3 != 3");
}

fn test_op_greater_than_or_equal_true_for_greater_than() {
    let program = "OP_3 OP_2 OP_GREATERTHANOREQUAL";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    engine.step();
    engine.step();

    let res = engine.step();
    assert!(res, "Execution of OP_GREATERTHANOREQUAL failed for 3 >= 2");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1 for 3 >= 2");

    let expected_stack = array!["\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for 3 >= 2");
}

#[test]
fn test_op_greater_than_or_equal_true_for_equal() {
    let program = "OP_2 OP_2 OP_GREATERTHANOREQUAL";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    engine.step();
    engine.step();

    let res = engine.step();
    assert!(res, "Execution of OP_GREATERTHANOREQUAL failed for 2 >= 2");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1 for 2 >= 2");

    let expected_stack = array!["\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for 2 >= 2");
}

#[test]
fn test_op_greater_than_or_equal_false_for_less_than() {
    let program = "OP_2 OP_3 OP_GREATERTHANOREQUAL";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    engine.step();
    engine.step();

    let res = engine.step();
    assert!(res, "Execution of OP_GREATERTHANOREQUAL failed for 2 >= 3");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1 for 2 >= 3");

    let expected_stack = array![""];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected for 2 >= 3");
}

#[test]
fn test_op_lessthan() {
    let program = "OP_1 OP_2 OP_LESSTHAN";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array!["\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_lessthan_reverse() {
    let program = "OP_2 OP_1 OP_LESSTHAN";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array![""];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_lessthan_equal() {
    let program = "OP_1 OP_1 OP_LESSTHAN";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array![""];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_equal() {
    let program = "OP_1 OP_1 OP_EQUAL";
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

fn test_op_dup() {
    let program = "OP_1 OP_2 OP_DUP";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    engine.step();
    engine.step();
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 3, "Stack length is not 3");
    let expected_stack = array!["\x01", "\x02", "\x02"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

fn test_op_drop() {
    let program = "OP_1 OP_1 OP_DROP";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array!["\x01"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
#[should_panic]
fn test_equal_panic() {
    let program = "OP_0 OP_1 OP_EQUAL";
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

fn test_op_2dup() {
    let program = "OP_1 OP_2 OP_2DUP";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    engine.step();
    engine.step();
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 4, "Stack length is not 4");

    let expected_stack = array!["\x01", "\x02", "\x01", "\x02"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

fn test_op_2drop() {
    let program = "OP_1 OP_2 OP_2DROP";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step();
    let _ = engine.step();
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 0, "Stack length is not 0");

    let expected_stack = array![];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
fn test_op_3dup() {
    let program = "OP_1 OP_2 OP_3 OP_3DUP";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    engine.step();
    engine.step();
    engine.step();
    let res = engine.step();
    assert!(res, "Execution of step failed");

    let dstack = engine.get_dstack();
    assert_eq!(dstack.len(), 6, "Stack length is not 6");
    let expected_stack = array!["\x01", "\x02", "\x03", "\x01", "\x02", "\x03"];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}

#[test]
#[should_panic(expected: "Stack underflow")]
fn test_op_2drop_underflow() {
    let program = "OP_1 OP_2DROP";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step();
    let _ = engine.step();
}

#[test]
#[should_panic(expected: "Stack underflow")]
fn test_op_drop_underflow() {
    let program = "OP_DROP";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);

    let _ = engine.step();
}

fn test_op_1negate() {
    let program = "OP_1NEGATE";
    let mut compiler = CompilerTraitImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineTraitImpl::new(bytecode);
    let res = engine.step();
    assert!(res, "Execution of run failed");
    let dstack = engine.get_dstack();

    assert_eq!(dstack.len(), 1, "Stack length is not 1");

    let expected_stack = array![ScriptNum::wrap(-1)];
    assert_eq!(dstack, expected_stack.span(), "Stack is not equal to expected");
}
