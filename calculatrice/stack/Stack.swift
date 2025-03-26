import Foundation

class Stack: ObservableObject {
    private var stackHistory: [[Value]] = [[]]

    private var stackHistoryPointer: Int =  0

    private var uniqueIdSeq: Int = 0

    private var nextId: Int {
        let current = uniqueIdSeq
        uniqueIdSeq += 1
        return current
    }

    let input = InputBuffer()

    @Published
    var content: [Value] = []

    @Published
    var selectedId: Int = -1

    func push(_ value: Value) {
        manipulateStack { content in
            var newStack = content
            newStack.insert(value.withId(nextId), at: 0)
            return newStack
        }
    }

    func pushInput() {
        if !input.isEmpty {
            push(Value(input.value))
            clearInput()
        } else if !content.isEmpty {
            push(content[0].duplicateForStack())
        }
    }

    func clearInput() {
        input.clear()
    }

    func pop() {
        manipulateStack { content in
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
        manipulateStack { _ in [] }
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

        manipulateStack { content in
            var newStack = content

            top = newStack.removeFirst()
            second = newStack.removeFirst()

            newStack.insert(top!.withId(nextId), at: 0)
            newStack.insert(second!.withId(nextId), at: 0)

            return newStack
        }
    }

    func undo() {
        if stackHistoryPointer > 0 {
            stackHistoryPointer -= 1
        }

        content = stackHistory[stackHistoryPointer]
    }

    func redo() {
        stackHistoryPointer = min(stackHistoryPointer + 1, stackHistory.count - 1)
        content = stackHistory[stackHistoryPointer]
    }

    private func manipulateStack(manipulator: (_ stackContent: [Value]) -> [Value]?) {
        if let newContent = manipulator(content) {
            content = newContent
            pushStackHistory()
        }
    }

    private func revertPreviousStack() {
        if stackHistory.isEmpty {
            return
        }

        content = stackHistory.removeLast()
        stackHistoryPointer = stackHistory.count - 1
    }

    private func pushStackHistory() {
        if !stackHistory.isEmpty && stackHistoryPointer != stackHistory.count - 1 {
            stackHistory = Array(stackHistory[...stackHistoryPointer])
        } else if stackHistory.count >= 100 {
            stackHistory.removeFirst()
        }

        stackHistory.append(content)
        stackHistoryPointer = stackHistory.count - 1
    }

    private func getForCalc(n: Int = 1) -> (calcInputs: [Value], nextStack: [Value])? {

        if n <= 0 ||
            (input.isEmpty && n > content.count) ||
            (!input.isEmpty && n > content.count + 1) {
            return nil
        }

        var calcInputs: [Value] = []

        var count = n
        if !input.isEmpty {
            calcInputs.insert(Value(input.value), at: 0)
            count -= 1
        }

        var nextStack = content

        while count > 0 {
            calcInputs.insert(nextStack.removeFirst(), at: 0)
            count -= 1
        }

        clearInput()

        return (calcInputs: calcInputs, nextStack: nextStack)
    }

    func calculate(_ calc: Calculation,
                   _ calculatorMode: CalculatorMode) throws {
        guard let calcParams = getForCalc(n: calc.arity) else {
            return
        }

        let inputs = calcParams.calcInputs

        let complexInputs = inputs.map { v in v.asComplex }
        let inputsAsReal = inputs.compactMap { n in n.asNumericalValue }
        let inputsAsRational = inputs.compactMap { r in r.asRational }

        let allInputsReal = inputsAsReal.count == inputs.count
        let allInputsRational = inputsAsRational.count == inputs.count

        let realCalc = calc as? RealCalculation
        let complexCalc = calc as? ComplexCalculation
        let ratCalc = calc as? RationalCalculation

        let preferComplexCalc = (allInputsReal &&
                                 (complexCalc?.preferComplexCalculationWith(thisInput: inputsAsReal) ??
                                  false))

        do {
            let resultValue: Value

            if let ratCalc = ratCalc, allInputsRational {
                let result = try ratCalc.calcRational(inputsAsRational, calculatorMode)
                resultValue = Value(result)
            } else if let realCalc = realCalc,
                allInputsReal,
               !preferComplexCalc {
                let result = try realCalc.calculate(inputsAsReal, calculatorMode)
                resultValue = Value(result)
            } else if let conversionCalc = calc as? NumTypeConversionCalculation, allInputsReal {
                resultValue = try conversionCalc.convert(inputsAsReal,
                                                         calculatorMode)
            } else if let complexCalc = complexCalc {
                let result = try complexCalc.calcComplex(complexInputs, calculatorMode)
                resultValue = Value(result)
            } else {
                throw CalcError.badCalculationOp()
            }

            manipulateStack { _ in
                var nextStack = calcParams.nextStack
                nextStack.insert(resultValue.withId(nextId), at: 0)
                return nextStack
            }
        } catch {
            throw error
        }
    }

    func printContents(_ calculatorMode: CalculatorMode) {
        print("Input Buffer: string = \(input.value.stringValue(precision: 8)) double = \(input.value.doubleValue)")
        print("STACK: ")
        content.enumerated().forEach { idx, value in
            print("  \(idx): string = \(value.stringValue(calculatorMode))")
        }
    }

    var testValues: StackTestValues {
        StackTestValues(stackHistory: stackHistory,
                        stackHistoryPointer: stackHistoryPointer)
    }
}

struct StackTestValues {
    var stackHistory: [[Value]]
    var stackHistoryPointer: Int
}

protocol Calculation {
    var arity: Int { get }
}

protocol RealCalculation {
    func calculate(_ inputs: [NumericalValue],
                   _ calculatorMode: CalculatorMode) throws -> NumericalValue
}

protocol ComplexCalculation {
    func preferComplexCalculationWith(thisInput: [NumericalValue]) -> Bool
    func calcComplex(_ inputs: [ComplexValue],
                     _ calculatorMode: CalculatorMode) throws -> ComplexValue
}

extension ComplexCalculation {
    func preferComplexCalculationWith(thisInput: [NumericalValue]) -> Bool {
        false
    }
}

protocol NumTypeConversionCalculation {
    func convert(_ inputs: [NumericalValue],
                 _ calculatorMode: CalculatorMode) throws -> Value
}

protocol RationalCalculation {
    func calcRational(_ inputs: [RationalValue],
                      _ calculatorMode: CalculatorMode) throws -> RationalValue
}

enum ValueNumberFormat {
    case fromInput
    case auto
    case decimal
    case eng
}
