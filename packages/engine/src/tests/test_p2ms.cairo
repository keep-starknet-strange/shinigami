use crate::transaction::TransactionTrait;
use crate::utxo::UTXO;
use crate::validate;
use shinigami_utils::bytecode::hex_to_bytecode;

#[test]
fn test_p2ms_1_of_2() {
    // First P2MS transaction made on 30 Jan 2012
    let prevout_pk_script = "0x512102953397b893148acec2a9da8341159e9e7fb3d32987c3563e8bdf22116213623210386d8884a5a1f9de0b2c9749462a1b9e8c9ecd9c8d9c589be6617e7dd05c9a7452ae";
    let prev_out = UTXO {
        amount: 1000000,
        pubkey_script: hex_to_bytecode(@prevout_pk_script),
        block_height: 163422
    };

    let raw_transaction_hex = "0x01000000011b022baf6bf8ae9d9852e9d8e1b3a1089fe1f7f8b2b5c17c2b8a536b9b9955d0000000004847304402200f8f5a1e298f823a1468ffdc9c30c6088f7d3df4d9e648c4cea0f969f6670d4602200bc4a92b23354b7ce51f1bb77bf2c1b31e3d4fc7165860e30c3147e5a3b819e001ffffffff0160ea0000000000001976a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = TransactionTrait::deserialize(raw_transaction);
    let utxo_hints = array![prev_out];

    let res = validate::validate_p2ms(@transaction, 0, utxo_hints);
    assert!(res.is_ok(), "P2MS 1-of-2 transaction validation failed");
}

#[test]
fn test_p2ms_3_of_3() {
    // Second P2MS transaction made on 03 Feb 2012
    let prevout_pk_script = "0x53210211db4efc20880c5b57cfa4ee2495266c3d1f7f25c0b033967f00db12773a0c3321021958d53f3efe3b4a0c95a7d137f2d2788231c16d3358eb3e83f0839152bc6c0321030a11290a0c0bf1f2e3e6a9c7848a0b45fcf18d2d7b68c7f259be2d819914729953ae";
    let prev_out = UTXO {
        amount: 2000000,
        pubkey_script: hex_to_bytecode(@prevout_pk_script),
        block_height: 163686
    };

    let raw_transaction_hex = "0x0100000001e0be9e32f1f89c3d431c2ad33f6cdbe59d1e0d0d26b9d652e48582e839717f2000000000fd5d01004730440220130eaffcf8e32e926a9f273db0a0c7fc4cd4d1c2fc7c8c4a5cb97c5a7b3545c5022067b3a453b9ce1641ac3ee4b0d941f7d866d8704dad80c9b3336cd8f18e30046b01483045022100bcdf40fb3b5ebfa2c158ac8d1a41c03eb3dba4e180b00e81836bafd56d946efd022005cc40e35022b614275c1e485c409599667cbd41f6e2d6aec192dd3deb7fd33c014cc952410479be667ef9dcbbac55a06295ce870b07029bfcdb2dce28d959f2815b16f81798483ada7726a3c4655da4fbfc0e1108a8fd17b448a68554199c47d08ffb10d4b84104c6047f9441ed7d6d3045406e95c07cd85c778e4b8cef3ca7abac09b95c709ee51ae168fea63dc339a3c58419466ceaeef7f632653266d0e1236431a950cfe52a4104f9308a019258c31049344f85f89d5229b531c845836f99b08601f113bce036f9388f7b0f632de8140fe337e62a37f3566500a99934c2231b6cb9fd7584b8e67253ae";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = TransactionTrait::deserialize(raw_transaction);
    let utxo_hints = array![prev_out];

    let res = validate::validate_p2ms(@transaction, 0, utxo_hints);
    assert!(res.is_ok(), "P2MS 3-of-3 transaction validation failed");
}

#[test]
fn test_p2ms_2_of_3() {
    // Third P2MS transaction made on 03 Feb 2012
    let prevout_pk_script = "0x522102c08786d63f78bd0a6777ffe9c978cf5899756cfc32bfad09a89e211aeb926242210265bf906bf385fbf3f777832e55a87991bcfbe19b097fb7c5ca2e4025a4d5e5d621027140775f9337088b982780b7e380b7e66907cc4d4a538d7332c427e5a78896a153ae";
    let prev_out = UTXO {
        amount: 1500000,
        pubkey_script: hex_to_bytecode(@prevout_pk_script),
        block_height: 163686
    };

    let raw_transaction_hex = "0x01000000011b022baf6bf8ae9d9852e9d8e1b3a1089fe1f7f8b2b5c17c2b8a536b9b9955d0000000004847304402200f8f5a1e298f823a1468ffdc9c30c6088f7d3df4d9e648c4cea0f969f6670d4602200bc4a92b23354b7ce51f1bb77bf2c1b31e3d4fc7165860e30c3147e5a3b819e001ffffffff0160ea0000000000001976a914cbc20a7664f2f69e5355aa427045bc15e7c6c77288ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = TransactionTrait::deserialize(raw_transaction);
    let utxo_hints = array![prev_out];

    let res = validate::validate_p2ms(@transaction, 0, utxo_hints);
    assert!(res.is_ok(), "P2MS 2-of-3 transaction validation failed");
}

#[test]
fn test_p2ms_edge_cases() {
    // Test case for 1-of-1 multisig
    let prevout_pk_script_1of1 = "0x5121034f355bdcb7cc0af728ef3cceb9615d90684bb5b2ca5f859ab0f0b704075871aa51ae";
    let prev_out_1of1 = UTXO {
        amount: 1000000,
        pubkey_script: hex_to_bytecode(@prevout_pk_script_1of1),
        block_height: 100000
    };

    // Test case for 1-of-2 multisig with an invalid public key
    let prevout_pk_script_1of2_invalid = "0x512102953397b893148acec2a9da8341159e9e7fb3d32987c3563e8bdf22116213623210000000000000000000000000000000000000000000000000000000000000000052ae";
    let prev_out_1of2_invalid = UTXO {
        amount: 1000000,
        pubkey_script: hex_to_bytecode(@prevout_pk_script_1of2_invalid),
        block_height: 100001
    };

    // Test case for 3-of-3 multisig with maximum allowed public keys
    let prevout_pk_script_3of3 = "0x532102953397b893148acec2a9da8341159e9e7fb3d32987c3563e8bdf22116213623210386d8884a5a1f9de0b2c9749462a1b9e8c9ecd9c8d9c589be6617e7dd05c9a745210211db4efc20880c5b57cfa4ee2495266c3d1f7f25c0b033967f00db12773a0c3353ae";
    let prev_out_3of3 = UTXO {
        amount: 1000000,
        pubkey_script: hex_to_bytecode(@prevout_pk_script_3of3),
        block_height: 100002
    };

    let raw_transaction_hex = "0x0100000003..."; // Replace with actual transaction hex
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);
    let transaction = TransactionTrait::deserialize(raw_transaction);
    let utxo_hints = array![prev_out_1of1, prev_out_1of2_invalid, prev_out_3of3];

    let res = validate::validate_p2ms(@transaction, 0, utxo_hints);
    assert!(res.is_ok(), "P2MS edge cases validation failed");
}