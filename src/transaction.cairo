use core::array::ArrayTrait;
use shinigami::utils::hex_to_bytecode;

#[derive(Drop, Copy)]
pub struct Outpoint {
    pub hash: u256,
    pub index: u32,
}

#[derive(Drop, Clone)]
pub struct TransactionInput {
    pub previous_outpoint: Outpoint,
    pub signature_script: ByteArray,
    pub witness: Array<ByteArray>,
    pub sequence: u32,
}

#[derive(Drop, Clone)]
pub struct TransactionOutput {
    pub value: i64,
    pub publickey_script: ByteArray,
}

#[derive(Drop, Clone)]
pub struct Transaction {
    pub version: u32,
    pub transaction_inputs: Array<TransactionInput>,
    pub transaction_outputs: Array<TransactionOutput>,
    pub locktime: u32,
    //temporary until clean transaction handling
    pub subscript: @ByteArray,
}

pub trait TransactionTrait {
    fn get_transaction(transaction: Option<Transaction>) -> Transaction;
    fn get_index(index: Option<u32>) -> u32;

    fn mock_transaction() -> Transaction;
    fn mock_witness_transaction() -> Transaction;
}
pub impl TransactionImpl of TransactionTrait{
    fn get_transaction(transaction: Option<Transaction>) -> Transaction {
        match transaction {
            Option::None => {Default::default()},
            Option::Some(x) => {x},
        }
    }

    fn get_index(index: Option<u32>) -> u32 {
        match index {
            Option::None => {Default::default()},
            Option::Some(x) => {x},
        }
    }

    fn mock_transaction() -> Transaction {
        let outpoint_0: Outpoint = Outpoint { hash: 0xb7994a0db2f373a29227e1d90da883c6ce1cb0dd2d6812e4558041ebbbcfa54b, index: 0};
        let transaction_input_0 :  TransactionInput = TransactionInput{ previous_outpoint: outpoint_0, signature_script: "", witness: ArrayTrait::<ByteArray>::new(), sequence: 0xffffffff};
        let mut transaction_inputs : Array<TransactionInput> = ArrayTrait::<TransactionInput>::new();
        transaction_inputs.append(transaction_input_0);
        let oscript_u256: u256 = 0x76a914b3e2819b6262e0b1f19fc7229d75677f347c91ac88ac;
        let mut oscript_byte: ByteArray = "";

        oscript_byte.append_word(oscript_u256.high.into(), 9);
        oscript_byte.append_word(oscript_u256.low.into(), 16);

        //little endian to i64 handle
        let output_0: TransactionOutput = TransactionOutput { value: 15000, publickey_script: oscript_byte};
        let mut transaction_outputs : Array<TransactionOutput> = ArrayTrait::<TransactionOutput>::new();
        transaction_outputs.append(output_0);

        let mut subscript = hex_to_bytecode(@"0x76a9144299ff317fcd12ef19047df66d72454691797bfc88ac");

        Transaction {
            version: 1,
            transaction_inputs: transaction_inputs,
            transaction_outputs: transaction_outputs,
            locktime:0,
            subscript: @subscript,
        }
    }

    fn mock_witness_transaction() -> Transaction {
        let outpoint_0: Outpoint = Outpoint { hash: 0xac4994014aa36b7f53375658ef595b3cb2891e1735fe5b441686f5e53338e76a, index: 1};
        let transaction_input_0 :  TransactionInput = TransactionInput{ previous_outpoint: outpoint_0, signature_script: "", witness: ArrayTrait::<ByteArray>::new(), sequence: 0xffffffff};
        let mut transaction_inputs : Array<TransactionInput> = ArrayTrait::<TransactionInput>::new();
        transaction_inputs.append(transaction_input_0);
        let script_u256: u256 = 0x76a914ce72abfd0e6d9354a660c18f2825eb392f060fdc88ac;
        let mut script_byte: ByteArray = "";

        script_byte.append_word(script_u256.high.into(), 9);
        script_byte.append_word(script_u256.low.into(), 16);

        //little endian to i64 handle
        let output_0: TransactionOutput = TransactionOutput { value: 15000, publickey_script: script_byte};
        let mut transaction_outputs : Array<TransactionOutput> = ArrayTrait::<TransactionOutput>::new();
        transaction_outputs.append(output_0);

        Transaction {
            version: 2,
            transaction_inputs: transaction_inputs,
            transaction_outputs: transaction_outputs,
            locktime:0,
            subscript: @"",
        }
    }
}

impl TransactionDefault of Default<Transaction> {
    fn default() -> Transaction {
        let transaction = Transaction {
            version: 0,
            transaction_inputs: ArrayTrait::<TransactionInput>::new(),
            transaction_outputs: ArrayTrait::<TransactionOutput>::new(),
            locktime: 0,
            subscript: @"",
        };
        transaction
    }
}