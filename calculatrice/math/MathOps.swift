import Foundation

class Plus: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = inputs[0].doubleValue + inputs[1].doubleValue
        return SingleDimensionalNumericalValue(result)
    }
}

class Minus: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = inputs[0].doubleValue - inputs[1].doubleValue
        return SingleDimensionalNumericalValue(result)
    }
}

class Mult: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = inputs[0].doubleValue * inputs[1].doubleValue
        return SingleDimensionalNumericalValue(result)
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
        return SingleDimensionalNumericalValue(result)
    }
}

class Neg: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = -inputs[0].doubleValue
        return SingleDimensionalNumericalValue(result)
    }
}

class Sin: Calculation {
    let arity: Int = 1

    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return SingleDimensionalNumericalValue(sin(input))
    }
}

class Cos: Calculation {
    let arity: Int = 1

    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return SingleDimensionalNumericalValue(cos(input))
    }
}

class Tan: Calculation {
    let arity: Int = 1

    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return SingleDimensionalNumericalValue(tan(input))
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
            return SingleDimensionalNumericalValue(Double.nan)
        } else {
            return SingleDimensionalNumericalValue(1.0 / input)
        }
    }
}

class Square: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = inputs[0].doubleValue
        return SingleDimensionalNumericalValue(input * input)
    }
}

class Pow: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = pow(inputs[0].doubleValue, inputs[1].doubleValue)
        return SingleDimensionalNumericalValue(result)
    }
}

class Pow3: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = pow(inputs[0].doubleValue, 3)
        return SingleDimensionalNumericalValue(result)
    }
}

class Sqrt: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return SingleDimensionalNumericalValue(sqrt(inputs[0].doubleValue))
    }
}

class Root3: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue {
        let base = inputs[0].doubleValue
        let result = pow(base, 1.0/3.0)
        return SingleDimensionalNumericalValue(result)
    }
}

class NthRoot: Calculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue {
        let base = inputs[0].doubleValue
        let exponent = inputs[1].doubleValue

        if exponent == 0 {
            return SingleDimensionalNumericalValue(Double.nan)
        }

        let result = pow(base, 1.0/exponent)
        return SingleDimensionalNumericalValue(result)
    }
}

class Log: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return SingleDimensionalNumericalValue(log(inputs[0].doubleValue))
    }
}

class Exp: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return SingleDimensionalNumericalValue(exp(inputs[0].doubleValue))
    }
}

class Log10: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return SingleDimensionalNumericalValue(log10(inputs[0].doubleValue))
    }
}

class Exp10: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue {
        return SingleDimensionalNumericalValue(powl(10, inputs[0].doubleValue))
    }
}

class ToEng: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return SingleDimensionalNumericalValue(inputs[0].doubleValue, numberFormat: .eng)
    }
}

class ToDecimal: Calculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return SingleDimensionalNumericalValue(inputs[0].doubleValue, numberFormat: .decimal)
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
                              _ calculatorMode: CalculatorMode) -> SingleDimensionalNumericalValue {
        if calculatorMode.angle == .Rad {
            return SingleDimensionalNumericalValue(value)
        } else {
            let result = value * 180.0 / Double.pi
            return SingleDimensionalNumericalValue(result)
        }
    }
}
