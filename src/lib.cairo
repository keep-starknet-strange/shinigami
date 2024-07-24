pub mod compiler;
pub mod opcodes {
    pub mod opcodes;
    mod tests {
        #[cfg(test)]
        mod test_opcodes;
    }
    pub(crate) use opcodes::Opcode;
}
pub mod engine;
pub mod stack;

mod main;
