import XCTest
@testable import calculatrice

class TestMathOps: XCTestCase {
    let calculatorMode = CalculatorMode()
    let twothree = [num(3), num(2)]

    func testPlus() {
        let result = Plus().calculate(twothree, calculatorMode)
        XCTAssertEqual(result.doubleValue, 5)
    }

    func testMinus() {
        let result = Minus().calculate(twothree, calculatorMode)
        XCTAssertEqual(result.doubleValue, 1)
    }

    func testMult() {
        let result = Mult().calculate(twothree, calculatorMode)
        XCTAssertEqual(result.doubleValue, 6)
    }

    func testDiv() {
        let result = try? Div().calculate(twothree, calculatorMode)
        XCTAssertEqual(result?.doubleValue, 1.5)
    }

    func testNeg() {
        let result = Neg().calculate([num(2.5)], calculatorMode)
        XCTAssertEqual(result.doubleValue, -2.5)
    }

    func testSin() {
        let result = Sin().calculate([num(90)], calculatorMode)
        XCTAssertEqual(result.doubleValue, 1)
    }

    func testCos() {
        let result = Cos().calculate([num(0)], calculatorMode)
        XCTAssertEqual(result.doubleValue, 1)
    }

    func testTan() {
        let result = Tan().calculate([num(45)], calculatorMode)
        XCTAssertEqual(result.doubleValue, 1, accuracy: 0.0001)
    }

    // TODO, add more of this.
}

struct IdContainer {
    static var valueId: Int = 0

    static func nextId() -> Int {
        valueId += 1
        return valueId
    }
}

func num(_ value: Double) -> DoublePrecisionValue {
    InputBufferStackValue(id: IdContainer.nextId(),
                          doubleValue: value,
                          stringValue: value.formatted())
}
