use core::dict::Felt252Dict;

#[derive(Destruct)]
pub struct ConditionalStack {
    stack: Felt252Dict<u8>,
    len: usize,
}

#[generate_trait()]
pub impl ConditionalStackImpl of ConditionalStackTrait {
    fn new() -> ConditionalStack {
        ConditionalStack { stack: Default::default(), len: 0 }
    }

    fn push(ref self: ConditionalStack, value: u8) {
        self.stack.insert(self.len.into(), value);
        self.len += 1;
    }

    fn pop(ref self: ConditionalStack) -> Result<(), felt252> {
        if self.len == 0 {
            return Result::Err('pop: conditional stack is empty');
        }
        self.len -= 1;
        return Result::Ok(());
    }

    fn branch_executing(ref self: ConditionalStack) -> bool {
        if self.len == 0 {
            return true;
        } else {
            return self.stack[self.len.into() - 1] == 1;
        }
    }

    fn len(ref self: ConditionalStack) -> usize {
        self.len
    }

    fn swap_condition(ref self: ConditionalStack) {
        let cond_idx = self.len() - 1;
        match self.stack.get(cond_idx.into()) {
            0 => self.stack.insert(cond_idx.into(), 1),
            1 => self.stack.insert(cond_idx.into(), 0),
            2 => self.stack.insert(cond_idx.into(), 2),
            _ => panic!("Invalid condition"),
        }
    }
}
