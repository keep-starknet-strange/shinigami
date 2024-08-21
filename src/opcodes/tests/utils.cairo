use shinigami::compiler::CompilerImpl;
use shinigami::engine::{Engine, EngineImpl};
use shinigami::transaction::{Transaction, TransactionInput, TransactionOutput, OutPoint};

// Runs a basic bitcoin script as the script_pubkey with empty script_sig
pub fn test_compile_and_run(program: ByteArray) -> Engine {
    let mut compiler = CompilerImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineImpl::new(@bytecode, Default::default(), 0, 0, 0);
    let res = engine.execute();
    assert!(res.is_ok(), "Execution of the program failed");
    engine
}

// Runs a bitcoin script `program` as script_pubkey with corresponding `transaction`
pub fn test_compile_and_run_with_tx(program: ByteArray, transaction: Transaction) -> Engine {
    let mut compiler = CompilerImpl::new();
    let mut bytecode = compiler.compile(program);
    let mut engine = EngineImpl::new(@bytecode, transaction, 0, 0, 0);
    let res = engine.execute();
    assert!(res.is_ok(), "Execution of the program failed");
    engine
}

// Runs a bitcoin script `program` as script_pubkey with empty script_sig expecting an error
pub fn test_compile_and_run_err(program: ByteArray, expected_err: felt252) -> Engine {
    let mut compiler = CompilerImpl::new();
    let bytecode = compiler.compile(program);
    let mut engine = EngineImpl::new(@bytecode, Default::default(), 0, 0, 0);
    let res = engine.execute();
    assert!(res.is_err(), "Execution of the program did not fail as expected");
    let err = res.unwrap_err();
    assert_eq!(err, expected_err, "Program did not return the expected error");
    engine
}

// Runs a bitcoin script `program` as script_pubkey with corresponding `transaction` expecting an
// error
pub fn test_compile_and_run_with_tx_err(
    program: ByteArray, transaction: Transaction, expected_err: felt252
) -> Engine {
    let mut compiler = CompilerImpl::new();
    let mut bytecode = compiler.compile(program);
    let mut engine = EngineImpl::new(@bytecode, transaction, 0, 0, 0);
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

pub fn mock_transaction(script_sig: ByteArray) -> Transaction {
    let outpoint_0: OutPoint = OutPoint {
        hash: 0xb7994a0db2f373a29227e1d90da883c6ce1cb0dd2d6812e4558041ebbbcfa54b, index: 0
    };
    let mut compiler = CompilerImpl::new();
    let mut script_sig = compiler.compile(script_sig);
    let transaction_input_0: TransactionInput = TransactionInput {
        previous_outpoint: outpoint_0,
        signature_script: script_sig,
        witness: ArrayTrait::<ByteArray>::new(),
        sequence: 0xffffffff
    };
    let mut transaction_inputs: Array<TransactionInput> = ArrayTrait::<TransactionInput>::new();
    transaction_inputs.append(transaction_input_0);
    let oscript_u256: u256 = 0x76a914b3e2819b6262e0b1f19fc7229d75677f347c91ac88ac;
    let mut oscript_byte: ByteArray = "";

    oscript_byte.append_word(oscript_u256.high.into(), 9);
    oscript_byte.append_word(oscript_u256.low.into(), 16);

    //little endian to i64 handle
    let output_0: TransactionOutput = TransactionOutput {
        value: 15000, publickey_script: oscript_byte
    };
    let mut transaction_outputs: Array<TransactionOutput> = ArrayTrait::<TransactionOutput>::new();
    transaction_outputs.append(output_0);

    //let mut subscript = hex_to_bytecode(
    //    @"0x76a9144299ff317fcd12ef19047df66d72454691797bfc88ac"
    //);

    Transaction {
        version: 1,
        transaction_inputs: transaction_inputs.span(),
        transaction_outputs: transaction_outputs.span(),
        locktime: 0,
    }
}

pub fn mock_witness_transaction() -> Transaction {
    let outpoint_0: OutPoint = OutPoint {
        hash: 0xac4994014aa36b7f53375658ef595b3cb2891e1735fe5b441686f5e53338e76a, index: 1
    };
    let transaction_input_0: TransactionInput = TransactionInput {
        previous_outpoint: outpoint_0,
        signature_script: "",
        witness: ArrayTrait::<ByteArray>::new(),
        sequence: 0xffffffff
    };
    let mut transaction_inputs: Array<TransactionInput> = ArrayTrait::<TransactionInput>::new();
    transaction_inputs.append(transaction_input_0);
    let script_u256: u256 = 0x76a914ce72abfd0e6d9354a660c18f2825eb392f060fdc88ac;
    let mut script_byte: ByteArray = "";

    script_byte.append_word(script_u256.high.into(), 9);
    script_byte.append_word(script_u256.low.into(), 16);

    //little endian to i64 handle
    let output_0: TransactionOutput = TransactionOutput {
        value: 15000, publickey_script: script_byte
    };
    let mut transaction_outputs: Array<TransactionOutput> = ArrayTrait::<TransactionOutput>::new();
    transaction_outputs.append(output_0);

    Transaction {
        version: 2,
        transaction_inputs: transaction_inputs.span(),
        transaction_outputs: transaction_outputs.span(),
        locktime: 0,
    }
}
