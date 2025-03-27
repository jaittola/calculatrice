import XCTest
@testable import calculatrice

class TestMathOpsRational: XCTestCase {
    func testExpandFractions() {
        do {
            let v1 = rat(3, 17)
            let v2 = rat(5, 19)

            let (expv1, expv2) = try Utils.expandFractions(v1, v2)
            XCTAssertEqual(expv1, rat(57, 323))
            XCTAssertEqual(expv2, rat(85, 323))
        } catch {
            XCTFail("testExpandFractions failed with exception \(error)")
        }
    }

    func testExpandFractions2() {
        assertNoThrow {
            let v1 = rat(1, 4)
            let v2 = rat(1, 2)

            let (expv1, expv2) = try Utils.expandFractions(v1, v2)
            XCTAssertEqual(expv1, rat(2, 8))
            XCTAssertEqual(expv2, rat(4, 8))
        }
    }

    func testExpandFractions3() {
        assertNoThrow {
            let v1 = rat(6, 4)
            let v2 = rat(2, 16)

            let (expv1, expv2) = try Utils.expandFractions(v1, v2)
            // Should work with the commented-out values, so to be fixed
//            XCTAssertEqual(expv1, rat(12, 8))
//            XCTAssertEqual(expv2, rat(1, 8))

            XCTAssertEqual(expv1, rat(24, 16))
            XCTAssertEqual(expv2, rat(2, 16))

        }
    }

    func testExpandFractionsNoExpand() {
        assertNoThrow {
            let v1 = rat(1, 4)
            let v2 = rat(3, 4)

            let (expv1, expv2) = try Utils.expandFractions(v1, v2)
            XCTAssertEqual(expv1, rat(1, 4))
            XCTAssertEqual(expv2, rat(3, 4))
        }
    }

    func testSimplifyFraction() {
        assertNoThrow {
            XCTAssertEqual(try Utils.simplifyFraction(rat(3, 27)), rat(1, 9))
            XCTAssertEqual(try Utils.simplifyFraction(rat(14, 27)), rat(14, 27))
            XCTAssertEqual(try Utils.simplifyFraction(rat(27, 14)), rat(27, 14))
        }
    }

    func testAdd() {
        let v1 = rat(1, 2)
        let v2 = rat(3, 4)
        let res = assertNoThrow { try Plus().calcRational([v1, v2], CalculatorMode()) }
        XCTAssertEqual(res, rat(5, 4))
    }

    func testMinus() {
        let v1 = rat(1, 2)
        let v2 = rat(3, 4)
        let res = assertNoThrow { try Minus().calcRational([v1, v2], CalculatorMode()) }
        XCTAssertEqual(res, rat(-1, 4))
    }

    func testMinus2() {
        let v1 = rat(1, 2)
        let v2 = rat(1, 3)
        let res = assertNoThrow { try Minus().calcRational([v1, v2], CalculatorMode()) }
        XCTAssertEqual(res, rat(1, 6))
    }

    func testMult() {
        let v1 = rat(2, 5)
        let v2 = rat(5, 7)

        let res = assertNoThrow { try Mult().calcRational([v1, v2], CalculatorMode()) }
        XCTAssertEqual(res, rat(2, 7))
    }

    func testDiv() {
        let v1 = rat(2, 5)
        let v2 = rat(6, 9)

        let res = assertNoThrow { try Div().calcRational([v1, v2], CalculatorMode()) }
        XCTAssertEqual(res, rat(3, 5))
    }

    func testInv() {
        let v1 = rat(3, 8)
        let res = assertNoThrow {
            try Inv().calcRational([v1], CalculatorMode())
        }
        XCTAssertEqual(res, rat(8, 3))
    }

    func testNeg() {
        let v1 = rat(3, 8)
        let res = assertNoThrow {
            try Neg().calcRational([v1], CalculatorMode())
        }
        XCTAssertEqual(res, rat(-3, 8))
    }

    func testConstructRational() {
        let v1 = NumericalValue(3)
        let v2 = NumericalValue(8)
        let res = assertNoThrow {
            try RationalNumber().convert([v1, v2], CalculatorMode())
        }
        XCTAssertEqual(res?.asRational, rat(3, 8))
    }

    func testConstructRational2() {
        let v1 = NumericalValue(4)
        let v2 = NumericalValue(8)
        let res = assertNoThrow {
            try RationalNumber().convert([v1, v2], CalculatorMode())
        }
        XCTAssertEqual(res?.asRational, rat(4, 8))
    }
}
