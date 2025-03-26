import Foundation

class RationalValue: NSObject, Num {
    enum DisplayFormat {
        case mixed
        case fractionalOnly
    }

    let numerator: NumericalValue
    let denominator: NumericalValue

    let displayFormat: DisplayFormat
    let simplifyOnInitialisation: Bool

    var floatingPoint: Double {
        numerator.value / denominator.value
    }

    var asComplex: ComplexValue {
        ComplexValue(realValue: self)
    }

    var asNumericalValue: NumericalValue {
        NumericalValue(floatingPoint)
    }

    var asRational: RationalValue? { self }

    var wholePart: Double {
        modf(numerator.floatingPoint / denominator.floatingPoint).0
    }

    var fractionalPart: RationalValue {
        let whole = wholePart
        let absWhole = abs(whole)
        if absWhole < 1 {
            return self
        } else {
            let absn = abs(numerator.floatingPoint)
            let fractNumerator = (absn - absWhole * denominator.floatingPoint)
            return (try? RationalValue(fractNumerator,
                                       denominator.floatingPoint,
                                       displayFormat: displayFormat,
                                       simplifyOnInitialisation: simplifyOnInitialisation)) ?? self
        }
    }

    var simplified: RationalValue {
        (try? RationalValue(numerator: numerator,
                            denominator: denominator,
                            displayFormat: .mixed,
                            simplifyOnInitialisation: true)) ?? self
    }

    var fracOnly: RationalValue {
        (try? RationalValue(numerator: numerator,
                            denominator: denominator,
                            displayFormat: .fractionalOnly,
                            simplifyOnInitialisation: true)) ?? self
    }

    func stringValue(precision: Int = realDefaultPrecision,
                     withSign: Bool = true) -> String {
        let whole = wholePart
        if isWholeNumber {
            return numerator.stringValue(precision: precision, withSign: withSign)
        } else if whole == 0 || displayFormat == .fractionalOnly {
            let ns = numerator.stringValue(precision: precision, withSign: withSign)
            let dns = denominator.stringValue(precision: precision)
            return "\(ns)/\(dns)"
        } else {
            let frac = fractionalPart
            let ws = NumericalValue(whole,
                                    numberFormat: numerator.numberFormat)
                .stringValue(precision: precision, withSign: withSign)
            let fracStr = frac.stringValue(precision: precision)
            return "\(ws) \(fracStr)"
        }
    }

    init(numerator: Num,
         denominator: Num,
         displayFormat: DisplayFormat = .mixed,
         simplifyOnInitialisation: Bool = true) throws {
        guard denominator.floatingPoint != 0 else {
            throw CalcError.badInput()
        }

        let absNumerator = abs(numerator.floatingPoint)
        let absDenominator = abs(denominator.floatingPoint)

        let sign = numerator.floatingPoint < 0 || denominator.floatingPoint < 0 ? -1.0 : 1.0

        if modf(numerator.floatingPoint).1 != 0.0 ||
            modf(absDenominator).1 != 0.0 {
            throw CalcError.nonIntegerInputToRational()
        }

        if simplifyOnInitialisation {
            let (num, den) = try Utils.simplifyFractionComponents(absNumerator,
                                                                  absDenominator)
            self.numerator = NumericalValue(sign * num)
            self.denominator = NumericalValue(den)
        } else {
            self.numerator = NumericalValue(sign * absNumerator)
            self.denominator = NumericalValue(absDenominator)
        }
        self.displayFormat = displayFormat
        self.simplifyOnInitialisation = simplifyOnInitialisation
    }

    convenience init(_ numerator: Double,
                     _ denominator: Double,
                     displayFormat: DisplayFormat = .mixed,
                     simplifyOnInitialisation: Bool = true) throws {
        try self.init(numerator: NumericalValue(numerator),
                      denominator: NumericalValue(denominator),
                      simplifyOnInitialisation: simplifyOnInitialisation)
    }

    convenience init(whole: Num,
                     numerator: Num,
                     denominator: Num) throws {
        if modf(whole.floatingPoint).1 != 0.0 ||
            modf(numerator.floatingPoint).1 != 0.0 ||
            modf(denominator.floatingPoint).1 != 0.0 {
            throw CalcError.nonIntegerInputToRational()
        }

        let sign = whole.floatingPoint < 0.0 ? -1.0 : 1.0
        let fracNumerator = sign * (abs(whole.floatingPoint) * abs(denominator.floatingPoint) + abs(numerator.floatingPoint))

        let numberFormat = whole.asNumericalValue.numberFormat

        try self.init(numerator: NumericalValue(fracNumerator, numberFormat: numberFormat),
                      denominator: denominator,
                      simplifyOnInitialisation: false)
    }

    func duplicateForStack() -> RationalValue {
        self.simplified
    }

    var isWholeNumber: Bool {
        denominator.floatingPoint == 1.0
    }

    override var description: String {
        return "RationalValue (\(stringValue(precision: realDefaultPrecision)))"
    }

    override func isEqual(_ to: Any?) -> Bool {
        if let other = to as? RationalValue {
            let selfSimplified = self.simplified
            let otherSimplified = other.simplified

            return selfSimplified.numerator == otherSimplified.numerator &&
            selfSimplified.denominator == otherSimplified.denominator
        } else if let other = to as? Num {
            return asNumericalValue.isEqual(other)
        } else {
            return false
        }
    }

    static func == (lhs: RationalValue, rhs: RationalValue) -> Bool {
        return lhs.isEqual(rhs)
    }
}
