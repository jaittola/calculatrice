import Foundation

private let epsilon = 0.0001 // Mostly for tests, where we use the equality operator.

enum ContainedValue {
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
            return c.stringValue(precision: 8, angleUnit: calculatorMode.angle)
        case .number(let n):
            return n.stringValue(precision: 12)
        }
    }
}

class Value {
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

    convenience init(_ value: DoublePrecisionValue, id: Int = 0) {
        self.init(ContainedValue.number(value: value), id: id)
    }

    convenience init(_ value: ComplexValue, id: Int = 0) {
        self.init(ContainedValue.complex(value: value), id: id)
    }

    func withId(_ newId: Int) -> Value {
        return Value(containedValue, id: newId)
    }

    func stringValue(_ calculatorMode: CalculatorMode) -> String {
        containedValue.stringValue(calculatorMode)
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

    var cartesian: [DoublePrecisionValue] {
        originalComponents  // TODO!!
    }

    var asReal: DoublePrecisionValue? {
        cartesian[1].doubleValue == 0 ? cartesian[0] : nil
    }

    func stringValue(precision: Int = 5) -> String {
        let cart = cartesian
        let realPart = cart[0].doubleValue != 0 ? cart[0].stringValue(precision: precision) : ""
        let plusminus = cart[1].doubleValue > 0 && cart[0].doubleValue != 0 ? "+" : ""
        var imaginaryPart = ""
        switch cartesian[1].doubleValue {
        case 1:
            imaginaryPart = "i"
        case -1:
            imaginaryPart = "-i"
        case 0:
            imaginaryPart = ""
        default:
            imaginaryPart = "\(cartesian[1].stringValue(precision: precision))i"
        }
        return "\(realPart)\(plusminus)\(imaginaryPart)"
    }

    override var description: String {
        return "ComplexValue (\(stringValue(precision: 8))"
    }

    init(_ components: [DoublePrecisionValue],
         originalFormat: Format) throws {
        if components.count != 2 {
            throw ValueError.invalidDimension
        }

        self.originalComponents = components
        self.originalFormat = originalFormat
    }

    convenience init(realValue: DoublePrecisionValue) {
        do {
            try self.init([realValue,
                           DoublePrecisionValue(0)],
                          originalFormat: .cartesian)
        } catch {
            fatalError("ComplexValue.init from real threw an exception. This should not happen")
        }
    }

    convenience init(_ real: Double, _ imaginary: Double) {
        do {
            try self.init([DoublePrecisionValue(real),
                           DoublePrecisionValue(imaginary)],
                          originalFormat: .cartesian)
        } catch {
            fatalError("ComplexValue init from doubles threw an exception. This should not happen")
        }
    }

    convenience init(_ v: ComplexValue, numberFormat: ValueNumberFormat) {
        do {
            try self.init([DoublePrecisionValue(v.originalComponents[0],
                                                numberFormat: numberFormat),
                           DoublePrecisionValue(v.originalComponents[1],
                                               numberFormat: numberFormat)],
                          originalFormat: v.originalFormat)
        } catch {
            fatalError("ComplexValue init from another complex value threw an exception. This should not happen")
        }
    }

    override func isEqual(_ to: Any?) -> Bool {
        print("Complex Equals")
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
        print("Complex ==")
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
        return "SingleDimensionalNumericalValue \(stringValue())"
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

    func stringValue(precision: Int = 9) -> String {
        switch numberFormat {
        case .fromInput:
            return originalStringValue
        case .auto:
            if doubleValue >= 1000000 || fabs(doubleValue) < 0.001 {
                return stringEngValue(precision: precision)
            } else {
                return stringDecimalValue(precision: precision)
            }
        case .decimal:
            if doubleValue >= 1E9 || fabs(doubleValue) < 1E-9 {
                return stringEngValue(precision: precision)
            } else {
                return stringDecimalValue(precision: precision)
            }
        case .eng:
            return stringEngValue(precision: precision)
        }
    }

    func stringDecimalValue(precision: Int) -> String {
        let dvParts = modf(doubleValue)
        if dvParts.1 == 0 {
            return String(format: "%.0f", dvParts.0)
        } else {
            let format = String(format: "%%.%dg", precision)
            return String(format: format, doubleValue)
        }
    }

    func stringEngValue(precision: Int) -> String {
        let format = String(format: "%%%dE", precision)
        return String(format: format, doubleValue)
    }

    override func isEqual(_ to: (Any)?) -> Bool {
        guard let other = to as? DoublePrecisionValue else {
            return false
        }
        return abs(doubleValue.distance(to: other.doubleValue)) < epsilon
    }
}
