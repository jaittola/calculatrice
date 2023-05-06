import XCTest
@testable import calculatrice

class TestMathOps: XCTestCase {
    let calculatorMode = CalculatorMode()
    let twothree = [num(3), num(2)]

    func testPlus() {
        XCTAssertNoThrow {
            let values = [complex(1.0, 2.0), complex(5, 6)]
            let result = try Plus().calcComplex(values, self.calculatorMode)
            XCTAssertEqual(result, complex(6, 8))
        }
    }

    func testPlus2() throws {
        XCTAssertNoThrow {
            let values = [complex(1, 0), complex(2, 0)]
            let result = try Plus().calcComplex(values, self.calculatorMode)
            XCTAssertEqual(result, complex(3, 0))
        }
    }

    func testMinus1() throws {
        XCTAssertNoThrow {
            let values = [complex(4, 1), complex(1, 3)]
            let result = try Minus().calcComplex(values, self.calculatorMode)
            XCTAssertEqual(result, complex(3, -2))
        }
    }

    func testMinus2() {
        XCTAssertNoThrow {
            let values = [complex(4, 0), complex(1, 0)]
            let result = try Minus().calcComplex(values, self.calculatorMode)
            XCTAssertEqual(result, complex(3, 0))
        }
    }

    func testMult() {
        let result = Mult().calculate(twothree, calculatorMode)
        XCTAssertEqual(result.doubleValue, 6)
    }

    func testDiv() {
        let result = try? Div().calculate(twothree, calculatorMode)
        XCTAssertEqual(result?.doubleValue, 1.5)
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

    func testComplex() throws {
        do {
            let result = try Complex().calcToComplex([num(1), num(2)], calculatorMode)
            XCTAssertEqual(result, complex(1, 2))
        } catch {
            throw error
        }
    }

    // TODO, add more of this.
}

func num(_ value: Double) -> DoublePrecisionValue {
    DoublePrecisionValue(value)
}

func complex(_ re: Double, _ im: Double) -> ComplexValue {
    ComplexValue(re, im)
}
