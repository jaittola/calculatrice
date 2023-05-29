import Foundation

class StackContainer {
    private var stackHistory: [[Value]] = []
    private var stackContent: [Value] = []

    var content: [Value] {
        stackContent
    }

    func manipulate(manipulator: (_ stackContent: [Value]) -> [Value]) {
        pushStackHistory()
        stackContent = manipulator(stackContent)
    }

    func revertPreviousStack() {
        if stackHistory.isEmpty {
            return
        }

        stackContent = stackHistory.removeLast()
    }

    func clear() {
        manipulate { _ in [] }
    }

    private func pushStackHistory() {
        if stackHistory.count >= 100 {
            stackHistory.removeFirst()
        }
        stackHistory.append(stackContent)
    }
}

class Stack {
    private let stackContainer = StackContainer()
    private(set) var input = InputBuffer()

    private var uniqueIdSeq: Int = 0

    var selectedId: Int = -1

    var content: [Value] {
        stackContainer.content
    }

    func push(_ value: Value) {
        stackContainer.manipulate { content in
            var newStack = content
            newStack.insert(value.withId(uniqueIdSeq), at: 0)
            return newStack
        }
        uniqueIdSeq += 1
    }

    func push(_ v: any Valueish) {
        if let d = v as? DoublePrecisionValue {
            push(Value(d))
        } else if let c = v as? ComplexValue {
            push(Value(c))
        }
    }

    func pushInput() {
        if !input.isEmpty {
            push(Value(input.value))
            clearInput()
        } else if !content.isEmpty {
            push(content[0])
        }
    }

    func clearInput() {
        input = InputBuffer()
    }

    func pop() {
        stackContainer.manipulate { content in
            if !content.isEmpty {
                var newStack = content
                newStack.removeFirst()
                return newStack
            } else {
                return content
            }
        }
    }

    func clear() {
        stackContainer.clear()
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

        var top: Value?
        var second: Value?

        stackContainer.manipulate { content in
            var newStack = content

            top = newStack.removeFirst()
            second = newStack.removeFirst()

            return newStack
        }

        push(top!)
        push(second!)
    }

    private func getForCalc(n: Int = 1) -> [Value]? {
        var result: [Value] = []

        if n <= 0 ||
            (input.isEmpty && n > content.count) ||
            (!input.isEmpty && n > content.count + 1) {
            return nil
        }

        var count = n
        if !input.isEmpty {
            result.insert(Value(input.value), at: 0)
            count -= 1
        }

        stackContainer.manipulate { content in
            var newStack = content

            while count > 0 {
                result.insert(newStack.removeFirst(), at: 0)
                count -= 1
            }

            return newStack
        }

        clearInput()

        return result
    }

    func calculate(_ calc: Calculation,
                   _ calculatorMode: CalculatorMode) throws {
        guard let inputs = getForCalc(n: calc.arity) else {
            return
        }

        let inputsAsReal = inputs.compactMap { n in n.asReal }
        let allInputsReal = inputsAsReal.count == inputs.count

        let realCalc = calc as? RealCalculation
        let complexCalc = calc as? ComplexCalculation

        let preferComplexCalc = (allInputsReal &&
                                 (complexCalc?.preferComplexCalculationWith(thisInput: inputsAsReal) ??
                                 false))

        do {
            if let realCalc = realCalc,
                allInputsReal,
               !preferComplexCalc {
                let result = try realCalc.calculate(inputsAsReal, calculatorMode)
                push(result)
            } else if let complexCalc = complexCalc {
                let complexInputs = inputs.map { v in v.asComplex }
                let result = try complexCalc.calcComplex(complexInputs, calculatorMode)
                push(result)
            } else {
                throw CalcError.badCalculationOp
            }
        } catch {
            stackContainer.revertPreviousStack()
            throw error
        }
    }

    func printContents(_ calculatorMode: CalculatorMode) {
        print("Input Buffer: string = \(input.value.stringValue(precision: 8)) double = \(input.value.doubleValue)")
        print("STACK: ")
        content.enumerated().forEach { idx, value in
            print("  \(idx): string = \(value.stringValue(calculatorMode.angle))")
        }
    }
}

protocol Calculation {
    var arity: Int { get }
}

protocol RealCalculation {
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) throws -> any Valueish
}

protocol ComplexCalculation {
    func preferComplexCalculationWith(thisInput: [DoublePrecisionValue]) -> Bool
    func calcComplex(_ inputs: [ComplexValue],
                     _ calculatorMode: CalculatorMode) throws -> any Valueish
}

extension ComplexCalculation {
    func preferComplexCalculationWith(thisInput: [DoublePrecisionValue]) -> Bool {
        false
    }
}

enum CalcError: Error {
    case divisionByZero
    case badInput
    case unsupportedValueType
    case badCalculationOp
}

enum ValueNumberFormat {
    case fromInput
    case auto
    case decimal
    case eng
}
