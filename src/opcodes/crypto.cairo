use shinigami::engine::{Engine, EngineTrait};
use shinigami::stack::ScriptStackTrait;

pub fn opcode_checksig(ref engine: Engine) -> Result<(), felt252> {
    let mut _pkBytes = engine.dstack.pop_byte_array();

    let mut full_sig_bytes = engine.dstack.pop_byte_array().unwrap();
    
    if full_sig_bytes.len() < 1 {
        engine.dstack.push_int(0);
    }

    return Result::Ok(());
}