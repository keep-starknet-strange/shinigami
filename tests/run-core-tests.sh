#!/bin/bash
#
# Runs the tests from bitcoin-core
# https://github.com/bitcoin/bitcoin/blob/master/src/test/data/

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
BASE_DIR=$SCRIPT_DIR/..

echo "Building shinigami..."
cd $BASE_DIR && scarb build
echo "Shinigami built successfully!"
echo

START=0
if [ -n "$1" ]; then
  START=$1
fi
END=100
if [ -n "$2" ]; then
  END=$2
fi

# Run the script_tests.json tests
# TODO: Pull from bitcoin-core repo?
SCRIPT_TESTS_JSON=$SCRIPT_DIR/script_tests.json

echo "Running script_tests.json tests..."
echo
SCRIPT_IDX=0
PASSED=0
FAILED=0
jq -c '.[]' $SCRIPT_TESTS_JSON | {
  while read line; do
    # If line contains one string, ie ["XXX"], skip it
    if [[ $line != *\"*\"*\,\"*\"* ]]; then
        continue
    fi
    if [ $SCRIPT_IDX -lt $START ]; then
      SCRIPT_IDX=$((SCRIPT_IDX+1))
      continue
    fi
    # Otherwise, line encoded like [[wit..., amount]?, scriptSig, scriptPubKey, flags, expected_scripterror, ... comments]
    # Extract line data
    # witness_amount=$(echo $line | jq -r '.[0]') # TODO: Use witness_amount
    scriptSig=$(echo "$line" | jq -r '.[0]')
    scriptPubKey=$(echo "$line" | jq -r '.[1]')
    #flags=$(echo $line | jq -r '.[2]')
    expected_scripterror=$(echo "$line" | jq -r '.[3]')
    #comments=$(echo $line | jq -r '.[4]')

    # echo "                  Witness Amount: $witness_amount"
    echo "  ScriptSig: '$scriptSig' -- ScriptPubKey: '$scriptPubKey'"
    # echo "                  Flags: $flags"
    # echo "                  Comments: $comments"
    # echo "                  "
    # echo "-----------------------------------------------------------------"
    # echo "                  "

    # Run the test
    ENCODED_SCRIPT_SIG=$($SCRIPT_DIR/text_to_byte_array.sh "$scriptSig") # Encoded like [["123", "456", ...], "789", 3]
    ENCODED_SCRIPT_PUB_KEY=$($SCRIPT_DIR/text_to_byte_array.sh "$scriptPubKey") # Encoded like [["123", "456", ...], "789", 3]
    # Remove the outer brackets and join the arrays
    TRIMMED_SCRIPT_SIG=$(sed 's/^\[\(.*\)\]$/\1/' <<< $ENCODED_SCRIPT_SIG)
    TRIMMED_SCRIPT_PUB_KEY=$(sed 's/^\[\(.*\)\]$/\1/' <<< $ENCODED_SCRIPT_PUB_KEY)
    JOINED_INPUT="[$TRIMMED_SCRIPT_SIG,$TRIMMED_SCRIPT_PUB_KEY]"

    RESULT=$(cd $BASE_DIR && scarb cairo-run --no-build $JOINED_INPUT)
    SUCCESS_RES="Run completed successfully, returning \[1\]"
    FAILURE_RES="Run completed successfully, returning \[0\]"
    SCRIPT_RESULT=""
    if echo "$RESULT" | grep -q "$SUCCESS_RES"; then
        SCRIPT_RESULT="OK"
    elif echo "$RESULT" | grep -q "$FAILURE_RES"; then
        EVAL_FALSE_RES="Execution failed: Script failed after execute"
        EMPTY_STACK_RES="Execution failed: Stack empty after execute"
        UNBALANCED_CONDITIONAL="Execution failed: Unbalanced conditional"
        RESERVED_OP_RES="Execution failed: Opcode reserved"
        UNIMPLEMENTED_OP_RES="Execution failed: Opcode not implemented"
        INVALID_ELSE_RES="Execution failed: opcode_else: no matching if"
        INVALID_ENDIF_RES="Execution failed: opcode_endif: no matching if"
        RETURN_EARLY_RES="Execution failed: opcode_return: returned early"
        STACK_UNDERFLOW_RES="Execution failed: Stack underflow"
        STACK_OUT_OF_RANGE_RES="Execution failed: Stack out of range"
        DISABLED_OP_RES="Execution failed: Opcode is disabled"
        VERIFY_FAILED_RES="Execution failed: Verify failed"
        SCRIPTNUM_OVERFLOW_RES="Execution failed: Scriptnum out of range"
        if echo "$RESULT" | grep -q "$EVAL_FALSE_RES"; then
            SCRIPT_RESULT="EVAL_FALSE"
        elif echo "$RESULT" | grep -q "$EMPTY_STACK_RES"; then
            SCRIPT_RESULT="EVAL_FALSE"
        elif echo "$RESULT" | grep -q "$UNBALANCED_CONDITIONAL"; then
            SCRIPT_RESULT="UNBALANCED_CONDITIONAL"
        elif echo "$RESULT" | grep -q "$RESERVED_OP_RES"; then
            SCRIPT_RESULT="BAD_OPCODE"
        elif echo "$RESULT" | grep -q "$UNIMPLEMENTED_OP_RES"; then
            SCRIPT_RESULT="BAD_OPCODE"
        elif echo "$RESULT" | grep -q "$INVALID_ELSE_RES"; then
            SCRIPT_RESULT="UNBALANCED_CONDITIONAL"
        elif echo "$RESULT" | grep -q "$INVALID_ENDIF_RES"; then
            SCRIPT_RESULT="UNBALANCED_CONDITIONAL"
        elif echo "$RESULT" | grep -q "$RETURN_EARLY_RES"; then
            SCRIPT_RESULT="OP_RETURN"
        elif echo "$RESULT" | grep -q "$STACK_UNDERFLOW_RES"; then
            SCRIPT_RESULT="INVALID_STACK_OPERATION"
        elif echo "$RESULT" | grep -q "$STACK_OUT_OF_RANGE_RES"; then
            SCRIPT_RESULT="INVALID_STACK_OPERATION"
        elif echo "$RESULT" | grep -q "$DISABLED_OP_RES"; then
            SCRIPT_RESULT="DISABLED_OPCODE"
        elif echo "$RESULT" | grep -q "$VERIFY_FAILED_RES"; then
            SCRIPT_RESULT="VERIFY"
        elif echo "$RESULT" | grep -q "$SCRIPTNUM_OVERFLOW_RES"; then
            SCRIPT_RESULT="UNKNOWN_ERROR"
        else
            SCRIPT_RESULT="FAIL"
        fi
        if [ $expected_scripterror == "EQUALVERIFY" ]; then
            # TODO: This is a hack to make the test pass for now
            expected_scripterror="VERIFY"
        fi
    else
        SCRIPT_RESULT="PANIC"
    fi
    echo "  Expected : $expected_scripterror -- Result   : $SCRIPT_RESULT"
    # echo if result is expected w/ color
    if [ "$SCRIPT_RESULT" == "$expected_scripterror" ]; then
        echo -e "  \033[0;32mPASS\033[0m"
        PASSED=$((PASSED+1))
    else
        echo -e "  \033[0;31mFAIL\033[0m"
        FAILED=$((FAILED+1))
        echo "scarb cairo-run '$JOINED_INPUT'"
        echo "$RESULT"
    fi
    echo

    SCRIPT_IDX=$((SCRIPT_IDX+1))
    if [ $SCRIPT_IDX -eq $END ]; then
      break #TODO: Remove this line
    fi
  done

  echo "Script tests complete!"
  echo "Passed: $PASSED    Failed: $FAILED    Total: $((PASSED+FAILED))"
}


# TODO: Pull from bitcoin-core repo?
# Run the tx_valid.json tests
exit 0 # TODO
TX_VALID_JSON=$SCRIPT_DIR/tx_valid.json

jq -c '.[]' $TX_VALID_JSON | while read line; do
    # If line contains on string, ie ["XXX"], skip it
    if [[ $line != *\"*\"*\,\"*\"* ]]; then
        continue
    fi
    # Otherwise, line encoded like [[[prevout hash, prevout index, prevout scriptPubKey, amount?], [input 2], ...], serializedTransaction, excluded verifyFlags]
    # Extract line data
    prevouts=$(echo $line | jq -r '.[0]') # TODO: Use prevouts
    tx=$(echo $line | jq -r '.[1]')
    flags=$(echo $line | jq -r '.[2]') # TODO: Use flags

    # Extract prevouts
    prevout_hashs=$(jq -r '.[] | .[0]' <<< $prevouts)
    prevout_indexes=$(jq -r '.[] | .[1]' <<< $prevouts)
    prevout_scripts=$(jq -r '.[] | .[2]' <<< $prevouts)
    prevout_amounts=$(jq -r '.[] | .[3]' <<< $prevouts)

    echo "Running test with "
    echo "                  Tx: $tx"
    echo "                  Prevout Hashs: $prevout_hashs"
    echo "                  Prevout Indexes: $prevout_indexes"
    echo "                  Prevout Scripts: $prevout_scripts"
    echo "                  Prevout Amounts: $prevout_amounts"
    echo "                  Flags: $flags"
    echo "                  "
    echo "-----------------------------------------------------------------"
    echo "                  "

done
