import Foundation

class Plus: Calculation, ComplexCalculation, RationalCalculation {
    let arity: Int = 2

    func calcComplex(_ inputs: [ComplexValue],
                     _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        let sum = try Utils.sumPolynomials(inputs[0].cartesian,
                                            inputs[1].cartesian,
                                            opNumerical: Self.numericalSum,
                                            opRational: Self.rationalSum)
        return try ComplexValue(sum,
                                originalFormat: .cartesian,
                                presentationFormat: inputs[0].presentationFormat)
    }

    func calcRational(_ inputs: [RationalValue], _ calculatorMode: CalculatorMode) throws -> RationalValue {
        return try Plus.rationalSum(inputs)
    }

    static func numericalSum(_ inputs: [Num]) throws -> Num {
        return NumericalValue(inputs[0].floatingPoint + inputs[1].floatingPoint)
    }

    static func rationalSum(_ inputs: [RationalValue]) throws -> RationalValue {
        let (v1, v2) = try Utils.expandFractions(inputs[0], inputs[1])
        return try RationalValue(v1.numerator.floatingPoint + v2.numerator.floatingPoint,
                                 v1.denominator.floatingPoint)
    }
}

class Minus: Calculation, ComplexCalculation, RationalCalculation {
    let arity: Int = 2

    func calcComplex(_ inputs: [ComplexValue],
                     _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        let diff = try Utils.sumPolynomials(inputs[0].cartesian,
                                            inputs[1].cartesian,
                                            opNumerical: Self.numericalDiff,
                                            opRational: Self.rationalDiff)
        return try ComplexValue(diff,
                                originalFormat: .cartesian,
                                presentationFormat: inputs[0].presentationFormat)
    }

    func calcRational(_ inputs: [RationalValue], _ calculatorMode: CalculatorMode) throws -> RationalValue {
        return try Minus.rationalDiff(inputs)
    }

    static func numericalDiff(_ inputs: [Num]) throws -> Num {
        return NumericalValue(inputs[0].floatingPoint - inputs[1].floatingPoint)
    }

    static func rationalDiff(_ inputs: [RationalValue]) throws -> RationalValue {
        let (v1, v2) = try Utils.expandFractions(inputs[0], inputs[1])
        return try RationalValue(v1.numerator.floatingPoint - v2.numerator.floatingPoint,
                                 v1.denominator.floatingPoint)
    }
}

class Mult: Calculation, ScalarCalculation, ComplexCalculation, RationalCalculation {
    let arity: Int = 2

    func calculate(_ inputs: [Num],
                   _ calculatorMode: CalculatorMode) -> NumericalValue {
        let result = inputs[0].floatingPoint * inputs[1].floatingPoint
        return NumericalValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        let v1 = inputs[0]
        let v2 = inputs[1]

        if let rationalResult = tryCalcComplexPolynomial(v1, v2, calculatorMode) {
            return rationalResult
        } else {
            let r = (v1.polarAbsolute.floatingPoint *
                     v2.polarAbsolute.floatingPoint)
            let arg = Utils.clampComplexArg(v1.polarArgument.floatingPoint +
                                            v2.polarArgument.floatingPoint)
            return ComplexValue(absolute: r,
                                argument: arg,
                                presentationFormat: v1.presentationFormat)
        }
    }

    func calcRational(_ inputs: [RationalValue], _ calculatorMode: CalculatorMode) throws -> RationalValue {
        let v1 = inputs[0]
        let v2 = inputs[1]

        return try RationalValue(v1.numerator.floatingPoint * v2.numerator.floatingPoint,
                                 v1.denominator.floatingPoint * v2.denominator.floatingPoint)
    }

    func tryCalcComplexPolynomial(_ v1: ComplexValue, _ v2: ComplexValue, _ calculatorMode: CalculatorMode) -> ComplexValue? {
        if v1.originalFormat == .cartesian && v2.originalFormat == .cartesian,
           let v1R = v1.real.asRational, let v1I = v1.imag.asRational,
           let v2R = v2.real.asRational, let v2I = v2.imag.asRational {

            do {
                let reals = [try calcRational([v1R, v2R], calculatorMode),
                             try Neg().calcRational([calcRational([v1I, v2I], calculatorMode)], calculatorMode)]
                let imags = [try calcRational([v1R, v2I], calculatorMode),
                             try calcRational([v1I, v2R], calculatorMode)]

                let real = try Plus().calcRational(reals, calculatorMode)
                let imag = try Plus().calcRational(imags, calculatorMode)

                return try ComplexValue([real, imag],
                                        originalFormat: .cartesian,
                                        presentationFormat: .cartesian)
            } catch { }
        }

        return nil
    }
}

class Div: Calculation, ScalarCalculation, ComplexCalculation, RationalCalculation {
    let arity: Int = 2

    func calculate(_ inputs: [Num],
                   _ calculatorMode: CalculatorMode) throws -> NumericalValue {
        if inputs[1].floatingPoint == 0 {
            throw CalcError.divisionByZero()
        }
        let result = inputs[0].floatingPoint / inputs[1].floatingPoint
        return NumericalValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        let v1 = inputs[0]
        let v2 = inputs[1]

        if v2.polarAbsolute.floatingPoint == 0 {
            throw CalcError.divisionByZero()
        }

        if let rationalResult = tryCalcComplexPolynomial(v1, v2, calculatorMode) {
            return rationalResult
        } else {
            let r = v1.polarAbsolute.floatingPoint / v2.polarAbsolute.floatingPoint
            let arg = Utils.clampComplexArg(v1.polarArgument.floatingPoint - v2.polarArgument.floatingPoint)

            return ComplexValue(absolute: r,
                                argument: arg,
                                presentationFormat: v2.presentationFormat)
        }
    }

    func calcRational(_ inputs: [RationalValue], _ calculatorMode: CalculatorMode) throws -> RationalValue {
        let v1 = inputs[0]
        let v2 = inputs[1]

        if v2.numerator.floatingPoint == 0 {
            throw CalcError.divisionByZero()
        }

        return try RationalValue(v1.numerator.floatingPoint * v2.denominator.floatingPoint,
                                 v1.denominator.floatingPoint * v2.numerator.floatingPoint)
    }

    // Division as a polynomial if the divisor is a real rational number.
    func tryCalcComplexPolynomial(_ v1: ComplexValue, _ v2: ComplexValue, _ calculatorMode: CalculatorMode) -> ComplexValue? {
        if v1.originalFormat == .cartesian,
           v2.originalFormat == .cartesian,
           v1.real.asRational != nil,
           v1.imag.asRational != nil,
           let v2r = v2.real.asRational,
           let invV2R = try? Inv().calcRational([v2r], calculatorMode),
           v2.imag.floatingPoint == 0 {
            let invV2RComplex = ComplexValue(realValue: invV2R,
                                             imagValue: RationalValue.zero)
            return Mult().tryCalcComplexPolynomial(v1,
                                                   invV2RComplex,
                                                   calculatorMode)
        }
        return nil
    }

    func preferRealCalculationWith(thisInput: [Value]) -> Bool {
        // Solves a special case:
        // when calculating a division of whole numbers (which can
        // be converted to rationals), the result should be a numeric
        // value, and not a fraction.
        // I.e., 1 / 2 should be 0.5 (not 1/2), but, on the other hand,
        // ((1/2) + (1/2)) / 2 should be 1/2

        if case .number = thisInput[0].containedValue,
            case .number = thisInput[1].containedValue {
            return true
        }

        return false
    }
}

class Neg: Calculation, ScalarCalculation, ComplexCalculation, RationalCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [Num],
                   _ calculatorMode: CalculatorMode) -> NumericalValue {
        let result = -inputs[0].floatingPoint
        return NumericalValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return Mult().calcComplex([inputs[0], ComplexValue(-1.0, 0)], calculatorMode)
    }

    func calcRational(_ inputs: [RationalValue], _ calculatorMode: CalculatorMode) throws -> RationalValue {
        let v = inputs[0]
        return try RationalValue(-1 * v.numerator.floatingPoint,
                              v.denominator.floatingPoint)
    }
}

class Sin: Calculation, ScalarCalculation, ComplexCalculation {
    let arity: Int = 1

    func calculate(_ inputs: [Num],
                   _ calculatorMode: CalculatorMode) -> NumericalValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return NumericalValue(sin(input))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        // sin(a + bi) = sin(a) * cosh(b) + i * cos(a) * sinh(b)
        let a = inputs[0].real.floatingPoint
        let b = inputs[0].imag.floatingPoint

        let re = sin(a) * cosh(b)
        let im = cos(a) * sinh(b)

        return ComplexValue(re, im,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Cos: Calculation, ScalarCalculation, ComplexCalculation {
    let arity: Int = 1

    func calculate(_ inputs: [Num],
                   _ calculatorMode: CalculatorMode) -> NumericalValue {
        let input = Utils.deg2Rad(inputs, calculatorMode)[0]
        return NumericalValue(cos(input))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        // cos(a + bi) = cos(a) * cosh(b) - i * sin(a) * sinh(b)

        let a = inputs[0].real.floatingPoint
        let b = inputs[0].imag.floatingPoint

        let re = cos(a) * cosh(b)
        let im = -sin(a) * sinh(b)

        return ComplexValue(re, im,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Tan: Calculation, ScalarCalculation, ComplexCalculation {
    let arity: Int = 1

    func calculate(_ inputs: [Num],
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

class ASin: Calculation, ScalarCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) -> NumericalValue {
        let res = asin(inputs[0].floatingPoint)
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

class ACos: Calculation, ScalarCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) -> NumericalValue {
        let res = acos(inputs[0].floatingPoint)
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

class ATan: Calculation, ScalarCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) -> NumericalValue {
        let res = atan(inputs[0].floatingPoint)
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

class Inv: Calculation, ScalarCalculation, ComplexCalculation, RationalCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) -> NumericalValue {
        let input = inputs[0].floatingPoint
        if input == 0 {
            return NumericalValue(Double.nan)
        } else {
            return NumericalValue(1.0 / input)
        }
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        if inputs[0].polarAbsolute.floatingPoint == 0 {
            return ComplexValue(Double.nan, Double.nan)
        }
        let absolute = 1.0 / inputs[0].polarAbsolute.floatingPoint
        let argument = Utils.clampComplexArg(-(inputs[0].polarArgument.floatingPoint))

        return ComplexValue(absolute: absolute,
                            argument: argument,
                            presentationFormat: inputs[0].presentationFormat)
    }

    func calcRational(_ inputs: [RationalValue], _ calculatorMode: CalculatorMode) throws -> RationalValue {
        let v1 = inputs[0]

        if v1.denominator.floatingPoint == 0 {
            throw CalcError.badCalculationOp()
        }

        return try RationalValue(v1.denominator.floatingPoint,
                                 v1.numerator.floatingPoint)
    }
}

class Complex: Calculation, NumTypeConversionCalculation {
    let arity: Int = 2

    func convert(_ inputs: [Num], _ calculatorMode: CalculatorMode) throws -> Value {
        return Value(ComplexValue(realValue: inputs[0], imagValue: inputs[1]))
    }
}

class ComplexPolar: Calculation, NumTypeConversionCalculation {
    let arity: Int = 2

    func convert(_ inputs: [Num], _ calculatorMode: CalculatorMode) -> Value {
        let argument = Utils.deg2Rad([inputs[1]], calculatorMode)[0]
        return Value(ComplexValue(absolute: inputs[0],
                                  argument: NumericalValue(argument)))
    }
}

class ImaginaryNumber: Calculation, ComplexCalculation {
    let arity: Int = 1

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        let inputAsReal = inputs[0].asReal

        if let inputAsReal = inputAsReal {
            return ComplexValue(imagValue: inputAsReal)
        } else {
            throw CalcError.unsupportedValueType()
        }
    }
}

class RationalNumber: Calculation, NumTypeConversionCalculation {
    var arity: Int = 2

    func convert(_ inputs: [Num], _ calculatorMode: CalculatorMode) throws -> Value {
        Value(try RationalValue(numerator: inputs[0],
                                denominator: inputs[1],
                                simplifyOnInitialisation: true))
    }
}

class MixedRationalNumber: Calculation, NumTypeConversionCalculation {
    var arity: Int = 3

    func convert(_ inputs: [Num], _ calculatorMode: CalculatorMode) throws -> Value {
        Value(try RationalValue(whole: inputs[0],
                                numerator: inputs[1],
                                denominator: inputs[2]))
    }
}

class OnlyFraction: Calculation, RationalCalculation {
    var arity: Int = 1

    func calcRational(_ inputs: [RationalValue], _ calculatorMode: CalculatorMode) -> RationalValue {
        inputs[0].fracOnly
    }
}

class Re: Calculation, ComplexCalculation {
    let arity: Int = 1

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return ComplexValue(realValue: inputs[0].real)
    }
}

class Im: Calculation, ComplexCalculation {
    let arity: Int = 1

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return ComplexValue(realValue: inputs[0].imag)
    }
}

class Conjugate: Calculation, ComplexCalculation {
    let arity: Int = 1

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        var negImag: Num
        if let imagRat = inputs[0].imag.asRational {
            print("Imag rational \(imagRat)")
            negImag = try Neg().calcRational([imagRat], calculatorMode) as Num
        }  else {
            print("Imag real \(inputs[0].imag)")
            negImag = Neg().calculate([inputs[0].imag], calculatorMode) as Num
            print("Neg imag \(negImag)")
        }

        return try ComplexValue([inputs[0].real,
                                 negImag],
                                originalFormat: .cartesian,
                                presentationFormat: inputs[0].presentationFormat)
    }
}

class Square: Calculation, ScalarCalculation, ComplexCalculation, RationalCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) -> NumericalValue {
        let input = inputs[0].floatingPoint
        return NumericalValue(input * input)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return Pow().calcComplex([inputs[0], ComplexValue(2.0, 0.0)],
                                 calculatorMode)
    }

    func calcRational(_ inputs: [RationalValue], _ calculatorMode: CalculatorMode) throws -> RationalValue {
        return try Pow().calcRational([inputs[0], RationalValue(2, 1)], calculatorMode)
    }
}

class Pow: Calculation, ScalarCalculation, ComplexCalculation, RationalCalculation {
    let arity: Int = 2
    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) -> NumericalValue {
        let result = pow(inputs[0].floatingPoint, inputs[1].floatingPoint)
        return NumericalValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        // Calculating (re^(iw))^(x+yi) = r^x * e^(-yw) * e^(i*(xw + yln(r)));
        // the variable names below are based on this equation.

        let r = inputs[0].polarAbsolute.floatingPoint
        let w = inputs[0].polarArgument.floatingPoint
        let x = inputs[1].real.floatingPoint
        let y = inputs[1].imag.floatingPoint

        let rx = pow(r, x)
        let eyw = exp(-y * w)
        let arg = x * w + y * log(r)

        let resultR = rx * eyw
        let resultArg = Utils.clampComplexArg(arg)

        return ComplexValue(absolute: resultR, argument: resultArg,
                            presentationFormat: inputs[0].presentationFormat)
    }

    func calcRational(_ inputs: [RationalValue], _ calculatorMode: CalculatorMode) throws -> RationalValue {
        guard inputs[1].isWholeNumber else {
            throw CalcError.badInput()
        }

        let resultNumerator = pow(inputs[0].numerator.floatingPoint, inputs[1].floatingPoint)
        let resultDenominator = pow(inputs[0].denominator.floatingPoint, inputs[1].floatingPoint)

        return try RationalValue(resultNumerator, resultDenominator)
    }

    func preferRealCalculationWith(thisInput: [Value]) -> Bool {
        return !(thisInput[1].asRational?.isWholeNumber ?? false)
    }
}

class Pow3: Calculation, ScalarCalculation, ComplexCalculation, RationalCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) -> NumericalValue {
        let result = pow(inputs[0].floatingPoint, 3)
        return NumericalValue(result)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return Pow().calcComplex([inputs[0], ComplexValue(3.0, 0.0)],
                                 calculatorMode)
    }

    func calcRational(_ inputs: [RationalValue], _ calculatorMode: CalculatorMode) throws -> RationalValue {
        return try Pow().calcRational([inputs[0], RationalValue(3, 1)], calculatorMode)
    }
}

class Sqrt: Calculation, ScalarCalculation, ComplexCalculation {
    let arity: Int = 1

    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) -> NumericalValue {
        return NumericalValue(sqrt(inputs[0].floatingPoint))
    }

    func preferComplexCalculationWith(thisInput: [Num]) -> Bool {
        thisInput[0].floatingPoint < 0
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return NthRoot().calcComplex([inputs[0], ComplexValue(2.0, 0.0)], calculatorMode)
    }
}

class Root3: Calculation, ScalarCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) throws -> NumericalValue {
        let base = inputs[0].floatingPoint
        let result = pow(base, 1.0/3.0)
        return NumericalValue(result)
    }

    func preferComplexCalculationWith(thisInput: [Num]) -> Bool {
        thisInput[0].floatingPoint < 0
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return NthRoot().calcComplex([inputs[0], ComplexValue(3.0, 0.0)], calculatorMode)
    }
}

class NthRoot: Calculation, ScalarCalculation, ComplexCalculation {
    let arity: Int = 2
    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) throws -> NumericalValue {
        let base = inputs[0].floatingPoint
        let exponent = inputs[1].floatingPoint

        if exponent == 0 {
            return NumericalValue(Double.nan)
        }

        let result = pow(base, 1.0/exponent)
        return NumericalValue(result)
    }

    func preferComplexCalculationWith(thisInput: [Num]) -> Bool {
        thisInput[0].floatingPoint < 0
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        let expv = Inv().calcComplex([inputs[1]], calculatorMode)
        if expv.isNan {
            return expv
        }

        return Pow().calcComplex([inputs[0], expv], calculatorMode)
    }
}

class Log: Calculation, ScalarCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) -> NumericalValue {
        return NumericalValue(log(inputs[0].floatingPoint))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        let resultR = log(inputs[0].polarAbsolute.floatingPoint)
        let resultI = Utils.clampComplexArg(inputs[0].polarArgument.floatingPoint)
        return ComplexValue(resultR, resultI,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Exp: Calculation, ScalarCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) -> NumericalValue {
        return NumericalValue(exp(inputs[0].floatingPoint))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return ComplexValue(absolute: exp(inputs[0].real.floatingPoint),
                            argument: Utils.clampComplexArg(inputs[0].imag.floatingPoint),
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class Log10: Calculation, ScalarCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) -> NumericalValue {
        return NumericalValue(log10(inputs[0].floatingPoint))
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

class Exp10: Calculation, ScalarCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) throws -> NumericalValue {
        return NumericalValue(pow(10.0, inputs[0].floatingPoint))
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) -> ComplexValue {
        return Pow().calcComplex([ComplexValue(10.0, 0.0,
                                               presentationFormat: inputs[0].presentationFormat),
                                  inputs[0]],
                                 calculatorMode)
    }
}

class ToEng: Calculation, ScalarCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) -> NumericalValue {
        return NumericalValue(inputs[0].floatingPoint, numberFormat: .eng)
    }

    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        return ComplexValue(inputs[0],
                            numberFormat: .eng,
                            presentationFormat: inputs[0].presentationFormat)
    }
}

class ToDecimal: Calculation, ScalarCalculation, ComplexCalculation {
    let arity: Int = 1
    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) -> NumericalValue {
        return NumericalValue(inputs[0].floatingPoint, numberFormat: .decimal)
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
        let v = inputs[0]
        return ComplexValue(v,
                            presentationFormat: .cartesian)
    }
}

class ToPolar: Calculation, ComplexCalculation {
    let arity: Int = 1
    func calcComplex(_ inputs: [ComplexValue], _ calculatorMode: CalculatorMode) throws -> ComplexValue {
        let v = inputs[0]
        return ComplexValue(v,
                            presentationFormat: .polar)
    }
}

class Combinations: Calculation, ScalarCalculation {
    let arity: Int = 2

    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) throws -> NumericalValue {
        let n = inputs[0]
        let r = inputs[1]

        let fn = try Factorial().calculate([n], calculatorMode)
        let fr = try Factorial().calculate([r], calculatorMode)
        guard let fMinusR = try Minus().calcComplex([n.asComplex, r.asComplex], calculatorMode).asReal else {
            throw CalcError.badInput()
        }
        let fnr = try Factorial().calculate([fMinusR], calculatorMode)
        let denominator = Mult().calculate([fr, fnr], calculatorMode)
        let result = try Div().calculate([fn, denominator], calculatorMode)
        return result
    }
}

class Permutations: Calculation, ScalarCalculation {
    let arity: Int = 2

    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) throws -> NumericalValue {
        let n = inputs[0]
        let r = inputs[1]

        let fn = try Factorial().calculate([n], calculatorMode)
        guard let fMinusR = try Minus().calcComplex([n.asComplex, r.asComplex], calculatorMode).asReal else {
            throw CalcError.badInput()
        }
        let fnr = try Factorial().calculate([fMinusR], calculatorMode)
        let result = try Div().calculate([fn, fnr], calculatorMode)
        return result
    }
}

class Factorial: Calculation, ScalarCalculation {
    let arity: Int = 1

    func calculate(_ inputs: [Num], _ calculatorMode: CalculatorMode) throws -> NumericalValue {
        let (whole, fractional) = modf(inputs[0].floatingPoint)

        guard fractional == 0, whole >= 0 else {
            throw CalcError.badInput()
        }

        if whole == 0 {
            return NumericalValue(1)
        }

        let n = Int64(inputs[0].floatingPoint)

        var result: Double = 1
        for i in 1...n {
            let partialResult = result * Double(i)
            if partialResult.isInfinite {
                throw CalcError.arithmeticOverflow()
            }

            result = partialResult
        }

        return NumericalValue(Double(result))
    }
}

class Utils {
    static func deg2Rad(_ inputs: [Num],
                        _ calculatorMode: CalculatorMode) -> [Double] {
        if calculatorMode.angle == .Rad {
            return inputs.map { input in input.floatingPoint }
        } else {
            return inputs.map { input in input.floatingPoint * Double.pi / 180.0}
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

    static func sumPolynomials(_ a: [Num], _ b: [Num],
                               opNumerical: (_ inputs: [Num]) throws -> any Num,
                               opRational: (_ inputs: [RationalValue]) throws -> any Num) throws -> [any Num] {
        return try a.enumerated().map { (index, v1) in
            let v2 = b[index]
            if let v1R = v1.asRational, let v2R = v2.asRational {
                return try opRational([v1R, v2R])
            } else {
                return try opNumerical([v1, v2])
            }
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

    static func expandFractions(_ v1: RationalValue, _ v2: RationalValue) throws -> (RationalValue, RationalValue) {
        let simplifiedV1 = try simplifyFraction(v1)
        let simplifiedV2 = try simplifyFraction(v2)

        if simplifiedV1.denominator.value == simplifiedV2.denominator.value {
            return (simplifiedV1, simplifiedV2)
        }

        let newV1 = try RationalValue(simplifiedV1.numerator.floatingPoint * simplifiedV2.denominator.floatingPoint,
                                      simplifiedV1.denominator.floatingPoint * simplifiedV2.denominator.floatingPoint,
                                      simplifyOnInitialisation: false)
        let newV2 = try RationalValue(simplifiedV2.numerator.floatingPoint * simplifiedV1.denominator.floatingPoint,
                                      simplifiedV2.denominator.floatingPoint * simplifiedV1.denominator.floatingPoint,
                                      simplifyOnInitialisation: false)

        return (newV1, newV2)
    }

    static func simplifyFraction(_ v: RationalValue) throws -> RationalValue {
        let (num, den) = try simplifyFractionComponents(v.numerator.floatingPoint,
                                                        v.denominator.floatingPoint)
        return try RationalValue(num, den)
    }

    static func simplifyFractionComponents(_ numerator: Double,
                                           _ denominator: Double) throws -> (Double, Double) {
        let absNum = abs(numerator)
        let absDen = abs(denominator)

        let common = try gcd(absNum, absDen)
        if common == 1 {
            return (numerator, absDen)
        } else {
            let dc = Double(common)
            return (numerator / dc, absDen / dc)
        }
    }

    static func gcd(_ xf: Double, _ yf: Double) throws -> Int64 {
        let x = Int64(exactly: xf)
        let y = Int64(exactly: yf)

        guard let x = x, let y = y else {
            throw CalcError.badInput()
        }

        var a: Int64 = 0
        var b = max(x, y)
        var r = min(x, y)

        while r != 0 {
            a = b
            b = r
            r = a % b
        }
        return b
    }
}
