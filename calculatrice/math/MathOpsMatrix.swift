import Foundation

extension Plus: MatrixCalculation {
    func calcMatrix(_ inputs: [MatrixCalcValue], _ calculatorMode: CalculatorMode) throws
        -> ContainedValue
    {
        let (a, b) = try obtainEquallyDimensionedMatrixes(inputs)

        let result = try a.values.enumerated().map { rowIndex, row in
            return try row.enumerated().map { colIndex, value in
                let v1Complex = value.asComplex
                let v2Complex = b.values[rowIndex][colIndex].asComplex
                return try calcComplex([v1Complex, v2Complex], calculatorMode)
            }
        }
        return .matrix(value: try MatrixValue(result))
    }
}

extension Minus: MatrixCalculation {
    func calcMatrix(_ inputs: [any MatrixCalcValue], _ calculatorMode: CalculatorMode) throws
        -> ContainedValue
    {
        let (a, b) = try obtainEquallyDimensionedMatrixes(inputs)

        let result = try a.values.enumerated().map { rowIndex, row in
            return try row.enumerated().map { colIndex, value in
                let v1Complex = value.asComplex
                let v2Complex = b.values[rowIndex][colIndex].asComplex
                return try calcComplex([v1Complex, v2Complex], calculatorMode)
            }
        }
        return .matrix(value: try MatrixValue(result))
    }
}

extension Mult: MatrixCalculation {
    func calcMatrix(_ inputs: [any MatrixCalcValue], _ calculatorMode: CalculatorMode) throws
        -> ContainedValue
    {
        if let scalarTimesMatrix = try? calcScalarTimesMatrix(inputs, calculatorMode) {
            return scalarTimesMatrix
        }

        guard let m1 = inputs[0] as? MatrixValue,
            let m2 = inputs[1] as? MatrixValue
        else {
            throw CalcError.errInputsMustBeMatrixes()
        }

        guard m1.cols == m2.rows else {
            throw CalcError.errBadMatrixDimensionsForMult()
        }

        let plus = Plus()

        // Using row and column indexes for the multiplication might be clearer, but going with map & reduce
        // avoids the using of mutable data structures, which is the norm in this codebase.
        let result = try m1.values.enumerated().map { rowIndex, row in
            return try m2.values[rowIndex].enumerated().map { colIndex, _ in
                return try row.enumerated().reduce(ComplexValue(0, 0)) {
                    partialResult, rowIterParams in
                    let (rowIterIdx, value) = rowIterParams
                    let v1Complex = value.asComplex
                    let v2Complex = m2.values[rowIterIdx][colIndex].asComplex

                    let elemProduct = calcComplex([v1Complex, v2Complex], calculatorMode)
                    let totalSum = try plus.calcComplex(
                        [partialResult, elemProduct], calculatorMode)

                    return totalSum
                }
            }
        }

        return .matrix(value: try MatrixValue(result))
    }

    func calcScalarTimesMatrix(
        _ inputs: [any MatrixCalcValue], _ calculatorMode: CalculatorMode
    ) throws -> ContainedValue {
        let scalar =
            (inputs[0] as? MatrixElement)?.asComplex ?? (inputs[1] as? MatrixElement)?.asComplex
        let matrix = inputs[0] as? MatrixValue ?? inputs[1] as? MatrixValue

        guard let scalar = scalar?.asComplex, let matrix = matrix else {
            throw CalcError.badInput()
        }

        let result = matrix.values.enumerated().map { rowIndex, row in
            return row.enumerated().map { colIndex, value in
                let v1Complex = value.asComplex
                return calcComplex([scalar, v1Complex], calculatorMode)
            }
        }
        return .matrix(value: try MatrixValue(result))
    }
}

private func obtainEquallyDimensionedMatrixes(_ inputs: [MatrixCalcValue]) throws -> (
    MatrixValue, MatrixValue
) {
    guard inputs.count >= 2,
        let a = inputs[0] as? MatrixValue, let b = inputs[1] as? MatrixValue
    else {
        throw CalcError.errInputsMustBeMatrixes()
    }

    guard a.dimensions == b.dimensions else {
        throw CalcError.unequalMatrixRowsCols()
    }

    return (a, b)
}
