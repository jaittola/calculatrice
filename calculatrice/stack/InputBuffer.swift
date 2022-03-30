import Foundation

class InputBuffer {
    var value: StackValue {
        buildValue()
    }

    var isEmpty: Bool {
        inputs.isEmpty
    }

    var isFull: Bool {
        inputs.count >= 12
    }

    private var inputs: [InputElement] = []
    private var signum: Double = 1.0

    func addNum(_ number: Int) {
        if (number != 0 || inputs.isEmpty || value.doubleValue != 0 || isInputtingDecimals) && !isFull {
            inputs.append(.Number(number))
        }
    }

    func paste(_ text: String) {
        text.forEach { c in
            if c == "." || c == "," {
                dot()
            } else if c.isNumber, let intv = Int(String(c)) {
                addNum(intv)
            }
        }
    }

    func dot() {
        if !isInputtingDecimals {
            inputs.append(.Dot)
        }
    }

    func plusminus() {
        if signum < 0 {
            signum = 1.0
        } else {
            signum = -1.0
        }
    }

    func backspace() {
        if !inputs.isEmpty {
            inputs.removeLast()
        }
    }

    private func buildValue() -> InputBufferStackValue {
        return InputBufferStackValue(id: 0,
                                     doubleValue: doubleValue,
                                     stringValue: stringValue)
    }

    private var isInputtingDecimals: Bool {
        inputs.contains(where: { ie in
            if case .Dot = ie {
                return true
            } else {
                return false
            }
        })
    }

    private var doubleValue: Double {
        var inputState: InputState = .Whole()
        return signum * inputs.reduce(0.0) { (_ acc: Double, _ input: InputElement) in
            switch input {
            case .Dot:
                if case .Whole = inputState {
                    inputState = .Decimal()
                }
                return acc
            case .Number(let num):
                switch inputState {
                case .Whole(let coeff):
                    return coeff * acc + Double(num)
                case .Decimal(let coeff):
                    let result = acc + coeff * Double(num)
                    inputState = .Decimal(coeff * 0.1)
                    return result
                }
            }
        }
    }

    private var stringValue: String {
        var startValue = signum > 0 ? "" : "-"
        if inputs.count == 0 {
            startValue.append("0")
        } else if case .Dot = inputs[0] {
            startValue.append("0")
        }
        return inputs.reduce(startValue) { (buffer, input) in
            var b = buffer
            switch input {
            case .Dot:
                b.append(".")
            case .Number(let n):
                b.append(String(n))
            }
            return b
        }
    }

    private enum InputElement {
        case Number(_ number: Int)
        case Dot
    }

    private enum InputState {
        case Whole(_ coeff: Double = 10.0)
        case Decimal(_ coeff: Double = 0.1)
    }
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
