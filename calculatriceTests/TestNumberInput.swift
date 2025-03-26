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

        let v = ib.value
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

        let v = ib.value
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

        let v = ib.value
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

        let v = ib.value
        XCTAssertEqual(v.floatingPoint, -0.0023)
        XCTAssertEqual(v.stringValue(), "-2.3E-3")
    }
}
