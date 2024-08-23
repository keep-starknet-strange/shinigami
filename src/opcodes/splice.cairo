use shinigami::engine::Engine;
use shinigami::stack::ScriptStackTrait;

pub fn opcode_size(ref engine: Engine) -> Result<(), felt252> {
    let top_element = engine.dstack.peek_byte_array(0)?;
    engine.dstack.push_int(top_element.len().into());
    return Result::Ok(());
}
