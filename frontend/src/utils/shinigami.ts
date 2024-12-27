// shinigami.ts - Part 1

// Constants
const MAX_STACK_SIZE = 1000;
const MAX_SCRIPT_SIZE = 10000;
const MAX_OPS_PER_SCRIPT = 201;
const MAX_SCRIPT_ELEMENT_SIZE = 520;
const MAX_MULTISIG_PUBKEYS = 20;

// Crypto imports
import * as crypto from 'crypto';

// Types
interface InputData {
    ScriptSig: string;
    ScriptPubKey: string;
}

enum Opcode {
    // Constants
    OP_0 = 0x00,
    OP_FALSE = 0x00,
    OP_PUSHDATA1 = 0x4c,
    OP_PUSHDATA2 = 0x4d,
    OP_PUSHDATA4 = 0x4e,
    OP_1NEGATE = 0x4f,
    OP_RESERVED = 0x50,
    OP_1 = 0x51,
    OP_TRUE = 0x51,
    OP_2 = 0x52,
    OP_3 = 0x53,
    OP_4 = 0x54,
    OP_5 = 0x55,
    OP_6 = 0x56,
    OP_7 = 0x57,
    OP_8 = 0x58,
    OP_9 = 0x59,
    OP_10 = 0x5a,
    OP_11 = 0x5b,
    OP_12 = 0x5c,
    OP_13 = 0x5d,
    OP_14 = 0x5e,
    OP_15 = 0x5f,
    OP_16 = 0x60,

    // Flow control
    OP_NOP = 0x61,
    OP_VER = 0x62,
    OP_IF = 0x63,
    OP_NOTIF = 0x64,
    OP_VERIF = 0x65,
    OP_VERNOTIF = 0x66,
    OP_ELSE = 0x67,
    OP_ENDIF = 0x68,
    OP_VERIFY = 0x69,
    OP_RETURN = 0x6a,

    // Stack
    OP_TOALTSTACK = 0x6b,
    OP_FROMALTSTACK = 0x6c,
    OP_2DROP = 0x6d,
    OP_2DUP = 0x6e,
    OP_3DUP = 0x6f,
    OP_2OVER = 0x70,
    OP_2ROT = 0x71,
    OP_2SWAP = 0x72,
    OP_IFDUP = 0x73,
    OP_DEPTH = 0x74,
    OP_DROP = 0x75,
    OP_DUP = 0x76,
    OP_NIP = 0x77,
    OP_OVER = 0x78,
    OP_PICK = 0x79,
    OP_ROLL = 0x7a,
    OP_ROT = 0x7b,
    OP_SWAP = 0x7c,
    OP_TUCK = 0x7d,

    // Splice
    OP_CAT = 0x7e,
    OP_SUBSTR = 0x7f,
    OP_LEFT = 0x80,
    OP_RIGHT = 0x81,
    OP_SIZE = 0x82,

    // Bitwise logic
    OP_INVERT = 0x83,
    OP_AND = 0x84,
    OP_OR = 0x85,
    OP_XOR = 0x86,
    OP_EQUAL = 0x87,
    OP_EQUALVERIFY = 0x88,
    OP_RESERVED1 = 0x89,
    OP_RESERVED2 = 0x8a,

    // Arithmetic
    OP_1ADD = 0x8b,
    OP_1SUB = 0x8c,
    OP_2MUL = 0x8d,
    OP_2DIV = 0x8e,
    OP_NEGATE = 0x8f,
    OP_ABS = 0x90,
    OP_NOT = 0x91,
    OP_0NOTEQUAL = 0x92,
    OP_ADD = 0x93,
    OP_SUB = 0x94,
    OP_MUL = 0x95,
    OP_DIV = 0x96,
    OP_MOD = 0x97,
    OP_LSHIFT = 0x98,
    OP_RSHIFT = 0x99,
    OP_BOOLAND = 0x9a,
    OP_BOOLOR = 0x9b,
    OP_NUMEQUAL = 0x9c,
    OP_NUMEQUALVERIFY = 0x9d,
    OP_NUMNOTEQUAL = 0x9e,
    OP_LESSTHAN = 0x9f,
    OP_GREATERTHAN = 0xa0,
    OP_LESSTHANOREQUAL = 0xa1,
    OP_GREATERTHANOREQUAL = 0xa2,
    OP_MIN = 0xa3,
    OP_MAX = 0xa4,
    OP_WITHIN = 0xa5,

    // Crypto
    OP_RIPEMD160 = 0xa6,
    OP_SHA1 = 0xa7,
    OP_SHA256 = 0xa8,
    OP_HASH160 = 0xa9,
    OP_HASH256 = 0xaa,
    OP_CODESEPARATOR = 0xab,
    OP_CHECKSIG = 0xac,
    OP_CHECKSIGVERIFY = 0xad,
    OP_CHECKMULTISIG = 0xae,
    OP_CHECKMULTISIGVERIFY = 0xaf,

    // Expansion
    OP_NOP1 = 0xb0,
    OP_CHECKLOCKTIMEVERIFY = 0xb1,
    OP_CHECKSEQUENCEVERIFY = 0xb2,
    OP_NOP4 = 0xb3,
    OP_NOP5 = 0xb4,
    OP_NOP6 = 0xb5,
    OP_NOP7 = 0xb6,
    OP_NOP8 = 0xb7,
    OP_NOP9 = 0xb8,
    OP_NOP10 = 0xb9,
}

// Error messages
const ERROR = {
    SCRIPT_ERR_OK: "No error",
    SCRIPT_ERR_UNKNOWN_ERROR: "Unknown error",
    SCRIPT_ERR_EVAL_FALSE: "Script evaluated without error but finished with a false/empty top stack element",
    SCRIPT_ERR_VERIFY: "Script failed an OP_VERIFY operation",
    SCRIPT_ERR_INVALID_STACK_OPERATION: "Invalid stack operation",
    SCRIPT_ERR_INVALID_ALTSTACK_OPERATION: "Invalid altstack operation",
    SCRIPT_ERR_UNBALANCED_CONDITIONAL: "Unbalanced conditional",
    SCRIPT_ERR_INVALID_NUMBER_RANGE: "Given number is out of range",
    SCRIPT_ERR_INVALID_OPCODE: "Invalid opcode",
    SCRIPT_ERR_DISABLED_OPCODE: "Disabled opcode",
    SCRIPT_ERR_INVALID_STACK_SIZE: "Invalid stack size",
    SCRIPT_ERR_INVALID_ALTSTACK_SIZE: "Invalid altstack size",
    SCRIPT_ERR_INVALID_OPCODE_COUNT: "Invalid opcode count",
    SCRIPT_ERR_PUSH_SIZE: "Push size exceeded",
    SCRIPT_ERR_OP_COUNT: "Operation count exceeded",
    SCRIPT_ERR_STACK_SIZE: "Stack size exceeded",
    SCRIPT_ERR_SCRIPT_SIZE: "Script size exceeded",
    SCRIPT_ERR_PUBKEY_COUNT: "Public key count exceeded",
    SCRIPT_ERR_SIG_COUNT: "Signature count exceeded",
    SCRIPT_ERR_INVALID_OPERAND_SIZE: "Invalid operand size",
};

// Script flags
const ScriptFlags = {
    SCRIPT_VERIFY_NONE: 0,
    SCRIPT_VERIFY_P2SH: (1 << 0),
    SCRIPT_VERIFY_STRICTENC: (1 << 1),
    SCRIPT_VERIFY_DERSIG: (1 << 2),
    SCRIPT_VERIFY_LOW_S: (1 << 3),
    SCRIPT_VERIFY_NULLDUMMY: (1 << 4),
    SCRIPT_VERIFY_SIGPUSHONLY: (1 << 5),
    SCRIPT_VERIFY_MINIMALDATA: (1 << 6),
    SCRIPT_VERIFY_DISCOURAGE_UPGRADABLE_NOPS: (1 << 7),
    SCRIPT_VERIFY_CLEANSTACK: (1 << 8),
    SCRIPT_VERIFY_CHECKLOCKTIMEVERIFY: (1 << 9),
    SCRIPT_VERIFY_CHECKSEQUENCEVERIFY: (1 << 10),
    SCRIPT_VERIFY_WITNESS: (1 << 11),
    SCRIPT_VERIFY_DISCOURAGE_UPGRADABLE_WITNESS_PROGRAM: (1 << 12),
    SCRIPT_VERIFY_MINIMALIF: (1 << 13),
    SCRIPT_VERIFY_NULLFAIL: (1 << 14),
    SCRIPT_VERIFY_WITNESS_PUBKEYTYPE: (1 << 15),
    SCRIPT_VERIFY_CONST_SCRIPTCODE: (1 << 16),
};

// shinigami.ts - Part 2

// ScriptNum implementation for handling Bitcoin script numbers
class ScriptNum {
    private value: bigint;
    private static readonly MAX_NUM_SIZE = 4;

    constructor(value: number | bigint | Buffer) {
        if (Buffer.isBuffer(value)) {
            this.value = ScriptNum.fromBuffer(value);
        } else {
            this.value = BigInt(value);
        }
    }

    static fromBuffer(buf: Buffer, fRequireMinimal: boolean = true, nMaxNumSize: number = ScriptNum.MAX_NUM_SIZE): bigint {
        if (buf.length > nMaxNumSize) {
            throw new Error(ERROR.SCRIPT_ERR_INVALID_NUMBER_RANGE);
        }

        if (fRequireMinimal && buf.length > 0) {
            // Check that the number is encoded with the minimum possible number of bytes
            if ((buf[buf.length - 1] & 0x7f) === 0 && 
                (buf.length <= 1 || (buf[buf.length - 2] & 0x80) === 0)) {
                throw new Error(ERROR.SCRIPT_ERR_INVALID_NUMBER_RANGE);
            }
        }

        let result = BigInt(0);
        for (let i = 0; i < buf.length; i++) {
            result |= BigInt(buf[i]) << BigInt(8 * i);
        }

        // If the most significant byte is >= 0x80, then we have a negative number
        if (buf.length > 0 && (buf[buf.length - 1] & 0x80) !== 0) {
            result &= (BigInt(1) << BigInt(8 * buf.length - 1)) - BigInt(1);
            result = -result;
        }

        return result;
    }

    toBuffer(): Buffer {
        if (this.value === BigInt(0)) return Buffer.alloc(0);

        const negative = this.value < BigInt(0);
        let absValue = negative ? -this.value : this.value;
        const result: number[] = [];

        while (absValue > BigInt(0)) {
            result.push(Number(absValue & BigInt(0xff)));
            absValue >>= BigInt(8);
        }

        if ((result[result.length - 1] & 0x80) !== 0) {
            result.push(negative ? 0x80 : 0x00);
        } else if (negative) {
            result[result.length - 1] |= 0x80;
        }

        return Buffer.from(result);
    }

    toNumber(): number {
        return Number(this.value);
    }

    toBigInt(): bigint {
        return this.value;
    }
}

// Stack implementation
class Stack {
    private items: Buffer[] = [];

    push(item: Buffer): void {
        if (this.items.length >= MAX_STACK_SIZE) {
            throw new Error(ERROR.SCRIPT_ERR_STACK_SIZE);
        }
        if (item.length > MAX_SCRIPT_ELEMENT_SIZE) {
            throw new Error(ERROR.SCRIPT_ERR_PUSH_SIZE);
        }
        this.items.push(item);
    }

    pop(): Buffer {
        if (this.items.length === 0) {
            throw new Error(ERROR.SCRIPT_ERR_INVALID_STACK_OPERATION);
        }
        return this.items.pop()!;
    }

    peek(index: number = 0): Buffer {
        if (index >= this.items.length) {
            throw new Error(ERROR.SCRIPT_ERR_INVALID_STACK_OPERATION);
        }
        return this.items[this.items.length - 1 - index];
    }

    size(): number {
        return this.items.length;
    }

    clear(): void {
        this.items = [];
    }

    removeAt(index: number): Buffer {
        if (index >= this.items.length) {
            throw new Error(ERROR.SCRIPT_ERR_INVALID_STACK_OPERATION);
        }
        return this.items.splice(this.items.length - 1 - index, 1)[0];
    }

    insertAt(index: number, item: Buffer): void {
        if (index >= this.items.length) {
            throw new Error(ERROR.SCRIPT_ERR_INVALID_STACK_OPERATION);
        }
        this.items.splice(this.items.length - 1 - index, 0, item);
    }

    asArray(): Buffer[] {
        return [...this.items];
    }
}

// Hash functions
class HashUtils {
    static ripemd160(data: Buffer): Buffer {
        return crypto.createHash('ripemd160').update(data).digest();
    }

    static sha1(data: Buffer): Buffer {
        return crypto.createHash('sha1').update(data).digest();
    }

    static sha256(data: Buffer): Buffer {
        return crypto.createHash('sha256').update(data).digest();
    }

    static hash160(data: Buffer): Buffer {
        return this.ripemd160(this.sha256(data));
    }

    static hash256(data: Buffer): Buffer {
        return this.sha256(this.sha256(data));
    }
}

// Signature verification
class SignatureChecker {
    static verifySignature(pubKey: Buffer, signature: Buffer, message: Buffer): boolean {
        try {
            if (signature.length === 0) return false;
            
            // Extract DER signature and hash type
            const hashType = signature[signature.length - 1];
            const derSignature = signature.slice(0, -1);

            // Verify using crypto module
            const verify = crypto.createVerify('SHA256');
            verify.update(message);
            return verify.verify(pubKey, derSignature);
        } catch (error) {
            return false;
        }
    }

    static verifyMultisig(
        pubKeys: Buffer[],
        signatures: Buffer[],
        message: Buffer
    ): boolean {
        let sigIndex = 0;
        let keyIndex = 0;

        while (sigIndex < signatures.length && keyIndex < pubKeys.length) {
            if (this.verifySignature(pubKeys[keyIndex], signatures[sigIndex], message)) {
                sigIndex++;
            }
            keyIndex++;
        }

        return sigIndex === signatures.length;
    }
}

// shinigami.ts - Part 3

// Compiler class for converting script text to bytecode
class Compiler {
    private static readonly opcodeMap: Map<string, number> = new Map([
        // Constants
        ['OP_0', Opcode.OP_0],
        ['OP_FALSE', Opcode.OP_FALSE],
        ['OP_PUSHDATA1', Opcode.OP_PUSHDATA1],
        ['OP_PUSHDATA2', Opcode.OP_PUSHDATA2],
        ['OP_PUSHDATA4', Opcode.OP_PUSHDATA4],
        ['OP_1NEGATE', Opcode.OP_1NEGATE],
        ['OP_RESERVED', Opcode.OP_RESERVED],
        ['OP_1', Opcode.OP_1],
        ['OP_TRUE', Opcode.OP_TRUE],
        ['OP_2', Opcode.OP_2],
        ['OP_3', Opcode.OP_3],
        ['OP_4', Opcode.OP_4],
        ['OP_5', Opcode.OP_5],
        ['OP_6', Opcode.OP_6],
        ['OP_7', Opcode.OP_7],
        ['OP_8', Opcode.OP_8],
        ['OP_9', Opcode.OP_9],
        ['OP_10', Opcode.OP_10],
        ['OP_11', Opcode.OP_11],
        ['OP_12', Opcode.OP_12],
        ['OP_13', Opcode.OP_13],
        ['OP_14', Opcode.OP_14],
        ['OP_15', Opcode.OP_15],
        ['OP_16', Opcode.OP_16],

        // Flow control
        ['OP_NOP', Opcode.OP_NOP],
        ['OP_VER', Opcode.OP_VER],
        ['OP_IF', Opcode.OP_IF],
        ['OP_NOTIF', Opcode.OP_NOTIF],
        ['OP_VERIF', Opcode.OP_VERIF],
        ['OP_VERNOTIF', Opcode.OP_VERNOTIF],
        ['OP_ELSE', Opcode.OP_ELSE],
        ['OP_ENDIF', Opcode.OP_ENDIF],
        ['OP_VERIFY', Opcode.OP_VERIFY],
        ['OP_RETURN', Opcode.OP_RETURN],

        // Stack
        ['OP_TOALTSTACK', Opcode.OP_TOALTSTACK],
        ['OP_FROMALTSTACK', Opcode.OP_FROMALTSTACK],
        ['OP_2DROP', Opcode.OP_2DROP],
        ['OP_2DUP', Opcode.OP_2DUP],
        ['OP_3DUP', Opcode.OP_3DUP],
        ['OP_2OVER', Opcode.OP_2OVER],
        ['OP_2ROT', Opcode.OP_2ROT],
        ['OP_2SWAP', Opcode.OP_2SWAP],
        ['OP_IFDUP', Opcode.OP_IFDUP],
        ['OP_DEPTH', Opcode.OP_DEPTH],
        ['OP_DROP', Opcode.OP_DROP],
        ['OP_DUP', Opcode.OP_DUP],
        ['OP_NIP', Opcode.OP_NIP],
        ['OP_OVER', Opcode.OP_OVER],
        ['OP_PICK', Opcode.OP_PICK],
        ['OP_ROLL', Opcode.OP_ROLL],
        ['OP_ROT', Opcode.OP_ROT],
        ['OP_SWAP', Opcode.OP_SWAP],
        ['OP_TUCK', Opcode.OP_TUCK],

        // Splice
        ['OP_CAT', Opcode.OP_CAT],
        ['OP_SUBSTR', Opcode.OP_SUBSTR],
        ['OP_LEFT', Opcode.OP_LEFT],
        ['OP_RIGHT', Opcode.OP_RIGHT],
        ['OP_SIZE', Opcode.OP_SIZE],

        // Bitwise logic
        ['OP_INVERT', Opcode.OP_INVERT],
        ['OP_AND', Opcode.OP_AND],
        ['OP_OR', Opcode.OP_OR],
        ['OP_XOR', Opcode.OP_XOR],
        ['OP_EQUAL', Opcode.OP_EQUAL],
        ['OP_EQUALVERIFY', Opcode.OP_EQUALVERIFY],

        // Arithmetic
        ['OP_1ADD', Opcode.OP_1ADD],
        ['OP_1SUB', Opcode.OP_1SUB],
        ['OP_2MUL', Opcode.OP_2MUL],
        ['OP_2DIV', Opcode.OP_2DIV],
        ['OP_NEGATE', Opcode.OP_NEGATE],
        ['OP_ABS', Opcode.OP_ABS],
        ['OP_NOT', Opcode.OP_NOT],
        ['OP_0NOTEQUAL', Opcode.OP_0NOTEQUAL],
        ['OP_ADD', Opcode.OP_ADD],
        ['OP_SUB', Opcode.OP_SUB],
        ['OP_MUL', Opcode.OP_MUL],
        ['OP_DIV', Opcode.OP_DIV],
        ['OP_MOD', Opcode.OP_MOD],
        ['OP_LSHIFT', Opcode.OP_LSHIFT],
        ['OP_RSHIFT', Opcode.OP_RSHIFT],
        ['OP_BOOLAND', Opcode.OP_BOOLAND],
        ['OP_BOOLOR', Opcode.OP_BOOLOR],
        ['OP_NUMEQUAL', Opcode.OP_NUMEQUAL],
        ['OP_NUMEQUALVERIFY', Opcode.OP_NUMEQUALVERIFY],
        ['OP_NUMNOTEQUAL', Opcode.OP_NUMNOTEQUAL],
        ['OP_LESSTHAN', Opcode.OP_LESSTHAN],
        ['OP_GREATERTHAN', Opcode.OP_GREATERTHAN],
        ['OP_LESSTHANOREQUAL', Opcode.OP_LESSTHANOREQUAL],
        ['OP_GREATERTHANOREQUAL', Opcode.OP_GREATERTHANOREQUAL],
        ['OP_MIN', Opcode.OP_MIN],
        ['OP_MAX', Opcode.OP_MAX],
        ['OP_WITHIN', Opcode.OP_WITHIN],

        // Crypto
        ['OP_RIPEMD160', Opcode.OP_RIPEMD160],
        ['OP_SHA1', Opcode.OP_SHA1],
        ['OP_SHA256', Opcode.OP_SHA256],
        ['OP_HASH160', Opcode.OP_HASH160],
        ['OP_HASH256', Opcode.OP_HASH256],
        ['OP_CODESEPARATOR', Opcode.OP_CODESEPARATOR],
        ['OP_CHECKSIG', Opcode.OP_CHECKSIG],
        ['OP_CHECKSIGVERIFY', Opcode.OP_CHECKSIGVERIFY],
        ['OP_CHECKMULTISIG', Opcode.OP_CHECKMULTISIG],
        ['OP_CHECKMULTISIGVERIFY', Opcode.OP_CHECKMULTISIGVERIFY],

        // Expansion
        ['OP_NOP1', Opcode.OP_NOP1],
        ['OP_CHECKLOCKTIMEVERIFY', Opcode.OP_CHECKLOCKTIMEVERIFY],
        ['OP_CHECKSEQUENCEVERIFY', Opcode.OP_CHECKSEQUENCEVERIFY],
        ['OP_NOP4', Opcode.OP_NOP4],
        ['OP_NOP5', Opcode.OP_NOP5],
        ['OP_NOP6', Opcode.OP_NOP6],
        ['OP_NOP7', Opcode.OP_NOP7],
        ['OP_NOP8', Opcode.OP_NOP8],
        ['OP_NOP9', Opcode.OP_NOP9],
        ['OP_NOP10', Opcode.OP_NOP10],
    ]);

    static compile(script: string): Buffer {
        const parts = script.trim().split(' ');
        const bytes: number[] = [];

        for (const part of parts) {
            if (part === '') continue;

            // Handle hex data
            if (part.startsWith('0x')) {
                const hex = part.slice(2);
                if (hex.length % 2 !== 0) {
                    throw new Error('Invalid hex string');
                }
                const data = Buffer.from(hex, 'hex');
                
                if (data.length <= 0x4b) {
                    bytes.push(data.length);
                } else if (data.length <= 0xff) {
                    bytes.push(Opcode.OP_PUSHDATA1);
                    bytes.push(data.length);
                } else if (data.length <= 0xffff) {
                    bytes.push(Opcode.OP_PUSHDATA2);
                    bytes.push(data.length & 0xff);
                    bytes.push((data.length >> 8) & 0xff);
                } else {
                    bytes.push(Opcode.OP_PUSHDATA4);
                    bytes.push(data.length & 0xff);
                    bytes.push((data.length >> 8) & 0xff);
                    bytes.push((data.length >> 16) & 0xff);
                    bytes.push((data.length >> 24) & 0xff);
                }
                bytes.push(...data);
                continue;
            }

            // Handle decimal numbers
            if (/^-?\d+$/.test(part)) {
                const num = parseInt(part, 10);
                const scriptNum = new ScriptNum(num);
                const numBuffer = scriptNum.toBuffer();
                
                if (numBuffer.length === 0) {
                    bytes.push(Opcode.OP_0);
                } else if (numBuffer.length === 1 && num >= 1 && num <= 16) {
                    bytes.push(Opcode.OP_1 + (num - 1));
                } else if (numBuffer.length === 1 && num === -1) {
                    bytes.push(Opcode.OP_1NEGATE);
                } else {
                    bytes.push(numBuffer.length);
                    bytes.push(...numBuffer);
                }
                continue;
            }

            // Handle opcodes
            const opcode = Compiler.opcodeMap.get(part);
            if (opcode === undefined) {
                throw new Error(`Unknown opcode: ${part}`);
            }
            bytes.push(opcode);
        }

        return Buffer.from(bytes);
    }
}

// shinigami.ts - Part 4

class ScriptEngine {
    private stack: Stack;
    private altStack: Stack;
    private script: Buffer;
    private pc: number;
    private opCount: number;
    private conditionalStack: boolean[];
    private hashCache: Map<string, Buffer>;

    constructor(script: Buffer) {
        this.stack = new Stack();
        this.altStack = new Stack();
        this.script = script;
        this.pc = 0;
        this.opCount = 0;
        this.conditionalStack = [];
        this.hashCache = new Map();
    }

    private readBytes(n: number): Buffer {
        if (this.pc + n > this.script.length) {
            throw new Error(ERROR.SCRIPT_ERR_INVALID_STACK_OPERATION);
        }
        const data = this.script.slice(this.pc, this.pc + n);
        this.pc += n;
        return data;
    }

    private pushInt(n: number): void {
        this.stack.push(new ScriptNum(n).toBuffer());
    }

    private popInt(): number {
        return new ScriptNum(this.stack.pop()).toNumber();
    }

    private popBool(): boolean {
        const buffer = this.stack.pop();
        for (let i = 0; i < buffer.length; i++) {
            if (buffer[i] !== 0) {
                // Can be negative zero
                if (i === buffer.length - 1 && buffer[i] === 0x80) {
                    return false;
                }
                return true;
            }
        }
        return false;
    }

    private executeOpcode(opcode: number): void {
        // Count non-push operations
        if (opcode > Opcode.OP_16) {
            this.opCount++;
            if (this.opCount > MAX_OPS_PER_SCRIPT) {
                throw new Error(ERROR.SCRIPT_ERR_OP_COUNT);
            }
        }

        switch (opcode) {
            // Constants
            case Opcode.OP_0:
                this.stack.push(Buffer.alloc(0));
                break;

            case Opcode.OP_1NEGATE:
                this.pushInt(-1);
                break;

            case Opcode.OP_1:
            case Opcode.OP_2:
            case Opcode.OP_3:
            case Opcode.OP_4:
            case Opcode.OP_5:
            case Opcode.OP_6:
            case Opcode.OP_7:
            case Opcode.OP_8:
            case Opcode.OP_9:
            case Opcode.OP_10:
            case Opcode.OP_11:
            case Opcode.OP_12:
            case Opcode.OP_13:
            case Opcode.OP_14:
            case Opcode.OP_15:
            case Opcode.OP_16:
                this.pushInt(opcode - (Opcode.OP_1 - 1));
                break;

            // Flow control
            case Opcode.OP_NOP:
                break;

            case Opcode.OP_IF:
            case Opcode.OP_NOTIF: {
                if (this.stack.size() < 1) {
                    throw new Error(ERROR.SCRIPT_ERR_INVALID_STACK_OPERATION);
                }
                const condition = this.popBool();
                this.conditionalStack.push(opcode === Opcode.OP_IF ? condition : !condition);
                break;
            }

            case Opcode.OP_ELSE: {
                if (this.conditionalStack.length === 0) {
                    throw new Error(ERROR.SCRIPT_ERR_UNBALANCED_CONDITIONAL);
                }
                this.conditionalStack[this.conditionalStack.length - 1] = 
                    !this.conditionalStack[this.conditionalStack.length - 1];
                break;
            }

            case Opcode.OP_ENDIF: {
                if (this.conditionalStack.length === 0) {
                    throw new Error(ERROR.SCRIPT_ERR_UNBALANCED_CONDITIONAL);
                }
                this.conditionalStack.pop();
                break;
            }

            case Opcode.OP_VERIFY: {
                if (this.stack.size() < 1) {
                    throw new Error(ERROR.SCRIPT_ERR_INVALID_STACK_OPERATION);
                }
                const value = this.popBool();
                if (!value) {
                    throw new Error(ERROR.SCRIPT_ERR_VERIFY);
                }
                break;
            }

            case Opcode.OP_RETURN:
                throw new Error(ERROR.SCRIPT_ERR_OP_RETURN);

            // Stack operations
            case Opcode.OP_TOALTSTACK:
                this.altStack.push(this.stack.pop());
                break;

            case Opcode.OP_FROMALTSTACK:
                this.stack.push(this.altStack.pop());
                break;

            case Opcode.OP_2DROP:
                this.stack.pop();
                this.stack.pop();
                break;

            case Opcode.OP_2DUP: {
                const v1 = this.stack.peek(1);
                const v2 = this.stack.peek(0);
                this.stack.push(Buffer.from(v1));
                this.stack.push(Buffer.from(v2));
                break;
            }

            case Opcode.OP_3DUP: {
                const v1 = this.stack.peek(2);
                const v2 = this.stack.peek(1);
                const v3 = this.stack.peek(0);
                this.stack.push(Buffer.from(v1));
                this.stack.push(Buffer.from(v2));
                this.stack.push(Buffer.from(v3));
                break;
            }

            case Opcode.OP_2OVER: {
                const v1 = this.stack.peek(3);
                const v2 = this.stack.peek(2);
                this.stack.push(Buffer.from(v1));
                this.stack.push(Buffer.from(v2));
                break;
            }

            case Opcode.OP_2ROT: {
                const v1 = this.stack.peek(5);
                const v2 = this.stack.peek(4);
                for (let i = 0; i < 4; i++) {
                    const temp = this.stack.pop();
                    this.stack.insertAt(1, temp);
                }
                this.stack.push(Buffer.from(v1));
                this.stack.push(Buffer.from(v2));
                break;
            }

            // shinigami.ts - Part 5 (continuing ScriptEngine class)

            case Opcode.OP_2SWAP: {
                const v1 = this.stack.pop();
                const v2 = this.stack.pop();
                const v3 = this.stack.pop();
                const v4 = this.stack.pop();
                this.stack.push(v2);
                this.stack.push(v1);
                this.stack.push(v4);
                this.stack.push(v3);
                break;
            }

            case Opcode.OP_IFDUP: {
                if (this.stack.size() < 1) {
                    throw new Error(ERROR.SCRIPT_ERR_INVALID_STACK_OPERATION);
                }
                const top = this.stack.peek();
                if (this.popBool()) {
                    this.stack.push(Buffer.from(top));
                }
                break;
            }

            case Opcode.OP_DEPTH:
                this.pushInt(this.stack.size());
                break;

            case Opcode.OP_DROP:
                this.stack.pop();
                break;

            case Opcode.OP_DUP:
                this.stack.push(Buffer.from(this.stack.peek()));
                break;

            case Opcode.OP_NIP: {
                const top = this.stack.pop();
                this.stack.pop();
                this.stack.push(top);
                break;
            }

            case Opcode.OP_OVER:
                this.stack.push(Buffer.from(this.stack.peek(1)));
                break;

            case Opcode.OP_PICK: {
                const n = this.popInt();
                if (n < 0 || n >= this.stack.size()) {
                    throw new Error(ERROR.SCRIPT_ERR_INVALID_STACK_OPERATION);
                }
                this.stack.push(Buffer.from(this.stack.peek(n)));
                break;
            }

            case Opcode.OP_ROLL: {
                const n = this.popInt();
                if (n < 0 || n >= this.stack.size()) {
                    throw new Error(ERROR.SCRIPT_ERR_INVALID_STACK_OPERATION);
                }
                const val = this.stack.removeAt(n);
                this.stack.push(val);
                break;
            }

            case Opcode.OP_ROT: {
                const v3 = this.stack.pop();
                const v2 = this.stack.pop();
                const v1 = this.stack.pop();
                this.stack.push(v2);
                this.stack.push(v3);
                this.stack.push(v1);
                break;
            }

            case Opcode.OP_SWAP: {
                const v2 = this.stack.pop();
                const v1 = this.stack.pop();
                this.stack.push(v2);
                this.stack.push(v1);
                break;
            }

            case Opcode.OP_TUCK: {
                const v2 = this.stack.pop();
                const v1 = this.stack.pop();
                this.stack.push(v2);
                this.stack.push(v1);
                this.stack.push(Buffer.from(v2));
                break;
            }

            // Arithmetic Operations
            case Opcode.OP_1ADD:
                this.pushInt(this.popInt() + 1);
                break;

            case Opcode.OP_1SUB:
                this.pushInt(this.popInt() - 1);
                break;

            case Opcode.OP_NEGATE:
                this.pushInt(-this.popInt());
                break;

            case Opcode.OP_ABS:
                this.pushInt(Math.abs(this.popInt()));
                break;

            case Opcode.OP_NOT:
                this.pushInt(this.popInt() === 0 ? 1 : 0);
                break;

            case Opcode.OP_0NOTEQUAL:
                this.pushInt(this.popInt() === 0 ? 0 : 1);
                break;

            case Opcode.OP_ADD: {
                const b = this.popInt();
                const a = this.popInt();
                this.pushInt(a + b);
                break;
            }

            case Opcode.OP_SUB: {
                const b = this.popInt();
                const a = this.popInt();
                this.pushInt(a - b);
                break;
            }

            case Opcode.OP_MUL: {
                const b = this.popInt();
                const a = this.popInt();
                this.pushInt(a * b);
                break;
            }

            case Opcode.OP_DIV: {
                const b = this.popInt();
                const a = this.popInt();
                if (b === 0) {
                    throw new Error(ERROR.SCRIPT_ERR_DIV_BY_ZERO);
                }
                this.pushInt(Math.floor(a / b));
                break;
            }

            case Opcode.OP_MOD: {
                const b = this.popInt();
                const a = this.popInt();
                if (b === 0) {
                    throw new Error(ERROR.SCRIPT_ERR_DIV_BY_ZERO);
                }
                this.pushInt(a % b);
                break;
            }

            case Opcode.OP_BOOLAND: {
                const b = this.popInt();
                const a = this.popInt();
                this.pushInt((a !== 0 && b !== 0) ? 1 : 0);
                break;
            }

            case Opcode.OP_BOOLOR: {
                const b = this.popInt();
                const a = this.popInt();
                this.pushInt((a !== 0 || b !== 0) ? 1 : 0);
                break;
            }

            case Opcode.OP_NUMEQUAL: {
                const b = this.popInt();
                const a = this.popInt();
                this.pushInt(a === b ? 1 : 0);
                break;
            }

            case Opcode.OP_NUMEQUALVERIFY: {
                const b = this.popInt();
                const a = this.popInt();
                if (a !== b) {
                    throw new Error(ERROR.SCRIPT_ERR_NUMEQUALVERIFY);
                }
                break;
            }

            case Opcode.OP_NUMNOTEQUAL: {
                const b = this.popInt();
                const a = this.popInt();
                this.pushInt(a !== b ? 1 : 0);
                break;
            }

            case Opcode.OP_LESSTHAN: {
                const b = this.popInt();
                const a = this.popInt();
                this.pushInt(a < b ? 1 : 0);
                break;
            }

            case Opcode.OP_GREATERTHAN: {
                const b = this.popInt();
                const a = this.popInt();
                this.pushInt(a > b ? 1 : 0);
                break;
            }
            // shinigami.ts - Part 6 (continuing ScriptEngine class)

            case Opcode.OP_LESSTHANOREQUAL: {
                const b = this.popInt();
                const a = this.popInt();
                this.pushInt(a <= b ? 1 : 0);
                break;
            }

            case Opcode.OP_GREATERTHANOREQUAL: {
                const b = this.popInt();
                const a = this.popInt();
                this.pushInt(a >= b ? 1 : 0);
                break;
            }

            case Opcode.OP_MIN: {
                const b = this.popInt();
                const a = this.popInt();
                this.pushInt(Math.min(a, b));
                break;
            }

            case Opcode.OP_MAX: {
                const b = this.popInt();
                const a = this.popInt();
                this.pushInt(Math.max(a, b));
                break;
            }

            case Opcode.OP_WITHIN: {
                const max = this.popInt();
                const min = this.popInt();
                const x = this.popInt();
                this.pushInt(x >= min && x < max ? 1 : 0);
                break;
            }

            // Crypto operations
            case Opcode.OP_RIPEMD160: {
                const data = this.stack.pop();
                this.stack.push(HashUtils.ripemd160(data));
                break;
            }

            case Opcode.OP_SHA1: {
                const data = this.stack.pop();
                this.stack.push(HashUtils.sha1(data));
                break;
            }

            case Opcode.OP_SHA256: {
                const data = this.stack.pop();
                this.stack.push(HashUtils.sha256(data));
                break;
            }

            case Opcode.OP_HASH160: {
                const data = this.stack.pop();
                this.stack.push(HashUtils.hash160(data));
                break;
            }

            case Opcode.OP_HASH256: {
                const data = this.stack.pop();
                this.stack.push(HashUtils.hash256(data));
                break;
            }

            case Opcode.OP_CODESEPARATOR:
                // Reset the last code separator position
                this.lastCodeSeparator = this.pc;
                break;

            case Opcode.OP_CHECKSIG: {
                const pubkey = this.stack.pop();
                const signature = this.stack.pop();
                const success = SignatureChecker.verifySignature(pubkey, signature, this.getSignatureHash());
                this.pushInt(success ? 1 : 0);
                break;
            }

            case Opcode.OP_CHECKSIGVERIFY: {
                const pubkey = this.stack.pop();
                const signature = this.stack.pop();
                if (!SignatureChecker.verifySignature(pubkey, signature, this.getSignatureHash())) {
                    throw new Error(ERROR.SCRIPT_ERR_CHECKSIGVERIFY);
                }
                break;
            }

            case Opcode.OP_CHECKMULTISIG: {
                // Get the number of public keys
                const numPubKeys = this.popInt();
                if (numPubKeys < 0 || numPubKeys > MAX_MULTISIG_PUBKEYS) {
                    throw new Error(ERROR.SCRIPT_ERR_PUBKEY_COUNT);
                }

                // Get public keys
                const pubkeys: Buffer[] = [];
                for (let i = 0; i < numPubKeys; i++) {
                    pubkeys.push(this.stack.pop());
                }

                // Get the number of signatures required
                const numRequired = this.popInt();
                if (numRequired < 0 || numRequired > numPubKeys) {
                    throw new Error(ERROR.SCRIPT_ERR_SIG_COUNT);
                }

                // Get signatures
                const signatures: Buffer[] = [];
                for (let i = 0; i < numRequired; i++) {
                    signatures.push(this.stack.pop());
                }

                // Remove the extra dummy value (Bitcoin protocol quirk)
                this.stack.pop();

                // Verify signatures
                const success = SignatureChecker.verifyMultisig(pubkeys, signatures, this.getSignatureHash());
                this.pushInt(success ? 1 : 0);
                break;
            }

            case Opcode.OP_CHECKMULTISIGVERIFY: {
                // Similar to OP_CHECKMULTISIG but throws on failure
                const numPubKeys = this.popInt();
                if (numPubKeys < 0 || numPubKeys > MAX_MULTISIG_PUBKEYS) {
                    throw new Error(ERROR.SCRIPT_ERR_PUBKEY_COUNT);
                }

                const pubkeys: Buffer[] = [];
                for (let i = 0; i < numPubKeys; i++) {
                    pubkeys.push(this.stack.pop());
                }

                const numRequired = this.popInt();
                if (numRequired < 0 || numRequired > numPubKeys) {
                    throw new Error(ERROR.SCRIPT_ERR_SIG_COUNT);
                }

                const signatures: Buffer[] = [];
                for (let i = 0; i < numRequired; i++) {
                    signatures.push(this.stack.pop());
                }

                this.stack.pop(); // dummy value

                if (!SignatureChecker.verifyMultisig(pubkeys, signatures, this.getSignatureHash())) {
                    throw new Error(ERROR.SCRIPT_ERR_CHECKMULTISIGVERIFY);
                }
                break;
            }

            // Bitwise operations
            case Opcode.OP_EQUAL: {
                const v1 = this.stack.pop();
                const v2 = this.stack.pop();
                this.pushInt(Buffer.compare(v1, v2) === 0 ? 1 : 0);
                break;
            }

            case Opcode.OP_EQUALVERIFY: {
                const v1 = this.stack.pop();
                const v2 = this.stack.pop();
                if (Buffer.compare(v1, v2) !== 0) {
                    throw new Error(ERROR.SCRIPT_ERR_EQUALVERIFY);
                }
                break;
            }

            // Time locks
            case Opcode.OP_CHECKLOCKTIMEVERIFY: {
                if (this.stack.size() < 1) {
                    throw new Error(ERROR.SCRIPT_ERR_INVALID_STACK_OPERATION);
                }
                const locktime = this.popInt();
                if (locktime < 0) {
                    throw new Error(ERROR.SCRIPT_ERR_NEGATIVE_LOCKTIME);
                }
                // Actual locktime verification would go here
                break;
            }

            case Opcode.OP_CHECKSEQUENCEVERIFY: {
                if (this.stack.size() < 1) {
                    throw new Error(ERROR.SCRIPT_ERR_INVALID_STACK_OPERATION);
                }
                const sequence = this.popInt();
                if (sequence < 0) {
                    throw new Error(ERROR.SCRIPT_ERR_NEGATIVE_LOCKTIME);
                }
                // Actual sequence verification would go here
                break;
            }

            default:
                throw new Error(ERROR.SCRIPT_ERR_BAD_OPCODE);
        }
    }

    private getSignatureHash(): Buffer {
        // In a real implementation, this would calculate the signature hash
        // based on the transaction data and current input
        return Buffer.alloc(32); // Placeholder
    }
// shinigami.ts - Part 7 (completing the implementation)

    // Main execution method in ScriptEngine class
    public execute(): boolean {
        try {
            while (this.pc < this.script.length) {
                // Get the current opcode
                const opcode = this.script[this.pc++];

                // Handle push operations
                if (opcode <= 0x4b) {
                    const data = this.readBytes(opcode);
                    this.stack.push(data);
                    continue;
                }

                // Handle PUSHDATA operations
                if (opcode === Opcode.OP_PUSHDATA1) {
                    const length = this.script[this.pc++];
                    this.stack.push(this.readBytes(length));
                    continue;
                }
                if (opcode === Opcode.OP_PUSHDATA2) {
                    const length = this.script.readUInt16LE(this.pc);
                    this.pc += 2;
                    this.stack.push(this.readBytes(length));
                    continue;
                }
                if (opcode === Opcode.OP_PUSHDATA4) {
                    const length = this.script.readUInt32LE(this.pc);
                    this.pc += 4;
                    this.stack.push(this.readBytes(length));
                    continue;
                }

                // Execute the opcode
                this.executeOpcode(opcode);
            }

            // Script succeeded if stack is not empty and top value is truthy
            return this.stack.size() > 0 && this.popBool();
        } catch (error) {
            console.error('Script execution failed:', error);
            return false;
        }
    }
}

// Main execution function that mirrors backend_run from lib.cairo
function backendRun(input: InputData): number {
    console.log(`Running Bitcoin Script with ScriptSig: '${input.ScriptSig}' and ScriptPubKey: '${input.ScriptPubKey}'`);

    try {
        // Compile both scripts
        const scriptSig = Compiler.compile(input.ScriptSig);
        const scriptPubKey = Compiler.compile(input.ScriptPubKey);

        // Create combined script
        const combinedScript = Buffer.concat([scriptSig, scriptPubKey]);

        // Execute the combined script
        const engine = new ScriptEngine(combinedScript);
        const success = engine.execute();

        if (success) {
            console.log("Execution successful");
            return 1;
        } else {
            console.log("Execution failed");
            return 0;
        }
    } catch (error) {
        console.log(`Execution failed: ${error.message}`);
        return 0;
    }
}

// Utility function to convert hex string to bytes
function hexToBytes(hex: string): Buffer {
    return Buffer.from(hex.replace('0x', ''), 'hex');
}

// Utility function to convert bytes to hex string
function bytesToHex(bytes: Buffer): string {
    return '0x' + bytes.toString('hex');
}

// Example usage:
const testScript: InputData = {
    ScriptSig: "OP_1",
    ScriptPubKey: "OP_DUP OP_1 OP_EQUAL"
};

// Export all necessary components
export {
    Opcode,
    ScriptNum,
    Stack,
    ScriptEngine,
    Compiler,
    HashUtils,
    SignatureChecker,
    InputData,
    backendRun,
    hexToBytes,
    bytesToHex,
    ERROR,
    ScriptFlags
};

// Usage example:
/*
import { backendRun, InputData } from './shinigami';

const script: InputData = {
    ScriptSig: "OP_1 OP_2",  // Push 1 and 2 onto the stack
    ScriptPubKey: "OP_ADD OP_3 OP_EQUAL"  // Add them and check if equal to 3
};

const result = backendRun(script);
console.log(result); // 1 for success, 0 for failure
*/

// Additional helper functions for debugging
function dumpStack(stack: Stack): void {
    console.log("Stack:");
    const items = stack.asArray();
    for (let i = items.length - 1; i >= 0; i--) {
        console.log(`${i}: ${bytesToHex(items[i])}`);
    }
}

function parseScript(scriptHex: string): string[] {
    const bytes = hexToBytes(scriptHex);
    const ops: string[] = [];
    let i = 0;
    
    while (i < bytes.length) {
        const opcode = bytes[i++];
        
        if (opcode <= 0x4b) {
            const data = bytes.slice(i, i + opcode);
            i += opcode;
            ops.push(bytesToHex(data));
            continue;
        }
        
        const opcodeName = Object.entries(Opcode)
            .find(([_, value]) => value === opcode)?.[0] || `Unknown(${opcode})`;
        ops.push(opcodeName);
    }
    
    return ops;
}

// Add test suite
function runTests(): void {
    const tests: Array<[InputData, boolean]> = [
        [
            {
                ScriptSig: "OP_1",
                ScriptPubKey: "OP_1 OP_EQUAL"
            },
            true
        ],
        [
            {
                ScriptSig: "OP_1",
                ScriptPubKey: "OP_2 OP_EQUAL"
            },
            false
        ],
        // Add more test cases here
    ];

    let passed = 0;
    let failed = 0;

    for (const [test, expected] of tests) {
        const result = backendRun(test) === 1;
        if (result === expected) {
            passed++;
        } else {
            failed++;
            console.log(`Test failed: ${JSON.stringify(test)}`);
            console.log(`Expected: ${expected}, got: ${result}`);
        }
    }

    console.log(`Tests complete: ${passed} passed, ${failed} failed`);
}

// If running directly (not imported as a module)
if (require.main === module) {
    runTests();
}