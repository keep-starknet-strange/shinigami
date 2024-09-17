use crate::compiler::CompilerImpl;

// TODO: More tests?

#[test]
fn test_compiler_unknown_opcode() {
    let mut compiler = CompilerImpl::new();
    let res = compiler.compile("OP_FAKE");
    assert!(res.is_err());
    assert_eq!(res.unwrap_err(), 'Compiler error: unknown opcode', "Error message mismatch");
}
