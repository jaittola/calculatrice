import Foundation
import XCTest

@testable import calculatrice

class TestNumericalValuesMatrix: XCTestCase {

    let emptyMatrix = try! MatrixValue([])

    let input1 = [[num(1), num(0), num(0)], [num(0), num(1), num(0)], [num(0), num(0), num(1)]]
    let input2: [[MatrixElement]] = [
        [
            ComplexValue(
                realValue: rat(1, 4),
                imagValue: rat(7, 11)),
            rat(7, 9),
        ],
        [num(2), rat(5, 4)],
    ]
    let inputVec: [[MatrixElement]] = [[num(1)], [num(2)], [num(3)]]

    func testEmptyMatrixStringFormat() {
        XCTAssertEqual(emptyMatrix.stringValue(), "[]")
    }

    func testBasicMatrixStringFormat() {
        let matrix1 = assertNoThrow { try MatrixValue(input1) }
        XCTAssertEqual(matrix1?.stringValue(), "[1  0  0\n0  1  0\n0  0  1]")

    }

    func testComplicatedMatrixStringFormat() {
        let matrix2 = assertNoThrow { try MatrixValue(input2) }
        XCTAssertEqual(matrix2?.stringValue(), "[1/4 + 7/11i  7/9\n2  1 1/4]")
    }

    func testVectorFormat() {
        let vector = assertNoThrow { try MatrixValue(inputVec) }
        XCTAssertEqual(vector?.stringValue(), "[1\n2\n3]")
    }

    func testInitWithBadDimensions() {
        let badMatrixInput = [
            [num(1), num(0), num(0)], [num(0), num(1)], [num(0), num(0), num(1)],
        ]
        XCTAssertThrowsError(try MatrixValue(badMatrixInput))
    }

    func testMatrixDimensions() {
        let matrix = assertNoThrow { try MatrixValue(input1) }
        XCTAssertEqual(matrix?.rows, 3)
        XCTAssertEqual(matrix?.cols, 3)

        let vector = assertNoThrow { try MatrixValue(inputVec) }
        XCTAssertEqual(vector?.rows, 3)
        XCTAssertEqual(vector?.cols, 1)

        XCTAssertEqual(emptyMatrix.rows, 0)
        XCTAssertEqual(emptyMatrix.cols, 0)
    }
}
