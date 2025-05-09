import Foundation
import XCTest

@testable import calculatrice

class TestMathOpsMatrix: XCTestCase {
    func testMatrixPlus() {
        let m1 = try! MatrixValue([[num(1), num(2)], [num(3), num(4)]])
        let m2 = try! MatrixValue([[num(5), num(6)], [num(7), num(8)]])
        let expectedResult = try! MatrixValue([[num(6), num(8)], [num(10), num(12)]])

        let r = assertNoThrow { try Plus().calcMatrix([m1, m2], CalculatorMode()) }
        XCTAssertEqual(r?.asMatrix, expectedResult)
    }

    func testMatrixPlus2() {
        let m1 = try! MatrixValue([
            [
                ComplexValue(
                    realValue: rat(1, 2),
                    imagValue: num(2)),
                num(2),
            ],
            [num(3), rat(1, 3)],
        ])
        let m2 = try! MatrixValue([[num(5), num(6)], [num(7), num(1)]])

        let expectedResult = try! MatrixValue([
            [
                ComplexValue(
                    realValue: rat(11, 2),
                    imagValue: num(2)),
                num(8),
            ],
            [num(10), rat(4, 3)],
        ])

        let r = assertNoThrow { try Plus().calcMatrix([m1, m2], CalculatorMode()) }
        XCTAssertEqual(r?.asMatrix, expectedResult)
        XCTAssertEqual(r?.stringValue(CalculatorMode()), "[5 1/2 + 2i  8\n10  1 1/3]")
    }

    func testMatrixPlusCalculationTypes() {
        verifyCalcMatrixAndNumNotAllowed(Plus())
        verifyMatrixCalcSameDimensionsRequired(Plus())
    }

    func testMatrixMinus() {
        let m1 = try! MatrixValue([
            [
                ComplexValue(
                    realValue: rat(1, 2),
                    imagValue: num(2)),
                num(2),
            ],
            [num(5), rat(1, 3)],
        ])
        let m2 = try! MatrixValue([[num(3), num(6)], [num(3), num(1)]])

        let expectedResult = try! MatrixValue([
            [
                ComplexValue(
                    realValue: rat(-5, 2),
                    imagValue: num(2)),
                num(-4),
            ],
            [num(2), rat(-2, 3)],
        ])

        let r = assertNoThrow { try Minus().calcMatrix([m1, m2], CalculatorMode()) }
        XCTAssertEqual(r?.asMatrix, expectedResult)
        XCTAssertEqual(r?.stringValue(CalculatorMode()), "[-2 1/2 + 2i  -4\n2  -2/3]")
    }

    func testMatrixMinusCalculationTypes() {
        verifyCalcMatrixAndNumNotAllowed(Minus())
        verifyMatrixCalcSameDimensionsRequired(Minus())
    }

    func testNumTimesMatrix() {
        let m1 = try! MatrixValue([
            [num(1), num(2)],
            [num(3), num(4)],
        ])
        let scalar = ComplexValue(realValue: rat(1, 2), imagValue: rat(2, 3))

        let expectedResult = try! MatrixValue([
            [
                scalar,
                ComplexValue(realValue: num(1), imagValue: rat(4, 3)),
            ],
            [
                ComplexValue(realValue: rat(3, 2), imagValue: num(2)),
                ComplexValue(realValue: num(2), imagValue: rat(8, 3)),
            ],
        ])

        let r = assertNoThrow { try Mult().calcMatrix([m1, scalar], CalculatorMode()) }
        XCTAssertEqual(r?.asMatrix, expectedResult)

        let r2 = assertNoThrow { try Mult().calcMatrix([scalar, m1], CalculatorMode()) }
        XCTAssertEqual(r?.asMatrix, r2?.asMatrix)
    }

    func testMatrixMult() {
        let m1 = try! MatrixValue([
            [num(1), num(2)],
            [num(3), num(4)],
        ])
        let m2 = try! MatrixValue([
            [num(5), num(6)],
            [num(7), num(8)],
        ])

        let expectedResult = try! MatrixValue([
            [num(19), num(22)],
            [num(43), num(50)],
        ])

        let r = assertNoThrow { try Mult().calcMatrix([m1, m2], CalculatorMode()) }
        XCTAssertEqual(r?.asMatrix, expectedResult)
    }

    func testMatrixMult2() {
        let m1 = try! MatrixValue([
            [num(1), num(2), num(3)],
            [num(4), num(5), num(6)],
        ])
        let m2 = try! MatrixValue([
            [num(5), num(6)],
            [num(7), num(8)],
            [num(9), num(10)],
        ])

        let expectedResult = try! MatrixValue([
            [num(46), num(52)],
            [num(109), num(124)],
        ])

        let r = assertNoThrow { try Mult().calcMatrix([m1, m2], CalculatorMode()) }
        XCTAssertEqual(r?.asMatrix, expectedResult)
    }

    func testMatrixVectorMult() {
        let m1 = try! MatrixValue([
            [num(1), num(2)],
            [num(3), num(4)],
        ])
        let m2 = try! MatrixValue([
            [num(5)],
            [num(6)],
        ])

        let expectedResult = try! MatrixValue([
            [num(17)],
            [num(39)],
        ])

        let r = assertNoThrow { try Mult().calcMatrix([m1, m2], CalculatorMode()) }
        XCTAssertEqual(r?.asMatrix, expectedResult)
    }

    func testMatrixMultBadDimensions() {
        let m1 = try! MatrixValue([
            [num(1), num(2), rat(2, 3)],
            [num(3), num(4), num(5)],
        ])
        let m2 = try! MatrixValue([
            [num(5), num(6), num(7)],
            [num(7), num(8), num(9)],
        ])

        XCTAssertThrowsError(try Mult().calcMatrix([m1, m2], CalculatorMode()))
    }

    func testMatrixNegative() {
        let m1 = try! MatrixValue([
            [num(1), num(2)],
            [num(3), num(4)],
        ])

        let expectedResult = try! MatrixValue([
            [num(-1), num(-2)],
            [num(-3), num(-4)],
        ])

        let r = assertNoThrow { try Neg().calcMatrix([m1], CalculatorMode()) }
        XCTAssertEqual(r?.asMatrix, expectedResult)
    }

    func testMatrixTranspose() {
        let m1 = try! MatrixValue([
            [num(1), num(2), num(3)],
            [num(4), num(5), num(6)],
        ])

        let expectedResult = try! MatrixValue([
            [num(1), num(4)],
            [num(2), num(5)],
            [num(3), num(6)],
        ])

        let r = assertNoThrow { try Transpose().calcMatrix([m1], CalculatorMode()) }
        XCTAssertEqual(r?.asMatrix, expectedResult)
    }

    func testVectorTranspose() {
        let v1 = try! MatrixValue([[num(1), num(2)]])
        let transposed = try! MatrixValue([[num(1)], [num(2)]])

        let transpose = Transpose()

        let r = assertNoThrow { try transpose.calcMatrix([v1], CalculatorMode()) }
        let r2 =
            if let resultVector = r?.asMatrix {
                assertNoThrow { try transpose.calcMatrix([resultVector], CalculatorMode()) }
            } else { nil as ContainedValue? }

        XCTAssertEqual(r?.asMatrix, transposed)
        XCTAssertEqual(r2?.asMatrix, v1)
    }

    func testMatrixTransposeEmpty() {
        let m = try! MatrixValue([])
        let r = assertNoThrow { try Transpose().calcMatrix([m], CalculatorMode()) }
        XCTAssertEqual(r?.asMatrix, try! MatrixValue([]))
    }

    func testMatrixDeterminant() {
        let m = try! MatrixValue([
            [num(1), num(2)],
            [num(3), num(4)],
        ])

        let r = assertNoThrow { try Determinant().calcMatrix([m], CalculatorMode()) }
        if case .number(let value)? = r {
            XCTAssertEqual(value, num(-2))
        } else {
            XCTFail("Result \(String(describing: r)) should be a single-dimension number")
        }
    }

    func testComplexMatrixDeterminant() {
        let m = try! MatrixValue([
            [
                ComplexValue(realValue: num(1), imagValue: num(2)),
                ComplexValue(realValue: num(3), imagValue: num(4)),
                NumericalValue(3),
            ],
            [
                ComplexValue(realValue: num(5), imagValue: num(6)),
                ComplexValue(realValue: num(7), imagValue: num(8)),
                ComplexValue(realValue: num(1), imagValue: num(-1)),
            ],
            [
                num(1), num(2), num(2),
            ],
        ])

        let r = assertNoThrow { try Determinant().calcMatrix([m], CalculatorMode()) }
        XCTAssertEqual(r?.asComplex, complex(10, -21))
    }

    func testMatrixDeterminantOneElementAndEmpty() {
        let emptyMatrix = try! MatrixValue([])
        let oneElementMatrix = try! MatrixValue([[complex(1, 2)]])
        let oneElementRealMatrix = try! MatrixValue([[num(2)]])

        let emptyDeterminant = assertNoThrow {
            try Determinant().calcMatrix([emptyMatrix], CalculatorMode())
        }
        XCTAssertEqual(emptyDeterminant?.asNumericalValue, num(0))

        let oneElementDeterminant = assertNoThrow {
            try Determinant().calcMatrix([oneElementMatrix], CalculatorMode())
        }
        XCTAssertEqual(oneElementDeterminant?.asComplex, complex(1, 2))

        let oneElementRealDeterminant = assertNoThrow {
            try Determinant().calcMatrix([oneElementRealMatrix], CalculatorMode())
        }

        if case .number(let value)? = oneElementRealDeterminant {
            XCTAssertEqual(value, num(2))
        } else {
            XCTFail(
                "Result \(String(describing: oneElementDeterminant)) should be a single-dimension number"
            )
        }
    }

    func testMatrixDeterminantBadDimensions() {
        let m = try! MatrixValue([[num(1), num(2)], [num(3), num(4)], [num(5), num(6)]])

        XCTAssertThrowsError(try Determinant().calcMatrix([m], CalculatorMode()))
    }

    func testDotProduct() {
        let m1 = try! MatrixValue([[num(1), num(2), num(3)]])
        let m2 = try! MatrixValue([[num(4), num(5), num(6)]])

        let r = assertNoThrow { try DotProduct().calcMatrix([m1, m2], CalculatorMode()) }
        if case .number(let value)? = r {
            XCTAssertEqual(value, num(32))
        } else {
            XCTFail("Expected single-dimensional numerical value, got \(String(describing: r))")
        }
    }

    func testDotProductComplex() {
        let m1 = try! MatrixValue([[complex(1, 2)], [num(2)], [num(3)]])
        let m2 = try! MatrixValue([[num(4)], [complex(4, 5)], [num(6)]])

        let r = assertNoThrow { try DotProduct().calcMatrix([m1, m2], CalculatorMode()) }
        XCTAssertEqual(r?.asComplex, ComplexValue(30, 18))
    }

    func testDotProductEmpty() {
        let m1 = try! MatrixValue([])
        let m2 = try! MatrixValue([])

        XCTAssertThrowsError(try DotProduct().calcMatrix([m1, m2], CalculatorMode()))
    }

    func testDotProductBadDimensions() {
        let m1 = try! MatrixValue([[num(1)], [num(2)], [num(3)]])
        let m2 = try! MatrixValue([[num(4)], [num(5)]])

        XCTAssertThrowsError(try DotProduct().calcMatrix([m1, m2], CalculatorMode()))
    }

    func testDotProductNotVector() {
        let m1 = try! MatrixValue([[num(1), num(2)], [num(3), num(4)]])
        let m2 = try! MatrixValue([[num(4)], [num(5)]])

        XCTAssertThrowsError(try DotProduct().calcMatrix([m1, m2], CalculatorMode()))
    }

    func testMatrixInverse() {
        let m = try! MatrixValue([
            [num(1), num(2), num(3)],
            [num(1), num(0), num(1)],
            [num(2), rat(1, 2), num(3)],
        ])

        let expectedResult = try! MatrixValue([
            [rat(1, 2), rat(9, 2), num(-2)],
            [num(1), num(3), num(-2)],
            [rat(-1, 2), rat(-7, 2), num(2)],
        ])

        let r = assertNoThrow { try Inv().calcMatrix([m], CalculatorMode()) }
        XCTAssertEqual(r?.asMatrix, expectedResult)
    }

    func testMatrixInverseComplex() {
        let m = try! MatrixValue([
            [ComplexValue(0, 1), num(1), num(1)],
            [num(1), num(0), num(1)],
            [num(2), num(1), num(1)],
        ])
        let expectedResult = try! MatrixValue([
            [ComplexValue(-0.4, -0.2), num(0), ComplexValue(0.4, 0.2)],
            [ComplexValue(0.4, 0.2), num(-1), ComplexValue(0.6, -0.2)],
            [ComplexValue(0.4, 0.2), num(1), ComplexValue(-0.4, -0.2)],
        ])

        let r = assertNoThrow { try Inv().calcMatrix([m], CalculatorMode()) }
        XCTAssertEqual(r?.asMatrix, expectedResult)
    }

    func testMatrixInverseComplexRational() {
        let m = try! MatrixValue([
            [ComplexValue(realValue: rat(1, 2), imagValue: num(1)), rat(1, 2), num(1)],
            [complex(1, 2), num(0), num(1)],
            [complex(0, 2), num(1), num(1)],
        ])
        let expectedResult = try! MatrixValue([
            [
                complex(0, 1),
                ComplexValue(realValue: num(0), imagValue: rat(-1, 2)),
                ComplexValue(realValue: num(0), imagValue: rat(-1, 2)),
            ],
            [
                complex(0, 1),
                ComplexValue(realValue: num(-1), imagValue: rat(-1, 2)),
                ComplexValue(realValue: num(1), imagValue: rat(-1, 2)),
            ],
            [
                complex(2, -1),
                ComplexValue(realValue: num(0), imagValue: rat(1, 2)),
                ComplexValue(realValue: num(-1), imagValue: rat(1, 2)),
            ],
        ])

        let r = assertNoThrow { try Inv().calcMatrix([m], CalculatorMode()) }
        XCTAssertEqual(r?.asMatrix, expectedResult)

    }

    func verifyCalcMatrixAndNumNotAllowed(_ calc: MatrixCalculation) {
        let m1 = try! MatrixValue([[num(1), num(2)], [num(3), num(4)]])
        let v2 = num(3)

        XCTAssertThrowsError(try calc.calcMatrix([m1, v2], CalculatorMode()))
    }

    func verifyMatrixCalcSameDimensionsRequired(_ calc: MatrixCalculation) {
        let m1 = try! MatrixValue([[num(1), num(2)], [num(3), num(4)]])
        let m2 = try! MatrixValue([[num(1)], [num(3)]])

        XCTAssertThrowsError(try calc.calcMatrix([m1, m2], CalculatorMode()))
    }
}
