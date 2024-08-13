use shinigami::engine::{Engine, EngineTrait};
use shinigami::stack::ScriptStackTrait;

pub fn opcode_ripemd160(ref engine: Engine) -> Result<(), felt252> {
    let m = engine.dstack.pop_byte_array()?;
    let h: ByteArray = (ripemd160::ripemd160_hash(@m)).into();
    engine.dstack.push_byte_array(h);
    return Result::Ok(());
}
