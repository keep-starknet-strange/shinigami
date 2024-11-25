#!/bin/bash
#
# This script fetches a transaction hash using block height and transaction index
# Usage: ./get_tx_from_block.sh <block_height> <tx_index>

if [ "$#" -ne 2 ]; then
    echo "Usage: $0 <block_height> <tx_index>"
    echo "Example: $0 869322 1"
    exit 1
fi

BLOCK_HEIGHT=$1
TX_INDEX=$2

RPC_API="https://bitcoin-mainnet.public.blastapi.io"

# First, get the block hash for the given height
BLOCK_HASH_RES=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"jsonrpc\":\"1.0\",\"id\":0,\"method\":\"getblockhash\",\"params\":[$BLOCK_HEIGHT]}" \
    $RPC_API)

BLOCK_HASH=$(echo $BLOCK_HASH_RES | jq -r '.result')

if [ -z "$BLOCK_HASH" ] || [ "$BLOCK_HASH" = "null" ]; then
    echo "Error: Could not fetch block hash for height $BLOCK_HEIGHT"
    exit 1
fi

# Then, get the block data which includes all transaction hashes
BLOCK_DATA_RES=$(curl -s -X POST -H "Content-Type: application/json" \
    -d "{\"jsonrpc\":\"1.0\",\"id\":0,\"method\":\"getblock\",\"params\":[\"$BLOCK_HASH\"]}" \
    $RPC_API)

# Extract the transaction hash at the specified index
TX_HASH=$(echo $BLOCK_DATA_RES | jq -r ".result.tx[$TX_INDEX]")

if [ -z "$TX_HASH" ] || [ "$TX_HASH" = "null" ]; then
    echo "Error: Could not find transaction at index $TX_INDEX in block $BLOCK_HEIGHT"
    exit 1
fi

echo $TX_HASH
