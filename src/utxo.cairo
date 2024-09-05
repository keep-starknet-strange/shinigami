#[derive(Debug, Drop)]
pub struct UTXO {
    pub amount: i64,
    pub pubkey_script: ByteArray,
    pub block_height: i32,
    // TODO: flags?
}
// TODO: implement UTXOSet?

