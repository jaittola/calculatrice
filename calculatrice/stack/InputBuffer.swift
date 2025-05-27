import Foundation

struct InputBufferValue {
    var numericalValue: NumericalValue
    var currentInput: String
}

class InputBuffer: ObservableObject {
    enum EmptyValueMode {
        case empty
        case zero
    }

    let emptyValueMode: EmptyValueMode

    var asContainedValue: ContainedValue {
        ContainedValue.number(value: value.numericalValue)
    }

    var isEmpty: Bool {
        value.currentInput.isEmpty ||
        (value.currentInput == "0" && emptyValueMode == .zero)
    }

    var isFull: Bool {
        value.currentInput.count >= 100
    }

    @Published
    private(set) var value: InputBufferValue

    init(emptyValueMode: EmptyValueMode = .empty) {
        let stringValue = Self.emptyValue(emptyValueMode)

        self.emptyValueMode = emptyValueMode
        self.value = InputBufferValue(numericalValue: NumericalValue(0, originalStringValue: stringValue),
                                      currentInput: stringValue)
    }

    func addNum(_ number: Int) {
        let nextInput = if value.currentInput == "0" {
            String(number)
        } else {
            value.currentInput + String(number)
        }
        parseInput(nextInput)
    }

    func dot() {
        if !isInputtingDecimals && !isInputtingExponent {
            parseInput(value.currentInput + ".")
        }
    }

    func E() {
        if !isInputtingExponent && !isEmpty {
            parseInput(value.currentInput + "E")
        }
    }

    func plusminus() {
        if isInputtingExponent {
            let parts = value.currentInput.split(separator: "E")
            guard parts.count == 2, parts[1].count > 0 else {
                return
            }

            let swappedSign = swapSign(String(parts[1]))
            let newValue = String(parts[0]) + "E" + swappedSign
            parseInput(newValue)
        } else {
            parseInput(swapSign(value.currentInput))
        }
    }

    @discardableResult
    func paste(_ text: String) -> Bool {
        parseInput(text)
    }

    func setValue(_ v: NumericalValue,
                  _ currentInput: String? = nil) {
        let stringValue = if let currentInput = currentInput {
            Self.emptyValue(emptyValueMode, currentInput)
        } else {
            v.stringValue()
        }
        value = InputBufferValue(numericalValue: v, currentInput: stringValue)
    }

    private func swapSign(_ input: String) -> String {
        var swappedSign = input
        if swappedSign.first == "-" {
            swappedSign.removeFirst()
        } else {
            swappedSign = "-" + swappedSign
        }
        return swappedSign
    }

    func backspace() {
        if !value.currentInput.isEmpty {
            var input = value.currentInput
            input.removeLast()
            parseInput(input)
        }
    }

    func clear() {
        setValue(NumericalValue(0), "")
    }

    @discardableResult
    private func parseInput(_ input: String) -> Bool {
        var cleanedInput = input
        cleanedInput.replace([",", "e"], with: [".", "E"])
        cleanedInput.replace(" ", with: "")

        while (cleanedInput.count > 1 && cleanedInput.last == ".") || cleanedInput.last == "E"
            || cleanedInput.last == "-"
        {
            cleanedInput.removeLast()
        }

        if cleanedInput.first == "+" {
            cleanedInput.removeFirst()
        }

        if cleanedInput.isEmpty {
            clear()
            return true
        }

        let withLeadingZero =
            switch cleanedInput {
            case let str where str.first == ".":
                "0" + str
            case let str where str.starts(with: "-."):
                "-0" + str.dropFirst()
            default:
                cleanedInput
            }

        guard let parsedValue = Double(withLeadingZero) else {
            return false
        }

        setValue(NumericalValue(parsedValue,
                                originalStringValue: Self.emptyValue(emptyValueMode, withLeadingZero)),
                 Self.emptyValue(emptyValueMode, input))

        return true
    }

    private var isInputtingDecimals: Bool {
        value.currentInput.firstIndex(of: Character(".")) != nil
    }

    private var isInputtingExponent: Bool {
        value.currentInput.firstIndex(of: Character("E")) != nil
    }

    private static func emptyValue(_ emptyValueMode: EmptyValueMode,
                                   _ value: String = "") -> String {
        if !value.isEmpty {
            value
        } else {
            switch emptyValueMode {
            case .zero:
                "0"
            case .empty:
                ""
            }
        }
    }
}
