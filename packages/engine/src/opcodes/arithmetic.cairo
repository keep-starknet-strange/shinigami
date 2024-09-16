use crate::engine::Engine;
use crate::opcodes::utils;
use crate::stack::ScriptStackTrait;

pub fn opcode_1add<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let value = engine.dstack.pop_int()?;
    let result = value + 1;
    engine.dstack.push_int(result);
    return Result::Ok(());
}

pub fn opcode_1sub<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    engine.dstack.push_int(a - 1);
    return Result::Ok(());
}

pub fn opcode_negate<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    engine.dstack.push_int(-a);
    return Result::Ok(());
}

pub fn opcode_abs<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let value = engine.dstack.pop_int()?;
    let abs_value = if value < 0 {
        -value
    } else {
        value
    };
    engine.dstack.push_int(abs_value);
    return Result::Ok(());
}

pub fn opcode_not<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let m = engine.dstack.pop_int()?;
    if m == 0 {
        engine.dstack.push_bool(true);
    } else {
        engine.dstack.push_bool(false);
    }
    return Result::Ok(());
}

pub fn opcode_0_not_equal<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;

    engine.dstack.push_int(if a != 0 {
        1
    } else {
        0
    });
    return Result::Ok(());
}

pub fn opcode_add<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_int(a + b);
    return Result::Ok(());
}

pub fn opcode_sub<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_int(b - a);
    return Result::Ok(());
}

pub fn opcode_bool_and<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_bool(if a != 0 && b != 0 {
        true
    } else {
        false
    });
    return Result::Ok(());
}

pub fn opcode_bool_or<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;

    engine.dstack.push_bool(if a != 0 || b != 0 {
        true
    } else {
        false
    });
    return Result::Ok(());
}

pub fn opcode_numequal<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_bool(if a == b {
        true
    } else {
        false
    });
    return Result::Ok(());
}

pub fn opcode_numequalverify<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    opcode_numequal(ref engine)?;
    utils::abstract_verify(ref engine)?;
    return Result::Ok(());
}

pub fn opcode_numnotequal<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_bool(if a != b {
        true
    } else {
        false
    });
    return Result::Ok(());
}

pub fn opcode_lessthan<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_bool(if b < a {
        true
    } else {
        false
    });
    return Result::Ok(());
}

pub fn opcode_greater_than<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_bool(if b > a {
        true
    } else {
        false
    });
    return Result::Ok(());
}

pub fn opcode_less_than_or_equal<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let v0 = engine.dstack.pop_int()?;
    let v1 = engine.dstack.pop_int()?;

    if v1 <= v0 {
        engine.dstack.push_bool(true);
    } else {
        engine.dstack.push_bool(false);
    }
    return Result::Ok(());
}

pub fn opcode_greater_than_or_equal<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let v0 = engine.dstack.pop_int()?;
    let v1 = engine.dstack.pop_int()?;

    if v1 >= v0 {
        engine.dstack.push_bool(true);
    } else {
        engine.dstack.push_bool(false);
    }
    return Result::Ok(());
}

pub fn opcode_min<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;

    engine.dstack.push_int(if a < b {
        a
    } else {
        b
    });
    return Result::Ok(());
}

pub fn opcode_max<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_int(if a > b {
        a
    } else {
        b
    });
    return Result::Ok(());
}

pub fn opcode_within<T, +Drop<T>>(ref engine: Engine<T>) -> Result<(), felt252> {
    let max = engine.dstack.pop_int()?;
    let min = engine.dstack.pop_int()?;
    let value = engine.dstack.pop_int()?;
    engine.dstack.push_bool(if value >= min && value < max {
        true
    } else {
        false
    });
    return Result::Ok(());
}
