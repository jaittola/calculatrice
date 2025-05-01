import Foundation
import XCTest

@testable import calculatrice

class TestPasteParser: XCTestCase {
    var pasteParser = PasteParser()

    func testPasteWholeNumber() {
        let input = "2"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.asNumericalValue?.originalStringValue, input)
    }

    func testPasteNegativeWholeNumber() {
        XCTAssertEqual(pasteParser.parsePastedInput("-2")?.asNumericalValue?.originalStringValue, "-2")
    }

    func testPasteFloatingPoint() {
        let input = "123.456"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.asNumericalValue?.originalStringValue, input)
    }

    func testPasteNegativeFloatingPoint() {
        let input = "-123.456"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.asNumericalValue?.originalStringValue, input)
        XCTAssertEqual(v?.asNumericalValue?.floatingPoint, -123.456)
    }

    func testPasteFloatingPointEng() {
        let input = "123.456E2"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.asNumericalValue?.originalStringValue, input)
        XCTAssertEqual(v?.asNumericalValue?.floatingPoint, 12345.6)
    }

    func testPasteFloatingPointEng2() {
        let input = "123.456E-2"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.asNumericalValue?.originalStringValue, input)
        XCTAssertEqual(v?.asNumericalValue?.floatingPoint, 1.23456)
    }

    func testPasteComplexNumber() {
        let input = "2 + 3i"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.stringValue(CalculatorMode()), input)
    }

    func testPasteComplexNumber2() {
        let input = "123.456 + 789.012i"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.stringValue(CalculatorMode()), input)
    }

    func testPasteComplexNumberEng() {
        let input = "123.456E1 + 789.012E-2i"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.stringValue(CalculatorMode()), input)
        XCTAssertEqual(v?.asComplex.real.floatingPoint, 1234.56)
        XCTAssertEqual(v?.asComplex.imag.floatingPoint, 7.89012)
    }

    func testParseImaginaryNumber() {
        let input = "123.456i"
        let v = pasteParser.parsePastedInput(input)
        let complex = v?.asComplex
        XCTAssertNotNil(complex)
        XCTAssertEqual(complex?.real.floatingPoint, 0)
        XCTAssertEqual(complex?.imag.floatingPoint, 123.456)
        XCTAssertEqual(v?.stringValue(CalculatorMode()), input)
    }

    func testParseNegativeImaginaryNumber() {
        let input = "-123.456i"
        let v = pasteParser.parsePastedInput(input)
        let complex = v?.asComplex
        XCTAssertNotNil(complex)
        XCTAssertEqual(complex?.real.floatingPoint, 0)
        XCTAssertEqual(complex?.imag.floatingPoint, -123.456)
        XCTAssertEqual(v?.stringValue(CalculatorMode()), "-123.456i")
    }

    func testParseComplexWithUnitImag() {
        let input = "3 - i"
        let v = pasteParser.parsePastedInput(input)
        let complex = v?.asComplex
        XCTAssertNotNil(complex)
        XCTAssertEqual(complex?.real.floatingPoint, 3)
        XCTAssertEqual(complex?.imag.floatingPoint, -1)
        XCTAssertEqual(v?.stringValue(CalculatorMode()), input)
    }

    func testParseI() {
        let input = "i"
        let v = pasteParser.parsePastedInput(input)
        let complex = v?.asComplex
        XCTAssertNotNil(complex)
        XCTAssertEqual(complex?.real.floatingPoint, 0)
        XCTAssertEqual(complex?.imag.floatingPoint, 1)
        XCTAssertEqual(v?.stringValue(CalculatorMode()), input)
    }

    func testParseMinusI() {
        let input = "-i"
        let v = pasteParser.parsePastedInput(input)
        let complex = v?.asComplex
        XCTAssertNotNil(complex)
        XCTAssertEqual(complex?.real.floatingPoint, 0)
        XCTAssertEqual(complex?.imag.floatingPoint, -1)
        XCTAssertEqual(v?.stringValue(CalculatorMode()), input)
    }

    func testParseComplexNumberWithFractionals() {
        let input = "3/4 - 2/5i"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.stringValue(CalculatorMode()), input)
        XCTAssertEqual(v?.asComplex.real.asRational?.stringValue(), "3/4")
        XCTAssertEqual(v?.asComplex.imag.asRational?.stringValue(), "-2/5")
    }

    func testParseFractional() {
        let input = "3/4"
        let v = pasteParser.parsePastedInput(input)
        let rat = v?.asRational
        XCTAssertNotNil(rat)
        XCTAssertEqual(rat?.numerator.floatingPoint, 3)
        XCTAssertEqual(rat?.denominator.floatingPoint, 4)
        XCTAssertEqual(v?.stringValue(CalculatorMode()), input)
    }

    func testParseMixedFractional() {
        let input = "1 3/4"
        let v = pasteParser.parsePastedInput(input)
        let rat = v?.asRational
        XCTAssertNotNil(rat)
        XCTAssertEqual(rat?.numerator.floatingPoint, 7)
        XCTAssertEqual(rat?.denominator.floatingPoint, 4)
        XCTAssertEqual(v?.stringValue(CalculatorMode()), input)
    }

    func testParseMixedFractionalNegative() {
        let input = "-1 3/4"
        let v = pasteParser.parsePastedInput(input)
        let rat = v?.asRational
        XCTAssertNotNil(rat)
        XCTAssertEqual(rat?.numerator.floatingPoint, -7)
        XCTAssertEqual(rat?.denominator.floatingPoint, 4)
        XCTAssertEqual(v?.stringValue(CalculatorMode()), "-1 3/4")
    }

    func testPasteGarbage() {
        XCTAssertNil(pasteParser.parsePastedInput("asdf123.456"))
        XCTAssertNil(pasteParser.parsePastedInput("123.456asdf"))
        XCTAssertNil(pasteParser.parsePastedInput("123.456iasdf"))
        XCTAssertNil(pasteParser.parsePastedInput("123.456 + 999.2iasdf"))
        XCTAssertNil(pasteParser.parsePastedInput("invalid input"))
    }
}
