pub mod compiler;
pub mod engine;
pub mod stack;
pub mod opcodes {
    pub mod opcodes;
    mod tests {
        #[cfg(test)]
        mod test_opcodes;
    }
    pub(crate) use opcodes::Opcode;
}
pub mod scriptnum {
    pub mod scriptnum;
    mod tests {
        #[cfg(test)]
        mod test_scriptnum;
    }
    pub(crate) use scriptnum::ScriptNum;
}

mod main;
