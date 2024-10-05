#!/bin/bash
#
# This script runs all transactions in a blocks

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASE_DIR=$SCRIPT_DIR/..

echo "Building shinigami..."
cd $BASE_DIR && scarb build
echo "Shinigami built successfully!"
echo

START_BLOCK=$1
END_BLOCK=$2
echo "Running blocks $START_BLOCK to $END_BLOCK"

IDX=$START_BLOCK
while true; do
  $SCRIPT_DIR/run_block_transactions.sh $IDX
  IDX=$((IDX+1))
  if [ $IDX -ge $END_BLOCK ]; then
    break
  fi
done
echo "Done running blocks"
