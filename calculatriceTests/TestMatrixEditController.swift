import Foundation
import XCTest

@testable import calculatrice

class TestMatrixEditController: XCTestCase {

    let sampleMatrix = try! MatrixValue([
        [ComplexValue(1, -3), NumericalValue(2)], [NumericalValue(3), NumericalValue(4)],
    ])

    func testDefaultMatrix() {
        let controller = MatrixEditController()
        XCTAssertEqual(
            controller.matrixValue, try! MatrixValue([[num(0), num(0)], [num(0), num(0)]]))
    }

    func testSetInputMatrix() {
        let controller = MatrixEditController()
        controller.setInputMatrix(sampleMatrix)
        XCTAssertEqual(controller.matrixValue, sampleMatrix)
    }

    func testSetInputMatrixNil() {
        let controller = MatrixEditController()
        controller.setInputMatrix(sampleMatrix)
        controller.setInputMatrix(nil)
        XCTAssertEqual(
            controller.matrixValue, try! MatrixValue([[num(0), num(0)], [num(0), num(0)]]))
    }

    func testBasicInput() {
        let controller = MatrixEditController()
        controller.inputBuffer.addNum(1)
        XCTAssertEqual(
            controller.matrixValue, try! MatrixValue([[num(1), num(0)], [num(0), num(0)]]))
        controller.inputBuffer.addNum(2)
        XCTAssertEqual(
            controller.matrixValue, try! MatrixValue([[num(12), num(0)], [num(0), num(0)]]))

        controller.selectedCell = (1, 1)
        controller.inputBuffer.addNum(3)
        XCTAssertEqual(
            controller.matrixValue, try! MatrixValue([[num(12), num(0)], [num(0), num(3)]]))
    }

    func testInputOutsideBounds() {
        let controller = MatrixEditController()
        controller.selectedCell = (3, 3)
        controller.inputBuffer.addNum(1)
        XCTAssertEqual(
            controller.matrixValue, try! MatrixValue([[num(0), num(0)], [num(0), num(0)]]))
        controller.selectedCell = (1, 1)
        controller.inputBuffer.addNum(3)
        XCTAssertEqual(
            controller.matrixValue, try! MatrixValue([[num(0), num(0)], [num(0), num(3)]]))
    }
}
