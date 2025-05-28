import XCTest
@testable import calculatrice

class TestCopyPaste: XCTestCase {
    func testCopyWithInputBufferContent() {
        let s = Stack()
        let ic = InputController()

        s.push(v(3))
        ic.activeInputBuffer.addNum(2)
        ic.activeInputBuffer.addNum(4)

        XCTAssertEqual(CopyPaste.handleCopy(ic, s, ValueMode(), inputOnly: false), "24")
    }

    func testCopyInputBufferOnly() {
        let s = Stack()
        let ic = InputController()

        s.push(v(3))
        ic.activeInputBuffer.addNum(2)
        ic.activeInputBuffer.addNum(4)

        XCTAssertEqual(CopyPaste.handleCopy(ic, s, ValueMode(), inputOnly: true), "24")
    }

    func testCopyInputBufferOnlyWhenInputEmpty() {
        let s = Stack()
        let ic = InputController()

        s.push(v(4))

        XCTAssertNil(CopyPaste.handleCopy(ic, s, ValueMode(), inputOnly: true))
    }

    func testCopySelectedValue() {
        let s = nonEmptyStack()
        let ic = InputController()

        ic.activeInputBuffer.addNum(1)
        ic.activeInputBuffer.addNum(2)

        s.selectedId = 0

        XCTAssertEqual(CopyPaste.handleCopy(ic, s, ValueMode(), inputOnly: false), "3")
    }

    func testPasteNumber() {
        let s = nonEmptyStack()
        let ic = InputController()

        XCTAssertTrue(CopyPaste.handlePaste("16", s, ic))
        XCTAssertEqual(s.content.count, 3)
        XCTAssertEqual(s.content.map { $0.asNumericalValue?.floatingPoint}, stackValues)
        XCTAssertEqual(ic.value.asNumericalValue?.floatingPoint, 16)
        XCTAssertEqual(ic.stringValue, "16")
    }

    func testPasteMatrix() {
        let s = nonEmptyStack()
        let ic = InputController()

        let matrixString = "[1  2\n3  2.4E-2]"
        let matrix = try! MatrixValue([[num(1), num(2)], [num(3), num(0.024)]])

        XCTAssertTrue(CopyPaste.handlePaste(matrixString, s, ic))
        XCTAssertEqual(s.content.count, 4)
        XCTAssertEqual(s.content[0].asMatrix, matrix)
    }

    private let stackValues: [Double] = [5, 2, 3]

    private func nonEmptyStack() -> Stack {
        let s = Stack()

        XCTAssertEqual(s.testValues.stackHistory.count, 1)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 0)

        stackValues.reversed().forEach {
            s.push(v($0))
        }

        XCTAssertEqual(s.content.count, stackValues.count)
        XCTAssertEqual(s.testValues.stackHistory.count, stackValues.count + 1)

        return s
    }

    private func v(_ value: Double) -> Value {
        Value(NumericalValue(value))
    }
}
