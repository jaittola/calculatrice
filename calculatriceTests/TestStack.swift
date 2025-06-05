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
        let ic = InputController()

        s.pushInput(ic)
        XCTAssertEqual(stackToDoubles(s.content), [5, 5, 2, 3])
        XCTAssertEqual(stackToIds(s.content), [3, 2, 1, 0])
    }

    func testPushInputIfEmptyInputAndEmptyStack() {
        let s = Stack()
        let ic = InputController()

        s.pushInput(ic)
        XCTAssertEqual(s.testValues.stackHistory, [[]])
        XCTAssertEqual(stackToDoubles(s.content), [])
    }

    func testPushInputWithInput() {
        let s = Stack()
        let ic = InputController()

        ic.activeInputBuffer.addNum(3)
        s.pushInput(ic)

        XCTAssertEqual(s.testValues.stackHistory.count, 2)
        XCTAssertEqual(stackToDoubles(s.testValues.stackHistory[1]), [3])
        XCTAssertEqual(stackToDoubles(s.content), [3])
    }

    func testCalcWhenInputNotPushed() {
        let s = threeValueStack()
        let ic = InputController()

        ic.activeInputBuffer.addNum(9)
        assertNoThrow {
            try s.calculate(ic, Plus(), CalculatorMode())
        }
        XCTAssertEqual(stackToDoubles(s.content), [14, 2, 3])
        XCTAssertEqual(stackToIds(s.content), [4, 1, 0])

        XCTAssertEqual(s.testValues.stackHistory.count, 6)
        XCTAssertEqual(s.testValues.stackHistory.map { stack in stackToDoubles(stack) }, [
            [],
            [3],
            [2, 3],
            [5, 2, 3],
            [9, 5, 2, 3],
            [14, 2, 3]])

        s.undo()
        XCTAssertEqual(stackToDoubles(s.content), [9, 5, 2, 3])
    }

    func testCalcIds() {
        let s = threeValueStack()
        let ic = InputController()

        assertNoThrow {
            try s.calculate(ic, Plus(), CalculatorMode())
        }

        ic.activeInputBuffer.addNum(9)
        s.pushInput(ic)

        XCTAssertEqual(stackToIds(s.content),
                       [4, 3, 0])
        XCTAssertEqual(stackToDoubles(s.content),
                       [9, 7, 3])
    }

    func testStackCalcHistory() {
        let s = threeValueStack()
        let ic = InputController()

        assertNoThrow {
            try s.calculate(ic, Plus(), CalculatorMode())
        }

        XCTAssertEqual(stackToDoubles(s.content), [7, 3])
        XCTAssertEqual(s.testValues.stackHistory.count, 5)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 4)
    }

    func testStackCalcAndUndoHistory() {
        let s = threeValueStack()
        let ic = InputController()

        assertNoThrow {
            try s.calculate(ic, Plus(), CalculatorMode())
        }

        XCTAssertEqual(stackToDoubles(s.content), [7, 3])

        s.undo()

        XCTAssertEqual(stackToDoubles(s.content), [5, 2, 3])
        XCTAssertEqual(s.testValues.stackHistory.count, 5)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 3)
    }

    func testStackCalcWithThrowingCalculation() {
        let s = Stack()
        let ic = InputController()

        s.push(v(3))
        s.push(Value(ComplexValue(2.0, 3.0)))

        XCTAssertEqual(s.testValues.stackHistory.count, 3)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 2)

        do {
            try s.calculate(ic, ImaginaryNumber(), CalculatorMode())
            XCTFail("Calculation did not throw an exception even though it should have")
        } catch {
            if case CalcError.unsupportedValueType = error {} else {
                XCTFail("The calculation threw unexpected exception \(error)")
            }
        }

        XCTAssertEqual(s.testValues.stackHistory.count, 3)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 2)
        let expectedValues = [ContainedValue.complex(value: ComplexValue(2.0, 3.0)),
                              ContainedValue.number(value: NumericalValue(3.0))]
        XCTAssertEqual(expectedValues,
                       s.content.map { v in v.containedValue })
    }

    func testInputAfterUndo() {
        let s = threeValueStack()
        let ic = InputController()

        XCTAssertEqual(s.testValues.stackHistory.count, 4)
        XCTAssertEqual(s.testValues.stackHistoryPointer, 3)

        s.undo()
        s.undo()
        s.redo()

        XCTAssertEqual(s.testValues.stackHistory.count, 4)
        XCTAssertEqual(s.testValues.stackHistory.map { stack in stackToDoubles(stack) },
                       [[], [3], [2, 3], [5, 2, 3]])
        XCTAssertEqual(s.testValues.stackHistoryPointer, 2)

        ic.activeInputBuffer.addNum(9)
        s.pushInput(ic)

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
        let ic = InputController()

        for n in 0...105 {
            ic.activeInputBuffer.addNum(n + 1)
            s.pushInput(ic)
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

    func testCalcRational() {
        let s = Stack()
        let ic = InputController()

        assertNoThrow {
            s.push(Value(try RationalValue(1, 2)))
            s.push(Value(try RationalValue(1, 4)))

            try s.calculate(ic, Plus(), CalculatorMode())
        }

        XCTAssertEqual(s.content.count, 1)

        let result = s.content[0].asRational

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.numerator.floatingPoint, 3)
        XCTAssertEqual(result?.denominator.floatingPoint, 4)
    }

    func testCalcIntegerWithRational() {
        let s = Stack()
        let ic = InputController()

        assertNoThrow {
            s.push(Value(NumericalValue(2)))
            s.push(Value(try RationalValue(1, 3)))

            try s.calculate(ic, Minus(), CalculatorMode())
        }

        XCTAssertEqual(s.content.count, 1)

        let result = s.content[0].asRational

        XCTAssertNotNil(result)
        XCTAssertEqual(result?.numerator.floatingPoint, 5)
        XCTAssertEqual(result?.denominator.floatingPoint, 3)
    }

    func testCalcRealWithRational() {
        let s = Stack()
        let ic = InputController()

        assertNoThrow {
            s.push(Value(NumericalValue(2.21)))
            s.push(Value(try RationalValue(2, 3)))

            try s.calculate(ic, Minus(), CalculatorMode())
        }

        XCTAssertEqual(s.content.count, 1)

        let result = s.content[0]
        XCTAssertNotNil(result)
        XCTAssertNil(result.asRational)

        XCTAssertEqual(result.asNumericalValue!.floatingPoint, 1.54333333,
                       accuracy: NumericalValue.epsilon)
    }

    func testComplexWithNegativeImaginaryPartInput() {
        // This is a regression test case for a bug.

        let s = Stack()
        let ic = InputController()

        ic.activeInputBuffer.addNum(2)
        s.pushInput(ic)
        ic.activeInputBuffer.addNum(3)
        ic.activeInputBuffer.plusminus()
        s.pushInput(ic)

        assertNoThrow {
            try s.calculate(ic, Complex(), CalculatorMode())
        }

        XCTAssertEqual(s.content[0].asComplex?.stringValue(), "2 - 3i")
        XCTAssertEqual(s.content[0].asComplex?.real.floatingPoint, 2.0)
        XCTAssertEqual(s.content[0].asComplex?.imag.floatingPoint, -3.0)
    }

    func testCalcInvWithIntegerValue() {
        // Special case to make sure that preferComplexCalculationWith is used correctly
        // with Inv.
        let s = Stack()
        let ic = InputController()

        assertNoThrow {
            s.push(Value(NumericalValue(4)))
            try s.calculate(ic, Inv(), CalculatorMode())
        }

        XCTAssertEqual(s.content.count, 1)

        let result = s.content[0]
        let numResult = s.content[0].asNum

        XCTAssertNotNil(numResult)
        XCTAssertEqual(numResult?.floatingPoint, 0.25)
        XCTAssertEqual(result.stringValue(ValueMode()), "0.25")
    }

    func testCalcWithMatrixes() {
        let s = Stack()
        let ic = InputController()

        assertNoThrow {
            let m1 = try MatrixValue([[num(1), num(2)], [num(3), num(4)]])
            let m2 = try MatrixValue([[num(5), num(6)], [num(7), num(8)]])

            s.push(Value(m1))
            s.push(Value(m2))

            try s.calculate(ic, Plus(), CalculatorMode())
        }

        XCTAssertEqual(s.content.count, 1)

        let result = s.content[0]
        XCTAssertEqual(result.stringValue(ValueMode()), "[6  8\n10  12]")
    }

    func testCalcScalarMatrix() {
        let s = Stack()
        let ic = InputController()

        assertNoThrow {
            let m = try MatrixValue([[num(1), num(1)], [num(2), num(5)]])

            s.push(Value(num(2)))
            s.push(Value(m))

            try s.calculate(ic, Mult(), CalculatorMode())
        }

        XCTAssertEqual(s.content.count, 1)

        let result = s.content[0]
        XCTAssertEqual(result.stringValue(ValueMode()), "[2  2\n4  10]")
    }

    func testCopyWithInputBufferContent() {
        let s = Stack()
        let ic = InputController()

        s.push(v(3))
        ic.activeInputBuffer.addNum(2)
        ic.activeInputBuffer.addNum(4)

        XCTAssertEqual(s.copy(ic, ValueMode(), inputOnly: false), "24")
    }

    func testCopyInputBufferOnly() {
        let s = Stack()
        let ic = InputController()

        s.push(v(3))
        ic.activeInputBuffer.addNum(2)
        ic.activeInputBuffer.addNum(4)

        XCTAssertEqual(s.copy(ic, ValueMode(), inputOnly: true), "24")
    }

    func testCopyInputBufferOnlyWhenInputEmpty() {
        let s = Stack()
        let ic = InputController()

        s.push(v(4))

        XCTAssertNil(s.copy(ic, ValueMode(), inputOnly: true))
    }

    func testCopySelectedValue() {
        let s = threeValueStack()
        let ic = InputController()

        ic.activeInputBuffer.addNum(1)
        ic.activeInputBuffer.addNum(2)

        s.selectedId = 0

        XCTAssertEqual(s.copy(ic, ValueMode(), inputOnly: false), "3")
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
        Value(NumericalValue(value))
    }

    private func stackToDoubles(_ values: [Value]) -> [Double?] {
        values.map { v in v.asNumericalValue?.floatingPoint }
    }

    private func stackToIds(_ values: [Value]) -> [Int] {
        values.map { v in v.id }
    }

    private func stackToDoubleIdTuples(_ values: [Value]) -> [(doubleValue: Double?, id: Int)] {
        values.map { v in (doubleValue: v.asNumericalValue?.floatingPoint,
                           id: v.id) }
    }
}
