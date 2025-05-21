import Foundation

class InputBuffer: ObservableObject {
    var value: ContainedValue {
        ContainedValue.number(
            value:
                NumericalValue(
                    doubleValue,
                    originalStringValue: cleanedStringValue))
    }

    var isEmpty: Bool {
        stringValue.isEmpty || stringValue == "0"
    }

    var isFull: Bool {
        stringValue.count >= 100
    }

    @Published
    private(set) var stringValue: String = ""

    @Published
    private(set) var cleanedStringValue: String = ""

    @Published
    private(set) var doubleValue: Double = 0

    func addNum(_ number: Int) {
        let nextInput = if stringValue == "0" {
            String(number)
        } else {
            stringValue + String(number)
        }
        parseInput(nextInput)
    }

    func dot() {
        if !isInputtingDecimals && !isInputtingExponent {
            parseInput(stringValue + ".")
        }
    }

    func E() {
        if !isInputtingExponent && !isEmpty {
            parseInput(stringValue + "E")
        }
    }

    func plusminus() {
        if isInputtingExponent {
            let parts = stringValue.split(separator: "E")
            guard parts.count == 2, parts[1].count > 0 else {
                return
            }

            let swappedSign = swapSign(String(parts[1]))
            let newValue = String(parts[0]) + "E" + swappedSign
            parseInput(newValue)
        } else {
            parseInput(swapSign(stringValue))
        }
    }

    @discardableResult
    func paste(_ text: String) -> Bool {
        parseInput(text)
    }

    func setValue(_ v: NumericalValue) {
        doubleValue = v.value
        stringValue = v.stringValue()
        cleanedStringValue = stringValue
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
        if !stringValue.isEmpty {
            var input = stringValue
            input.removeLast()
            parseInput(input)
        }
    }

    func clear() {
        doubleValue = 0
        stringValue = ""
        cleanedStringValue = ""
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
            return false
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

        doubleValue = parsedValue
        stringValue = input
        cleanedStringValue = withLeadingZero

        return true
    }

    private var isInputtingDecimals: Bool {
        stringValue.firstIndex(of: Character(".")) != nil
    }

    private var isInputtingExponent: Bool {
        stringValue.firstIndex(of: Character("E")) != nil
    }
}
