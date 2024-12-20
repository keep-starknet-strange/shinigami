#[derive(Debug, Drop, Clone, Default)]
pub struct UTXO {
    pub amount: i64,
    pub pubkey_script: ByteArray,
    pub block_height: u32,
    // TODO: flags?
}
