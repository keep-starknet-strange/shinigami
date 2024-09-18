use crate::engine::Engine;
use crate::stack::ScriptStackTrait;

pub fn opcode_size<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let top_element = engine.dstack.peek_byte_array(0)?;
    engine.dstack.push_int(top_element.len().into());
    return Result::Ok(());
}
