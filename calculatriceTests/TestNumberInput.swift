import XCTest

@testable import calculatrice

class TestNumberInput: XCTestCase {
    func testPositiveFloatingInput() {
        let ib = InputBuffer()
        ib.addNum(1)
        ib.addNum(2)
        ib.dot()
        for _ in 0..<9 {
            ib.addNum(0)
        }
        ib.addNum(2)

        let v = ib.value.asNumericalValue!
        XCTAssertEqual(v.floatingPoint, 12.0000000002)
        XCTAssertEqual(v.stringValue(), "12.0000000002")
    }

    func testPositiveEngValue() {
        let ib = InputBuffer()
        ib.addNum(1)
        ib.dot()
        ib.addNum(9)
        ib.addNum(9)
        ib.E()
        ib.addNum(1)
        ib.plusminus()

        let v = ib.value.asNumericalValue!
        XCTAssertEqual(v.floatingPoint, 0.199)
        XCTAssertEqual(v.stringValue(), "1.99E-1")
    }

    func testSmallEngValue() {
        let ib = InputBuffer()
        ib.addNum(1)
        ib.dot()
        ib.addNum(2)
        ib.addNum(5)
        ib.E()
        ib.addNum(9)
        ib.plusminus()

        let v = ib.value.asNumericalValue!
        XCTAssertEqual(v.floatingPoint, 1.25E-9)
        XCTAssertEqual(v.stringValue(), "1.25E-9")
    }

    func testNegativeEngValue() {
        let ib = InputBuffer()
        ib.addNum(2)
        ib.dot()
        ib.addNum(3)
        ib.plusminus()
        ib.E()
        ib.addNum(3)
        ib.plusminus()

        let v = ib.value.asNumericalValue!
        XCTAssertEqual(v.floatingPoint, -0.0023)
        XCTAssertEqual(v.stringValue(), "-2.3E-3")
    }

    func testBackspace() {
        let ib = InputBuffer()
        ib.addNum(1)
        ib.addNum(2)
        ib.backspace()

        XCTAssertEqual(ib.value.asNumericalValue!.floatingPoint, 1)
        XCTAssertEqual(ib.value.stringValue(ValueMode()), "1")

        ib.addNum(2)
        ib.dot()
        ib.addNum(3)
        ib.addNum(4)
        ib.backspace()

        XCTAssertEqual(ib.value.asNumericalValue!.floatingPoint, 12.3)
        XCTAssertEqual(ib.value.stringValue(ValueMode()), "12.3")
    }

    func testBackspace2() {
        let ib = InputBuffer()
        ib.addNum(1)
        ib.addNum(2)
        ib.dot()
        ib.addNum(3)
        ib.addNum(4)
        ib.E()

        XCTAssertEqual(ib.stringValue, "12.34E")
        XCTAssertEqual(ib.value.asNumericalValue!.stringValue(), "12.34")

        ib.backspace()

        XCTAssertEqual(ib.value.asNumericalValue!.floatingPoint, 12.34)
        XCTAssertEqual(ib.value.stringValue(ValueMode()), "12.34")
    }

    func testBackspaceToEmpty() {
        let ib = InputBuffer()
        ib.addNum(1)
        ib.addNum(2)
        ib.backspace()
        ib.backspace()
        XCTAssertEqual(ib.stringValue, "")
        XCTAssertEqual(ib.value.stringValue(ValueMode()), "")
        XCTAssertEqual(ib.value.asNumericalValue!.floatingPoint, 0)
    }

    func testBackspaceWithEMinusAtEnd() {
        let ib = InputBuffer()
        ib.addNum(1)
        ib.addNum(2)
        ib.dot()
        ib.addNum(3)
        ib.E()
        ib.addNum(2)
        ib.plusminus()
        ib.backspace()

        XCTAssertEqual(ib.stringValue, "12.3E-")
        XCTAssertEqual(ib.value.asNumericalValue!.floatingPoint, 12.3)
        XCTAssertEqual(ib.value.stringValue(ValueMode()), "12.3")
    }

    func testInputWithoutLeadingZero() {
        let ib = InputBuffer()
        ib.dot()
        ib.addNum(2)
        ib.addNum(3)
        XCTAssertEqual(ib.stringValue, ".23")
        XCTAssertEqual(ib.value.stringValue(ValueMode()), "0.23")
        XCTAssertEqual(ib.value.asNumericalValue!.floatingPoint, 0.23)
    }

    func testNegativeInputWithoutLeadingZero() {
        let ib = InputBuffer()
        ib.dot()
        ib.addNum(2)
        ib.addNum(3)
        ib.plusminus()
        XCTAssertEqual(ib.stringValue, "-.23")
        XCTAssertEqual(ib.value.stringValue(ValueMode()), "-0.23")
        XCTAssertEqual(ib.value.asNumericalValue!.floatingPoint, -0.23)
    }

    func testPaste() {
        verifyPaste("1.2", num(1.2), "1.2")
        verifyPaste("-1.2", num(-1.2), "-1.2")
        verifyPaste("9.12E-3", num(9.12E-3), "9.12E-3")
        verifyPaste("-2.156E-6", num(-2.156E-6), "-2.156E-6")
    }

    func verifyPaste(_ text: String, _ expectedNumericalValue: Num, _ expectedString: String) {
        let ib = InputBuffer()
        ib.paste(text)
        let v = ib.value.asNumericalValue!
        XCTAssertTrue(v.isEqual(expectedNumericalValue))
        XCTAssertEqual(v.stringValue(), expectedString)
    }
}
