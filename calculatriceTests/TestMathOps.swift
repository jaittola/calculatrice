import XCTest
@testable import calculatrice

class TestMathOps: XCTestCase {
    let calculatorMode = CalculatorMode()
    let twothree = [num(3), num(2)]

    func testPlus() {
        let values = [complex(1.0, 2.0), complex(5, 6)]
        let result = assertNoThrow {
            try Plus().calcComplex(values, self.calculatorMode).asComplex
        }
        XCTAssertEqual(result, complex(6, 8))
    }

    func testPlus2() throws {
        let values = [complex(1, 0), complex(2, 0)]
        let result = assertNoThrow {
            try Plus().calcComplex(values, self.calculatorMode).asComplex
        }
        XCTAssertEqual(result, complex(3, 0))
    }

    func testMinus1() throws {
        let values = [complex(4, 1), complex(1, 3)]
        let result = assertNoThrow {
            try Minus().calcComplex(values, self.calculatorMode).asComplex
        }
        XCTAssertEqual(result, complex(3, -2))
    }

    func testMinus2() {
        let values = [complex(4, 0), complex(1, 0)]
        let result = assertNoThrow {
            try Minus().calcComplex(values, self.calculatorMode).asComplex
        }
        XCTAssertEqual(result, complex(3, 0))
    }

    func testImaginaryNumber() {
        let values = [DoublePrecisionValue(2).asComplex]
        let result = assertNoThrow {
            try ImaginaryNumber().calcComplex(values, self.calculatorMode).asComplex
        }
        XCTAssertEqual(result, complex(0, 2))
    }

    func testImaginaryNumberNotForComplexNumbers() {
        let values = [complex(1, 2)]
        XCTAssertThrowsError(try ImaginaryNumber().calcComplex(values, self.calculatorMode))
    }

    func testComplexNeg() {
        let value = [complex(2, 4)]
        let result = Neg().calcComplex(value, self.calculatorMode).asComplex
        XCTAssertEqual(result, complex(-2, -4))
    }

    func testMult() {
        let result = Mult().calculate(twothree, calculatorMode).asReal
        XCTAssertEqual(result?.doubleValue, 6)
    }

    func testComplexMult() {
        let values = [complex(4, 1), complex(2, 2)]
        let result = Mult().calcComplex(values, self.calculatorMode).asComplex
        XCTAssertEqual(result, complex(6, 10))
    }

    func testComplexMultReal() {
        let values = [complex(4, 0), complex(2, 0)]
        let result = Mult().calcComplex(values, self.calculatorMode).asComplex
        XCTAssertEqual(result, complex(8, 0))
    }

    func testDiv() {
        let result = try? Div().calculate(twothree, calculatorMode).asReal
        XCTAssertEqual(result?.doubleValue, 1.5)
    }

    func testComplexDiv() {
        let values = [complexPolar(4, 60), complexPolar(2, 30)]
        let result = assertNoThrow {
            try Div().calcComplex(values, self.calculatorMode).asComplex.asComplex
        }
        XCTAssertEqual(result, complexPolar(2, 30))
    }

    func testComplexSquare() {
        let values = [complex(3, 2)]
        let result = Square().calcComplex(values, self.calculatorMode).asComplex
        XCTAssertEqual(result, complex(5, 12))
    }

    func testComplexSquare2() {
        let values = [ComplexValue(absolute: sqrt(2), argument: Double.pi/4)]
        let result = Square().calcComplex(values, self.calculatorMode).asComplex
        XCTAssertEqual(result, complex(0, 2))
    }

    func testComplex3rd() {
        let values = [ComplexValue(absolute: sqrt(2), argument: Double.pi/4)]
        let result = Pow3().calcComplex(values, self.calculatorMode).asComplex
        XCTAssertEqual(result, complex(-2, 2))
    }

    func testComplexPow() {
        let values = [complex(1, 2), complex(2, 1)]
        let result = Pow().calcComplex(values, self.calculatorMode).asComplex
        XCTAssertEqual(result,
                       complex(-1.64010, 0.20205))
    }

    func testComplexRoot() {
        let values = [ComplexValue(absolute: 4, argument: Double.pi/4),
                      ComplexValue(absolute: 2, argument: 0)]
        let result = NthRoot().calcComplex(values, self.calculatorMode).asComplex
        XCTAssertEqual(result, ComplexValue(absolute: 2,
                                            argument: Double.pi/8))
    }

    func testComplexSqrt() {
        let values = [ComplexValue(absolute: 4, argument: Double.pi/4)]
        let result = Sqrt().calcComplex(values, self.calculatorMode).asComplex
        XCTAssertEqual(result, ComplexValue(absolute: 2,
                                            argument: Double.pi/8))
    }

    func testComplex3rdRoot() {
        let values = [ComplexValue(absolute: 8, argument: Double.pi/3)]
        let result = Root3().calcComplex(values, self.calculatorMode).asComplex
        XCTAssertEqual(result, ComplexValue(absolute: 2,
                                            argument: Double.pi/9))
    }

    func testComplexExp() {
        let values = [complex(1, Double.pi/4)]
        let result = Exp().calcComplex(values, self.calculatorMode).asComplex
        XCTAssertEqual(result, ComplexValue(absolute: 2.71828,
                                            argument: Double.pi/4))
    }

    func testComplexExp2() {
        let values = [complex(1, 4 * Double.pi + Double.pi/4)]
        let result = Exp().calcComplex(values, self.calculatorMode).asComplex
        XCTAssertEqual(result.polarAbsolute.doubleValue, 2.71828,
                       accuracy: epsilon)
        XCTAssertEqual(result.polarArgument.doubleValue, Double.pi/4,
                       accuracy: epsilon)
    }

    func testComplexExp10() {
        let values = [complex(1, 2)]
        let result = Exp10().calcComplex(values, self.calculatorMode).asComplex
        XCTAssertEqual(result.polarAbsolute.doubleValue, 10)
        XCTAssertEqual(result.polarArgument.doubleValue, -1.6780151,
                       accuracy: epsilon)
    }

    func testComplexLog() {
        let v = complex(1, 2)
        let values = [v]
        let result = Log().calcComplex(values, self.calculatorMode).asComplex
        XCTAssertEqual(result, complex(log(v.polarAbsolute.doubleValue),
                                       v.polarArgument.doubleValue))
    }

    func testComplexLog10() {
        let v = complex(1, 2)
        let values = [v]
        let result = assertNoThrow {
            try Log10().calcComplex(values, self.calculatorMode).asComplex
        }
        XCTAssertEqual(result, complex(0.34949, 0.48083))
    }

    func testNeg() {
        let result = Neg().calculate([num(2.5)], calculatorMode).asReal
        XCTAssertEqual(result?.doubleValue, -2.5)
    }

    func testSin() {
        let result = Sin().calculate([num(90)], calculatorMode).asReal
        XCTAssertEqual(result?.doubleValue, 1)
    }

    func testCos() {
        let result = Cos().calculate([num(0)], calculatorMode).asReal
        XCTAssertEqual(result?.doubleValue, 1)
    }

    func testTan() {
        let result = Tan().calculate([num(45)], calculatorMode).asReal
        XCTAssertEqual(result!.doubleValue, 1, accuracy: 0.0001)
    }

    func testComplexCartesian() {
        let result = assertNoThrow {
            try Complex().calculate([num(1), num(2)],
                                        self.calculatorMode).asComplex
        }
        XCTAssertEqual(result, complex(1, 2))
    }

    func testComplexPolar() {
        let result = ComplexPolar().calculate([num(2), num(45)],
                                              self.calculatorMode).asComplex
        XCTAssertEqual(result, complex(sqrt(2), sqrt(2)))
    }

    func testComplexPolarRad() {
        let calculatorModeRad = CalculatorMode()
        calculatorModeRad.swapAngle()
        XCTAssertEqual(calculatorModeRad.angle, .Rad)
        let result = ComplexPolar().calculate([num(2), num(Double.pi / 4.0)],
                                              calculatorModeRad).asComplex
        XCTAssertEqual(result, complex(sqrt(2), sqrt(2)))
    }

    func testComplexInv() {
        let result = Inv().calcComplex([complex(1, 1)],
                                       calculatorMode).asComplex
        XCTAssertEqual(result, complex(0.5, -0.5))
    }

    func testComplexInvPolar() {
        let result = Inv().calcComplex([ComplexValue(absolute: 1, argument: 2.25 * Double.pi)], calculatorMode).asComplex
        XCTAssertEqual(result, ComplexValue(absolute: 1, argument: -Double.pi / 4))
    }

    func testComplexInvZero() {
        let result = Inv().calcComplex([complex(0, 0)],
                                       calculatorMode).asComplex
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
        XCTAssertEqual(Utils.clampCyclical(-0.2, 0, 1), 0.8)

        XCTAssertEqual(Utils.clampComplexArg(-3 * Double.pi / 2.0),
                       Double.pi / 2.0,
                       accuracy: epsilon)
        XCTAssertEqual(Utils.clampComplexArg(3 * Double.pi / 2.0),
                       -Double.pi / 2.0,
                       accuracy: epsilon)
    }

    func testToPolar() {
        let result = assertNoThrow {
            try ToPolar().calcComplex([complex(3, 3)], calculatorMode).asComplex
        }
        XCTAssertEqual(result?.stringValue(precision: 5), "4.2426 ∠ 45°")
    }

    func testToPolarRad() {
        let calculatorModeRad = CalculatorMode()
        calculatorModeRad.swapAngle()
        XCTAssertEqual(calculatorModeRad.angle, .Rad)

        let result = assertNoThrow {
            try ToPolar().calcComplex([complex(3, 3)], calculatorModeRad).asComplex
        }
        XCTAssertEqual(result?.stringValue(precision: 5,
                                           angleUnit: calculatorModeRad.angle),
                       "4.2426 ∠ 0.7854")
    }

    func testToCartesian() {
        let result = assertNoThrow {
            try ToCartesian().calcComplex([ComplexValue(absolute: sqrt(18),
                                                        argument: Double.pi/4.0)],
                                          calculatorMode).asComplex
        }
        XCTAssertEqual(result?.stringValue(precision: 5), "3 + 3i")
    }

    // TODO, add more of this.
}

func num(_ value: Double) -> DoublePrecisionValue {
    DoublePrecisionValue(value)
}

func complex(_ re: Double, _ im: Double) -> ComplexValue {
    ComplexValue(re, im)
}

func complexPolar(_ absolute: Double, _ argumentDegrees: Double) -> ComplexValue {
    return ComplexValue(absolute: absolute,
                        argument: Utils.deg2Rad([DoublePrecisionValue(argumentDegrees)],
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
