import XCTest
import BigNum
@testable import calculatrice

class TestNumericalValues: XCTestCase {
    func testBasicWithAutoFormat() {
        let v1 = Value(NumericalValue(BigFloat(1.2), numberFormat: .auto), id: 3)
        XCTAssertEqual("1.2", v1.stringValue(CalculatorMode()))
    }

    func testVeryLargeNumber() {
        let v1 = Value(NumericalValue(BigFloat(sign: .plus,
                                               exponent: 2128,
                                               significand: 2),
                                      numberFormat: .decimal))
        XCTAssertEqual(v1.stringValue(CalculatorMode()),
                       "39068863052250606675316075180094805854729238916271509523201597573290614178776258196125946187086384038426399410211596209825641006735815039349133571830814078426466367365756921815889043251782568216079937145581248380435562394709016860832903218461544174770465394800625479339537757537335553249850158191505318133510572607431520276555674875416599120317498059301881116979310243887366538357942833724193611196800156498222854457190574387431417252777540878783889717888098291728829027659361469209990779876001125013459865368124059563063357660165138062933843690520698442037155866153558918340961688671910520761972614713950055844461518093082929232185923731456")
    }

    func testVeryLargeNumberWithDecimalPart() {
        let bf1 = BigFloat(sign: .plus,
                           exponent: 2128,
                           significand: 2)
        let bf2 = BigFloat(0.25)
        let sum = bf1 + bf2

        let v = Value(NumericalValue(sum, numberFormat: .decimal))

        XCTAssertEqual(v.stringValue(CalculatorMode()),
                       "39068863052250606675316075180094805854729238916271509523201597573290614178776258196125946187086384038426399410211596209825641006735815039349133571830814078426466367365756921815889043251782568216079937145581248380435562394709016860832903218461544174770465394800625479339537757537335553249850158191505318133510572607431520276555674875416599120317498059301881116979310243887366538357942833724193611196800156498222854457190574387431417252777540878783889717888098291728829027659361469209990779876001125013459865368124059563063357660165138062933843690520698442037155866153558918340961688671910520761972614713950055844461518093082929232185923731456.25")
    }

    func testVeryLargeNegativeNumber() {
        let v1 = Value(NumericalValue(BigFloat(sign: .minus,
                                               exponent: 2128,
                                               significand: 2),
                                      numberFormat: .decimal))
        XCTAssertEqual(v1.stringValue(CalculatorMode()),
                       "-39068863052250606675316075180094805854729238916271509523201597573290614178776258196125946187086384038426399410211596209825641006735815039349133571830814078426466367365756921815889043251782568216079937145581248380435562394709016860832903218461544174770465394800625479339537757537335553249850158191505318133510572607431520276555674875416599120317498059301881116979310243887366538357942833724193611196800156498222854457190574387431417252777540878783889717888098291728829027659361469209990779876001125013459865368124059563063357660165138062933843690520698442037155866153558918340961688671910520761972614713950055844461518093082929232185923731456")
    }

    func testVeryLargeNegativeNumberWithDecimalPart() {
        let bf1 = BigFloat(sign: .minus,
                           exponent: 2128,
                           significand: 2)
        let bf2 = BigFloat(0.25)
        let sum = bf1 - bf2

        let v = Value(NumericalValue(sum, numberFormat: .decimal))

        XCTAssertEqual(v.stringValue(CalculatorMode()),
                       "-39068863052250606675316075180094805854729238916271509523201597573290614178776258196125946187086384038426399410211596209825641006735815039349133571830814078426466367365756921815889043251782568216079937145581248380435562394709016860832903218461544174770465394800625479339537757537335553249850158191505318133510572607431520276555674875416599120317498059301881116979310243887366538357942833724193611196800156498222854457190574387431417252777540878783889717888098291728829027659361469209990779876001125013459865368124059563063357660165138062933843690520698442037155866153558918340961688671910520761972614713950055844461518093082929232185923731456.25")
    }

    func testVeryLargeNumberEngFormat() {
        let v1 = Value(NumericalValue(BigFloat(sign: .plus,
                                               exponent: 2128,
                                               significand: 2),
                                      numberFormat: .eng))
        XCTAssertEqual(v1.stringValue(CalculatorMode()),
                       "3.9068863e640")
    }

    func testVeryLargeNegativeNumberEngFormat() {
        let v1 = Value(NumericalValue(BigFloat(sign: .minus,
                                               exponent: 2128,
                                               significand: 2),
                                      numberFormat: .eng))
        XCTAssertEqual(v1.stringValue(CalculatorMode()),
                       "-3.9068863e640")
    }

    func testWithId() {
        let v1 = Value(NumericalValue(1.2))
        let v2 = v1.withId(4)
        let v1r = v1.asNum!
        let v2r = v2.asNum!
        XCTAssertEqual(v1r, v2r)
        XCTAssertEqual(v1r.stringValue(), v2r.stringValue())
        XCTAssertEqual(v1r.numberFormat,
                       v2r.numberFormat)
        XCTAssertEqual(v2.id, 4)
    }

    func testWithIdAndInputNumberFormat() {
        let v1 = Value(NumericalValue(BigFloat(1.2),
                                      originalStringValue: "My weird number format"), id: 3)
        let v2 = v1.withId(4)
        let v1r = v1.asNum!
        let v2r = v2.asNum!
        XCTAssertEqual(v1r.doubleValue, v2r.doubleValue)
        XCTAssertEqual(v2r.stringValue(), "My weird number format")
        XCTAssertEqual(v1r.numberFormat,
                       v2r.numberFormat)
        XCTAssertEqual(v2.id, 4)
    }

    func testWithIdAndEngNumberFormat() {
        let v1 = Value(NumericalValue(BigFloat(1.2), numberFormat: .eng), id: 99)
        let v2 = v1.withId(4)
        let v1r = v1.asNum!
        let v2r = v2.asNum!
        XCTAssertEqual(v1r.doubleValue, v2r.doubleValue)
        XCTAssertEqual(v2r.stringValue(), "1.2000000e+00")
        XCTAssertEqual(v1r.numberFormat,
                       v2r.numberFormat)
        XCTAssertEqual(v2.id, 4)
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
        checkPolarComplexToCartesian(ComplexValue(absolute: 2, argument: BigFloat.pi / 4), sqrt(2), sqrt(2))
    }

    func testComplexPolar2() {
        checkPolarComplexToCartesian(ComplexValue(absolute: 2.0, argument: 0.0), 2, 0)
    }

    func testComplexPolar3() {
        checkPolarComplexToCartesian(ComplexValue(absolute: 1, argument: BigFloat.pi / 2), 0, 1)
    }

    func checkPolarComplexToCartesian(_ c: ComplexValue, _ real: Double, _ imaginary: Double) {
        XCTAssertEqual(c.real.doubleValue, real, accuracy: NumericalValue.epsilond)
        XCTAssertEqual(c.imag.doubleValue, imaginary, accuracy: NumericalValue.epsilond)
    }

    func checkComplexToPolar(_ c: ComplexValue, _ absolute: Double, _ argument: Double) {
        XCTAssertEqual(c.polarAbsolute.doubleValue, absolute, accuracy: NumericalValue.epsilond)

        if argument.isNaN && c.polarArgument.doubleValue.isNaN {
            return
        }
        if (argument.isNaN && !c.polarArgument.doubleValue.isNaN) ||
            (!argument.isNaN && c.polarArgument.doubleValue.isNaN) {
            XCTFail("Arguments not equal: \(c.polarAbsolute.doubleValue) \(argument)")
        } else {
            XCTAssertEqual(c.polarArgument.doubleValue, argument, accuracy: NumericalValue.epsilond)
        }
    }
}
