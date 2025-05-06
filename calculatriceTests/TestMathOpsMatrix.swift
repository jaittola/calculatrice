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
