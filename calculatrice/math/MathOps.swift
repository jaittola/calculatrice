import Foundation

class Plus: Calculation, ComplexCalculation {
    let arity: Int = 2

    func calcComplex(_ inputs: [ComplexValue],
                     _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        do {
            return try Utils.calculateComplexCartesian(inputs) { v1, v2 in
                Utils.num(v1.doubleValue + v2.doubleValue)
            }
        } catch {
            throw error
        }
    }
}

class Minus: Calculation, ComplexCalculation {
    let arity: Int = 2

    func calcComplex(_ inputs: [ComplexValue],
                     _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        do {
            return try Utils.calculateComplexCartesian(inputs) { v1, v2 in
                Utils.num(v1.doubleValue - v2.doubleValue)
            }
        } catch {
            throw error
        }
    }
}

class Mult: Calculation, RealCalculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = inputs[0].doubleValue * inputs[1].doubleValue
        return DoublePrecisionValue(result)
    }
}

class Div: Calculation, RealCalculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue {
        if inputs[1].doubleValue == 0 {
            throw CalcError.divisionByZero
        }
        let result = inputs[0].doubleValue / inputs[1].doubleValue
        return DoublePrecisionValue(result)
    }
}

class Neg: Calculation, RealCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = -inputs[0].doubleValue
        return DoublePrecisionValue(result)
    }
}

class Sin: Calculation, RealCalculation {
    let arity: Int = 1

    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return DoublePrecisionValue(sin(input))
    }
}

class Cos: Calculation, RealCalculation {
    let arity: Int = 1

    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return DoublePrecisionValue(cos(input))
    }
}

class Tan: Calculation, RealCalculation {
    let arity: Int = 1

    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return DoublePrecisionValue(tan(input))
    }
}

class ASin: Calculation, RealCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let res = asin(inputs[0].doubleValue)
        return Utils.radResult2Deg(res, calculatorMode)
    }
}

class ACos: Calculation, RealCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let res = acos(inputs[0].doubleValue)
        return Utils.radResult2Deg(res, calculatorMode)
    }
}

class ATan: Calculation, RealCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let res = atan(inputs[0].doubleValue)
        return Utils.radResult2Deg(res, calculatorMode)
    }
}

class Inv: Calculation, RealCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = inputs[0].doubleValue
        if input == 0 {
            return DoublePrecisionValue(Double.nan)
        } else {
            return DoublePrecisionValue(1.0 / input)
        }
    }
}

class Complex: Calculation, RealToComplexCalculation {
    let arity: Int = 2

    func calcToComplex(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        return ComplexValue(inputs[0].doubleValue, inputs[1].doubleValue)
    }
}

class Square: Calculation, RealCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = inputs[0].doubleValue
        return DoublePrecisionValue(input * input)
    }
}

class Pow: Calculation, RealCalculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = pow(inputs[0].doubleValue, inputs[1].doubleValue)
        return DoublePrecisionValue(result)
    }
}

class Pow3: Calculation, RealCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = pow(inputs[0].doubleValue, 3)
        return DoublePrecisionValue(result)
    }
}

class Sqrt: Calculation, RealCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return DoublePrecisionValue(sqrt(inputs[0].doubleValue))
    }
}

class Root3: Calculation, RealCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue {
        let base = inputs[0].doubleValue
        let result = pow(base, 1.0/3.0)
        return DoublePrecisionValue(result)
    }
}

class NthRoot: Calculation, RealCalculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue {
        let base = inputs[0].doubleValue
        let exponent = inputs[1].doubleValue

        if exponent == 0 {
            return DoublePrecisionValue(Double.nan)
        }

        let result = pow(base, 1.0/exponent)
        return DoublePrecisionValue(result)
    }
}

class Log: Calculation, RealCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return DoublePrecisionValue(log(inputs[0].doubleValue))
    }
}

class Exp: Calculation, RealCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return DoublePrecisionValue(exp(inputs[0].doubleValue))
    }
}

class Log10: Calculation, RealCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return DoublePrecisionValue(log10(inputs[0].doubleValue))
    }
}

class Exp10: Calculation, RealCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue {
        return DoublePrecisionValue(powl(10, inputs[0].doubleValue))
    }
}

class ToEng: Calculation, RealCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return DoublePrecisionValue(inputs[0].doubleValue, numberFormat: .eng)
    }
}

class ToDecimal: Calculation, RealCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return DoublePrecisionValue(inputs[0].doubleValue, numberFormat: .decimal)
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
                              _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        if calculatorMode.angle == .Rad {
            return DoublePrecisionValue(value)
        } else {
            let result = value * 180.0 / Double.pi
            return DoublePrecisionValue(result)
        }
    }

    static func calculateComplexCartesian(_ values: [ComplexValue],
                                          _ op: (DoublePrecisionValue, DoublePrecisionValue) -> DoublePrecisionValue) throws -> ComplexValue {
        do {
            let resultComponents: [DoublePrecisionValue] = values[0].cartesian.enumerated().map { (index, v1) in
                let v2 = values[1].cartesian[index]
                return op(v1, v2)
            }

            return try ComplexValue(resultComponents, originalFormat: .cartesian)
        } catch {
            throw error
        }
    }

    static func num(_ v: Double) -> DoublePrecisionValue {
        DoublePrecisionValue(v)
    }
}
