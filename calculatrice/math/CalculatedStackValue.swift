import Foundation

class CalculatedStackValue: NSObject, StackValue {
    let id: Int
    private(set) var doubleValue: Double
    var stringValue: String {
        let dvParts = modf(doubleValue)
        if doubleValue >= 1000000 || fabs(doubleValue) < 0.001 {
            return String(format: "%9E", doubleValue)
        } else if dvParts.1 == 0 {
            return String(format: "%.0f", dvParts.0)
        } else {
            return "\(doubleValue)"
        }
    }

    init(_ doubleValue: Double, id: Int = 0) {
        self.id = id
        self.doubleValue = doubleValue
        super.init()
    }

    func withId(_ newId: Int) -> StackValue {
        CalculatedStackValue(doubleValue, id: newId)
    }
}
