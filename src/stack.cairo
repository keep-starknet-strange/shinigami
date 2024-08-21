use core::dict::{Felt252Dict, Felt252DictEntryTrait};
use shinigami::scriptnum::ScriptNum;
use shinigami::errors::Error;
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
        let bytes = ScriptNum::wrap(value);
        self.push_byte_array(bytes);
    }

    fn push_bool(ref self: ScriptStack, value: bool) {
        if value {
            let mut v: ByteArray = Default::default();
            v.append_byte(1);
            self.push_byte_array(v);
        } else {
            self.push_byte_array(Default::default());
        }
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
        return Result::Ok(utils::byte_array_to_bool(@bytes));
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
        return Result::Ok(utils::byte_array_to_bool(@bytes));
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

    fn rot_n(ref self: ScriptStack, n: u32) -> Result<(), felt252> {
        if n < 1 {
            return Result::Err('rot_n: invalid n value');
        }
        let mut err = '';
        let entry_index = 3 * n - 1;
        let mut i = n;
        while i > 0 {
            let res = self.nip_n(entry_index);
            if res.is_err() {
                err = res.unwrap_err();
                break;
            }
            self.push_byte_array(res.unwrap());
            i -= 1;
        };
        if err != '' {
            return Result::Err(err);
        }
        return Result::Ok(());
    }

    fn stack_to_span(ref self: ScriptStack) -> Span<ByteArray> {
        let mut result = array![];
        let mut i = 0;
        while i < self.len {
            let (entry, arr) = self.data.entry(i.into());
            let arr = arr.deref();
            result.append(arr.clone());
            self.data = entry.finalize(NullableTrait::new(arr));
            i += 1
        };

        return result.span();
    }

    fn dup_n(ref self: ScriptStack, n: u32) -> Result<(), felt252> {
        // TODO: STACK_OUT_OF_RANGE?
        if (n == 0 || n > self.len()) {
            return Result::Err('dup_n: stack out of range');
        }
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

    fn nip_n(ref self: ScriptStack, idx: usize) -> Result<ByteArray, felt252> {
        let value = self.peek_byte_array(idx)?;

        // Shift all elements above idx down by one
        let mut i = 0;
        while i < idx {
            let next_value = self.peek_byte_array(idx - i - 1).unwrap();
            let (entry, _) = self.data.entry((self.len - idx + i - 1).into());
            self.data = entry.finalize(NullableTrait::new(next_value));
            i += 1;
        };
        let (last_entry, _) = self.data.entry((self.len - 1).into());
        self.data = last_entry.finalize(NullableTrait::new(""));
        self.len -= 1;
        return Result::Ok(value);
    }

    fn pick_n(ref self: ScriptStack, idx: i32) -> Result<(), felt252> {
        if idx < 0 {
            return Result::Err(Error::STACK_OUT_OF_RANGE);
        }

        let idxU32: u32 = idx.try_into().unwrap();
        if idxU32 >= self.len {
            return Result::Err(Error::STACK_OUT_OF_RANGE);
        }

        let so = self.peek_byte_array(idxU32)?;

        self.push_byte_array(so);
        return Result::Ok(());
    }

    fn roll_n(ref self: ScriptStack, n: i32) -> Result<(), felt252> {
        if n < 0 {
            return Result::Err(Error::STACK_OUT_OF_RANGE);
        }
        let nU32: u32 = n.try_into().unwrap();
        if nU32 >= self.len {
            return Result::Err(Error::STACK_OUT_OF_RANGE);
        }

        let value = self.nip_n(nU32)?;
        self.push_byte_array(value);
        return Result::Ok(());
    }

    fn over_n(ref self: ScriptStack, mut n: u32) -> Result<(), felt252> {
        if n < 1 {
            return Result::Err('over_n: invalid n value');
        }
        let entry: u32 = (2 * n) - 1;
        let mut err = '';
        while n > 0 {
            let res = self.peek_byte_array(entry);
            if res.is_err() {
                err = res.unwrap_err();
                break;
            }

            self.push_byte_array(res.unwrap());
            n -= 1;
        };

        return Result::Ok(());
    }
}
