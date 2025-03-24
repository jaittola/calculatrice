import Foundation

class Plus: Calculation, ComplexCalculation {
    let arity: Int = 2

    func calcComplex(_ inputs: [ComplexValue],
                     _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        do {
            return try Utils.calculateComplexCartesian(inputs) { v1, v2 in
                NumericalValue(v1.value + v2.value)
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
                NumericalValue(v1.value - v2.value)
            }
        } catch {
            throw error
        }
    }
}

class Mult: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 2
    func calculate(_ inputs: [NumericalValue],
                   _ calculatorMode: CalculatorMode) -> NumericalValue {
        let result = inputs[0].value * inputs[1].value
        return NumericalValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        let r = (inputs[0].polarAbsolute.value *
                 inputs[1].polarAbsolute.value)
        let arg = Utils.clampComplexArg(inputs[0].polarArgument.value +
                                        inputs[1].polarArgument.value)
        return ComplexValue(absolute: r,
                            argument: arg,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Div: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 2
    func calculate(_ inputs: [NumericalValue],
                   _ calculatorMode: CalculatorMode) throws -> NumericalValue {
        if inputs[1].value == 0 {
            throw CalcError.divisionByZero
        }
        let result = inputs[0].value / inputs[1].value
        return NumericalValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {

        if inputs[1].polarAbsolute.value == 0 {
            throw CalcError.divisionByZero
        }

        let r = inputs[0].polarAbsolute.value / inputs[1].polarAbsolute.value
        let arg = Utils.clampComplexArg(inputs[0].polarArgument.value - inputs[1].polarArgument.value)

        return ComplexValue(absolute: r,
                            argument: arg,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Neg: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [NumericalValue],
                   _ calculatorMode: CalculatorMode) -> NumericalValue {
        let result = -inputs[0].value
        return NumericalValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return Mult().calcComplex([inputs[0], ComplexValue(-1.0, 0)], calculatorMode)
    }
}

class Sin: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1

    func calculate(_ inputs: [NumericalValue],
                   _ calculatorMode: CalculatorMode) -> NumericalValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return NumericalValue(sin(input))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        // sin(a + bi) = sin(a) * cosh(b) + i * cos(a) * sinh(b)
        let a = inputs[0].real.value
        let b = inputs[0].imag.value

        let re = sin(a) * cosh(b)
        let im = cos(a) * sinh(b)

        return ComplexValue(re, im,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Cos: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1

    func calculate(_ inputs: [NumericalValue],
                   _ calculatorMode: CalculatorMode) -> NumericalValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return NumericalValue(cos(input))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        // cos(a + bi) = cos(a) * cosh(b) - i * sin(a) * sinh(b)

        let a = inputs[0].real.value
        let b = inputs[0].imag.value

        let re = cos(a) * cosh(b)
        let im = -sin(a) * sinh(b)

        return ComplexValue(re, im,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Tan: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1

    func calculate(_ inputs: [NumericalValue],
                   _ calculatorMode: CalculatorMode) -> NumericalValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return NumericalValue(tan(input))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        let num = Sin().calcComplex(inputs, calculatorMode)
        let denom = Cos().calcComplex(inputs, calculatorMode)

        do {
            return try Div().calcComplex([num, denom], calculatorMode)
        } catch {
            throw error
        }
    }
}

class ASin: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) -> NumericalValue {
        let res = asin(inputs[0].value)
        return Utils.radResult2Deg(res, calculatorMode)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        // Logarithmic form: arcsin(z) = i * ln(sqrt(1 - z^2) - iz)
        // variables below refer to the formula above
        do {
            let z = inputs[0]
            let i = ComplexValue(0.0, 1.0)
            let iz = Mult().calcComplex([i, z], calculatorMode)
            let z2 = Square().calcComplex([z], calculatorMode)
            let oneMinusZ2 = try Minus().calcComplex([ComplexValue(1.0, 0), z2], calculatorMode)
            let sqrtOneMinusZ2 = Sqrt().calcComplex([oneMinusZ2], calculatorMode)
            let lnArg = try Minus().calcComplex([sqrtOneMinusZ2, iz], calculatorMode)
            let logarithm = Log().calcComplex([lnArg], calculatorMode)
            let result = Mult().calcComplex([i, logarithm], calculatorMode)

            return ComplexValue(result,
                                presentationFormat: inputs[0].presentationFormat)
        } catch {
            throw error
        }
    }
}

class ACos: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) -> NumericalValue {
        let res = acos(inputs[0].value)
        return Utils.radResult2Deg(res, calculatorMode)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        do {
            // arccos(z) = PI/2 - arcsin(z)
            let asine = try ASin().calcComplex(inputs, calculatorMode)
            let halfPi = NumericalValue(Double.pi / 2.0)
            let result = try Minus().calcComplex([halfPi.asComplex, asine], calculatorMode)

            return ComplexValue(result,
                                presentationFormat: inputs[0].presentationFormat)
        } catch {
            throw error
        }
    }
}

class ATan: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) -> NumericalValue {
        let res = atan(inputs[0].value)
        return Utils.radResult2Deg(res, calculatorMode)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        do {
            // arctan(z) = -i/2 * ln((i - z) / (i + z))
            // variables below refer to the formula above

            let z = inputs[0]
            let i = ComplexValue(0, 1.0)
            let minuxHalfI = ComplexValue(0, -0.5)
            let iMinusZ = try Minus().calcComplex([i, z], calculatorMode)
            let iPlusZ = try Plus().calcComplex([i, z], calculatorMode)
            let division = try Div().calcComplex([iMinusZ, iPlusZ], calculatorMode)
            let logarithm = Log().calcComplex([division], calculatorMode)
            let result = Mult().calcComplex([minuxHalfI, logarithm], calculatorMode)

            return ComplexValue(result,
                                presentationFormat: inputs[0].presentationFormat)
        } catch {
            throw error
        }
    }
}

class Inv: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) -> NumericalValue {
        let input = inputs[0].value
        if input == 0 {
            return NumericalValue(Double.nan)
        } else {
            return NumericalValue(1.0 / input)
        }
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        if inputs[0].polarAbsolute.value == 0 {
            return ComplexValue(Double.nan, Double.nan)
        }
        let absolute = 1.0 / inputs[0].polarAbsolute.value
        let argument = Utils.clampComplexArg(-(inputs[0].polarArgument.value))

        return ComplexValue(absolute: absolute,
                            argument: argument,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Complex: Calculation, NumTypeConversionCalculation {
    let arity: Int = 2

    func convert(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) throws -> Value {
        return Value(ComplexValue(inputs[0].value, inputs[1].value))
    }
}

class ComplexPolar: Calculation, NumTypeConversionCalculation {
    let arity: Int = 2

    func convert(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) -> Value {
        let argument = Utils.deg2Rad([inputs[1]], calculatorMode)[0]
        return Value(ComplexValue(absolute: inputs[0].value,
                                  argument: argument))
    }
}

class ImaginaryNumber: Calculation, ComplexCalculation {
    let arity: Int = 1

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        let inputAsReal = inputs[0].asReal

        if let inputAsReal = inputAsReal {
            return ComplexValue(0, inputAsReal.value, presentationFormat: .cartesian)
        } else {
            throw CalcError.unsupportedValueType
        }
    }
}

class Re: Calculation, ComplexCalculation {
    let arity: Int = 1

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return ComplexValue(inputs[0].real.value, 0)
    }
}

class Im: Calculation, ComplexCalculation {
    let arity: Int = 1

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return ComplexValue(inputs[0].imag.value, 0)
    }
}

class Conjugate: Calculation, ComplexCalculation {
    let arity: Int = 1

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return ComplexValue(inputs[0].real.value,
                            -inputs[0].imag.value,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Square: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) -> NumericalValue {
        let input = inputs[0].value
        return NumericalValue(input * input)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return Pow().calcComplex([inputs[0], ComplexValue(2.0, 0.0)],
                                 calculatorMode)
    }
}

class Pow: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 2
    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) -> NumericalValue {
        let result = pow(inputs[0].value, inputs[1].value)
        return NumericalValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        // Calculating (re^(iw))^(x+yi) = r^x * e^(-yw) * e^(i*(xw + yln(r)));
        // the variable names below are based on this equation.

        let r = inputs[0].polarAbsolute.value
        let w = inputs[0].polarArgument.value
        let x = inputs[1].real.value
        let y = inputs[1].imag.value

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
    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) -> NumericalValue {
        let result = pow(inputs[0].value, 3)
        return NumericalValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return Pow().calcComplex([inputs[0], ComplexValue(3.0, 0.0)],
                                 calculatorMode)
    }
}

class Sqrt: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1

    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) -> NumericalValue {
        return NumericalValue(sqrt(inputs[0].value))
    }

    func preferComplexCalculationWith(thisInput: [NumericalValue]) -> Bool {
        thisInput[0].value < 0
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return NthRoot().calcComplex([inputs[0], ComplexValue(2.0, 0.0)], calculatorMode)
    }
}

class Root3: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) throws -> NumericalValue {
        let base = inputs[0].value
        let result = pow(base, 1.0/3.0)
        return NumericalValue(result)
    }

    func preferComplexCalculationWith(thisInput: [NumericalValue]) -> Bool {
        thisInput[0].value < 0
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return NthRoot().calcComplex([inputs[0], ComplexValue(3.0, 0.0)], calculatorMode)
    }
}

class NthRoot: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 2
    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) throws -> NumericalValue {
        let base = inputs[0].value
        let exponent = inputs[1].value

        if exponent == 0 {
            return NumericalValue(Double.nan)
        }

        let result = pow(base, 1.0/exponent)
        return NumericalValue(result)
    }

    func preferComplexCalculationWith(thisInput: [NumericalValue]) -> Bool {
        thisInput[0].value < 0
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
    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) -> NumericalValue {
        return NumericalValue(log(inputs[0].value))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        let resultR = log(inputs[0].polarAbsolute.value)
        let resultI = Utils.clampComplexArg(inputs[0].polarArgument.value)
        return ComplexValue(resultR, resultI,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Exp: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) -> NumericalValue {
        return NumericalValue(exp(inputs[0].value))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return ComplexValue(absolute: exp(inputs[0].real.value),
                            argument: Utils.clampComplexArg(inputs[0].imag.value),
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Log10: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) -> NumericalValue {
        return NumericalValue(log10(inputs[0].value))
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
    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) throws -> NumericalValue {
        return NumericalValue(pow(10.0, inputs[0].value))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return Pow().calcComplex([ComplexValue(10.0, 0.0,
                                               presentationFormat: inputs[0].presentationFormat),
                                  inputs[0]],
                                 calculatorMode)
    }
}

class ToEng: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) -> NumericalValue {
        return NumericalValue(inputs[0].value, numberFormat: .eng)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        return ComplexValue(inputs[0],
                            numberFormat: .eng,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class ToDecimal: Calculation, RealCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [NumericalValue], _ calculatorMode: CalculatorMode) -> NumericalValue {
        return NumericalValue(inputs[0].value, numberFormat: .decimal)
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
    static func deg2Rad(_ inputs: [NumericalValue],
                        _ calculatorMode: CalculatorMode) -> [Double] {
        if calculatorMode.angle == .Rad {
            return inputs.map { input in input.value }
        } else {
            return inputs.map { input in input.value * Double.pi / 180.0}
        }
    }

    static func radResult2Deg(_ value: Double,
                              _ calculatorMode: CalculatorMode) -> NumericalValue {
        if calculatorMode.angle == .Rad {
            return NumericalValue(value)
        } else {
            let result = value * 180.0 / Double.pi
            return NumericalValue(result)
        }
    }

    static func calculateComplexCartesian(_ values: [ComplexValue],
                                          _ op: (NumericalValue, NumericalValue) -> NumericalValue) throws -> ComplexValue {
        do {
            let resultComponents: [NumericalValue] = values[0].cartesian.enumerated().map { (index, v1) in
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
        clampCyclical(value,
                      -Double.pi,
                      Double.pi)
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
}
