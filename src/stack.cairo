use core::dict::Felt252DictEntryTrait;
use shinigami::utils;

#[derive(Destruct)]
pub struct ScriptStack {
    data: Felt252Dict<Nullable<ByteArray>>,
    len: usize,
}

#[generate_trait()]
pub impl ScriptStackImpl of ScriptStackTrait {
    fn new() -> ScriptStack {
        ScriptStack { data: Default::default(), len: 0, }
    }

    fn push_byte_array(ref self: ScriptStack, value: ByteArray) {
        self.data.insert(self.len.into(), NullableTrait::new(value));
        self.len += 1;
    }

    fn push_int(ref self: ScriptStack, value: i64) {
        let mut bytes = utils::int_to_bytes(value);
        self.push_byte_array(bytes);
    }

    fn pop_byte_array(ref self: ScriptStack) -> ByteArray {
        if self.len == 0 {
            // TODO
            panic!("pop_byte_array: stack underflow");
        }
        self.len -= 1;
        let (entry, bytes) = self.data.entry(self.len.into());
        self.data = entry.finalize(NullableTrait::new(""));
        bytes.deref()
    }

    fn pop_int(ref self: ScriptStack) -> i64 {
        let bytes = self.pop_byte_array();
        // TODO: Error handling & MakeScriptNum
        let bytes_len = bytes.len();
        if bytes_len == 0 {
            return 0;
        }
        let mut value: i64 = 0;
        let mut i = 0;
        if bytes_len < 8 {
            while i < bytes_len {
                value = value * 256 + bytes.at(i).unwrap().into();
                i += 1;
            };
            return value;
        } else {
            while i < 8 {
                value = value * 256 + bytes.at(bytes_len - 8 + i).unwrap().into();
                i += 1;
            };
            return value;
        }
    }

    fn pop_bool(ref self: ScriptStack) -> bool {
        let bytes = self.pop_byte_array();

        let mut i = 0;
        let mut ret_bool = false;
        while i < bytes
            .len() {
                if bytes.at(i).unwrap() != 0 {
                    // Can be negative zero
                    if i == bytes.len() - 1 && bytes.at(i).unwrap() == 0x80 {
                        ret_bool = false;
                        break;
                    }
                    ret_bool = true;
                    break;
                }
                i += 1;
            };
        return ret_bool;
    }

    fn len(ref self: ScriptStack) -> usize {
        self.len
    }

    fn depth(ref self: ScriptStack) -> usize {
        self.len
    }

    fn print_element(ref self: ScriptStack, idx: usize) {
        let (entry, arr) = self.data.entry(idx.into());
        let arr = arr.deref();
        if arr.len() == 0 {
            println!("stack[{}]: null", idx);
        } else {
            println!("stack[{}]: {}", idx, arr);
        }
        self.data = entry.finalize(NullableTrait::new(arr));
    }

    fn print(ref self: ScriptStack) {
        let mut i = self.len;
        while i > 0 {
            i -= 1;
            self.print_element(i.into());
        }
    }

    fn stack_to_span(ref self: ScriptStack) -> Span<ByteArray> {
        let mut result = array![];
        let mut i = self.len;
        while i > 0 {
            i -= 1;
            let (entry, arr) = self.data.entry(i.into());
            let arr = arr.deref();
            result.append(arr.clone());
            self.data = entry.finalize(NullableTrait::new(arr));
        };

        return result.span();
    }
}
