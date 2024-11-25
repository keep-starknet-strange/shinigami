#!/bin/bash
#
# This script runs a custom bitcoin script as the script sig

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASE_DIR=$SCRIPT_DIR/..

SCRIPTIN=$1
echo "Running script: $SCRIPTIN"

# Convert the input to a string
SCRIPTSIG=$($SCRIPT_DIR/text_to_byte_array.sh "$SCRIPTIN")

# Remove outer brackets []
SCRIPTSIG=${SCRIPTSIG:1:${#SCRIPTSIG}-2}

JOINED_INPUTS="[[],0,0,$SCRIPTSIG]"

echo "scarb cairo-run --package shinigami_cmds --function run $JOINED_INPUTS"
scarb cairo-run --package shinigami_cmds --function run $JOINED_INPUTS
# TODO: Error checking
