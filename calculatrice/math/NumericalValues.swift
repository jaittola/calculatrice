import Foundation
import BigNum

public let realDefaultPrecision = 7

enum ContainedValue: Equatable {
    case number(value: NumericalValue)
    case complex(value: ComplexValue)

    var asComplex: ComplexValue {
        switch self {
        case .complex(let c):
            return c
        case .number(let n):
            return n.asComplex
        }
    }

    var asReal: NumericalValue? {
        switch self {
        case .complex(let c):
            return c.asReal
        case .number(let n):
            return n
        }
    }

    func stringValue(_ calculatorMode: CalculatorMode) -> String {
        switch self {
        case .complex(let c):
            return c.stringValue(precision: realDefaultPrecision,
                                 angleUnit: calculatorMode.angle)
        case .number(let n):
            return n.stringValue(precision: realDefaultPrecision)
        }
    }
}

struct Value: Identifiable, Equatable {
    let containedValue: ContainedValue
    let id: Int

    var asComplex: ComplexValue {
        containedValue.asComplex
    }

    var asNum: NumericalValue? {
        containedValue.asReal
    }

    init(_ containedValue: ContainedValue, id: Int = 0) {
        self.containedValue = containedValue
        self.id = id
    }

    init(_ value: NumericalValue, id: Int = 0) {
        self.init(ContainedValue.number(value: value), id: id)
    }

    init(_ value: ComplexValue, id: Int = 0) {
        self.init(ContainedValue.complex(value: value), id: id)
    }

    func withId(_ newId: Int) -> Value {
        return Value(containedValue, id: newId)
    }

    func stringValue(_ calculatorMode: CalculatorMode) -> String {
        containedValue.stringValue(calculatorMode)
    }

    static func == (lhs: Value, rhs: Value) -> Bool {
        lhs.id == rhs.id
    }
}

enum ValueError: Error {
    case invalidDimension
}

class ComplexValue: NSObject {
    enum Format {
        case polar
        case cartesian
    }

    let dimensions = [2]

    let originalComponents: [NumericalValue]
    let originalFormat: Format
    let presentationFormat: Format

    var cartesian: [NumericalValue] {
        switch originalFormat {
        case .cartesian:
            return originalComponents
        case .polar:
            let re = polarAbsolute.value * BigFloat.cos(polarArgument.value)
            let imag = polarAbsolute.value * BigFloat.sin(polarArgument.value)
            return [NumericalValue(re), NumericalValue(imag)]
        }
    }

    var real: NumericalValue { cartesian[0] }
    var imag: NumericalValue { cartesian[1] }

    var polarAbsolute: NumericalValue {
        switch originalFormat {
        case .cartesian:
            let r = sqrt(pow(real.doubleValue, 2) + pow(imag.doubleValue, 2))
            return NumericalValue(r)
        case .polar:
            return originalComponents[0]
        }
    }

    var polarArgument: NumericalValue {
        switch originalFormat {
        case .cartesian:
            let x = real.doubleValue
            let y = imag.doubleValue

            // Based on https://en.wikipedia.org/wiki/Complex_number#Modulus_and_argument,
            // referred on May 1st 2023.
            if y == 0 && x == 0 {
                return NumericalValue(Double.nan)
            } else if x < 0 && y == 0 {
                return NumericalValue(Double.pi)
            } else { // y != 0 || x > 0 {
                let arg = 2 * atan(imag.doubleValue / (polarAbsolute.doubleValue + real.doubleValue))
                return NumericalValue(arg)
            }
        case .polar:
            return originalComponents[1]
        }
    }

    var asReal: NumericalValue? {
        cartesian[1].doubleValue == 0 ? cartesian[0] : nil
    }

    var isNan: Bool {
        originalComponents[0].doubleValue.isNaN ||
        originalComponents[1].doubleValue.isNaN
    }

    func stringValue(precision: Int = realDefaultPrecision,
                     angleUnit: CalculatorMode.Angle = .Deg) -> String {
        switch presentationFormat {
        case .cartesian:
            return cartesianStringValue(precision)
        case .polar:
            return polarStringValue(precision, angleUnit)
        }
    }

    func cartesianStringValue(_ precision: Int) -> String {
        let cart = cartesian

        if cart[0].doubleValue == 0 && cart[1].doubleValue == 0 {
            return "0"
        }

        let realPart = (cart[0].doubleValue != 0 ?
                        cart[0].stringValue(precision: precision)
                        : "")
        var plusminus = ""
        var imaginaryPart = ""

        switch cartesian[1].doubleValue {
        case 1:
            imaginaryPart = "i"
            plusminus = (cart[0].doubleValue != 0 ? " + " : "")
        case -1:
            imaginaryPart = "i"
            plusminus = cart[0].doubleValue != 0 ? " - " : "-"
        case 0:
            plusminus = ""
            imaginaryPart = ""
        default:
            let withSign: Bool
            if cart[0].doubleValue != 0 {
                plusminus = cart[1].doubleValue > 0 ? " + " : " - "
                withSign = false
            } else {
                plusminus = ""
                withSign = true
            }
            let formatted = cart[1].stringValue(precision: precision,
                                                     withSign: withSign)
            imaginaryPart = "\(formatted)i"
        }
        return "\(realPart)\(plusminus)\(imaginaryPart)"
    }

    func polarStringValue(_ precision: Int,
                          _ angleUnit: CalculatorMode.Angle) -> String {
        let polarAbs = polarAbsolute
        let polarArg = polarArgument

        if polarAbs.doubleValue == 0 {
            return "0"
        }

        let absPart = polarAbs.stringValue(precision: precision)
        let argPart: String
        let angleUnitS: String

        switch angleUnit {
        case .Deg:
            let argDeg = NumericalValue(polarArg.doubleValue * 180.0 / Double.pi)
            argPart = argDeg.stringValue(precision: precision)
            angleUnitS = "°"
        case .Rad:
            argPart = polarArg.stringValue(precision: precision)
            angleUnitS = ""
        }

        return "\(absPart) ∠ \(argPart)\(angleUnitS)"
    }

    override var description: String {
        return "ComplexValue (\(stringValue(precision: realDefaultPrecision))"
    }

    init(_ components: [NumericalValue],
         originalFormat: Format,
         presentationFormat: Format) throws {
        if components.count != 2 {
            throw ValueError.invalidDimension
        }

        self.originalComponents = components
        self.originalFormat = originalFormat
        self.presentationFormat = presentationFormat
    }

    convenience init(realValue: NumericalValue) {
        do {
            try self.init([realValue,
                           NumericalValue(Double(0))],
                          originalFormat: .cartesian,
                          presentationFormat: .cartesian)
        } catch {
            fatalError("ComplexValue.init from real threw an exception. This should not happen")
        }
    }

    convenience init(_ real: Double,
                     _ imaginary: Double,
                     presentationFormat: Format = .cartesian) {
        do {
            try self.init([NumericalValue(real),
                           NumericalValue(imaginary)],
                          originalFormat: .cartesian,
                          presentationFormat: presentationFormat)
        } catch {
            fatalError("ComplexValue init from doubles threw an exception. This should not happen")
        }
    }

    convenience init(_ real: BigFloat,
                     _ imaginary: BigFloat,
                     presentationFormat: Format = .cartesian) {
        do {
            try self.init([NumericalValue(real),
                           NumericalValue(imaginary)],
                          originalFormat: .cartesian,
                          presentationFormat: presentationFormat)
        } catch {
            fatalError("ComplexValue init from doubles threw an exception. This should not happen")
        }
    }

    convenience init(absolute: Double,
                     argument: Double,
                     presentationFormat: Format = .polar) {
        do {
            try self.init([NumericalValue(absolute),
                           NumericalValue(argument)],
                          originalFormat: .polar,
                          presentationFormat: presentationFormat)
        } catch {
            fatalError("ComplexValue init from polar doubles threw an exception. This should not happen")
        }
    }

    convenience init(absolute: BigFloat,
                     argument: BigFloat,
                     presentationFormat: Format = .polar) {
        do {
            try self.init([NumericalValue(absolute),
                           NumericalValue(argument)],
                          originalFormat: .polar,
                          presentationFormat: presentationFormat)
        } catch {
            fatalError("ComplexValue init from polar doubles threw an exception. This should not happen")
        }
    }

    convenience init(_ v: ComplexValue,
                     numberFormat: ValueNumberFormat? = nil,
                     presentationFormat: Format) {
        do {
            let nf = numberFormat ?? v.originalComponents[0].numberFormat

            try self.init([NumericalValue(v.originalComponents[0].value,
                                          numberFormat: nf),
                           NumericalValue(v.originalComponents[1].value,
                                          numberFormat: nf)],
                          originalFormat: v.originalFormat,
                          presentationFormat: presentationFormat)
        } catch {
            fatalError("ComplexValue init from another complex value threw an exception. This should not happen")
        }
    }

    override func isEqual(_ to: Any?) -> Bool {
        guard let other = to as? ComplexValue else {
            return false
        }

        return cartesian.enumerated().map { (index, v) in
            let otherValue = other.cartesian[index]
            return v.isEqual(otherValue)
        }
        .allSatisfy { isEqual in isEqual }
    }

    static func == (lhs: ComplexValue, rhs: ComplexValue) -> Bool {
        return lhs.isEqual(rhs)
    }
}

class NumericalValue: NSObject {
    private(set) var value: BigFloat
    private(set) var originalStringValue: String
    private (set) var numberFormat: ValueNumberFormat

    var doubleValue: Double {
        value.asDouble
    }

    var asComplex: ComplexValue {
        ComplexValue(realValue: self)
    }

    override var description: String {
        return "SingleDimensionalNumericalValue \(stringValue(precision: realDefaultPrecision))"
    }

    init(_ doubleValue: Double,
         numberFormat: ValueNumberFormat = .auto) {
        self.value = BigFloat(doubleValue)
        self.numberFormat = numberFormat
        self.originalStringValue = ""
    }

    init(_ value: BigFloat,
         numberFormat: ValueNumberFormat = .auto) {
        self.value = value
        self.numberFormat = numberFormat
        self.originalStringValue = ""
    }

    init(_ v: BigFloat,
         originalStringValue: String) {
        self.value = v
        self.numberFormat = .fromInput
        self.originalStringValue = originalStringValue
    }

    func stringValue(precision: Int = realDefaultPrecision,
                     engDecimalPlaces: Int = realDefaultPrecision,
                     maxAutoDecimalFormat: BigFloat = 1E7,
                     minAutoDecimalFormat: BigFloat = 1E-4,
                     withSign: Bool = true) -> String {
        let absv = abs(value)

        switch numberFormat {
        case .fromInput:
            return originalStringValue
        case .auto:
            if absv >= maxAutoDecimalFormat || absv < minAutoDecimalFormat {
                return stringEngValue(precision: precision,
                                      engDecimalPlaces: engDecimalPlaces,
                                      withSign: withSign)
            } else {
                return stringDecimalValue(precision: precision,
                                          withSign: withSign)
            }
        case .decimal:
            return stringDecimalValue(precision: precision,
                                      withSign: withSign)
        case .eng:
            return stringEngValue(precision: precision,
                                  engDecimalPlaces: engDecimalPlaces,
                                  withSign: withSign)
        }
    }

    func stringDecimalValue(precision: Int, withSign: Bool) -> String {
        let v = withSign ? doubleValue : fabs(doubleValue)
        if v.isInfinite {
            return stringLargeNumDecimalValue(withSign: withSign)
        }

        let rounding = NSDecimalNumberHandler(roundingMode: .plain,
                                              scale: Int16(precision),
                                              raiseOnExactness: false,
                                              raiseOnOverflow: false,
                                              raiseOnUnderflow: false,
                                              raiseOnDivideByZero: true)
        let rounded = NSDecimalNumber(value: v).rounding(accordingToBehavior: rounding)
        return rounded.stringValue
    }

    func stringLargeNumDecimalValue(withSign: Bool) -> String {
        if value.isInfinite {
            return "Inf"
        }

        let v = withSign ? value : abs(value)
        var stringified = v.toString()

        if stringified.hasPrefix("+") {
            stringified.removeFirst()
        }
        if stringified.hasSuffix(".0") {
            stringified.removeLast(2)
        }

        return stringified
    }

    func stringEngValue(precision: Int, engDecimalPlaces: Int, withSign: Bool) -> String {
        let v = withSign ? doubleValue : fabs(doubleValue)
        if v.isInfinite {
            return stringLargeNumEngValue(engDecimalPlaces: engDecimalPlaces, withSign: withSign)
        }

        let format = String(format: "%%%d.%de", precision, engDecimalPlaces)
        return String(format: format, v)
    }

    func stringLargeNumEngValue(engDecimalPlaces: Int, withSign: Bool) -> String {
        let absv = abs(value)
        let v = withSign ? value : absv

        let logv = BigFloat.log10(absv)
        let exponent = logv.rounded(.towardZero)
        let significand = v / BigFloat.exp10(exponent)

        let rounding = NSDecimalNumberHandler(roundingMode: .plain,
                                              scale: Int16(engDecimalPlaces),
                                              raiseOnExactness: false,
                                              raiseOnOverflow: false,
                                              raiseOnUnderflow: false,
                                              raiseOnDivideByZero: true)
        let roundedSignificand = NSDecimalNumber(value: significand.asDouble).rounding(accordingToBehavior: rounding)

        return String(format: "%@e%.0f",
                      roundedSignificand.stringValue,
                      exponent.asDouble)
    }

    override func isEqual(_ to: (Any)?) -> Bool {
        guard let other = to as? NumericalValue else {
            return false
        }
        return abs(value.distance(to: other.value)) < NumericalValue.epsilon
    }

    static let pi = NumericalValue(BigFloat.pi)

    static let epsilon = BigFloat(0.0001) // Mostly for tests, where we use the equality operator.
    static var epsilond: Double { epsilon.asDouble }
}
