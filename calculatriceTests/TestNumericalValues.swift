import XCTest
@testable import calculatrice

class TestNumericalValues: XCTestCase {
    func testBasicWithAutoFormat() {
        let v1 = Value(NumericalValue(1.2, numberFormat: .auto), id: 3)
        XCTAssertEqual("1.2", v1.stringValue(CalculatorMode()))
    }

    func testWithId() {
        let v1 = Value(NumericalValue(1.2))
        let v2 = v1.withId(4)
        let v1r = v1.asNumericalValue!
        let v2r = v2.asNumericalValue!
        XCTAssertEqual(v1r, v2r)
        XCTAssertEqual(v1r.stringValue(), v2r.stringValue())
        XCTAssertEqual(v1r.numberFormat,
                       v2r.numberFormat)
        XCTAssertEqual(v2.id, 4)
    }

    func testWithIdAndInputNumberFormat() {
        let v1 = Value(NumericalValue(1.2,
                                      originalStringValue: "My weird number format"),
                       id: 3)
        let v2 = v1.withId(4)
        let v1r = v1.asNumericalValue!
        let v2r = v2.asNumericalValue!
        XCTAssertEqual(v1r.floatingPoint, v2r.floatingPoint)
        XCTAssertEqual(v2r.stringValue(), "My weird number format")
        XCTAssertEqual(v1r.numberFormat,
                       v2r.numberFormat)
        XCTAssertEqual(v2.id, 4)
    }

    func testWithIdAndEngNumberFormat() {
        let v1 = Value(NumericalValue(1.2, numberFormat: .eng), id: 99)
        let v2 = v1.withId(4)
        let v1r = v1.asNumericalValue!
        let v2r = v2.asNumericalValue!
        XCTAssertEqual(v1r.floatingPoint, v2r.floatingPoint)
        XCTAssertEqual(v2r.stringValue(), "1.2000000e+00")
        XCTAssertEqual(v1r.numberFormat,
                       v2r.numberFormat)
        XCTAssertEqual(v2.id, 4)
    }

    func testEquality() {
        let v1 = NumericalValue(1.2)
        let v2 = NumericalValue(1.2)
        let v3 = NumericalValue(1.3)
        let v4 = Value(v1)

        XCTAssertTrue(v1.isEqual(v1))
        XCTAssertTrue(v1.isEqual(v2))

        XCTAssertFalse(v1.isEqual(v3))
        XCTAssertFalse(v1.isEqual(v4))
    }

    func testPositiveComplexNumberString() {
        let c = ComplexValue(3.0, 2.0)
        XCTAssertEqual(c.stringValue(), "3 + 2i")
    }

    func testPositiveComplexNumberString2() {
        let c = ComplexValue(3.0, 1.0)
        XCTAssertEqual(c.stringValue(), "3 + i")
    }

    func testComplexNumberString() {
        let c = ComplexValue(3.0, -2.0)
        XCTAssertEqual(c.stringValue(), "3 - 2i")
    }

    func testNegativeComplexNumberString() {
        let c = ComplexValue(-2.0, -9.25)
        XCTAssertEqual(c.stringValue(), "-2 - 9.25i")
    }

    func testNegativeComplexNumberString2() {
        let c = ComplexValue(-2.0, -1.0)
        XCTAssertEqual(c.stringValue(), "-2 - i")
    }

    func testRealComplexNumberString() {
        let c = ComplexValue(-2.0, 0.0)
        XCTAssertEqual(c.stringValue(), "-2")
    }

    func testImaginaryComplexNumberString() {
        let c = ComplexValue(0.0, -2.2)
        XCTAssertEqual(c.stringValue(), "-2.2i")
    }

    func testComplexValueWithEngFormat() {
        let c = ComplexValue(2.1E-3, 9.4E-2)
        XCTAssertEqual(c.stringValue(), "0.0021 + 0.094i")
        let ce = ComplexValue(c,
                              numberFormat: .eng,
                              presentationFormat: .cartesian)
        XCTAssertEqual(ce.stringValue(), "2.1000000e-03 + 9.4000000e-02i")
    }

    func testRealComplexString() {
        let c = ComplexValue(3.0, 0.0)
        XCTAssertEqual(c.stringValue(), "3")
    }

    func testComplexOneString() {
        let c = ComplexValue(0.0, 1.0)
        XCTAssertEqual(c.stringValue(), "i")
    }

    func testComplexMinuxOneString() {
        let c = ComplexValue(0.0, -1.0)
        XCTAssertEqual(c.stringValue(), "-i")
    }

    func testComplexString() {
        let c = ComplexValue(0.0, 3.2)
        XCTAssertEqual(c.stringValue(), "3.2i")
    }

    func testComplexZeroString() {
        let c = ComplexValue(0.0, 0.0)
        XCTAssertEqual(c.stringValue(), "0")
    }

    func testComplexCartesianToPolar() {
        checkComplexToPolar(ComplexValue(2.0, 2.0), 2.828427, Double.pi / 4)
    }

    func testComplexCartesianToPolar2() {
        checkComplexToPolar(ComplexValue(-2.0, 2.0), 2.828427, 3 * Double.pi
         / 4)
    }

    func testComplexZeroToPolar() {
        checkComplexToPolar(ComplexValue(0.0, 0.0), 0, Double.nan)
    }

    func testComplexNegToPolar() {
        checkComplexToPolar(ComplexValue(-2.0, 0.0), 2, Double.pi)
    }

    func testComplexPolar() {
        checkPolarComplexToCartesian(ComplexValue(absolute: 2, argument: Double.pi / 4), sqrt(2), sqrt(2))
    }

    func testComplexPolar2() {
        checkPolarComplexToCartesian(ComplexValue(absolute: 2.0, argument: 0.0), 2, 0)
    }

    func testComplexPolar3() {
        checkPolarComplexToCartesian(ComplexValue(absolute: 1, argument: Double.pi / 2), 0, 1)
    }

    func checkPolarComplexToCartesian(_ c: ComplexValue, _ real: Double, _ imaginary: Double) {
        XCTAssertEqual(c.real.floatingPoint, real, accuracy: NumericalValue.epsilond)
        XCTAssertEqual(c.imag.floatingPoint, imaginary, accuracy: NumericalValue.epsilond)
    }

    func checkComplexToPolar(_ c: ComplexValue, _ absolute: Double, _ argument: Double) {
        XCTAssertEqual(c.polarAbsolute.floatingPoint, absolute, accuracy: NumericalValue.epsilond)

        if argument.isNaN && c.polarArgument.floatingPoint.isNaN {
            return
        }
        if (argument.isNaN && !c.polarArgument.floatingPoint.isNaN) ||
            (!argument.isNaN && c.polarArgument.floatingPoint.isNaN) {
            XCTFail("Arguments not equal: \(c.polarAbsolute.floatingPoint) \(argument)")
        } else {
            XCTAssertEqual(c.polarArgument.floatingPoint, argument, accuracy: NumericalValue.epsilond)
        }
    }
}
