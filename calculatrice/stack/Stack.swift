import Foundation

class Stack {
    private(set) var content: [DoublePrecisionValue] = []
    private(set) var input = InputBuffer()

    private var uniqueIdSeq: Int = 0

    var selectedId: Int = -1

    func push(_ value: DoublePrecisionValue) {
        content.insert(value.withId(uniqueIdSeq), at: 0)
        uniqueIdSeq += 1
    }

    func pushInput() {
        if !input.isEmpty {
            push(input.value)
            clearInput()
        } else if !content.isEmpty {
            push(content[0])
        }
    }

    func clearInput() {
        input = InputBuffer()
    }

    func pop() {
        if !content.isEmpty {
            content.removeFirst()
        }
    }

    func clear() {
        if !content.isEmpty {
            content.removeAll()
        }
        clearInput()
    }

    func pickSelected() {
        if let selected = content.first(where: { v in v.id == selectedId }) {
            push(selected)
        }
    }

    func swapTop2() {
        if content.count < 2 {
            return
        }

        let top = content.removeFirst()
        let second = content.removeFirst()

        push(top)
        push(second)
    }

    private func getForCalc(n: Int = 1) -> [DoublePrecisionValue]? {
        var result: [DoublePrecisionValue] = []

        if n <= 0 {
            return nil
        }

        var count = n
        if !input.isEmpty {
            result.insert(input.value, at: 0)
            count -= 1
        }

        if count > content.count {
            return nil
        }

        while count > 0 {
            result.insert(content.removeFirst(), at: 0)
            count -= 1
        }

        clearInput()

        return result
    }

    func calculate(_ calc: Calculation,
                   _ calculatorMode: CalculatorMode) throws {
        guard let inputs = getForCalc(n: calc.arity) else {
            return
        }

        do {
            let result = try calc.calculate(inputs,
                                            calculatorMode)
            push(result)
        } catch {
            throw error
        }
    }

    func printContents() {
        print("Input Buffer: string = \(input.value.stringValue) double = \(input.value.doubleValue)")
        print("STACK: ")
        content.enumerated().forEach { idx, value in
            print("  \(idx): string = \(value.stringValue) double =  \(value.doubleValue) ")
        }
    }
}

protocol Calculation {
    var arity: Int { get }

    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue
}

enum CalcError: Error {
    case divisionByZero
    case badInput
}

enum ValueNumberFormat {
    case auto
    case decimal
    case eng
}
