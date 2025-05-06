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
