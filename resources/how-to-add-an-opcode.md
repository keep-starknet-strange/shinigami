## How to add an opcode to "Shinigami"

1. Understand how the opcode works by looking at documentation:
  - [Bitcoin Script Wiki](https://en.bitcoin.it/wiki/Script)
  - [Reference implementation in btcd](https://github.com/btcsuite/btcd/blob/b161cd6a199b4e35acec66afc5aad221f05fe1e3/txscript/opcode.go#L312)
  - In btcd find the function that matches the last element in `opcodeArray` for the specified opcode, that will be the reference implementation.
1. Add the Opcode to `src/opcodes/opcodes.cairo`.
  - Add the Opcode byte const like `pub const OP_ADD: u8 = 147;`
  - Create the function implementing the opcode like `fn opcode_add(ref engine: Engine) {`
  - Add the function to the `execute` method like `147 => opcode_add(ref engine),`
1. Add the Opcode to the compiler dict at `src/compiler.cairo` like `opcodes.insert('OP_ADD', Opcode::OP_ADD);`.
1. Create a test for your opcode at `src/opcodes/tests/test_opcodes.cairo` and ensure all the logic works as expected.
1. Create a PR, ensure CI passes, and await review.
