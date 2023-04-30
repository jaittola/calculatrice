import Foundation

protocol StackValue {
    var id: Int { get }
    var doubleValue: Double { get }
    var stringValue: String { get }

    func withId(_ newId: Int) -> StackValue
}

class InputBufferStackValue: NSObject, StackValue {
    let id: Int
    let doubleValue: Double
    let stringValue: String

    init( id: Int,
          doubleValue: Double,
          stringValue: String) {
        self.id = id
        self.doubleValue = doubleValue
        self.stringValue = stringValue
        super.init()
    }

    func withId(_ newId: Int) -> StackValue {
        InputBufferStackValue(id: newId,
                              doubleValue: doubleValue,
                              stringValue: stringValue)
    }
}

class CalculatedStackValue: StackValue {
    let id: Int
    private(set) var doubleValue: Double
    private (set) var numberFormat: ValueNumberFormat
    var stringValue: String {
        switch numberFormat {
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
    }

    var stringDecimalValue: String {
        let dvParts = modf(doubleValue)
        return dvParts.1 == 0 ? String(format: "%.0f", dvParts.0) : "\(doubleValue)"
    }

    var stringEngValue: String {
        return String(format: "%9E", doubleValue)
    }

    func withId(_ newId: Int) -> StackValue {
        CalculatedStackValue(doubleValue, id: newId, numberFormat: numberFormat)
    }
}
