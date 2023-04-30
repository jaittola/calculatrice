import Foundation

class Plus: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = inputs[0].doubleValue + inputs[1].doubleValue
        return CalculatedStackValue(result)
    }
}

class Minus: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = inputs[0].doubleValue - inputs[1].doubleValue
        return CalculatedStackValue(result)
    }
}

class Mult: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = inputs[0].doubleValue * inputs[1].doubleValue
        return CalculatedStackValue(result)
    }
}

class Div: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue {
        if inputs[1].doubleValue == 0 {
            throw CalcError.divisionByZero
        }
        let result = inputs[0].doubleValue / inputs[1].doubleValue
        return CalculatedStackValue(result)
    }
}

class Neg: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = -inputs[0].doubleValue
        return CalculatedStackValue(result)
    }
}

class Sin: Calculation {
    let arity: Int = 1

    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return CalculatedStackValue(sin(input))
    }
}

class Cos: Calculation {
    let arity: Int = 1

    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return CalculatedStackValue(cos(input))
    }
}

class Tan: Calculation {
    let arity: Int = 1

    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return CalculatedStackValue(tan(input))
    }
}

class ASin: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let res = asin(inputs[0].doubleValue)
        return Utils.radResult2Deg(res, calculatorMode)
    }
}

class ACos: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let res = acos(inputs[0].doubleValue)
        return Utils.radResult2Deg(res, calculatorMode)
    }
}

class ATan: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let res = atan(inputs[0].doubleValue)
        return Utils.radResult2Deg(res, calculatorMode)
    }
}

class Inv: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = inputs[0].doubleValue
        if input == 0 {
            return CalculatedStackValue(Double.nan)
        } else {
            return CalculatedStackValue(1.0 / input)
        }
    }
}

class Square: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = inputs[0].doubleValue
        return CalculatedStackValue(input * input)
    }
}

class Pow: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = pow(inputs[0].doubleValue, inputs[1].doubleValue)
        return CalculatedStackValue(result)
    }
}

class Pow3: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = pow(inputs[0].doubleValue, 3)
        return CalculatedStackValue(result)
    }
}

class Sqrt: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return CalculatedStackValue(sqrt(inputs[0].doubleValue))
    }
}

class Root3: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue {
        let base = inputs[0].doubleValue
        let result = pow(base, 1.0/3.0)
        return CalculatedStackValue(result)
    }
}

class NthRoot: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue {
        let base = inputs[0].doubleValue
        let exponent = inputs[1].doubleValue

        if exponent == 0 {
            return CalculatedStackValue(Double.nan)
        }

        let result = pow(base, 1.0/exponent)
        return CalculatedStackValue(result)
    }
}

class Log: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return CalculatedStackValue(log(inputs[0].doubleValue))
    }
}

class Exp: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return CalculatedStackValue(exp(inputs[0].doubleValue))
    }
}

class Log10: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return CalculatedStackValue(log10(inputs[0].doubleValue))
    }
}

class Exp10: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue {
        return CalculatedStackValue(powl(10, inputs[0].doubleValue))
    }
}

class ToEng: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return CalculatedStackValue(inputs[0].doubleValue, numberFormat: .eng)
    }
}

class ToDecimal: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return CalculatedStackValue(inputs[0].doubleValue, numberFormat: .decimal)
    }
}

class Utils {
    static func deg2Rad(_ inputs: [DoublePrecisionValue],
                        _ calculatorMode: CalculatorMode) -> [Double] {
        if calculatorMode.angle == .Rad {
            return inputs.map { input in input.doubleValue }
        } else {
            return inputs.map { input in input.doubleValue * Double.pi / 180.0}
        }
    }

    static func radResult2Deg(_ value: Double,
                              _ calculatorMode: CalculatorMode) -> CalculatedStackValue {
        if calculatorMode.angle == .Rad {
            return CalculatedStackValue(value)
        } else {
            let result = value * 180.0 / Double.pi
            return CalculatedStackValue(result)
        }
    }
}
