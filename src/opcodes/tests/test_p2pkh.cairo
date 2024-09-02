use crate::opcodes::tests::utils;
use crate::scriptnum::ScriptNum;


#[test]
fn test_p2pkh_first_tx() {
    // from [
    //     "0x47
    //     0x304402206e05a6fe23c59196ffe176c9ddc31e73a9885638f9d1328d47c0c703863b8876022076feb53811aa5b04e0e79f938eb19906cc5e67548bc555a8e8b8b0fc603d840c01
    //     0x21 0x038282263212c609d9ea2a6e3e172de238d8c39cabd5ac1ca10646e23fd5f51508", "DUP HASH160
    //     0x14 0x1018853670f9f3b0582c5b9ee8ce93764ac32b93 EQUALVERIFY CHECKSIG", "",
    //     "OK",
    //     "P2PKH"
    // ]
    let script_sig =
        "OP_DATA_71 0x3044022034bb0494b50b8ef130e2185bb220265b9284ef5b4b8a8da4d8415df489c83b5102206259a26d9cc0a125ac26af6153b17c02956855ebe1467412f066e402f5f05d1201 OP_DATA_33 0x03363d90d446b00c9c99ceac05b6262ee053441c7e55552ffe526bad8f83ff4640";
    let script_pubkey =
        "OP_DUP OP_HASH160 OP_DATA_20 0x1018853670f9f3b0582c5b9ee8ce93764ac32b93 OP_EQUALVERIFY OP_CHECKSIG";
    let mut transaction = utils::mock_transaction(script_sig);
    let mut engine = utils::test_compile_and_run_with_tx(script_pubkey, transaction);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}

#[test]
fn test_p2pkh_btcd_copy() {
    // from https://github.com/btcsuite/btcd/blob/2b53ed198955ac40fe5b3ce4a854e9f5bfa68258/txscript/pkscript_test.go#L209
        let script_sig =
        "OP_DATA_73 0x304402206592d88e1d0a4a3cc59f92aefe625474a94d13a59f849778fce7df4be0c228d802202dea3696191fb700c5a77e22d9fb6b426742a42cacdb74a27c43cd89a0f94454127401 OP_DATA_33 0x027d5612097531c217fdd4d2e17a354b17f27aef309fb27f1f1f7b737d9a244990";
    let script_pubkey =
        "OP_DUP OP_HASH160 OP_DATA_20 0xf07ab8ce72da4e760b747d48d665ec96adf024f5 OP_EQUALVERIFY OP_CHECKSIG";
    let mut transaction = utils::mock_transaction(script_sig);
    let mut engine = utils::test_compile_and_run_with_tx(script_pubkey, transaction);
    utils::check_dstack_size(ref engine, 1);
    let expected_stack = array![ScriptNum::wrap(1)];
    utils::check_expected_dstack(ref engine, expected_stack.span());
}