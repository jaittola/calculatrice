import XCTest
@testable import calculatrice

class TestStack: XCTestCase {
    func testStackHistory() {
        let s = threeValueStack()

        XCTAssertEqual(s.testValues.stackHistory.count, 4)
        XCTAssertEqual(stackToDoubles(s.testValues.stackHistory[0]), [])
        XCTAssertEqual(stackToDoubles(s.testValues.stackHistory[1]), [3])
        XCTAssertEqual(stackToDoubles(s.testValues.stackHistory[2]), [2, 3])
        XCTAssertEqual(stackToDoubles(s.testValues.stackHistory[3]), [5, 2, 3])
    }

    func testEmptyStackUndo() {
        let s = Stack()

        s.undo()

        XCTAssertEqual(s.testValues.stackHistoryPointer, 0)
        XCTAssertEqual(s.testValues.stackHistory.count, 1)
        XCTAssertTrue(s.content.isEmpty)
    }

    func testUndo() {
        let s = threeValueStack()

        s.undo()

        XCTAssertEqual(s.testValues.stackHistory.count, 4)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 2)
        XCTAssertEqual(stackToDoubles(s.content), [2, 3])
    }

    func testUndo2() {
        let s = threeValueStack()

        s.undo()
        s.undo()

        XCTAssertEqual(s.testValues.stackHistory.count, 4)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 1)
        XCTAssertEqual(stackToDoubles(s.content), [3])
    }

    func testUndoBeyondEmpty() {
        let s = threeValueStack()

        s.undo()
        s.undo()
        s.undo()
        s.undo()
        s.undo()

        XCTAssertEqual(s.testValues.stackHistory.count, 4)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 0)
        XCTAssertEqual(s.content.count, 0)
        XCTAssertEqual(stackToDoubles(s.content), [])
    }

    func testUndoRedo() {
        let s = threeValueStack()

        s.undo()
        s.redo()

        XCTAssertEqual(s.testValues.stackHistory.count, 4)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 3)
        XCTAssertEqual(stackToDoubles(s.content), [5, 2, 3])
    }

    func testUndo2Redo() {
        let s = threeValueStack()

        s.undo()
        s.undo()
        s.redo()

        XCTAssertEqual(s.testValues.stackHistory.count, 4)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 2)
        XCTAssertEqual(stackToDoubles(s.content), [2, 3])
    }

    func testEmptyStackRedo() {
        let s = Stack()
        s.redo()

        XCTAssertEqual(s.testValues.stackHistoryPointer, 0)
        XCTAssertEqual(s.testValues.stackHistory, [[]])
    }

    func testRedoBeyondLastItem() {
        let s = threeValueStack()

        s.undo()
        s.redo()
        s.redo()

        XCTAssertEqual(s.testValues.stackHistory.count, 4)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 3)
        XCTAssertEqual(stackToDoubles(s.content), [5, 2, 3])
    }

    func testPushInputIfEmptyInput() {
        let s = threeValueStack()

        s.pushInput()
        XCTAssertEqual(stackToDoubles(s.content), [5, 5, 2, 3])
        XCTAssertEqual(stackToIds(s.content), [3, 2, 1, 0])
    }

    func testPushInputIfEmptyInputAndEmptyStack() {
        let s = Stack()

        s.pushInput()
        XCTAssertEqual(s.testValues.stackHistory, [[]])
        XCTAssertEqual(stackToDoubles(s.content), [])
    }

    func testPushInputWithInput() {
        let s = Stack()
        s.input.addNum(3)
        s.pushInput()

        XCTAssertEqual(s.testValues.stackHistory.count, 2)
        XCTAssertEqual(stackToDoubles(s.testValues.stackHistory[1]), [3])
        XCTAssertEqual(stackToDoubles(s.content), [3])
    }

    func testCalcIds() {
        let s = threeValueStack()

        assertNoThrow {
            try s.calculate( Plus(), CalculatorMode())
        }

        s.input.addNum(9)
        s.pushInput()

        XCTAssertEqual(stackToIds(s.content),
                       [4, 3, 0])
        XCTAssertEqual(stackToDoubles(s.content),
                       [9, 7, 3])
    }

    func testStackCalcHistory() {
        let s = threeValueStack()

        assertNoThrow {
            try s.calculate(Plus(), CalculatorMode())
        }

        XCTAssertEqual(stackToDoubles(s.content), [7, 3])
        XCTAssertEqual(s.testValues.stackHistory.count, 5)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 4)
    }

    func testStackCalcAndUndoHistory() {
        let s = threeValueStack()
        assertNoThrow {
            try s.calculate(Plus(), CalculatorMode())
        }

        s.undo()

        XCTAssertEqual(stackToDoubles(s.content), [5, 2, 3])
        XCTAssertEqual(s.testValues.stackHistory.count, 5)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 3)
    }

    func testStackCalcWithThrowingCalculation() {
        let s = Stack()
        s.push(v(3))
        s.push(Value(ComplexValue(2, 3)))

        XCTAssertEqual(s.testValues.stackHistory.count, 3)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 2)

        do {
            try s.calculate(ImaginaryNumber(), CalculatorMode())
            XCTFail("Calculation did not throw an exception even though it should have")
        } catch {
            if case CalcError.unsupportedValueType = error {} else {
                XCTFail("The calculation threw unexpected exception \(error)")
            }
        }

        XCTAssertEqual(s.testValues.stackHistory.count, 3)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 2)
        let expectedValues = [ContainedValue.complex(value: ComplexValue(2, 3)),
                              ContainedValue.number(value: DoublePrecisionValue(3))]
        XCTAssertEqual(expectedValues,
                       s.content.map { v in v.containedValue })
    }

    func testInputAfterUndo() {
        let s = threeValueStack()

        XCTAssertEqual(s.testValues.stackHistory.count, 4)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 3)

        s.undo()
        s.undo()
        s.redo()

        XCTAssertEqual(s.testValues.stackHistory.count, 4)
        XCTAssertEqual(s.testValues.stackHistory.map { stack in stackToDoubles(stack) },
                       [[], [3], [2, 3], [5, 2, 3]])
        XCTAssertEqual(s.testValues.stackHistoryPointer, 2)

        s.input.addNum(9)
        s.pushInput()

        XCTAssertEqual(s.testValues.stackHistory.count, 4)
        XCTAssertEqual(s.testValues.stackHistory.map { stack in stackToDoubles(stack) },
                       [[], [3], [2, 3], [9, 2, 3]])
        XCTAssertEqual(s.testValues.stackHistoryPointer, 3)

        XCTAssertEqual(stackToIds(s.content),
                       [3, 1, 0])
        XCTAssertEqual(stackToDoubles(s.content),
                       [9, 2, 3])
    }

    func testMoreThan100StackHistory() {
        let s = Stack()
        for n in 0...105 {
            s.input.addNum(n + 1)
            s.pushInput()
        }

        XCTAssertEqual(s.testValues.stackHistory.count, 100)
        let s2 = stackToDoubles(s.content)
        XCTAssertEqual(s2.count, 106)
        XCTAssertEqual(s2[0], 106)
    }

    func testSwap2() {
        let s = threeValueStack()

        s.swapTop2()

        XCTAssertEqual(s.testValues.stackHistory.count, 5)
        XCTAssertEqual(s.testValues.stackHistory.map { stack in stackToDoubles(stack) },
                       [[], [3], [2, 3], [5, 2, 3], [2, 5, 3]])

        s.swapTop2()

        XCTAssertEqual(s.testValues.stackHistory.count, 6)
        XCTAssertEqual(s.testValues.stackHistory.map { stack in stackToDoubles(stack) },
                       [[], [3], [2, 3], [5, 2, 3], [2, 5, 3], [5, 2, 3]])
    }

    private func threeValueStack() -> Stack {
        let s = Stack()

        XCTAssertEqual(s.testValues.stackHistory.count, 1)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 0)

        s.push(v(3))
        s.push(v(2))
        s.push(v(5))

        XCTAssertEqual(stackToIds(s.content),
                       [2, 1, 0])
        XCTAssertEqual(stackToDoubles(s.content),
                       [5, 2, 3])

        XCTAssertEqual(s.testValues.stackHistory.count, 4)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 3)

        return s
    }

    private func v(_ value: Double) -> Value {
        Value(DoublePrecisionValue(value))
    }

    private func stackToDoubles(_ values: [Value]) -> [Double?] {
        values.map { v in v.asReal?.doubleValue }
    }

    private func stackToIds(_ values: [Value]) -> [Int] {
        values.map { v in v.id }
    }

    private func stackToDoubleIdTuples(_ values: [Value]) -> [(doubleValue: Double?, id: Int)] {
        values.map { v in (doubleValue: v.asReal?.doubleValue,
                           id: v.id) }
    }
}
