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

    var doubleValue: Double {
        numerator.value / denominator.value
    }

    var asComplex: ComplexValue {
        ComplexValue(realValue: NumericalValue(doubleValue))
    }

    var asRational: RationalValue? { self }

    var wholePart: Double {
        modf(numerator.doubleValue / denominator.doubleValue).0
    }

    var fractionalPart: RationalValue {
        let whole = wholePart
        let absWhole = abs(whole)
        if absWhole < 1 {
            return self
        } else {
            let absn = abs(numerator.doubleValue)
            let fractNumerator = (absn - absWhole * denominator.doubleValue)
            return (try? RationalValue(fractNumerator,
                                       denominator.doubleValue,
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

    init(numerator: NumericalValue,
         denominator: NumericalValue,
         displayFormat: DisplayFormat = .mixed,
         simplifyOnInitialisation: Bool = true) throws {
        guard denominator.doubleValue != 0 else {
            throw CalcError.badInput()
        }

        let absNumerator = abs(numerator.doubleValue)
        let absDenominator = abs(denominator.doubleValue)

        let sign = numerator.doubleValue < 0 || denominator.doubleValue < 0 ? -1.0 : 1.0

        if modf(numerator.doubleValue).1 != 0.0 ||
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

    convenience init(whole: NumericalValue,
                     numerator: NumericalValue,
                     denominator: NumericalValue) throws {
        let sign = whole.doubleValue < 0.0 ? -1.0 : 1.0
        let fracNumerator = sign * (abs(whole.doubleValue) * abs(denominator.doubleValue) + abs(numerator.doubleValue))
        try self.init(numerator: NumericalValue(fracNumerator, numberFormat: whole.numberFormat),
                      denominator: denominator,
                      simplifyOnInitialisation: false)
    }

    func duplicateForStack() -> RationalValue {
        self.simplified
    }

    var isWholeNumber: Bool {
        denominator.doubleValue == 1.0
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
            return NumericalValue(doubleValue).isEqual(other)
        } else {
            return false
        }
    }

    static func == (lhs: RationalValue, rhs: RationalValue) -> Bool {
        return lhs.isEqual(rhs)
    }
}
