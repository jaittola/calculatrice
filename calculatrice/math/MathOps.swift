import Foundation

class Plus: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [StackValue],
                   _ calculatorMode: CalculatorMode) -> StackValue {
        let result = inputs[0].doubleValue + inputs[1].doubleValue
        return CalculatedStackValue(result)
    }
}

class Minus: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [StackValue],
                   _ calculatorMode: CalculatorMode) -> StackValue {
        let result = inputs[0].doubleValue - inputs[1].doubleValue
        return CalculatedStackValue(result)
    }
}

class Mult: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [StackValue],
                   _ calculatorMode: CalculatorMode) -> StackValue {
        let result = inputs[0].doubleValue * inputs[1].doubleValue
        return CalculatedStackValue(result)
    }
}

class Div: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [StackValue],
                   _ calculatorMode: CalculatorMode) throws -> StackValue {
        if inputs[1].doubleValue == 0 {
            return CalculatedStackValue(Double.nan)
        }
        let result = inputs[0].doubleValue / inputs[1].doubleValue
        return CalculatedStackValue(result)
    }
}

class Neg: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [StackValue],
                   _ calculatorMode: CalculatorMode) -> StackValue {
        let result = -inputs[0].doubleValue
        return CalculatedStackValue(result)
    }
}

class Sin: Calculation {
    let arity: Int = 1

    func calculate(_ inputs: [StackValue],
                   _ calculatorMode: CalculatorMode) -> StackValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return CalculatedStackValue(sin(input))
    }
}

class Cos: Calculation {
    let arity: Int = 1

    func calculate(_ inputs: [StackValue],
                   _ calculatorMode: CalculatorMode) -> StackValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return CalculatedStackValue(cos(input))
    }
}

class Tan: Calculation {
    let arity: Int = 1

    func calculate(_ inputs: [StackValue],
                   _ calculatorMode: CalculatorMode) -> StackValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return CalculatedStackValue(tan(input))
    }
}

class ASin: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [StackValue], _ calculatorMode: CalculatorMode) -> StackValue {
        let res = asin(inputs[0].doubleValue)
        return Utils.radResult2Deg(res, calculatorMode)
    }
}

class ACos: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [StackValue], _ calculatorMode: CalculatorMode) -> StackValue {
        let res = acos(inputs[0].doubleValue)
        return Utils.radResult2Deg(res, calculatorMode)
    }
}

class ATan: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [StackValue], _ calculatorMode: CalculatorMode) -> StackValue {
        let res = atan(inputs[0].doubleValue)
        return Utils.radResult2Deg(res, calculatorMode)
    }
}

class Inv: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [StackValue], _ calculatorMode: CalculatorMode) -> StackValue {
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
    func calculate(_ inputs: [StackValue], _ calculatorMode: CalculatorMode) -> StackValue {
        let input = inputs[0].doubleValue
        return CalculatedStackValue(input * input)
    }
}

class Pow: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [StackValue], _ calculatorMode: CalculatorMode) -> StackValue {
        let result = pow(inputs[0].doubleValue, inputs[1].doubleValue)
        return CalculatedStackValue(result)
    }
}

class Sqrt: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [StackValue], _ calculatorMode: CalculatorMode) -> StackValue {
        return CalculatedStackValue(sqrt(inputs[0].doubleValue))
    }
}

class NthRoot: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [StackValue], _ calculatorMode: CalculatorMode) throws -> StackValue {
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
    func calculate(_ inputs: [StackValue], _ calculatorMode: CalculatorMode) -> StackValue {
        return CalculatedStackValue(log(inputs[0].doubleValue))
    }
}

class Exp: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [StackValue], _ calculatorMode: CalculatorMode) -> StackValue {
        return CalculatedStackValue(exp(inputs[0].doubleValue))
    }
}

class Utils {
    static func deg2Rad(_ inputs: [StackValue],
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
