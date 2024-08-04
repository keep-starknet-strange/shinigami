use core::option::OptionTrait;
use core::dict::Felt252DictEntryTrait;
use shinigami::scriptnum::ScriptNum;
use shinigami::errors::Error;

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
        let bytes = ScriptNum::wrap(value);
        self.push_byte_array(bytes);
    }

    fn pop_byte_array(ref self: ScriptStack) -> Result<ByteArray, felt252> {
        if self.len == 0 {
            return Result::Err(Error::STACK_UNDERFLOW);
        }
        self.len -= 1;
        let (entry, bytes) = self.data.entry(self.len.into());
        self.data = entry.finalize(NullableTrait::new(""));
        return Result::Ok(bytes.deref());
    }

    fn pop_int(ref self: ScriptStack) -> Result<i64, felt252> {
        let value = self.pop_byte_array()?;
        return Result::Ok(ScriptNum::unwrap(value));
    }

    fn pop_bool(ref self: ScriptStack) -> Result<bool, felt252> {
        let bytes = self.pop_byte_array()?;

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
        return Result::Ok(ret_bool);
    }

    fn peek_byte_array(ref self: ScriptStack, idx: usize) -> Result<ByteArray, felt252> {
        if idx >= self.len {
            return Result::Err(Error::STACK_OUT_OF_RANGE);
        }
        let (entry, bytes) = self.data.entry((self.len - idx - 1).into());
        let bytes = bytes.deref();
        self.data = entry.finalize(NullableTrait::new(bytes.clone()));
        return Result::Ok(bytes);
    }

    fn peek_int(ref self: ScriptStack, idx: usize) -> Result<i64, felt252> {
        let bytes = self.peek_byte_array(idx)?;
        return Result::Ok(ScriptNum::unwrap(bytes));
    }

    fn peek_bool(ref self: ScriptStack, idx: usize) -> Result<bool, felt252> {
        let bytes = self.peek_byte_array(idx)?;

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
        return Result::Ok(ret_bool);
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
        let mut i = 0;
        while i < self
            .len {
                let (entry, arr) = self.data.entry(i.into());
                let arr = arr.deref();
                result.append(arr.clone());
                self.data = entry.finalize(NullableTrait::new(arr));
                i += 1
            };

        return result.span();
    }

    fn dup_n(ref self: ScriptStack, n: u32) -> Result<(), felt252> {
        if (n < 1) {
            return Result::Err('dup_n: invalid n value');
        }
        let mut i = n;
        let mut err = '';
        while i > 0 {
            i -= 1;
            let value = self.peek_byte_array(n - 1);
            if value.is_err() {
                break;
            }
            self.push_byte_array(value.unwrap());
        };
        if err != '' {
            return Result::Err(err);
        }
        return Result::Ok(());
    }


    fn tuck(ref self: ScriptStack) -> Result<(), felt252> {
        let top_element = self.pop_byte_array()?;
        let next_element = self.pop_byte_array()?;

        self.push_byte_array(top_element.clone());
        self.push_byte_array(next_element);
        self.push_byte_array(top_element);
        return Result::Ok(());
    }
}
