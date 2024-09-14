use crate::compiler::CompilerImpl;

#[test]
fn test_compiler_OP_2() {
    let mut compiler = CompilerImpl::new();
    let bytecode = compiler.compile("OP_2");
    assert_eq!(bytecode, "R");
}

#[test]
fn test_compiler_OP_11() {
    let mut compiler = CompilerImpl::new();
    let bytecode = compiler.compile("OP_11");
    assert_eq!(bytecode, "[");
}

#[test]
fn test_compiler_OP_2DROP() {
    let mut compiler = CompilerImpl::new();
    let bytecode = compiler.compile("OP_2DROP");
    assert_eq!(bytecode, "m");
}
