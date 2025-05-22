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
        XCTAssertEqual(v?.stringValue(ValueMode()), input)
    }

    func testPasteComplexNumber2() {
        let input = "123.456 + 789.012i"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.stringValue(ValueMode()), input)
    }

    func testPasteComplexNumber3() {
        let input = "2 - 3i"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.stringValue(ValueMode()), input)
    }

    func testPasteComplexNumberEng() {
        let input = "123.456E1 + 7.89012E-2i"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.stringValue(ValueMode()), "123.456E1 + 0.0789012i")
        XCTAssertEqual(v?.asComplex?.real.floatingPoint, 1234.56)
        XCTAssertEqual(v?.asComplex?.imag.floatingPoint, 0.0789012)
    }

    func testPasteComplexNumberEng2() {
        let input = "123.456 - 7.89012E8i"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.stringValue(ValueMode()), "123.456 - 7.89012E8i")
    }

    func testParseImaginaryNumber() {
        let input = "123.456i"
        let v = pasteParser.parsePastedInput(input)
        let complex = v?.asComplex
        XCTAssertNotNil(complex)
        XCTAssertEqual(complex?.real.floatingPoint, 0)
        XCTAssertEqual(complex?.imag.floatingPoint, 123.456)
        XCTAssertEqual(v?.stringValue(ValueMode()), input)
    }

    func testParseNegativeImaginaryNumber() {
        let input = "-123.456i"
        let v = pasteParser.parsePastedInput(input)
        let complex = v?.asComplex
        XCTAssertNotNil(complex)
        XCTAssertEqual(complex?.real.floatingPoint, 0)
        XCTAssertEqual(complex?.imag.floatingPoint, -123.456)
        XCTAssertEqual(v?.stringValue(ValueMode()), "-123.456i")
    }

    func testParseComplexWithUnitImag() {
        let input = "3 - i"
        let v = pasteParser.parsePastedInput(input)
        let complex = v?.asComplex
        XCTAssertNotNil(complex)
        XCTAssertEqual(complex?.real.floatingPoint, 3)
        XCTAssertEqual(complex?.imag.floatingPoint, -1)
        XCTAssertEqual(v?.stringValue(ValueMode()), input)
    }

    func testParseI() {
        let input = "i"
        let v = pasteParser.parsePastedInput(input)
        let complex = v?.asComplex
        XCTAssertNotNil(complex)
        XCTAssertEqual(complex?.real.floatingPoint, 0)
        XCTAssertEqual(complex?.imag.floatingPoint, 1)
        XCTAssertEqual(v?.stringValue(ValueMode()), input)
    }

    func testParseMinusI() {
        let input = "-i"
        let v = pasteParser.parsePastedInput(input)
        let complex = v?.asComplex
        XCTAssertNotNil(complex)
        XCTAssertEqual(complex?.real.floatingPoint, 0)
        XCTAssertEqual(complex?.imag.floatingPoint, -1)
        XCTAssertEqual(v?.stringValue(ValueMode()), input)
    }

    func testParseComplexNumberWithFractionals() {
        let input = "3/4 - 2/5i"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.stringValue(ValueMode()), input)
        XCTAssertEqual(v?.asComplex?.real.asRational?.stringValue(), "3/4")
        XCTAssertEqual(v?.asComplex?.imag.asRational?.stringValue(), "-2/5")
    }

    func testPastePolarComplexDeg() {
        let input = "2 ∠ 32°"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.stringValue(ValueMode()), input)
        XCTAssertEqual(v?.asComplex?.polarAbsolute.floatingPoint, 2)
        XCTAssertEqual(v?.asComplex?.polarArgument.floatingPoint,
                       Utils.deg2Rad([NumericalValue(32)], CalculatorMode())[0])
    }

    func testPastePolarComplexRad() {
        let input = "2 ∠ 0.7853982"
        let v = pasteParser.parsePastedInput(input)
        XCTAssertEqual(v?.stringValue(ValueMode(angle: .Rad)), input)
        XCTAssertEqual(v?.asComplex?.polarAbsolute.floatingPoint, 2)
        XCTAssertEqual(v?.asComplex?.polarArgument.floatingPoint,
                       0.7853982)
        XCTAssertEqual(v?.asComplex?.polarArgument.floatingPoint ?? -1,
                       Utils.deg2Rad([NumericalValue(45)], CalculatorMode())[0],
                       accuracy: NumericalValue.epsilon)
    }

    func testParseFractional() {
        let input = "3/4"
        let v = pasteParser.parsePastedInput(input)
        let rat = v?.asRational
        XCTAssertNotNil(rat)
        XCTAssertEqual(rat?.numerator.floatingPoint, 3)
        XCTAssertEqual(rat?.denominator.floatingPoint, 4)
        XCTAssertEqual(v?.stringValue(ValueMode()), input)
    }

    func testParseMixedFractional() {
        let input = "1 3/4"
        let v = pasteParser.parsePastedInput(input)
        let rat = v?.asRational
        XCTAssertNotNil(rat)
        XCTAssertEqual(rat?.numerator.floatingPoint, 7)
        XCTAssertEqual(rat?.denominator.floatingPoint, 4)
        XCTAssertEqual(v?.stringValue(ValueMode()), input)
    }

    func testParseMixedFractionalNegative() {
        let input = "-1 3/4"
        let v = pasteParser.parsePastedInput(input)
        let rat = v?.asRational
        XCTAssertNotNil(rat)
        XCTAssertEqual(rat?.numerator.floatingPoint, -7)
        XCTAssertEqual(rat?.denominator.floatingPoint, 4)
        XCTAssertEqual(v?.stringValue(ValueMode()), "-1 3/4")
    }

    func testParseSimpleMatrix() {
        let input = "[1  0  0\n0  1  0\n0  0  1]"
        let expectedResult = try! MatrixValue(
            [
                [NumericalValue(1), NumericalValue(0), NumericalValue(0)],
                [NumericalValue(0), NumericalValue(1), NumericalValue(0)],
                [NumericalValue(0), NumericalValue(0), NumericalValue(1)],
            ]
        )
        let v = pasteParser.parsePastedInput(input)
        let matrix = v?.asMatrix
        XCTAssertNotNil(matrix)
        XCTAssertEqual(matrix, expectedResult)
    }

    func testParseComplicatedMatrix() {
        let input = "[1 + i  0  1 2/3 + 4 1/4i\n0  1  0\n0  0  1]"
        let expectedResult = try! MatrixValue(
            [
                [complex(1, 1), NumericalValue(0), ComplexValue(realValue: rat(5, 3), imagValue: rat(17, 4))],
                [NumericalValue(0), NumericalValue(1), NumericalValue(0)],
                [NumericalValue(0), NumericalValue(0), NumericalValue(1)],
            ]
        )
        let v = pasteParser.parsePastedInput(input)
        let matrix = v?.asMatrix
        XCTAssertNotNil(matrix)
        XCTAssertEqual(matrix, expectedResult)
    }

    func testPasteGarbage() {
        XCTAssertNil(pasteParser.parsePastedInput("asdf123.456"))
        XCTAssertNil(pasteParser.parsePastedInput("123.456asdf"))
        XCTAssertNil(pasteParser.parsePastedInput("123.456iasdf"))
        XCTAssertNil(pasteParser.parsePastedInput("123.456 + 999.2iasdf"))
        XCTAssertNil(pasteParser.parsePastedInput("invalid input"))
    }
}
