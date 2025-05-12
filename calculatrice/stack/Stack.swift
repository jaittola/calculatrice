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

    func copy(
        _ calculatorMode: CalculatorMode,
        inputOnly: Bool
    ) -> String? {
        if inputOnly {
            return !input.isEmpty ? input.stringValue : nil
        }

        return if selectedId != -1, let selectedValue = content.first(where: { $0.id == selectedId }) {
            selectedValue.stringValue(calculatorMode)
        } else if !input.isEmpty {
            input.stringValue
        } else if !content.isEmpty {
            content[0].stringValue(calculatorMode)
        } else {
            nil
        }
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

        if !input.isEmpty {
            pushInput()
        }


        var calcInputs: [Value] = []

        var count = n
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

        let complexInputs = inputs.compactMap { v in v.asComplex }
        let inputsAsNum = inputs.compactMap { n in n.asNum }
        let inputsAsRational = inputs.compactMap { r in r.asRational }
        let inputsAsMatrix = inputs.compactMap { m in m.asMatrix }
        let inputsAsMatrixCalcValue = inputs.compactMap { v in v.asMatrixCalcValue }

        let allInputsNum = inputsAsNum.count == inputs.count
        let allInputsRational = inputsAsRational.count == inputs.count
        let allInputsConvertableToComplex = complexInputs.count == inputs.count
        let haveMatrixInput = inputsAsMatrix.count > 0

        let realCalc = calc as? ScalarCalculation
        let complexCalc = calc as? ComplexCalculation
        let ratCalc = calc as? RationalCalculation
        let matrixCalc = calc as? MatrixCalculation

        let preferComplexCalc = (allInputsNum &&
                                 (complexCalc?.preferComplexCalculationWith(thisInput: inputsAsNum) ??
                                  false))
        let preferRealCalc = (allInputsRational && ratCalc?.preferRealCalculationWith(thisInput: inputs) ?? false)

        let resultValue: Value

        if let matrixCalc = matrixCalc, haveMatrixInput {
            let result = try matrixCalc.calcMatrix(inputsAsMatrixCalcValue, calculatorMode)
            resultValue = Value(result)
        }
        else if let ratCalc = ratCalc, allInputsRational, !preferRealCalc {
            let result = try ratCalc.calcRational(inputsAsRational, calculatorMode)
            resultValue = Value(result)
        } else if let realCalc = realCalc,
                  allInputsNum,
                  !preferComplexCalc {
            let result = try realCalc.calculate(inputsAsNum, calculatorMode)
            resultValue = Value(result)
        } else if let conversionCalc = calc as? NumTypeConversionCalculation, allInputsNum {
            resultValue = try conversionCalc.convert(inputsAsNum,
                                                     calculatorMode)
        } else if let complexCalc = complexCalc, allInputsConvertableToComplex {
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
    }

    func printContents(_ calculatorMode: CalculatorMode) {
        print(
            "Input Buffer: string = \(input.value.stringValue(calculatorMode))"
        )
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

protocol ScalarCalculation {
    func calculate(_ inputs: [Num],
                   _ calculatorMode: CalculatorMode) throws -> NumericalValue
}

protocol ComplexCalculation {
    func preferComplexCalculationWith(thisInput: [Num]) -> Bool
    func calcComplex(_ inputs: [ComplexValue],
                     _ calculatorMode: CalculatorMode) throws -> ComplexValue
}

extension ComplexCalculation {
    func preferComplexCalculationWith(thisInput: [Num]) -> Bool {
        false
    }
}

protocol NumTypeConversionCalculation {
    func convert(_ inputs: [Num],
                 _ calculatorMode: CalculatorMode) throws -> Value
}

protocol RationalCalculation {
    func preferRealCalculationWith(thisInput: [Value]) -> Bool
    func calcRational(_ inputs: [RationalValue],
                      _ calculatorMode: CalculatorMode) throws -> RationalValue
}

extension RationalCalculation {
    func preferRealCalculationWith(thisInput: [Value]) -> Bool {
        false
    }
}

protocol MatrixCalculation {
    func calcMatrix(_ inputs: [MatrixCalcValue],
                    _ calculatorMode: CalculatorMode) throws -> ContainedValue
}

enum ValueNumberFormat {
    case fromInput
    case auto
    case decimal
    case eng
}
