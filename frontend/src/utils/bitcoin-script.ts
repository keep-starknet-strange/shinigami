export const bitcoinScriptLanguage = {
  tokenizer: {
    root: [
      [/\/\/.*/, "comment"],
      [/OP_CAT/, "special-keyword"],
      [/OP_[A-Z0-9_]+/, "keyword"],
      // Strings can be like: <'hello'>, <"hello">, 'hello', "hello"
      [/<'[^']+'>/, "string"],
      [/<"[^"]+">/, "string"],
      [/"[^"]+"/, "string"],
      [/'[^']+'/, "string"],
      // Numbers can be like: 0x123, 123, -123, <123>
      [/0x[0-9a-fA-f]+/, "number"],
      [/[0-9]+/, "number"],
      [/-[0-9]+/, "number"],
      [/<[0-9]+>/, "number"],
      // Anything else is invalid
      [/[^\s]+/, "error"],
    ],
  },
};

// TODO: Pull from compiler instead of opcodes
export const bitcoinScriptOpcodes = [
  {
    label: "OP_0",
    description: "An empty array of bytes is pushed onto the stack. (This is not a no-op: an item is added to the stack.)"
  },
  {
    label: "OP_DATA_1",
    description: "Pushes 1 byte of data onto the stack."
  },
  {
    label: "OP_DATA_2",
    description: "Pushes 2 bytes of data onto the stack."
  },
  {
    label: "OP_DATA_3",
    description: "Pushes 3 bytes of data onto the stack."
  },
  {
    label: "OP_DATA_4",
    description: "Pushes 4 bytes of data onto the stack."
  },
  {
    label: "OP_DATA_5",
    description: "Pushes 5 bytes of data onto the stack."
  },
  {
    label: "OP_DATA_6",
    description: "Pushes 6 bytes of data onto the stack."
  },
  {
    label: "OP_DATA_7",
    description: "Pushes 7 bytes of data onto the stack."
  },
  {
    label: "OP_DATA_8",
    description: "Pushes 8 bytes of data onto the stack."
  },
  {
    label: "OP_DATA_9",
    description: "Pushes 9 bytes of data onto the stack."
  },
  {
    label: "OP_DATA_10",
    description: "Pushes 10 bytes of data onto the stack."
  },
  {
    label: "OP_DATA_11",
    description: "Pushes 11 bytes of data onto the stack."
  },
  {
    label: "OP_DATA_12",
    description: "Pushes 12 bytes of data onto the stack."
  },
  {
    label: "OP_DATA_13",
    description: "Pushes 13 bytes of data onto the stack."
  },
  {
    label: "OP_DATA_14",
    description: "Pushes 14 bytes of data onto the stack."
  },
  {
    label: "OP_DATA_15",
    description: "Pushes 15 bytes of data onto the stack."
  },
  {
    label: "OP_DATA_16",
    description: "Pushes 16 bytes of data onto the stack."
  },
  {
    label: "OP_PUSHDATA1",
    description: "Pushes up to 255 bytes of data onto the stack."
  },
  {
    label: "OP_PUSHDATA2",
    description: "Pushes up to 65535 bytes of data onto the stack."
  },
  {
    label: "OP_PUSHDATA4",
    description: "Pushes up to 4,294,967,295 bytes of data onto the stack."
  },
  {
    label: "OP_1NEGATE",
    description: "Pushes the number -1 onto the stack."
  },
  {
    label: "OP_RESERVED",
    description: "Reserved opcode. Invalid if executed."
  },
  {
    label: "OP_TRUE",
    description: "Pushes the number 1 onto the stack."
  },
  {
    label: "OP_1",
    description: "Alias for OP_TRUE. Pushes the number 1 onto the stack."
  },
  {
    label: "OP_2",
    description: "Pushes the number 2 onto the stack."
  },
  {
    label: "OP_3",
    description: "Pushes the number 3 onto the stack."
  },
  {
    label: "OP_4",
    description: "Pushes the number 4 onto the stack."
  },
  {
    label: "OP_5",
    description: "Pushes the number 5 onto the stack."
  },
  {
    label: "OP_6",
    description: "Pushes the number 6 onto the stack."
  },
  {
    label: "OP_7",
    description: "Pushes the number 7 onto the stack."
  },
  {
    label: "OP_8",
    description: "Pushes the number 8 onto the stack."
  },
  {
    label: "OP_9",
    description: "Pushes the number 9 onto the stack."
  },
  {
    label: "OP_10",
    description: "Pushes the number 10 onto the stack."
  },
  {
    label: "OP_11",
    description: "Pushes the number 11 onto the stack."
  },
  {
    label: "OP_12",
    description: "Pushes the number 12 onto the stack."
  },
  {
    label: "OP_13",
    description: "Pushes the number 13 onto the stack."
  },
  {
    label: "OP_14",
    description: "Pushes the number 14 onto the stack."
  },
  {
    label: "OP_15",
    description: "Pushes the number 15 onto the stack."
  },
  {
    label: "OP_16",
    description: "Pushes the number 16 onto the stack."
  },
  {
    label: "OP_NOP",
    description: "Does nothing."
  },
  {
    label: "OP_VER",
    description: "Reserved opcode. Invalid if executed."
  },
  {
    label: "OP_IF",
    description: "If the top stack value is not 0, the statements are executed. The value is removed."
  },
  {
    label: "OP_NOTIF",
    description: "If the top stack value is 0, the statements are executed. The value is removed."
  },
  {
    label: "OP_VERIF",
    description: "Reserved opcode. Invalid if executed."
  },
  {
    label: "OP_VERNOTIF",
    description: "Reserved opcode. Invalid if executed."
  },
  {
    label: "OP_ELSE",
    description: "Marks the beginning of the else branch of an if statement."
  },
  {
    label: "OP_ENDIF",
    description: "Marks the end of an if/else block."
  },
  {
    label: "OP_VERIFY",
    description: "Fails the script if the top stack value is not true."
  },
  {
    label: "OP_RETURN",
    description: "Marks the end of a script. When executed, the script fails immediately."
  },
  {
    label: "OP_TOALTSTACK",
    description: "Puts the top stack item onto the alternate stack."
  },
  {
    label: "OP_FROMALTSTACK",
    description: "Puts the top item on the alternate stack back onto the main stack."
  },
  {
    label: "OP_2DROP",
    description: "Removes the top two stack items."
  },
  {
    label: "OP_2DUP",
    description: "Duplicates the top two stack items."
  },
  {
    label: "OP_3DUP",
    description: "Duplicates the top three stack items."
  },
  {
    label: "OP_2OVER",
    description: "Copies the 3rd and 4th items to the top of the stack."
  },
  {
    label: "OP_2ROT",
    description: "Moves the 5th and 6th items to the top of the stack."
  },
  {
    label: "OP_2SWAP",
    description: "Swaps the top two pairs of items."
  },
  {
    label: "OP_IFDUP",
    description: "Duplicates the top stack item if it is not 0."
  },
  {
    label: "OP_DEPTH",
    description: "Pushes the number of stack items onto the stack."
  },
  {
    label: "OP_DROP",
    description: "Removes the top stack item."
  },
  {
    label: "OP_DUP",
    description: "Duplicates the top stack item."
  },
  {
    label: "OP_NIP",
    description: "Removes the second-to-top stack item."
  },
  {
    label: "OP_OVER",
    description: "Copies the second-to-top stack item to the top."
  },
  {
    label: "OP_PICK",
    description: "Copies an item from the stack based on a provided index."
  },
  {
    label: "OP_ROLL",
    description: "Moves an item from the stack to the top, based on a provided index."
  },
  {
    label: "OP_ROT",
    description: "Rotates the top three items on the stack."
  },
  {
    label: "OP_SWAP",
    description: "Swaps the top two items on the stack."
  },
  {
    label: "OP_TUCK",
    description: "Copies the top item and inserts it before the second-to-top item."
  },
  {
    label: "OP_CAT",
    description: "Concatenates two strings (Disabled)."
  },
  {
    label: "OP_SUBSTR",
    description: "Returns a section of a string (Disabled)."
  },
  {
    label: "OP_LEFT",
    description: "Returns the left part of a string (Disabled)."
  },
  {
    label: "OP_RIGHT",
    description: "Returns the right part of a string (Disabled)."
  },
  {
    label: "OP_SIZE",
    description: "Pushes the string length of the top element of the stack."
  },
  {
    label: "OP_INVERT",
    description: "Flips all of the bits in the input (Disabled)."
  },
  {
    label: "OP_AND",
    description: "Boolean AND between each bit of the inputs (Disabled)."
  },
  {
    label: "OP_OR",
    description: "Boolean OR between each bit of the inputs (Disabled)."
  },
  {
    label: "OP_XOR",
    description: "Boolean XOR between each bit of the inputs (Disabled)."
  },
  {
    label: "OP_EQUAL",
    description: "Returns 1 if the inputs are exactly equal, 0 otherwise."
  },
  {
    label: "OP_EQUALVERIFY",
    description: "Same as OP_EQUAL, but runs OP_VERIFY afterward."
  },
  {
    label: "OP_RESERVED1",
    description: "Reserved opcode. Invalid if executed."
  },
  {
    label: "OP_RESERVED2",
    description: "Reserved opcode. Invalid if executed."
  },
  {
    label: "OP_1ADD",
    description: "Adds 1 to the top item."
  },
  {
    label: "OP_1SUB",
    description: "Subtracts 1 from the top item."
  },
  {
    label: "OP_2MUL",
    description: "Multiplies the top item by 2 (Disabled)."
  },
  {
    label: "OP_2DIV",
    description: "Divides the top item by 2 (Disabled)."
  },
  {
    label: "OP_NEGATE",
    description: "Negates the top item."
  },
  {
    label: "OP_ABS",
    description: "Pushes the absolute value of the top item."
  },
  {
    label: "OP_NOT",
    description: "If the input is 0, pushes 1; otherwise, pushes 0."
  },
  {
    label: "OP_0NOTEQUAL",
    description: "Returns 0 if the input is 0. Otherwise, returns 1."
  },
  {
    label: "OP_ADD",
    description: "Adds the top two items."
  },
  {
    label: "OP_SUB",
    description: "Subtracts the top two items."
  },
  {
    label: "OP_MUL",
    description: "Multiplies the top two items (Disabled)."
  },
  {
    label: "OP_DIV",
    description: "Divides the top two items (Disabled)."
  },
  {
    label: "OP_MOD",
    description: "Returns the remainder after dividing the top two items (Disabled)."
  },
  {
    label: "OP_LSHIFT",
    description: "Shifts the top item to the left (Disabled)."
  },
  {
    label: "OP_RSHIFT",
    description: "Shifts the top item to the right (Disabled)."
  },
  {
    label: "OP_BOOLAND",
    description: "Boolean AND across the top two items."
  },
  {
    label: "OP_BOOLOR",
    description: "Boolean OR across the top two items."
  },
  {
    label: "OP_NUMEQUAL",
    description: "Returns 1 if the top two items are equal, 0 otherwise."
  },
  {
    label: "OP_NUMEQUALVERIFY",
    description: "Same as OP_NUMEQUAL, but runs OP_VERIFY afterward."
  },
  {
    label: "OP_NUMNOTEQUAL",
    description: "Returns 1 if the top two items are not equal."
  },
  {
    label: "OP_LESSTHAN",
    description: "Returns 1 if the second item is less than the top item."
  },
  {
    label: "OP_GREATERTHAN",
    description: "Returns 1 if the second item is greater than the top item."
  },
  {
    label: "OP_LESSTHANOREQUAL",
    description: "Returns 1 if the second item is less than or equal to the top item."
  },
  {
    label: "OP_GREATERTHANOREQUAL",
    description: "Returns 1 if the second item is greater than or equal to the top item."
  },
  {
    label: "OP_MIN",
    description: "Returns the smaller of the top two items."
  },
  {
    label: "OP_MAX",
    description: "Returns the larger of the top two items."
  },
  {
    label: "OP_WITHIN",
    description: "Returns 1 if the second item is between the top two items."
  },
  {
    label: "OP_RIPEMD160",
    description: "Hashes the top item using RIPEMD-160."
  },
  {
    label: "OP_SHA1",
    description: "Hashes the top item using SHA-1."
  },
  {
    label: "OP_SHA256",
    description: "Hashes the top item using SHA-256."
  },
  {
    label: "OP_HASH160",
    description: "Hashes the top item using SHA-256 and then RIPEMD-160."
  },
  {
    label: "OP_HASH256",
    description: "Hashes the top item twice using SHA-256."
  },
  {
    label: "OP_CODESEPARATOR",
    description: "Marks a point after which the script is evaluated."
  },
  {
    label: "OP_CHECKSIG",
    description: "Checks whether the signature is valid for the top public key and message."
  },
  {
    label: "OP_CHECKSIGVERIFY",
    description: "Same as OP_CHECKSIG, but runs OP_VERIFY afterward."
  },
  {
    label: "OP_CHECKMULTISIG",
    description: "Checks whether the signatures are valid for the top public keys and message."
  },
  {
    label: "OP_CHECKMULTISIGVERIFY",
    description: "Same as OP_CHECKMULTISIG, but runs OP_VERIFY afterward."
  },
  {
    label: "OP_NOP1",
    description: "Does nothing."
  },
  {
    label: "OP_CHECKLOCKTIMEVERIFY",
    description: "Verifies the locktime before the transaction can be valid."
  },
  {
    label: "OP_CHECKSEQUENCEVERIFY",
    description: "Verifies the relative locktime before the transaction can be valid."
  },
  {
    label: "OP_NOP4",
    description: "Does nothing."
  },
  {
    label: "OP_NOP5",
    description: "Does nothing."
  },
  {
    label: "OP_NOP6",
    description: "Does nothing."
  },
  {
    label: "OP_NOP7",
    description: "Does nothing."
  },
  {
    label: "OP_NOP8",
    description: "Does nothing."
  },
  {
    label: "OP_NOP9",
    description: "Does nothing."
  },
  {
    label: "OP_NOP10",
    description: "Does nothing."
  }
];
