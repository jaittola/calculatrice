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
        controller.inputController.activeInputBuffer.addNum(1)
        XCTAssertEqual(
            controller.matrixValue, try! MatrixValue([[num(1), num(0)], [num(0), num(0)]]))
        controller.inputController.activeInputBuffer.addNum(2)
        XCTAssertEqual(
            controller.matrixValue, try! MatrixValue([[num(12), num(0)], [num(0), num(0)]]))

        controller.selectedCell = (1, 1)
        controller.inputController.activeInputBuffer.addNum(3)
        XCTAssertEqual(
            controller.matrixValue, try! MatrixValue([[num(12), num(0)], [num(0), num(3)]]))
    }

    func testInputOutsideBounds() {
        let controller = MatrixEditController()
        controller.selectedCell = (3, 3)
        controller.inputController.activeInputBuffer.addNum(1)
        XCTAssertEqual(
            controller.matrixValue, try! MatrixValue([[num(0), num(0)], [num(0), num(0)]]))
        controller.selectedCell = (1, 1)
        controller.inputController.activeInputBuffer.addNum(3)
        XCTAssertEqual(
            controller.matrixValue, try! MatrixValue([[num(0), num(0)], [num(0), num(3)]]))
    }

    func testAddColumn() {
        let controller = MatrixEditController()
        controller.setInputMatrix(sampleMatrix)
        controller.adjustColumns(1)
        let expectedMatrix = try! MatrixValue([
            [ComplexValue(1, -3), NumericalValue(2), NumericalValue(0)],
            [NumericalValue(3), NumericalValue(4), NumericalValue(0)],
        ])
        XCTAssertEqual(
            controller.matrixValue,
            expectedMatrix)
    }

    func testRemoveColumn() {
        let controller = MatrixEditController()
        controller.setInputMatrix(sampleMatrix)
        controller.adjustColumns(-1)
        let expectedMatrix = try! MatrixValue([
            [ComplexValue(1, -3)],
            [NumericalValue(3)],
        ])
        XCTAssertEqual(
            controller.matrixValue,
            expectedMatrix)
    }

    func testRemoveColumnUntilZero() {
        let controller = MatrixEditController()
        controller.setInputMatrix(sampleMatrix)
        controller.adjustColumns(-1)
        controller.adjustColumns(-1)
        let expectedMatrix = try! MatrixValue([
            [ComplexValue(1, -3)],
            [NumericalValue(3)],
        ])
        XCTAssertEqual(
            controller.matrixValue,
            expectedMatrix)
    }

    func testRemoveSeveralColumnsAtTimeFails() {
        let controller = MatrixEditController()
        controller.setInputMatrix(sampleMatrix)
        controller.adjustColumns(-2)
        XCTAssertEqual(
            controller.matrixValue,
            sampleMatrix)
    }

    func testAddRow() {
        let controller = MatrixEditController()
        controller.setInputMatrix(sampleMatrix)
        controller.adjustRows(1)
        let expectedMatrix = try! MatrixValue([
            [ComplexValue(1, -3), NumericalValue(2)],
            [NumericalValue(3), NumericalValue(4)],
            [NumericalValue(0), NumericalValue(0)],
        ])
        XCTAssertEqual(
            controller.matrixValue,
            expectedMatrix)
    }

    func testRemoveRow() {
        let controller = MatrixEditController()
        controller.setInputMatrix(sampleMatrix)
        controller.adjustRows(-1)
        let expectedMatrix = try! MatrixValue([
            [ComplexValue(1, -3), NumericalValue(2)],
        ])
        XCTAssertEqual(
            controller.matrixValue,
            expectedMatrix)
    }

    func testRemoveRowUntilZero() {
        let controller = MatrixEditController()
        controller.setInputMatrix(sampleMatrix)
        controller.adjustRows(-1)
        controller.adjustRows(-1)
        let expectedMatrix = try! MatrixValue([
            [ComplexValue(1, -3), NumericalValue(2)],
        ])
        XCTAssertEqual(
            controller.matrixValue,
            expectedMatrix)
    }

    func testRemoveSeveralRowsFails() {
        let controller = MatrixEditController()
        controller.setInputMatrix(sampleMatrix)
        controller.adjustRows(-2)
        XCTAssertEqual(
            controller.matrixValue,
            sampleMatrix)
    }
}
