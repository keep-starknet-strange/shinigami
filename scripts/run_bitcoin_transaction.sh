#!/bin/bash
#
# This script fetches and runs a bitcoin transaction using Shinigami Script Engine.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASE_DIR=$SCRIPT_DIR/..

# BIP activation heights (mainnet)
BIP_16_BLOCK_HEIGHT=173805  # P2SH
BIP_66_BLOCK_HEIGHT=363725  # Strict DER signatures
BIP_65_BLOCK_HEIGHT=388381  # CHECKLOCKTIMEVERIFY
BIP_112_BLOCK_HEIGHT=419328 # CHECKSEQUENCEVERIFY
BIP_141_BLOCK_HEIGHT=481824 # SegWit
BIP_341_BLOCK_HEIGHT=709632 # Taproot

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

# Get block hash from transaction
BLOCK_HASH=$(echo $RES | jq -r '.result.blockhash')
# Fetch block info to get height
BLOCK_INFO=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"jsonrpc\":\"1.0\",\"id\":0,\"method\":\"getblock\",\"params\":[\"$BLOCK_HASH\"]}" $RPC_API)
BLOCK_HEIGHT=$(echo $BLOCK_INFO | jq -r '.result.height')
echo "BLOCK_HEIGHT: $BLOCK_HEIGHT"
BLOCK_VERSION=$(echo $BLOCK_INFO | jq -r '.result.version')

# Check if this is a coinbase transaction
IS_COINBASE=false
VIN_TXID=$(echo $RES | jq -r '.result.vin[0].txid')
if [ "$VIN_TXID" = "null" ] || [ "$VIN_TXID" = "0000000000000000000000000000000000000000000000000000000000000000" ]; then
    IS_COINBASE=true
    echo "Detected coinbase transaction"
    FLAGS=""  # Empty flags for coinbase
else
    # Initialize empty flags string
    FLAGS=""

    # BIP16 (P2SH)
    if [ $BLOCK_HEIGHT -ge $BIP_16_BLOCK_HEIGHT ]; then
        FLAGS="P2SH"
    fi

    # BIP66 (Strict DER signatures)
    if [ $BLOCK_VERSION -ge 3 ] && [ $BLOCK_HEIGHT -ge $BIP_66_BLOCK_HEIGHT ]; then
        [ -n "$FLAGS" ] && FLAGS="$FLAGS,"
        FLAGS="${FLAGS}DERSIG"
    fi

    # BIP65 (CHECKLOCKTIMEVERIFY)
    if [ $BLOCK_VERSION -ge 4 ] && [ $BLOCK_HEIGHT -ge $BIP_65_BLOCK_HEIGHT ]; then
        [ -n "$FLAGS" ] && FLAGS="$FLAGS,"
        FLAGS="${FLAGS}CHECKLOCKTIMEVERIFY"
    fi

    # BIP112 (CHECKSEQUENCEVERIFY)
    if [ $BLOCK_HEIGHT -ge $BIP_112_BLOCK_HEIGHT ]; then
        [ -n "$FLAGS" ] && FLAGS="$FLAGS,"
        FLAGS="${FLAGS}CHECKSEQUENCEVERIFY"
    fi

    # BIP141 (SegWit)
    if [ $BLOCK_HEIGHT -ge $BIP_141_BLOCK_HEIGHT ]; then
        [ -n "$FLAGS" ] && FLAGS="$FLAGS,"
        FLAGS="${FLAGS}WITNESS"
        FLAGS="${FLAGS},NULLDUMMY"
    fi

    # BIP341 (Taproot)
    if [ $BLOCK_HEIGHT -ge $BIP_341_BLOCK_HEIGHT ]; then
        [ -n "$FLAGS" ] && FLAGS="$FLAGS,"
        FLAGS="${FLAGS}TAPROOT"
    fi
fi

echo "Transaction type: $([ "$IS_COINBASE" = true ] && echo 'Coinbase' || echo 'Regular')"
echo "Block height: $BLOCK_HEIGHT"
echo "Script flags: $FLAGS"
echo "UTXO construction: $UTXOS"

AMOUNT=0 # TODO?
UTXOS=""
if [ "$IS_COINBASE" = true ]; then
    echo "Setting up empty UTXO list for coinbase transaction"
    # Leave UTXOS empty for coinbase transactions
    UTXOS=""
else
    UTXOS=""
    for vin in $(echo $VINS | jq -r '.[] | @base64'); do
            _jq() {
                echo ${vin} | base64 --decode | jq -r ${1}
            }

            TXID=$(echo $(_jq '.txid'))
            VOUT=$(echo $(_jq '.vout'))

            # Fetch the transaction
            RES=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"jsonrpc\":\"1.0\",\"id\":0,\"method\":\"getrawtransaction\",\"params\":[\"$TXID\", true]}" $RPC_API)

            AMOUNT=$(echo $RES | jq ".result.vout[$VOUT].value * 100000000 | floor")
            PUBKEY_SCRIPT=$(echo $RES | jq ".result.vout[$VOUT].scriptPubKey.hex" | tr -d '"')
            PUBKEY_SCRIPT="0x$PUBKEY_SCRIPT"

            PUBKEY_SCRIPT_TEXT=$($SCRIPT_DIR/text_to_byte_array.sh $PUBKEY_SCRIPT)
            PUBKEY_SCRIPT_INPUT=$(sed 's/^\[\(.*\)\]$/\1/' <<< $PUBKEY_SCRIPT_TEXT)

            UTXOS="$UTXOS$AMOUNT,$PUBKEY_SCRIPT_INPUT,$BLOCK_HEIGHT"
        done
    UTXOS=$(sed 's/,$//' <<< $UTXOS)
fi

FLAGS_TEXT=$($SCRIPT_DIR/text_to_byte_array.sh "$FLAGS")
FLAGS_INPUT=$(sed 's/^\[\(.*\)\]$/\1/' <<< $FLAGS_TEXT)

JOINED_INPUT="[$RAW_TX_INPUT,[$UTXOS],$FLAGS_INPUT]"
# echo "JOINED_INPUT: $JOINED_INPUT"

echo "scarb cairo-run --package shinigami_cmds --function run_raw_transaction \"$JOINED_INPUT\""
scarb cairo-run --package shinigami_cmds --function run_raw_transaction --no-build $JOINED_INPUT
# TODO: Error checking
