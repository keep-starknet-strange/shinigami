use crate::transaction::TransactionTrait;
use crate::scriptnum::ScriptNum;
use crate::utils::{felt252_to_byte_array, hex_to_bytecode};
use crate::compiler::CompilerImpl;
use crate::engine::{EngineImpl, EngineTrait};
use crate::transaction::{TransactionImpl};
use crate::utxo::UTXO;
use crate::validate;
use crate::scriptflags;
use crate::witness;
#[test]
fn test_coinbase_tx() {
    let validate_raw_input = ValidateRawInput {
        raw_transaction: "01000000010000000000000000000000000000000000000000000000000000000000000000ffffffff4d04ffff001d0104455468652054696d65732030332f4a616e2f32303039204368616e63656c6c6f72206f6e206272696e6b206f66207365636f6e64206261696c6f757420666f722062616e6b73ffffffff0100f2052a01000000434104678afdb0fe5548271967f1a67130b7105cd6a828e03909a67962e0ea1f61deb649f6bc3f4cef38c4f35504e51ec112de5c384df7ba0b8d578a4c702b6bf11d5fac00000000",
        utxo_hints: array![]
    };
    let result = run_raw_transaction(validate_raw_input);
    assert_eq!(result, 1);
}

#[test]
fn test_satoshi_to_halfiney_tx() {
    let prevout_pk_script =
        "0x410411db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a6909a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f656b412a3ac";
    let prev_out = UTXO {
        amount: 5000000000, pubkey_script: hex_to_bytecode(@prevout_pk_script), block_height: 9
    };
    let utxo_hints = array![prev_out];
    let validate_raw_input = ValidateRawInput {
        raw_transaction: "0x0100000001c997a5e56e104102fa209c6a852dd90660a20b2d9c352423edce25857fcd3704000000004847304402204e45e16932b8af514961a1d3a1a25fdf3f4f7732e9d624c6c61548ab5fb8cd410220181522ec8eca07de4860a4acdd12909d831cc56cbbac4622082221a8768d1d0901ffffffff0200ca9a3b00000000434104ae1a62fe09c5f51b13905f07f06b99a2f7159b2225f374cd378d71302fa28414e7aab37397f554a7df5f142c21c1b7303b8a0626f1baded5c72a704f7e6cd84cac00286bee0000000043410411db93e1dcdb8a016b49840f8c53bc1eb68a382e97b1482ecad7b148a6909a5cb2e0eaddfb84ccf9744464f82e160bfa9b8b64f9d4c03f999b8643f656b412a3ac00000000",
        utxo_hints: utxo_hints,
    };
    let result = run_raw_transaction(validate_raw_input);
    assert_eq!(result, 1);
}

#[derive(Drop)]
struct ValidateRawInput {
    raw_transaction: ByteArray,
    utxo_hints: Array<UTXO>
}


fn run_raw_transaction(input: ValidateRawInput) -> u8 {
    println!("Running Bitcoin Script with raw transaction: '{}'", input.raw_transaction);
    let raw_transaction = hex_to_bytecode(@input.raw_transaction);
    let transaction = TransactionTrait::deserialize(raw_transaction);
    let res = validate::validate_transaction(transaction, 0, input.utxo_hints);

    match res {
        Result::Ok(_) => {
            println!("Execution successful");
            1
        },
        Result::Err(e) => {
            println!("Execution failed: {}", felt252_to_byte_array(e));
            0
        }
    }
}
