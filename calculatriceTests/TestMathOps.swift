import XCTest
@testable import calculatrice

class TestMathOps: XCTestCase {
    let calculatorMode = CalculatorMode()
    let twothree = [num(3), num(2)]

    func testPlus() {
        let values = [complex(1.0, 2.0), complex(5, 6)]
        let result = assertNoThrow {
            try Plus().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, complex(6, 8))
    }

    func testPlus2() throws {
        let values = [complex(1, 0), complex(2, 0)]
        let result = assertNoThrow {
            try Plus().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, complex(3, 0))
    }

    func testPlus3() {
        let values = [complex(1, 2), complex(3, -4)]
        let result = assertNoThrow {
            try Plus().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, complex(4, -2))
    }

    func testMinus1() throws {
        let values = [complex(4, 1), complex(1, 3)]
        let result = assertNoThrow {
            try Minus().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, complex(3, -2))
    }

    func testMinus2() {
        let values = [complex(4, 0), complex(1, 0)]
        let result = assertNoThrow {
            try Minus().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, complex(3, 0))
    }

    func testMinus3() {
        let values = [complex(1, 2), complex(3, -4)]
        let result = assertNoThrow {
            try Minus().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, complex(-2, 6))
    }

    func testComplexRe() {
        let values = [complex(1, -2)]
        let result = Re().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, complex(1, 0))
    }

    func testComplexIm() {
        let values = [complex(1, -2)]
        let result = Im().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, complex(-2, 0))
    }

    func testComplexConjugate() {
        let values = [complex(1, -2)]
        let result = Conjugate().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, complex(1, 2))
    }

    func testComplexConjugate2() {
        let values = [complex(-3, -2)]
        let result = Conjugate().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, complex(-3, 2))
    }

    func testComplexConjugate3() {
        let values = [ComplexValue(absolute: 1, argument: Double.pi / 6)]
        let result = Conjugate().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, ComplexValue(absolute: 1, argument: -Double.pi / 6))
        XCTAssertEqual(result.stringValue(precision: 6, angleUnit: .Deg),
                       "1 ∠ -30°")
    }

    func testImaginaryNumber() {
        let values = [NumericalValue(Double(2)).asComplex]
        let result = assertNoThrow {
            try ImaginaryNumber().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, complex(0, 2))
    }

    func testImaginaryNumberNotForComplexNumbers() {
        let values = [complex(1, 2)]
        XCTAssertThrowsError(try ImaginaryNumber().calcComplex(values, self.calculatorMode))
    }

    func testComplexNeg() {
        let value = [complex(2, 4)]
        let result = Neg().calcComplex(value, self.calculatorMode)
        XCTAssertEqual(result, complex(-2, -4))
    }

    func testMult() {
        let result = Mult().calculate(twothree, calculatorMode)
        XCTAssertEqual(result.doubleValue, 6)
    }

    func testComplexMult() {
        let values = [complex(4, 1), complex(2, 2)]
        let result = Mult().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, complex(6, 10))
    }

    func testComplexMultReal() {
        let values = [complex(4, 0), complex(2, 0)]
        let result = Mult().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, complex(8, 0))
    }

    func testDiv() {
        let result = try? Div().calculate(twothree, calculatorMode)
        XCTAssertEqual(result?.doubleValue, 1.5)
    }

    func testComplexDiv() {
        let values = [complexPolar(4, 60), complexPolar(2, 30)]
        let result = assertNoThrow {
            try Div().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, complexPolar(2, 30))
    }

    func testComplexSquare() {
        let values = [complex(3, 2)]
        let result = Square().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, complex(5, 12))
    }

    func testComplexSquare2() {
        let values = [ComplexValue(absolute: sqrt(2), argument: Double.pi/4)]
        let result = Square().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, complex(0, 2))
    }

    func testComplex3rd() {
        let values = [ComplexValue(absolute: sqrt(2), argument: Double.pi/4)]
        let result = Pow3().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, complex(-2, 2))
    }

    func testComplexPow() {
        let values = [complex(1, 2), complex(2, 1)]
        let result = Pow().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result,
                       complex(-1.64010, 0.20205))
    }

    func testComplexRoot() {
        let values = [ComplexValue(absolute: 4.0, argument: Double.pi/4),
                      ComplexValue(absolute: 2.0, argument: 0.0)]
        let result = NthRoot().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, ComplexValue(absolute: 2,
                                            argument: Double.pi/8))
    }

    func testComplexSqrt() {
        let values = [ComplexValue(absolute: 4, argument: Double.pi/4)]
        let result = Sqrt().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, ComplexValue(absolute: 2,
                                            argument: Double.pi/8))
    }

    func testComplex3rdRoot() {
        let values = [ComplexValue(absolute: 8, argument: Double.pi/3)]
        let result = Root3().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, ComplexValue(absolute: 2,
                                            argument: Double.pi/9))
    }

    func testComplex3rdRoot2() {
        let values = [complex(2, 2)]
        let result = Root3().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, complex(1.36603, 0.36603))
    }

    func testComplex3rdRoot3() {
        let values = [complex(2, -2)]
        let result = Root3().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, complex(1.36603, -0.36603))
    }

    func testComplexExp() {
        let values = [complex(1, Double.pi/4)]
        let result = Exp().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, ComplexValue(absolute: 2.71828,
                                            argument: Double.pi/4))
    }

    func testComplexExp2() {
        let values = [complex(1, 4 * Double.pi + Double.pi/4)]
        let result = Exp().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result.polarAbsolute.doubleValue, 2.71828,
                       accuracy: NumericalValue.epsilond)
        XCTAssertEqual(result.polarArgument.doubleValue, Double.pi/4,
                       accuracy: NumericalValue.epsilond)
    }

    func testComplexExp10() {
        let values = [complex(1, 2)]
        let result = Exp10().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result.polarAbsolute.doubleValue, 10)
        XCTAssertEqual(result.polarArgument.doubleValue, -1.6780151,
                       accuracy: NumericalValue.epsilond)
    }

    func testComplexLog() {
        let v = complex(1, 2)
        let values = [v]
        let result = Log().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, complex(log(v.polarAbsolute.doubleValue),
                                       v.polarArgument.doubleValue))
    }

    func testComplexLog10() {
        let v = complex(1, 2)
        let values = [v]
        let result = assertNoThrow {
            try Log10().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, complex(0.34949, 0.48083))
    }

    func testComplexSin() {
        let values = [complex(1, 2)]
        let result = Sin().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, complex(3.16578, 1.95960))
        XCTAssertEqual(result.stringValue(precision: 6, angleUnit: calculatorMode.angle), "3.165779 + 1.959601i")
    }

    func testComplexSin2() {
        let values = [ComplexValue(absolute: 3, argument: Double.pi / 3)]
        let result = Sin().calcComplex(values, self.calculatorMode)

        XCTAssertEqual(result, ComplexValue(absolute: 6.755768, argument: 0.0700191))
        XCTAssertEqual(result.stringValue(precision: 6, angleUnit: .Rad),
                       "6.755769 ∠ 0.070019")
    }

    func testComplexCos() {
        let values = [complex(1, 2)]
        let result = Cos().calcComplex(values, self.calculatorMode)
        XCTAssertEqual(result, complex(2.032723, -3.051897))
        XCTAssertEqual(result.stringValue(precision: 6, angleUnit: calculatorMode.angle),
                       "2.032723 - 3.051898i")
    }

    func testComplexCos2() {
        let values = [ComplexValue(absolute: 3, argument: Double.pi / 3)]
        let result = Cos().calcComplex(values, self.calculatorMode)

        XCTAssertEqual(result, ComplexValue(absolute: 6.68209689, argument: -1.49921))
        XCTAssertEqual(result.stringValue(precision: 6, angleUnit: .Rad),
                       "6.682097 ∠ -1.499214")
    }

    func testComplexTan() {
        let values = [complex(1, 2)]
        let result = assertNoThrow {
            try Tan().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, complex(0.033812826079897, 1.014793616146634))
        XCTAssertEqual(result?.stringValue(precision: 6, angleUnit: calculatorMode.angle),
                       "0.033813 + 1.014794i")
    }

    func testComplexTan2() {
        let values = [ComplexValue(absolute: 3, argument: Double.pi / 3)]
        let result = assertNoThrow {
            try Tan().calcComplex(values, self.calculatorMode)
        }
        // r≈1.01102525998059 (radius), θ = 1.56923 (angle)
        XCTAssertEqual(result, ComplexValue(absolute: 1.011025, argument: 1.56923))
        XCTAssertEqual(result?.stringValue(precision: 6, angleUnit: .Rad),
                       "1.011025 ∠ 1.569233")
    }

    func testComplexASin() {
        let values = [complex(1, 2)]
        let result = assertNoThrow {
            try ASin().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, complex(0.427078586, 1.528570919))
        XCTAssertEqual(result?.stringValue(precision: 6, angleUnit: calculatorMode.angle),
                       "0.427079 + 1.528571i")
    }

    func testComplexASin2() {
        let values = [ComplexValue(absolute: 1.2, argument: Double.pi / 3)]
        let result = assertNoThrow {
            try ASin().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, ComplexValue(absolute: 1.05427, argument: 1.17299))
        XCTAssertEqual(result?.stringValue(precision: 6, angleUnit: .Rad),
                       "1.054273 ∠ 1.172989")
    }

    func testComplexACos() {
        let values = [complex(1, 2)]
        let result = assertNoThrow {
            try ACos().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, complex(1.143717, -1.5285709))
        XCTAssertEqual(result?.stringValue(precision: 6, angleUnit: calculatorMode.angle),
                       "1.143718 - 1.528571i")
    }

    func testComplexACos2() {
        let values = [ComplexValue(absolute: 1.2, argument: Double.pi / 3)]
        let result = assertNoThrow {
            try ACos().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, ComplexValue(absolute: 1.51518, argument: -0.696414))
        XCTAssertEqual(result?.stringValue(precision: 6, angleUnit: .Rad),
                       "1.515187 ∠ -0.696413")
    }

    func testComplexATan() {
        let values = [complex(1, 2)]
        let result = assertNoThrow {
            try ATan().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, complex(1.33897252, 0.40235947))
        XCTAssertEqual(result?.stringValue(precision: 6, angleUnit: calculatorMode.angle),
                       "1.338973 + 0.402359i")
    }

    func testComplexATan2() {
        let values = [ComplexValue(absolute: 1.2, argument: Double.pi / 3)]
        let result = assertNoThrow {
            try ATan().calcComplex(values, self.calculatorMode)
        }
        XCTAssertEqual(result, ComplexValue(absolute: 1.14996, argument: 0.581232))
        XCTAssertEqual(result?.stringValue(precision: 6, angleUnit: .Rad),
                       "1.149959 ∠ 0.581232")
    }

    func testNeg() {
        let result = Neg().calculate([num(2.5)], calculatorMode)
        XCTAssertEqual(result.doubleValue, -2.5)
    }

    func testSin() {
        let result = Sin().calculate([num(90)], calculatorMode)
        XCTAssertEqual(result.doubleValue, 1)
    }

    func testCos() {
        let result = Cos().calculate([num(0)], calculatorMode)
        XCTAssertEqual(result.doubleValue, 1)
    }

    func testTan() {
        let result = Tan().calculate([num(45)], calculatorMode)
        XCTAssertEqual(result.doubleValue, 1, accuracy: 0.0001)
    }

    func testComplexCartesian() {
        let result = assertNoThrow {
            try Complex().convert([num(1), num(2)],
                                        self.calculatorMode)
        }
        XCTAssertEqual(result?.asComplex, complex(1, 2))
    }

    func testComplexCartesian2() {
        let result = assertNoThrow {
            try Complex().convert([num(1), num(-2)],
                                        self.calculatorMode)
        }
        XCTAssertEqual(result?.asComplex, complex(1, -2))
    }

    func testComplexPolar() {
        let result = ComplexPolar().convert([num(2), num(45)],
                                                   self.calculatorMode)
        XCTAssertEqual(result.asComplex, complex(sqrt(2), sqrt(2)))
    }

    func testComplexPolarRad() {
        let calculatorModeRad = CalculatorMode()
        calculatorModeRad.swapAngle()
        XCTAssertEqual(calculatorModeRad.angle, .Rad)
        let result = ComplexPolar().convert([num(2), num(Double.pi / 4.0)],
                                                  calculatorModeRad)
        XCTAssertEqual(result.asComplex, complex(sqrt(2), sqrt(2)))
    }

    func testComplexInv() {
        let result = Inv().calcComplex([complex(1, 1)],
                                       calculatorMode)
        XCTAssertEqual(result, complex(0.5, -0.5))
    }

    func testComplexInvPolar() {
        let result = Inv().calcComplex([ComplexValue(absolute: 1, argument: 2.25 * Double.pi)], calculatorMode)
        XCTAssertEqual(result, ComplexValue(absolute: 1, argument: -Double.pi / 4))
    }

    func testComplexInvZero() {
        let result = Inv().calcComplex([complex(0, 0)],
                                       calculatorMode)
        XCTAssertTrue(result.real.doubleValue.isNaN)
        XCTAssertTrue(result.imag.doubleValue.isNaN)
    }

    func testClampCyclical() {
        XCTAssertEqual(Utils.clampCyclical(0, -1, 1), 0)
        XCTAssertEqual(Utils.clampCyclical(0.5, -1, 1), 0.5)
        XCTAssertEqual(Utils.clampCyclical(-0.5, -1, 1), -0.5)
        XCTAssertEqual(Utils.clampCyclical(-1, -1, 1), 1)
        XCTAssertEqual(Utils.clampCyclical(1, -1, 1), 1)
        XCTAssertEqual(Utils.clampCyclical(-1.5, -1, 1), 0.5)
        XCTAssertEqual(Utils.clampCyclical(1.5, -1, 1), -0.5)

        XCTAssertEqual(Utils.clampCyclical(0.5, 0, 1), 0.5)
        XCTAssertEqual(Utils.clampCyclical(-0.2, 0, 1), 0.8,
                       accuracy: NumericalValue.epsilon)

        XCTAssertEqual(Utils.clampComplexArg(-3 * Double.pi / 2.0),
                       Double.pi / 2.0,
                       accuracy: NumericalValue.epsilond)
        XCTAssertEqual(Utils.clampComplexArg(3 * Double.pi / 2.0),
                       -Double.pi / 2.0,
                       accuracy: NumericalValue.epsilond)
    }

    func testToPolar() {
        let result = assertNoThrow {
            try ToPolar().calcComplex([complex(3, 3)], calculatorMode)
        }
        XCTAssertEqual(result?.stringValue(precision: 5), "4.24264 ∠ 45°")
    }

    func testToPolarRad() {
        let calculatorModeRad = CalculatorMode()
        calculatorModeRad.swapAngle()
        XCTAssertEqual(calculatorModeRad.angle, .Rad)

        let result = assertNoThrow {
            try ToPolar().calcComplex([complex(3, 3)], calculatorModeRad)
        }
        XCTAssertEqual(result?.stringValue(precision: 5,
                                           angleUnit: calculatorModeRad.angle),
                       "4.24264 ∠ 0.7854")
    }

    func testToCartesian() {
        let result = assertNoThrow {
            try ToCartesian().calcComplex([ComplexValue(absolute: sqrt(18),
                                                        argument: Double.pi/4.0)],
                                          calculatorMode)
        }
        XCTAssertEqual(result?.stringValue(precision: 5), "3 + 3i")
    }

    // TODO, add more of this.
}

func num(_ value: Double) -> NumericalValue {
    NumericalValue(value)
}

func complex(_ re: Double, _ im: Double) -> ComplexValue {
    ComplexValue(re, im)
}

func complexPolar(_ absolute: Double, _ argumentDegrees: Double) -> ComplexValue {
    return ComplexValue(absolute: absolute,
                        argument: Utils.deg2Rad([NumericalValue(argumentDegrees)],
                                                CalculatorMode())[0])
}

func assertNoThrow<T>(f: () throws -> T) -> T? {
    do {
        return try f()
    } catch {
        XCTFail("Caught exception \(error)")
    }
    return nil
}
