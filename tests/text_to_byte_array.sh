#!/bin/bash
#
# Convert a passed string to a cairo byte array representation

TEXT=$1

# Loop through each character in the string
MOD_INDEX=0 # Group characters in sets of 31
CURRENT_INDEX=0
GROUPED_TEXTS=()
for (( i=0; i<${#TEXT}; i++ )); do
  if [ $MOD_INDEX -eq 31 ]; then
    MOD_INDEX=0
    CURRENT_INDEX=$((CURRENT_INDEX+1))
  fi

  GROUPED_TEXTS[$CURRENT_INDEX]="${GROUPED_TEXTS[$CURRENT_INDEX]}${TEXT:$i:1}"

  MOD_INDEX=$((MOD_INDEX+1))
done

CAIRO_STRINGS=()
for (( i=0; i<${#GROUPED_TEXTS[@]}; i++ )); do
  CAIRO_STRINGS[$i]=$(starkli to-cairo-string "${GROUPED_TEXTS[$i]}")
done

BYTE_ARRAY="["
# If current index is 0, then we only have one string
if [ $CURRENT_INDEX -eq 0 ]; then
  BYTE_ARRAY="${BYTE_ARRAY}[],"
else
  BYTE_ARRAY="${BYTE_ARRAY}["
  for (( i=0; i<$CURRENT_INDEX; i++ )); do
    CAIRO_STRING_UPPER=$(echo ${CAIRO_STRINGS[$i]} | sed 's/0x//g' | tr '[:lower:]' '[:upper:]')
    DECIMAL_VALUE=$(echo "ibase=16; ${CAIRO_STRING_UPPER}" | bc | tr -d '\\\n')
    BYTE_ARRAY="${BYTE_ARRAY}\"${DECIMAL_VALUE}\""
    if [ $i -lt $((CURRENT_INDEX-1)) ]; then
      BYTE_ARRAY="${BYTE_ARRAY},"
    fi
  done
  BYTE_ARRAY="${BYTE_ARRAY}],"
fi

# Add last element
if [ $MOD_INDEX -eq 0 ]; then
  BYTE_ARRAY="${BYTE_ARRAY}0,0]"
else
  CAIRO_STRING_UPPER=$(echo ${CAIRO_STRINGS[$CURRENT_INDEX]} | sed 's/0x//g' | tr '[:lower:]' '[:upper:]')
  DECIMAL_VALUE=$(echo "ibase=16; ${CAIRO_STRING_UPPER}" | bc | tr -d '\\\n')
  BYTE_ARRAY="${BYTE_ARRAY}\"${DECIMAL_VALUE}\",$MOD_INDEX]"
fi

echo $BYTE_ARRAY
