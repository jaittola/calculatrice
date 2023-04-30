import Foundation

protocol DoublePrecisionValue {
    var id: Int { get }
    var doubleValue: Double { get }
    var stringValue: String { get }

    func withId(_ newId: Int) -> DoublePrecisionValue
}

class SingleDimensionalNumericalValue: DoublePrecisionValue {
    let id: Int
    private(set) var doubleValue: Double
    private(set) var originalStringValue: String
    private (set) var numberFormat: ValueNumberFormat
    var stringValue: String {
        switch numberFormat {
        case .fromInput:
            return originalStringValue
        case .auto:
            if doubleValue >= 1000000 || fabs(doubleValue) < 0.001 {
                return stringEngValue
            } else {
                return stringDecimalValue
            }
        case .decimal:
            if doubleValue >= 1E9 || fabs(doubleValue) < 1E-9 {
                return stringEngValue
            } else {
                return stringDecimalValue
            }
        case .eng:
            return stringEngValue
        }
    }

    init(_ doubleValue: Double,
         id: Int = 0,
         numberFormat: ValueNumberFormat = .auto) {
        self.id = id
        self.numberFormat = numberFormat
        self.doubleValue = doubleValue
        self.originalStringValue = ""
    }

    init(_ doubleValue: Double,
         _ originalStringValue: String,
         id: Int = 0,
         numberFormat: ValueNumberFormat = .fromInput) {
        self.id = id
        self.numberFormat = numberFormat
        self.doubleValue = doubleValue
        self.originalStringValue = originalStringValue
    }

    var stringDecimalValue: String {
        let dvParts = modf(doubleValue)
        return dvParts.1 == 0 ? String(format: "%.0f", dvParts.0) : "\(doubleValue)"
    }

    var stringEngValue: String {
        return String(format: "%9E", doubleValue)
    }

    func withId(_ newId: Int) -> DoublePrecisionValue {
        SingleDimensionalNumericalValue(doubleValue,
                                        originalStringValue,
                                        id: newId,
                                        numberFormat: numberFormat)
    }
}
