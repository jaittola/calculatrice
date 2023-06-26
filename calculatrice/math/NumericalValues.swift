import Foundation

public let epsilon = 0.0001 // Mostly for tests, where we use the equality operator.

public let realDefaultPrecision = 7

enum ContainedValue: Equatable {
    case number(value: DoublePrecisionValue)
    case complex(value: ComplexValue)

    var asComplex: ComplexValue {
        switch self {
        case .complex(let c):
            return c
        case .number(let n):
            return n.asComplex
        }
    }

    var asReal: DoublePrecisionValue? {
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

    var asReal: DoublePrecisionValue? {
        containedValue.asReal
    }

    init(_ containedValue: ContainedValue, id: Int = 0) {
        self.containedValue = containedValue
        self.id = id
    }

    init(_ value: DoublePrecisionValue, id: Int = 0) {
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

    let originalComponents: [DoublePrecisionValue]
    let originalFormat: Format
    let presentationFormat: Format

    var cartesian: [DoublePrecisionValue] {
        switch originalFormat {
        case .cartesian:
            return originalComponents
        case .polar:
            let re = polarAbsolute.doubleValue * cos(polarArgument.doubleValue)
            let imag = polarAbsolute.doubleValue * sin(polarArgument.doubleValue)
            return [DoublePrecisionValue(re), DoublePrecisionValue(imag)]
        }
    }

    var real: DoublePrecisionValue { cartesian[0] }
    var imag: DoublePrecisionValue { cartesian[1] }

    var polarAbsolute: DoublePrecisionValue {
        switch originalFormat {
        case .cartesian:
            let r = sqrt(pow(real.doubleValue, 2) + pow(imag.doubleValue, 2))
            return DoublePrecisionValue(r)
        case .polar:
            return originalComponents[0]
        }
    }

    var polarArgument: DoublePrecisionValue {
        switch originalFormat {
        case .cartesian:
            let x = real.doubleValue
            let y = imag.doubleValue

            // Based on https://en.wikipedia.org/wiki/Complex_number#Modulus_and_argument,
            // referred on May 1st 2023.
            if y == 0 && x == 0 {
                return DoublePrecisionValue(Double.nan)
            } else if x < 0 && y == 0 {
                return DoublePrecisionValue(Double.pi)
            } else { // y != 0 || x > 0 {
                let arg = 2 * atan(imag.doubleValue / (polarAbsolute.doubleValue + real.doubleValue))
                return DoublePrecisionValue(arg)
            }
        case .polar:
            return originalComponents[1]
        }
    }

    var asReal: DoublePrecisionValue? {
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
            let argDeg = DoublePrecisionValue(polarArg.doubleValue * 180.0 / Double.pi)
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

    init(_ components: [DoublePrecisionValue],
         originalFormat: Format,
         presentationFormat: Format) throws {
        if components.count != 2 {
            throw ValueError.invalidDimension
        }

        self.originalComponents = components
        self.originalFormat = originalFormat
        self.presentationFormat = presentationFormat
    }

    convenience init(realValue: DoublePrecisionValue) {
        do {
            try self.init([realValue,
                           DoublePrecisionValue(0)],
                          originalFormat: .cartesian,
                          presentationFormat: .cartesian)
        } catch {
            fatalError("ComplexValue.init from real threw an exception. This should not happen")
        }
    }

    convenience init(_ real: Double, _ imaginary: Double,
                     presentationFormat: Format = .cartesian) {
        do {
            try self.init([DoublePrecisionValue(real),
                           DoublePrecisionValue(imaginary)],
                          originalFormat: .cartesian,
                          presentationFormat: presentationFormat)
        } catch {
            fatalError("ComplexValue init from doubles threw an exception. This should not happen")
        }
    }

    convenience init(absolute: Double, argument: Double,
                     presentationFormat: Format = .polar) {
        do {
            try self.init([DoublePrecisionValue(absolute),
                           DoublePrecisionValue(argument)],
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

            try self.init([DoublePrecisionValue(v.originalComponents[0],
                                                numberFormat: nf),
                           DoublePrecisionValue(v.originalComponents[1],
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

class DoublePrecisionValue: NSObject {
    private(set) var doubleValue: Double
    private(set) var originalStringValue: String
    private (set) var numberFormat: ValueNumberFormat

    var asComplex: ComplexValue {
        ComplexValue(realValue: self)
    }

    override var description: String {
        return "SingleDimensionalNumericalValue \(stringValue(precision: realDefaultPrecision))"
    }

    init(_ doubleValue: Double,
         numberFormat: ValueNumberFormat = .auto) {
        self.numberFormat = numberFormat
        self.doubleValue = doubleValue
        self.originalStringValue = ""
    }

    init(_ doubleValue: Double,
         _ originalStringValue: String,
         numberFormat: ValueNumberFormat = .fromInput) {
        self.numberFormat = numberFormat
        self.doubleValue = doubleValue
        self.originalStringValue = originalStringValue
    }

    init(_ v: DoublePrecisionValue,
         numberFormat: ValueNumberFormat) {
        self.numberFormat = numberFormat
        self.doubleValue = v.doubleValue
        self.originalStringValue = ""
    }

    func stringValue(precision: Int = realDefaultPrecision,
                     engDecimalPlaces: Int = realDefaultPrecision,
                     maxAutoDecimalFormat: Double = 1E7,
                     minAutoDecimalFormat: Double = 1E-4,
                     maxDecimalFormat: Double = 1E18,
                     minDecimalFormat: Double = 1E-4,
                     withSign: Bool = true) -> String {
        let absv = fabs(doubleValue)

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
            if absv >= maxDecimalFormat || absv < minDecimalFormat {
                return stringEngValue(precision: precision,
                                      engDecimalPlaces: engDecimalPlaces,
                                      withSign: withSign)
            } else {
                return stringDecimalValue(precision: precision,
                                          withSign: withSign)
            }
        case .eng:
            return stringEngValue(precision: precision,
                                  engDecimalPlaces: engDecimalPlaces,
                                  withSign: withSign)
        }
    }

    func stringDecimalValue(precision: Int, withSign: Bool) -> String {
        let v = withSign ? doubleValue : fabs(doubleValue)

        let dvParts = modf(v)
        if dvParts.1 == 0 {
            return String(format: "%.0f", dvParts.0)
        } else {
            let format = String(format: "%%.%dg", precision)
            return String(format: format, v)
        }
    }

    func stringEngValue(precision: Int, engDecimalPlaces: Int, withSign: Bool) -> String {
        let v = withSign ? doubleValue : fabs(doubleValue)

        let format = String(format: "%%%d.%de", precision, engDecimalPlaces)
        return String(format: format, v)
    }

    override func isEqual(_ to: (Any)?) -> Bool {
        guard let other = to as? DoublePrecisionValue else {
            return false
        }
        return abs(doubleValue.distance(to: other.doubleValue)) < epsilon
    }
}
