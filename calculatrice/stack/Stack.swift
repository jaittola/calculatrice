import Foundation

class Stack {
    private(set) var content: [Value] = []
    private(set) var input = InputBuffer()

    private var uniqueIdSeq: Int = 0

    var selectedId: Int = -1

    func push(_ value: Value) {
        content.insert(value.withId(uniqueIdSeq), at: 0)
        uniqueIdSeq += 1
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

    private func getForCalc(n: Int = 1) -> [Value]? {
        var result: [Value] = []

        if n <= 0 {
            return nil
        }

        var count = n
        if !input.isEmpty {
            result.insert(Value(input.value), at: 0)
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

        let inputsAsReal = inputs.compactMap { n in n.asReal }
        let allInputsReal = inputsAsReal.count == inputs.count

        do {
            if let realCalc = calc as? RealCalculation, allInputsReal {
                let result = try realCalc.calculate(inputsAsReal, calculatorMode)
                push(Value(result))
            } else if let realToComplexCalc = calc as? RealToComplexCalculation, allInputsReal {
                let result = try realToComplexCalc.calcToComplex(inputsAsReal, calculatorMode)
                push(Value(result))
            } else if let complexCalc = calc as? ComplexCalculation {
                let complexInputs = inputs.map { v in v.asComplex }
                let result = try complexCalc.calcComplex(complexInputs, calculatorMode)
                push(Value(result))
            } else {
                throw CalcError.badCalculationOp
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
}

protocol Calculation {
    var arity: Int { get }
}

protocol RealCalculation {
    func calculate(_ inputs: [DoublePrecisionValue],
                   _ calculatorMode: CalculatorMode) throws -> DoublePrecisionValue
}

protocol ComplexCalculation {
    func calcComplex(_ inputs: [ComplexValue],
                     _ calculatorMode: CalculatorMode) throws -> ComplexValue
}

protocol RealToComplexCalculation {
    func calcToComplex(_ inputs: [DoublePrecisionValue],
                       _ calculatorMode: CalculatorMode) throws -> ComplexValue
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
