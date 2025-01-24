use shinigami_engine::transaction::{UTXO, EngineInternalTransactionTrait};
use shinigami_utils::bytecode::hex_to_bytecode;
use crate::validate;

#[test]
fn test_p2pkh_transaction() {
    // First ever P2PKH transaction
    // tx: 6f7cf9580f1c2dfb3c4d5d043cdbb128c640e3f20161245aa7372e9666168516
    let raw_transaction_hex =
        "0x0100000002f60b5e96f09422354ab150b0e506c4bffedaf20216d30059cc5a3061b4c83dff000000004a493046022100e26d9ff76a07d68369e5782be3f8532d25ecc8add58ee256da6c550b52e8006b022100b4431f5a9a4dcb51cbdcaae935218c0ae4cfc8aa903fe4e5bac4c208290b7d5d01fffffffff7272ef43189f5553c2baea50f59cde99b3220fd518884d932016d055895b62d000000004a493046022100a2ab7cdc5b67aca032899ea1b262f6e8181060f5a34ee667a82dac9c7b7db4c3022100911bc945c4b435df8227466433e56899fbb65833e4853683ecaa12ee840d16bf01ffffffff0100e40b54020000001976a91412ab8dc588ca9d5787dde7eb29569da63c3a238c88ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let prevout_pk_script_1 =
        "0x4104c9560dc538db21476083a5c65a34c7cc219960b1e6f27a87571cd91edfd00dac16dca4b4a7c4ab536f85bc263b3035b762c5576dc6772492b8fb54af23abff6dac";
    let prevout_1 = UTXO {
        amount: 5000000000, pubkey_script: hex_to_bytecode(@prevout_pk_script_1), block_height: 509,
    };
    let prevout_pk_script_2 =
        "0x41043987a76015929873f06823f4e8d93abaaf7bcf55c6a564bed5b7f6e728e6c4cb4e2c420fe14d976f7e641d8b791c652dfeee9da584305ae544eafa4f7be6f777ac";
    let prevout_2 = UTXO {
        amount: 50000000000,
        pubkey_script: hex_to_bytecode(@prevout_pk_script_2),
        block_height: 357,
    };
    let utxo_hints = array![prevout_1, prevout_2];
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, 0, utxo_hints);

    let res = validate::validate_transaction(@transaction, 0);
    assert!(res.is_ok(), "Transaction validation failed");
}

#[test]
fn test_p2pkh_transaction_spend() {
    // Spend the first ever P2PKH transaction output
    // tx: 12e753ef5cc30925a6eee2c457aa7f53022443ca013ea81882a6b59b69e342a6
    let raw_transaction_hex =
        "0x01000000030dd7891efbf67da47c651531db8aab3144ed7a524e4ae1e30b773525e27ddd7b000000004948304502206f6a68710a51f77e5a1fa4d1037a23a76723724a51fd54710949e0189ee02dfa022100dad3454ade12fe84f3818e14c41ec2e02bbb154dd3136a094cdf86f67ebbe0b601ffffffff16851666962e37a75a246101f2e340c628b1db3c045d4d3cfb2d1c0f58f97c6f000000008b48304502203f004eeed0cef2715643e2f25a27a28f3c578e94c7f0f6a4df104e7d163f7f8f022100b8b248c1cfd8f77a0365107a9511d759b7544d979dd152a955c867afac0ef7860141044d05240cfbd8a2786eda9dadd520c1609b8593ff8641018d57703d02ba687cf2f187f0cee2221c3afb1b5ff7888caced2423916b61444666ca1216f26181398cffffffffffda5d38e91fd9a0d92872d51f83cb746fc7bf5d3ff13402f8d0d5ed60ddc79c0000000049483045022100b6fd43f2fa16e092678283f64d2e08fb2070b4af2b3ddfb9ca3c5e238288acaa02200c5a28e0a4fc1a540f6eeb30ccc4788050eae46964fe33ccb4500c3de1320c2501ffffffff02c0c62d00000000001976a91417194e1bd175fb5b1b2a1f9d221f6f5c29e1928388ac00c817a8040000001976a91465bda9b05f7e9a8f96a7f4ba0996a877708ef90888ac00000000";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let prevout_pk_script_0 =
        "0x4104889fcdfd7c5430d13f1eb5f508e2e87f38d2406fad8425a824e032ccb371ef62465331e1a6334d7c3770a2ad2a958e740130343399d01dbd87426db850f9faf9ac";
    let prevout_pkh_script_1 = "0x76a91412ab8dc588ca9d5787dde7eb29569da63c3a238c88ac";
    let prevout_pk_script_2 =
        "0x4104f51707ee3fd26b490bb83582f22c73b97c364b9c51a80c49e6a9bc491538f5206fc0ca8fc4c97dfd0a8b2ae9b82d1ef94599ce51eaf9ba82ce4a69d9ac9dc225ac";

    let prev_out0 = UTXO {
        amount: 5003000000,
        pubkey_script: hex_to_bytecode(@prevout_pk_script_0),
        block_height: 12983,
    };

    let prev_out1 = UTXO {
        amount: 10000000000,
        pubkey_script: hex_to_bytecode(@prevout_pkh_script_1),
        block_height: 728,
    };

    let prev_out2 = UTXO {
        amount: 5000000000,
        pubkey_script: hex_to_bytecode(@prevout_pk_script_2),
        block_height: 17233,
    };

    let utxo_hints = array![prev_out0, prev_out1, prev_out2];
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, 0, utxo_hints);

    // Run Shinigami and validate the transaction execution
    let res = validate::validate_transaction(@transaction, 0);
    assert!(res.is_ok(), "Transaction validation failed");
}

#[ignore]
#[test]
fn test_10000_btc_pizza_transaction() { // The famous 10000 BTC pizza transaction
// tx: a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d
// TODO
}

#[test]
fn test_block_770000_p2pkh_transaction() {
    // tx: a2bf21f6d8b7aa77c740d0374e4759791d97c0134bc918c93bae8e14879c8ecc
    let raw_transaction_hex =
        "0x0200000001c3cbbd0f9ac1f59225df1381c10c4b104ed7d78beef73e89cbd163c8d98b729e000000006a47304402202acb8afaa5745d1fd99dab6e74d89ee679daca1973796f61916e6e27905cd01b022067120362c1145cdd2a2de182435618b3c356a72849718997e5546d62ea9925fb012102e34755efb7b73a51f0a2facc10c9aab73b99a3f676c60fe5a7e865c75d61cce3feffffff02acf15608020000001976a9149ee1cd0c085b88bd7b22e44abe52734e0a61c94288ac404b4c00000000001976a914a7e9478b4f77c490c32472cfe8ad672d24fc77a888accfbf0b00";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let prevout_pk_script = "0x76a9140900bb14c7cb6a52fd8a22fd68a5986eb193c9f588ac";
    let prevout = UTXO {
        amount: 8734850959,
        pubkey_script: hex_to_bytecode(@prevout_pk_script),
        block_height: 769998,
    };
    let utxo_hints = array![prevout];
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, 0, utxo_hints);

    let res = validate::validate_transaction(@transaction, 0);
    assert!(res.is_ok(), "Transaction validation failed");
}

#[test]
fn test_block_770002_p2pkh_transaction() {
    // tx: faf2987fd2240d9c46575cc35c354eeca71b794c482f3cc49fba1a5f9a80808c
    let raw_transaction_hex =
        "0x0200000001cc8e9c87148eae3bc918c94b13c0971d7959474e37d040c777aab7d8f621bfa2000000006a47304402204321dc44fa1207aa353ce1b0270887910c10825b284cfc5dc1e5451da43defd002204b0cab71575f765d11f52b1f03bdc3d11b00a6d94e1f2185530c6f82bdae2e7d012102e9698e55e8b3bca5aa108e094e4b0b42ce0dd697268c77ccc14ef54bd336088efeffffff02404b4c00000000001976a9148ca7043a7bf78518c3dfc9c756f3af8fef4ce6db88acc9a30a08020000001976a914b8b5866bc6828bb1e9c9ddc132fe42965355c19b88acd1bf0b00";
    let raw_transaction = hex_to_bytecode(@raw_transaction_hex);

    let prevout_pk_script = "0x76a9149ee1cd0c085b88bd7b22e44abe52734e0a61c94288ac";
    let prevout = UTXO {
        amount: 8729850284,
        pubkey_script: hex_to_bytecode(@prevout_pk_script),
        block_height: 769998,
    };
    let utxo_hints = array![prevout];
    let transaction = EngineInternalTransactionTrait::deserialize(raw_transaction, 0, utxo_hints);

    let res = validate::validate_transaction(@transaction, 0);
    assert!(res.is_ok(), "Transaction validation failed");
}
