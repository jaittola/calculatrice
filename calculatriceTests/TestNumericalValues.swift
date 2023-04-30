import XCTest
@testable import calculatrice

class TestNumericalValues: XCTestCase {
    func testWithId() {
        let v1 = SingleDimensionalNumericalValue(1.2, id: 3)
        let v2 = v1.withId(4)
        XCTAssertEqual(v1.doubleValue, v2.doubleValue)
        XCTAssertEqual(v1.stringValue, v2.stringValue)
        XCTAssertEqual(v1.numberFormat,
                       (v2 as! SingleDimensionalNumericalValue).numberFormat)
        XCTAssertEqual(v2.id, 4)
    }

    func testWithIdAndInputNumberFormat() {
        let v1 = SingleDimensionalNumericalValue(1.2, "My weird number format", id: 2)
        let v2 = v1.withId(4)
        XCTAssertEqual(v1.doubleValue, v2.doubleValue)
        XCTAssertEqual(v2.stringValue, "My weird number format")
        XCTAssertEqual(v1.numberFormat,
                       (v2 as! SingleDimensionalNumericalValue).numberFormat)
        XCTAssertEqual(v2.id, 4)
    }

    func testWithIdAndEngNumberFormat() {
        let v1 = SingleDimensionalNumericalValue(1.2, id: 2, numberFormat: .eng)
        let v2 = v1.withId(4)
        XCTAssertEqual(v1.doubleValue, v2.doubleValue)
        XCTAssertEqual(v2.stringValue, "1.200000E+00")
        XCTAssertEqual(v1.numberFormat,
                       (v2 as! SingleDimensionalNumericalValue).numberFormat)
        XCTAssertEqual(v2.id, 4)
    }
}
