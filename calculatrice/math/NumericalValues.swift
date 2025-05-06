import Foundation

public let realDefaultPrecision = 7

enum ContainedValue: Equatable {
    case number(value: NumericalValue)
    case complex(value: ComplexValue)
    case rational(value: RationalValue)
    case matrix(value: MatrixValue)

    var asNumericalValue: NumericalValue? {
        switch self {
        case .complex(let c):
            return c.asReal?.asNumericalValue
        case .number(let n):
            return n
        case .rational(let r):
            return r.asNumericalValue
        case .matrix:
            return nil
        }
    }

    var asComplex: ComplexValue? {
        switch self {
        case .complex(let c):
            return c
        case .number(let n):
            return n.asComplex
        case .rational(let r):
            return r.asComplex
        case .matrix:
            return nil
        }
    }

    var asNum: Num? {
        switch self {
        case .complex(let c):
            return c.asReal
        case .number(let n):
            return n
        case .rational(let r):
            return r
        case .matrix:
            return nil
        }
    }

    var asRational: RationalValue? {
        switch self {
        case .complex:
            return nil
        case .number(let n):
            return n.asRational
        case .rational(let r):
            return r
        case .matrix:
            return nil
        }
    }

    var asMatrix: MatrixValue? {
        switch self {
        case .matrix(let m):
            return m
        default:
            return nil
        }
    }

    func stringValue(_ calculatorMode: CalculatorMode) -> String {
        switch self {
        case .complex(let c):
            return c.stringValue(precision: realDefaultPrecision,
                                 angleUnit: calculatorMode.angle)
        case .number(let n):
            return n.stringValue(precision: realDefaultPrecision)

        case .rational(let r):
            return r.stringValue(precision: realDefaultPrecision)

        case .matrix(let m):
            return m.stringValue(precision: realDefaultPrecision)
        }
    }

    func duplicateForStack() -> ContainedValue {
        switch self {
        case .complex(let c):
            return ContainedValue.complex(value: c.duplicateForStack()) // TODO
        case .number:
            return self
        case .rational(let r):
            return ContainedValue.rational(value: r.duplicateForStack())
        case .matrix(let m):
            return ContainedValue.matrix(value: m.duplicateForStack())
        }
    }
}

struct Value: Identifiable, Equatable {
    let containedValue: ContainedValue
    let id: Int

    var asNumericalValue: NumericalValue? {
        containedValue.asNum?.asNumericalValue
    }

    var asComplex: ComplexValue? {
        containedValue.asComplex
    }

    var asNum: Num? {
        containedValue.asNum
    }

    var asRational: RationalValue? {
        containedValue.asRational
    }

    var asMatrix: MatrixValue? {
        containedValue.asMatrix
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

    init(_ value: RationalValue, id: Int = 0) {
        self.init(ContainedValue.rational(value: value), id: id)
    }

    init(_ value: MatrixValue, id: Int = 0) {
        self.init(ContainedValue.matrix(value: value), id: id)
    }

    func withId(_ newId: Int) -> Value {
        return Value(containedValue, id: newId)
    }

    func duplicateForStack() -> Value {
        return Value(containedValue.duplicateForStack(), id: id)
    }

    func stringValue(_ calculatorMode: CalculatorMode) -> String {
        containedValue.stringValue(calculatorMode)
    }

    static func == (lhs: Value, rhs: Value) -> Bool {
        lhs.id == rhs.id
    }
}

protocol MatrixCalcValue { }

protocol MatrixElement: MatrixCalcValue {
    var asComplex: ComplexValue { get }
    func stringValue(precision: Int, calculatorMode: CalculatorMode) -> String
    func isEqual(_ to: (Any)?) -> Bool
}

protocol Num: MatrixElement {
    var floatingPoint: Double { get }
    var asComplex: ComplexValue { get }
    var asRational: RationalValue? { get }
    var asNumericalValue: NumericalValue { get }
    var withDefaultPresentation: any Num { get }
    var isWholeNumber: Bool { get }
    var description: String { get }
    func withFloatingPointNumberFormat(_ format: ValueNumberFormat) -> Num
    func stringValue(precision: Int, withSign: Bool) -> String
    func isEqual(_ to: Any?) -> Bool
}

class NumericalValue: NSObject, Num, MatrixElement {
    private(set) var value: Double
    private(set) var originalStringValue: String
    private(set) var numberFormat: ValueNumberFormat

    var floatingPoint: Double {
        value
    }

    var asComplex: ComplexValue {
        ComplexValue(realValue: self)
    }

    var asRational: RationalValue? {
        isWholeNumber ? try? RationalValue(value, 1) : nil
    }

    var asNumericalValue: NumericalValue {
        self
    }

    var withDefaultPresentation: any Num {
        return NumericalValue(value)
    }

    var isWholeNumber: Bool {
        modf(value).1 == 0.0
    }

    override var description: String {
        return "SingleDimensionalNumericalValue \(stringValue(precision: realDefaultPrecision))"
    }

    init(_ doubleValue: Double,
         originalStringValue: String? = nil,
         numberFormat: ValueNumberFormat? = nil) {
        self.value = doubleValue
        self.numberFormat = numberFormat ??
            (originalStringValue != nil ? .fromInput : .auto)
        self.originalStringValue = originalStringValue ?? ""
    }

    func stringValue(precision: Int = realDefaultPrecision,
                     engDecimalPlaces: Int = realDefaultPrecision,
                     maxAutoDecimalFormat: Double = 1E7,
                     minAutoDecimalFormat: Double = 1E-4,
                     withSign: Bool = true) -> String {
        let absv = abs(value)
        let format: ValueNumberFormat = numberFormat == .fromInput && !withSign ? .auto : numberFormat

        switch format {
        case .fromInput:
            return originalStringValue
        case .auto:
            if absv != 0 && (absv >= maxAutoDecimalFormat || absv < minAutoDecimalFormat) {
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

    func stringValue(precision: Int, calculatorMode: CalculatorMode) -> String {
        return self.stringValue(precision: precision, withSign: true)
    }

    func withFloatingPointNumberFormat(_ format: ValueNumberFormat) -> Num {
        NumericalValue(floatingPoint, numberFormat: format)
    }

    func stringValue(precision: Int, withSign: Bool) -> String {
        stringValue(precision: precision, engDecimalPlaces: precision, withSign: withSign)
    }

    func stringDecimalValue(precision: Int, withSign: Bool) -> String {
        let v = withSign ? floatingPoint : fabs(floatingPoint)
        if v.isInfinite {
            return Self.infFormatted
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

    func stringEngValue(precision: Int, engDecimalPlaces: Int, withSign: Bool) -> String {
        let v = withSign ? floatingPoint : fabs(floatingPoint)
        if v.isInfinite {
            return Self.infFormatted
        }

        if floatingPoint == 0 {
            return "0"
        }

        let style = FloatingPointFormatStyle<Double>(locale: Locale(identifier: "en_US"))
            .notation(.scientific)
            .sign(strategy: withSign ? .automatic : .never)

        return floatingPoint.formatted(style)
    }

    override func isEqual(_ to: (Any)?) -> Bool {
        guard let other = to as? Num ??
                (to as? ComplexValue)?.asReal else {
            return false
        }
        return abs(floatingPoint.distance(to: other.floatingPoint)) < NumericalValue.epsilon
    }

    static let pi = NumericalValue(Double.pi)

    static let epsilon = 0.0001 // Mostly for tests, where we use the equality operator.
    static var epsilond: Double { epsilon }

    static let infFormatted = "Inf"
}
