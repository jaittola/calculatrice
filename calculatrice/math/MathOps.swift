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

class Mult: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = inputs[0].doubleValue * inputs[1].doubleValue
        return DoublePrecisionValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        let r = (inputs[0].polarAbsolute.doubleValue *
                 inputs[1].polarAbsolute.doubleValue)
        let arg = Utils.clampComplexArg(inputs[0].polarArgument.doubleValue +
                                        inputs[1].polarArgument.doubleValue)
        return ComplexValue(absolute: r,
                            argument: arg,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Div: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue {
        if inputs[1].doubleValue == 0 {
            throw CalcError.divisionByZero
        }
        let result = inputs[0].doubleValue / inputs[1].doubleValue
        return DoublePrecisionValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {

        if inputs[1].polarAbsolute.doubleValue == 0 {
            throw CalcError.divisionByZero
        }

        let r = inputs[0].polarAbsolute.doubleValue / inputs[1].polarAbsolute.doubleValue
        let arg = Utils.clampComplexArg(inputs[0].polarArgument.doubleValue - inputs[1].polarArgument.doubleValue)

        return ComplexValue(absolute: r,
                            argument: arg,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Neg: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = -inputs[0].doubleValue
        return DoublePrecisionValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return Mult().calcComplex([inputs[0], ComplexValue(-1.0, 0)], calculatorMode)
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

class Inv: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = inputs[0].doubleValue
        if input == 0 {
            return DoublePrecisionValue(Double.nan)
        } else {
            return DoublePrecisionValue(1.0 / input)
        }
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        if inputs[0].polarAbsolute.doubleValue == 0 {
            return ComplexValue(Double.nan, Double.nan)
        }
        let absolute = 1.0 / inputs[0].polarAbsolute.doubleValue
        let argument = Utils.clampComplexArg(-(inputs[0].polarArgument.doubleValue))

        return ComplexValue(absolute: absolute,
                            argument: argument)
    }
}

class Complex: Calculation, RealToComplexCalculation {
    let arity: Int = 2

    func calcToComplex(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        return ComplexValue(inputs[0].doubleValue, inputs[1].doubleValue)
    }
}

class ComplexPolar: Calculation, RealToComplexCalculation {
    let arity: Int = 2

    func calcToComplex(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        let argument = Utils.deg2Rad([inputs[1]], calculatorMode)[0]
        return ComplexValue(absolute: inputs[0].doubleValue,
                            argument: argument)
    }
}

class ImaginaryNumber: Calculation, ComplexCalculation {
    let arity: Int = 1

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        let inputAsReal = inputs[0].asReal

        if let inputAsReal = inputAsReal {
            return ComplexValue(0, inputAsReal.doubleValue, presentationFormat: .cartesian)
        } else {
            throw CalcError.unsupportedValueType
        }
    }
}

class Square: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let input = inputs[0].doubleValue
        return DoublePrecisionValue(input * input)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return Pow().calcComplex([inputs[0], ComplexValue(2, 0)],
                                 calculatorMode)
    }
}

class Pow: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 2
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = pow(inputs[0].doubleValue, inputs[1].doubleValue)
        return DoublePrecisionValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        // Calculating (re^(iw))^(x+yi) = r^x * e^(-yw) * e^(i*(xw + yln(r)));
        // the variable names below are based on this equation.

        let r = inputs[0].polarAbsolute.doubleValue
        let w = inputs[0].polarArgument.doubleValue
        let x = inputs[1].real.doubleValue
        let y = inputs[1].imag.doubleValue

        let rx = pow(r, x)
        let eyw = exp(-y * w)
        let arg = x * w + y * log(r)

        let resultR = rx * eyw
        let resultArg = Utils.clampComplexArg(arg)

        return ComplexValue(absolute: resultR, argument: resultArg,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Pow3: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        let result = pow(inputs[0].doubleValue, 3)
        return DoublePrecisionValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return Pow().calcComplex([inputs[0], ComplexValue(3, 0)],
                                 calculatorMode)
    }
}

class Sqrt: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return DoublePrecisionValue(sqrt(inputs[0].doubleValue))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return NthRoot().calcComplex([inputs[0], ComplexValue(2, 0)], calculatorMode)
    }
}

class Root3: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue {
        let base = inputs[0].doubleValue
        let result = pow(base, 1.0/3.0)
        return DoublePrecisionValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return NthRoot().calcComplex([inputs[0], ComplexValue(3, 0)], calculatorMode)
    }
}

class NthRoot: Calculation, RealCalculation, ComplexCalculation {
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

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        let expv = Inv().calcComplex([inputs[1]], calculatorMode)
        if expv.isNan {
            return expv
        }

        return Pow().calcComplex([inputs[0], expv], calculatorMode)
    }
}

class Log: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return DoublePrecisionValue(log(inputs[0].doubleValue))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        let resultR = log(inputs[0].polarAbsolute.doubleValue)
        let resultI = Utils.clampComplexArg(inputs[0].polarArgument.doubleValue)
        return ComplexValue(resultR, resultI,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Exp: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return DoublePrecisionValue(exp(inputs[0].doubleValue))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return ComplexValue(absolute: exp(inputs[0].real.doubleValue),
                            argument: Utils.clampComplexArg(inputs[0].imag.doubleValue),
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Log10: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return DoublePrecisionValue(log10(inputs[0].doubleValue))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        let logr = Log().calcComplex(inputs, calculatorMode)
        do {
            return try Div().calcComplex([logr, ComplexValue(log(10), 0)],
                                          calculatorMode)
        } catch {
            throw error
        }
    }
}

class Exp10: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue {
        return DoublePrecisionValue(pow(10.0, inputs[0].doubleValue))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return Pow().calcComplex([ComplexValue(10, 0,
                                               presentationFormat: inputs[0].presentationFormat),
                                  inputs[0]],
                                 calculatorMode)
    }
}

class ToEng: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return DoublePrecisionValue(inputs[0].doubleValue, numberFormat: .eng)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        return ComplexValue(inputs[0],
                            numberFormat: .eng,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class ToDecimal: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [DoublePrecisionValue], _ calculatorMode: CalculatorMode) -> DoublePrecisionValue {
        return DoublePrecisionValue(inputs[0].doubleValue, numberFormat: .decimal)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        return ComplexValue(inputs[0],
                            numberFormat: .decimal,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class ToCartesian: Calculation, ComplexCalculation {
    let arity: Int = 1
    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        return ComplexValue(inputs[0],
                            numberFormat: inputs[0].originalComponents[0].numberFormat,
                            presentationFormat: .cartesian)
    }
}

class ToPolar: Calculation, ComplexCalculation {
    let arity: Int = 1
    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        return ComplexValue(inputs[0],
                            numberFormat: inputs[0].originalComponents[0].numberFormat,
                            presentationFormat: .polar)
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

            return try ComplexValue(resultComponents,
                                    originalFormat: .cartesian,
                                    presentationFormat: values[0].presentationFormat)
        } catch {
            throw error
        }
    }

    static func clampComplexArg(_ value: Double) -> Double {
        clampCyclical(value, -Double.pi, Double.pi)
    }

    static func clampCyclical(_ value: Double,
                              _ min: Double,
                              _ max: Double) -> Double {
        let diff = max - min
        var result = value
        while result > max {
            result -= diff
        }
        while result <= min {
            result += diff
        }
        return result
    }

    static func num(_ v: Double) -> DoublePrecisionValue {
        DoublePrecisionValue(v)
    }
}
