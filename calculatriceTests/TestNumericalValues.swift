import XCTest
@testable import calculatrice

class TestNumericalValues: XCTestCase {
    func testWithId() {
        let v1 = Value(DoublePrecisionValue(1.2))
        let v2 = v1.withId(4)
        let v1r = v1.asReal!
        let v2r = v2.asReal!
        XCTAssertEqual(v1r, v2r)
        XCTAssertEqual(v1r.stringValue(), v2r.stringValue())
        XCTAssertEqual(v1r.numberFormat,
                       v2r.numberFormat)
        XCTAssertEqual(v2.id, 4)
    }

    func testWithIdAndInputNumberFormat() {
        let v1 = Value(DoublePrecisionValue(1.2, "My weird number format"), id: 3)
        let v2 = v1.withId(4)
        let v1r = v1.asReal!
        let v2r = v2.asReal!
        XCTAssertEqual(v1r.doubleValue, v2r.doubleValue)
        XCTAssertEqual(v2r.stringValue(), "My weird number format")
        XCTAssertEqual(v1r.numberFormat,
                       v2r.numberFormat)
        XCTAssertEqual(v2.id, 4)
    }

    func testWithIdAndEngNumberFormat() {
        let v1 = Value(DoublePrecisionValue(1.2, numberFormat: .eng), id: 99)
        let v2 = v1.withId(4)
        let v1r = v1.asReal!
        let v2r = v2.asReal!
        XCTAssertEqual(v1r.doubleValue, v2r.doubleValue)
        XCTAssertEqual(v2r.stringValue(), "1.200000E+00")
        XCTAssertEqual(v1r.numberFormat,
                       v2r.numberFormat)
        XCTAssertEqual(v2.id, 4)
    }

    func testPositiveComplexNumberString() {
        let c = ComplexValue(3, 2)
        XCTAssertEqual(c.stringValue(), "3+2i")
    }

    func testNegativeComplexNumberString() {
        let c = ComplexValue(-2, -9.25)
        XCTAssertEqual(c.stringValue(), "-2-9.25i")
    }

    func testComplexValueWithEngFormat() {
        let c = ComplexValue(2.1E-3, 9.4E-2)
        XCTAssertEqual(c.stringValue(), "0.0021+0.094i")
        let ce = ComplexValue(c, numberFormat: .eng)
        XCTAssertEqual(ce.stringValue(), "2.100000E-03+9.400000E-02i")
    }

    func testRealComplexString() {
        let c = ComplexValue(3, 0)
        XCTAssertEqual(c.stringValue(), "3")
    }

    func testComplexOneString() {
        let c = ComplexValue(0, 1)
        XCTAssertEqual(c.stringValue(), "i")
    }

    func testComplexMinuxOneString() {
        let c = ComplexValue(0, -1)
        XCTAssertEqual(c.stringValue(), "-i")
    }

    func testComplexString() {
        let c = ComplexValue(0, 3.2)
        XCTAssertEqual(c.stringValue(), "3.2i")
    }
}
