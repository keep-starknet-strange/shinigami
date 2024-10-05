#!/bin/bash
#
# This script fetches and runs a bitcoin transaction using Shinigami Script Engine.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASE_DIR=$SCRIPT_DIR/..

TXID=$1

RPC_API="https://bitcoin-mainnet.public.blastapi.io"

# Input needed
# raw_transaction_hex: ByteArray,
# utxo_hints: Array<UTXO>
#  pub struct UTXO {
#    pub amount: i64,
#    pub pubkey_script: ByteArray,
#    pub block_height: i32,
#    // TODO: flags?
#} 

# Fetch the transaction
RES=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"jsonrpc\":\"1.0\",\"id\":0,\"method\":\"getrawtransaction\",\"params\":[\"$TXID\", true]}" $RPC_API)

RAW_TX_HEX=$(echo $RES | jq '.result.hex' | tr -d '"')
RAW_TX_HEX="0x$RAW_TX_HEX"
# echo "RAW_TX_HEX: $RAW_TX_HEX"

RAW_TX_TEXT=$($SCRIPT_DIR/text_to_byte_array.sh $RAW_TX_HEX)
RAW_TX_INPUT=$(sed 's/^\[\(.*\)\]$/\1/' <<< $RAW_TX_TEXT)
# echo "RAW_TX_INPUT: $RAW_TX_INPUT"

# Fetch the vin's for utxo_hints
VINS=$(echo $RES | jq '.result.vin')
# echo "VINS: $VINS"

BLOCK_HEIGHT=0 # TODO?
AMOUNT=0 # TODO?
UTXOS=""
for vin in $(echo $VINS | jq -r '.[] | @base64'); do
    _jq() {
     echo ${vin} | base64 --decode | jq -r ${1}
    }

    TXID=$(echo $(_jq '.txid'))
    VOUT=$(echo $(_jq '.vout'))

    # Fetch the transaction
    RES=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"jsonrpc\":\"1.0\",\"id\":0,\"method\":\"getrawtransaction\",\"params\":[\"$TXID\", true]}" $RPC_API)

    # AMOUNT=$(echo $RES | jq ".result.vout[$VOUT].value")
    # echo "AMOUNT: $AMOUNT"

    PUBKEY_SCRIPT=$(echo $RES | jq ".result.vout[$VOUT].scriptPubKey.hex" | tr -d '"')
    PUBKEY_SCRIPT="0x$PUBKEY_SCRIPT"
    # echo "PUBKEY_SCRIPT: $PUBKEY_SCRIPT"

    PUBKEY_SCRIPT_TEXT=$($SCRIPT_DIR/text_to_byte_array.sh $PUBKEY_SCRIPT)
    PUBKEY_SCRIPT_INPUT=$(sed 's/^\[\(.*\)\]$/\1/' <<< $PUBKEY_SCRIPT_TEXT)
    # echo "PUBKEY_SCRIPT_INPUT: $PUBKEY_SCRIPT_INPUT"

    # Construct UTXO
    UTXO="{\"amount\":$AMOUNT,\"pubkey_script\":\"$PUBKEY_SCRIPT\",\"block_height\":$BLOCK_HEIGHT}"
    # echo "UTXO: $UTXO"

    UTXOS="$UTXOS$AMOUNT,$PUBKEY_SCRIPT_INPUT,$BLOCK_HEIGHT,"
done
UTXOS=$(sed 's/,$//' <<< $UTXOS)

JOINED_INPUT="[$RAW_TX_INPUT,[$UTXOS]]"
# echo "JOINED_INPUT: $JOINED_INPUT"

echo "scarb cairo-run --package shinigami_cmds --function run_raw_transaction \"$JOINED_INPUT\""
scarb cairo-run --package shinigami_cmds --function run_raw_transaction --no-build $JOINED_INPUT
# TODO: Error checking
