#!/bin/bash
#
# This script fetches and runs a bitcoin transaction using Shinigami Script Engine.

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASE_DIR=$SCRIPT_DIR/..

BLOCK=$1
echo "Running block $BLOCK"

OUTPUTS=$BASE_DIR/outputs/block-$BLOCK
mkdir -p $OUTPUTS

RPC_API="https://bitcoin-mainnet.public.blastapi.io"

# Fetch blockhash
RES=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"jsonrpc\":\"1.0\",\"id\":0,\"method\":\"getblockhash\", \"params\": [$BLOCK]}" $RPC_API)
BLOCKHASH=$(echo $RES | jq -r '.result')

# Fetch the block
RES=$(curl -s -X POST -H "Content-Type: application/json" -d "{\"jsonrpc\":\"1.0\",\"id\":0,\"method\":\"getblock\", \"params\": [\"$BLOCKHASH\"]}" $RPC_API)

# Loop through the transactions
FIRST_IDX=$2
if [ -z "$FIRST_IDX" ]; then
  FIRST_IDX=0
fi
LAST_IDX=$3
if [ -z "$LAST_IDX" ]; then
  LAST_IDX=$(echo $RES | jq -r ".result.tx | length")
fi
IDX=$FIRST_IDX
while true; do
  TXID=$(echo $RES | jq -r ".result.tx[$IDX]")
  if [ "$TXID" == "null" ]; then
    break
  fi
  OUTPUT_FILE=$OUTPUTS/tx-$IDX.txt
  rm -f $OUTPUT_FILE
  touch $OUTPUT_FILE
  echo "Running transaction $BLOCK::$IDX -  $TXID" >> $OUTPUT_FILE
  echo "" >> $OUTPUT_FILE
  if [ $IDX -eq 0 ]; then
    # TODO
    echo "Skipping coinbase transaction" >> $OUTPUT_FILE
    IDX=$((IDX+1))
    continue
  fi
  $SCRIPT_DIR/run_bitcoin_transaction.sh $TXID >> $OUTPUT_FILE
  IDX=$((IDX+1))
  if [ $IDX -ge $LAST_IDX ]; then
    break
  fi
done
echo "Done running block $BLOCK"
