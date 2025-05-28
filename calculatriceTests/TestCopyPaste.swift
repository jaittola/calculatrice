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
        let s = threeValueStack()
        let ic = InputController()

        ic.activeInputBuffer.addNum(1)
        ic.activeInputBuffer.addNum(2)

        s.selectedId = 0

        XCTAssertEqual(CopyPaste.handleCopy(ic, s, ValueMode(), inputOnly: false), "3")
    }

    private func threeValueStack() -> Stack {
        let s = Stack()

        XCTAssertEqual(s.testValues.stackHistory.count, 1)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 0)

        s.push(v(3))
        s.push(v(2))
        s.push(v(5))

        XCTAssertEqual(s.testValues.stackHistory.count, 4)

        return s
    }

    private func v(_ value: Double) -> Value {
        Value(NumericalValue(value))
    }
}
