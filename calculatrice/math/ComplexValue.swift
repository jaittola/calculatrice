import Foundation

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
            let re = polarAbsolute.value * cos(polarArgument.value)
            let imag = polarAbsolute.value * sin(polarArgument.value)
            return [NumericalValue(re), NumericalValue(imag)]
        }
    }

    var real: NumericalValue { cartesian[0] }
    var imag: NumericalValue { cartesian[1] }

    var polarAbsolute: NumericalValue {
        switch originalFormat {
        case .cartesian:
            let r = sqrt(pow(real.floatingPoint, 2) + pow(imag.floatingPoint, 2))
            return NumericalValue(r)
        case .polar:
            return originalComponents[0]
        }
    }

    var polarArgument: NumericalValue {
        switch originalFormat {
        case .cartesian:
            let x = real.floatingPoint
            let y = imag.floatingPoint

            // Based on https://en.wikipedia.org/wiki/Complex_number#Modulus_and_argument,
            // referred on May 1st 2023.
            if y == 0 && x == 0 {
                return NumericalValue(Double.nan)
            } else if x < 0 && y == 0 {
                return NumericalValue(Double.pi)
            } else { // y != 0 || x > 0 {
                let arg = 2 * atan(imag.floatingPoint / (polarAbsolute.floatingPoint + real.floatingPoint))
                return NumericalValue(arg)
            }
        case .polar:
            return originalComponents[1]
        }
    }

    var asReal: NumericalValue? {
        cartesian[1].floatingPoint == 0 ? cartesian[0] : nil
    }

    var isNan: Bool {
        originalComponents[0].floatingPoint.isNaN ||
        originalComponents[1].floatingPoint.isNaN
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

        if cart[0].floatingPoint == 0 && cart[1].floatingPoint == 0 {
            return "0"
        }

        let realPart = (cart[0].floatingPoint != 0 ?
                        cart[0].stringValue(precision: precision)
                        : "")
        var plusminus = ""
        var imaginaryPart = ""

        switch cartesian[1].floatingPoint {
        case 1:
            imaginaryPart = "i"
            plusminus = (cart[0].floatingPoint != 0 ? " + " : "")
        case -1:
            imaginaryPart = "i"
            plusminus = cart[0].floatingPoint != 0 ? " - " : "-"
        case 0:
            plusminus = ""
            imaginaryPart = ""
        default:
            let withSign: Bool
            if cart[0].floatingPoint != 0 {
                plusminus = cart[1].floatingPoint > 0 ? " + " : " - "
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

        if polarAbs.floatingPoint == 0 {
            return "0"
        }

        let absPart = polarAbs.stringValue(precision: precision)
        let argPart: String
        let angleUnitS: String

        switch angleUnit {
        case .Deg:
            let argDeg = NumericalValue(polarArg.floatingPoint * 180.0 / Double.pi)
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
            throw CalcError.invalidComplexDimension()
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

