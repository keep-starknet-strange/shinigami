use shinigami::engine::{Engine, EngineTrait};
use shinigami::stack::ScriptStackTrait;
use shinigami::opcodes::utils;

pub fn opcode_1add(ref engine: Engine) -> Result<(), felt252> {
    let value = engine.dstack.pop_int()?;
    let result = value + 1;
    engine.dstack.push_int(result);
    return Result::Ok(());
}

pub fn opcode_1sub(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    engine.dstack.push_int(a - 1);
    return Result::Ok(());
}

pub fn opcode_negate(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    engine.dstack.push_int(-a);
    return Result::Ok(());
}

pub fn opcode_abs(ref engine: Engine) -> Result<(), felt252> {
    let value = engine.dstack.pop_int()?;
    let abs_value = if value < 0 {
        -value
    } else {
        value
    };
    engine.dstack.push_int(abs_value);
    return Result::Ok(());
}

pub fn opcode_not(ref engine: Engine) -> Result<(), felt252> {
    let m = engine.dstack.pop_int()?;
    if m == 0 {
        engine.dstack.push_int(1);
    } else {
        engine.dstack.push_int(0);
    }
    return Result::Ok(());
}

pub fn opcode_0_not_equal(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;

    engine.dstack.push_int(if a != 0 {
        1
    } else {
        0
    });
    return Result::Ok(());
}

pub fn opcode_add(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_int(a + b);
    return Result::Ok(());
}

pub fn opcode_sub(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_int(b - a);
    return Result::Ok(());
}

pub fn opcode_bool_and(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_int(if a != 0 && b != 0 {
        1
    } else {
        0
    });
    return Result::Ok(());
}

pub fn opcode_bool_or(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;

    engine.dstack.push_int(if a != 0 || b != 0 {
        1
    } else {
        0
    });
    return Result::Ok(());
}

pub fn opcode_numequal(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_int(if a == b {
        1
    } else {
        0
    });
    return Result::Ok(());
}

pub fn opcode_numequalverify(ref engine: Engine) -> Result<(), felt252> {
    opcode_numequal(ref engine)?;
    utils::abstract_verify(ref engine)?;
    return Result::Ok(());
}

pub fn opcode_numnotequal(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_int(if a != b {
        1
    } else {
        0
    });
    return Result::Ok(());
}

pub fn opcode_lessthan(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_int(if b < a {
        1
    } else {
        0
    });
    return Result::Ok(());
}

pub fn opcode_greater_than(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_int(if b > a {
        1
    } else {
        0
    });
    return Result::Ok(());
}

pub fn opcode_less_than_or_equal(ref engine: Engine) -> Result<(), felt252> {
    let v0 = engine.dstack.pop_int()?;
    let v1 = engine.dstack.pop_int()?;

    if v1 <= v0 {
        engine.dstack.push_int(1);
    } else {
        engine.dstack.push_int(0);
    }
    return Result::Ok(());
}

pub fn opcode_greater_than_or_equal(ref engine: Engine) -> Result<(), felt252> {
    let v0 = engine.dstack.pop_int()?;
    let v1 = engine.dstack.pop_int()?;

    if v1 >= v0 {
        engine.dstack.push_int(1);
    } else {
        engine.dstack.push_int(0);
    }
    return Result::Ok(());
}

pub fn opcode_min(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;

    engine.dstack.push_int(if a < b {
        a
    } else {
        b
    });
    return Result::Ok(());
}

pub fn opcode_max(ref engine: Engine) -> Result<(), felt252> {
    let a = engine.dstack.pop_int()?;
    let b = engine.dstack.pop_int()?;
    engine.dstack.push_int(if a > b {
        a
    } else {
        b
    });
    return Result::Ok(());
}

pub fn opcode_within(ref engine: Engine) -> Result<(), felt252> {
    let max = engine.dstack.pop_int()?;
    let min = engine.dstack.pop_int()?;
    let value = engine.dstack.pop_int()?;
    engine.dstack.push_int(if value >= min && value < max {
        1
    } else {
        0
    });
    return Result::Ok(());
}
