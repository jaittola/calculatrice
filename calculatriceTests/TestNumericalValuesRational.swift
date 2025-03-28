import XCTest
@testable import calculatrice

class TestNumericalValuesRational: XCTestCase {
    func testSimpleRational() {
        let v = assertNoThrow { try RationalValue(3, 7) }!
        XCTAssertEqual(3.0, v.numerator.doubleValue)
        XCTAssertEqual(7.0, v.denominator.doubleValue)
        XCTAssertEqual("3/7", v.stringValue())
        XCTAssertEqual(0.42857143, v.doubleValue, accuracy: NumericalValue.epsilon)
    }

    func testNonIntInputToRational() {
        do {
            _ = try RationalValue(3.1, 3)
            XCTFail("Non-integer input to rational value should fail")
        } catch {
            guard case CalcError.nonIntegerInputToRational = error else {
                XCTFail("Got bad error with incorrect input to rational number: \(error)")
                return
            }
        }
    }

    func testNonIntDenominatorInputToRational() {
        do {
            _ = try RationalValue(3, 3.2)
            XCTFail("Non-integer input to rational value should fail")
        } catch {
            guard case CalcError.nonIntegerInputToRational = error else {
                XCTFail("Got bad error with incorrect input to rational number: \(error)")
                return
            }
        }
    }

    func testZeroDenominatorInputToRational() {
        do {
            _ = try RationalValue(3, 0)
            XCTFail("Zero in denominator rational value should fail")
        } catch {
            guard case CalcError.badInput = error else {
                XCTFail("Got bad error with incorrect input to rational number: \(error)")
                return
            }
        }
    }

    func testNegativeInputToRational() {
        let v = assertNoThrow { try RationalValue(-3, -7) }!
        XCTAssertEqual(-3.0, v.numerator.doubleValue)
        XCTAssertEqual(7.0, v.denominator.doubleValue)
        XCTAssertEqual("-3/7", v.stringValue())
        XCTAssertEqual(-0.42857143, v.doubleValue, accuracy: NumericalValue.epsilon)
    }

    func testNegativeDenominatorInputToRational() {
        let v = assertNoThrow { try RationalValue(3, -7) }!
        XCTAssertEqual(-3.0, v.numerator.doubleValue)
        XCTAssertEqual(7.0, v.denominator.doubleValue)
        XCTAssertEqual("-3/7", v.stringValue())
        XCTAssertEqual(-0.42857143, v.doubleValue, accuracy: NumericalValue.epsilon)
    }

    func testSimplifyingRationalConstructor() {
        let v = assertNoThrow { try RationalValue(-2, 4) }!
        XCTAssertEqual(-1, v.numerator.doubleValue)
        XCTAssertEqual(2, v.denominator.doubleValue)
        XCTAssertFalse(v.isWholeNumber)
    }

    func testSimplifyingRationalConstructor2() {
        let v = assertNoThrow { try RationalValue(8, 4) }!
        XCTAssertEqual(2, v.numerator.doubleValue)
        XCTAssertEqual(1, v.denominator.doubleValue)
        XCTAssertTrue(v.isWholeNumber)
    }

    func testNonSimplifyingRationalConstructor() {
        let v = assertNoThrow { try RationalValue(-2, 4,
                                                   simplifyOnInitialisation: false) }!
        XCTAssertEqual(-2, v.numerator.doubleValue)
        XCTAssertEqual(4, v.denominator.doubleValue)
        XCTAssertFalse(v.isWholeNumber)
    }

    func testWholeFractionConstructor() {
        let v = assertNoThrow {
            try RationalValue(whole: NumericalValue(2),
                              numerator: NumericalValue(2),
                              denominator: NumericalValue(6))
        }
        XCTAssertEqual(try RationalValue(7, 3), v)
        XCTAssertEqual("2 2/6", v?.stringValue())
    }

    func testWholeFractionFormatting() {
        let v = assertNoThrow { try RationalValue(14, 6) }!
        let negv = assertNoThrow { try RationalValue(-14, 6) }!
        let vNoSimplify = assertNoThrow { try RationalValue(14, 6, simplifyOnInitialisation: false) }!
        let wholeNum = assertNoThrow { try RationalValue(2, 1) }!

        let fractionalised = vNoSimplify.fracOnly

        XCTAssertEqual(2, v.wholePart)
        XCTAssertEqual(try RationalValue(1, 3), v.fractionalPart)
        XCTAssertEqual("2 1/3", v.stringValue())

        XCTAssertEqual(-2, negv.wholePart)
        XCTAssertEqual(try RationalValue(1, 3), negv.fractionalPart)
        XCTAssertEqual("-2 1/3", negv.stringValue())

        XCTAssertEqual(2, vNoSimplify.wholePart)
        XCTAssertEqual(try RationalValue(2, 6,
                                         simplifyOnInitialisation: false), vNoSimplify.fractionalPart)
        XCTAssertEqual("2 2/6", vNoSimplify.stringValue())

        XCTAssertEqual("2", wholeNum.stringValue())

        XCTAssertEqual("7/3", fractionalised.stringValue())
    }

    func testEquality() {
        let v1 = assertNoThrow { try RationalValue(-2, 4) }!
        let v2 = assertNoThrow { try RationalValue(-1, 2) }!
        let v3 = NumericalValue(-0.5)

        let v4 = assertNoThrow { try RationalValue(-1, 3) }!
        let v5 = NumericalValue(1.3)
        let v6 = Value(v1)

        XCTAssertTrue(v1.isEqual(v1))
        XCTAssertTrue(v1.isEqual(v2))
        XCTAssertTrue(v1.isEqual(v3), "v1 == v3 (\(v1) == \(v3))")
        XCTAssertTrue(v3.isEqual(v1), "v3 == v1 (\(v3) == \(v1))")

        XCTAssertFalse(v1.isEqual(v4))
        XCTAssertFalse(v1.isEqual(v5))
        XCTAssertFalse(v1.isEqual(v6))
    }

}
