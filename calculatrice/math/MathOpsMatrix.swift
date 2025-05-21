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

                    let elemProduct = try calcComplex([v1Complex, v2Complex], calculatorMode)
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

        let result = try matrix.values.enumerated().map { rowIndex, row in
            return try row.enumerated().map { colIndex, value in
                let v1Complex = value.asComplex
                return try calcComplex([scalar, v1Complex], calculatorMode)
            }
        }
        return .matrix(value: try MatrixValue(result))
    }
}

extension Neg: MatrixCalculation {
    func calcMatrix(_ inputs: [any MatrixCalcValue], _ calculatorMode: CalculatorMode) throws
        -> ContainedValue
    {
        guard let m = inputs[0] as? MatrixValue else {
            throw CalcError.errInputsMustBeMatrixes()
        }

        let result = try Mult().calcMatrix([NumericalValue(-1), m], calculatorMode)

        return result
    }
}

class Transpose: Calculation, MatrixCalculation {
    let arity = 1

    func calcMatrix(_ inputs: [any MatrixCalcValue], _ calculatorMode: CalculatorMode) throws
        -> ContainedValue
    {
        guard let m = inputs[0] as? MatrixValue else {
            throw CalcError.errInputsMustBeMatrixes()
        }

        guard m.rows > 0, m.cols > 0 else {
            return try .matrix(value: MatrixValue([]))
        }

        let result = (0..<m.cols).map { colIndex in
            (0..<m.rows).map { rowIndex in
                m.values[rowIndex][colIndex]
            }
        }

        return .matrix(value: try MatrixValue(result))
    }
}

class Determinant: Calculation, MatrixCalculation {
    let arity = 1

    func calcMatrix(_ inputs: [any MatrixCalcValue], _ calculatorMode: CalculatorMode) throws
        -> ContainedValue
    {
        guard let m = inputs[0] as? MatrixValue else {
            throw CalcError.errInputsMustBeMatrixes()
        }

        guard m.rows == m.cols else {
            throw CalcError.errMatrixMustBeSquare()
        }

        switch m.rows {
        case 0:  // empty
            return .number(value: NumericalValue(0))

        case 1:  // 1x1
            return complexOrNumber(m.values[0][0].asComplex)

        case 2:  // 2x2 => calculate determinant directly
            let mult = Mult()
            let v1 = try mult.calcComplex(
                [m.values[0][0].asComplex, m.values[1][1].asComplex], CalculatorMode())
            let v2 = try mult.calcComplex(
                [m.values[0][1].asComplex, m.values[1][0].asComplex], CalculatorMode())
            let determinant = try Minus().calcComplex([v1, v2], calculatorMode).asComplex
            return complexOrNumber(determinant)

        default:  // larger => use submatrixes
            let mult = Mult()
            let plus = Plus()
            var determinant = ComplexValue(0, 0)
            for col in 0..<m.cols {
                let subMatrix = try createSubMatrix(matrix: m, excludingRow: 0, excludingCol: col)
                let cofactor = try mult.calcComplex(
                    [
                        m.values[0][col].asComplex,
                        ComplexValue((col % 2 == 0 ? 1 : -1), 0),
                    ],
                    calculatorMode)
                guard let subDeterminant = try calcMatrix([subMatrix], calculatorMode).asComplex
                else {
                    throw CalcError.badCalculationOp()
                }
                determinant =
                    try plus.calcComplex(
                        [
                            determinant,
                            mult.calcComplex([cofactor, subDeterminant], calculatorMode),
                        ], calculatorMode)
            }
            return complexOrNumber(determinant)
        }
    }

    private func createSubMatrix(matrix: MatrixValue, excludingRow: Int, excludingCol: Int) throws
        -> MatrixValue
    {
        let subMatrixValues = matrix.values.enumerated().compactMap {
            rowIndex, row -> [MatrixElement]? in
            guard rowIndex != excludingRow else { return nil }
            return row.enumerated().compactMap { colIndex, value -> MatrixElement? in
                colIndex != excludingCol ? value : nil
            }
        }
        return try MatrixValue(subMatrixValues)
    }
}

class DotProduct: Calculation, MatrixCalculation {
    let arity = 2

    func calcMatrix(_ inputs: [any MatrixCalcValue], _ calculatorMode: CalculatorMode) throws
        -> ContainedValue
    {
        let transpose = Transpose()
        let plus = Plus()
        let mult = Mult()

        guard inputs.count == 2,
            let v1 = inputs[0] as? MatrixValue,
            let v2 = inputs[1] as? MatrixValue,
            v1.isVector, v2.isVector,
            v1.dimensions == v2.dimensions,
            let v1r = v1.rows == 1 ? v1 : try transpose.calcMatrix([v1], calculatorMode).asMatrix,
            let v2r = v2.rows == 1 ? v2 : try transpose.calcMatrix([v2], calculatorMode).asMatrix
        else {
            throw CalcError.sameDimensionVectorsRequired()
        }

        let result = try v1r.values[0].enumerated().reduce(ComplexValue(0, 0)) {
            partialResult, iterParams in
            let (idx, value) = iterParams

            let val1 = value.asComplex
            let val2 = v2r.values[0][idx].asComplex
            let elemProduct = try mult.calcComplex([val1, val2], calculatorMode)
            let totalSum = try plus.calcComplex(
                [partialResult, elemProduct], calculatorMode)

            return totalSum
        }

        return complexOrNumber(result)
    }
}

extension Inv: MatrixCalculation {
    func calcMatrix(_ inputs: [any MatrixCalcValue], _ calculatorMode: CalculatorMode) throws
        -> ContainedValue
    {
        guard let matrix = inputs[0] as? MatrixValue else {
            throw CalcError.errInputsMustBeMatrixes()
        }

        guard matrix.rows == matrix.cols, matrix.rows > 0 else {
            throw CalcError.errMatrixMustBeSquare()
        }

        guard let determinant = try Determinant().calcMatrix([matrix], calculatorMode).asComplex,
            determinant != ComplexValue(0, 0)
        else {
            throw CalcError.badInput()
        }

        let mult = Mult()
        let minus = Minus()
        let div = Div()

        var augmentedMatrix = try createAugmentedMatrix(matrix)

        let dimension = matrix.rows
        for i in 0..<dimension {
            // Find pivot
            let pivot = augmentedMatrix[i][i]
            if pivot == ComplexValue(0, 0) {
                // Swap with row below
                var swapped = false
                for j in (i + 1)..<dimension {
                    if augmentedMatrix[j][i] != ComplexValue(0, 0) {
                        augmentedMatrix.swapAt(i, j)
                        swapped = true
                        break
                    }
                }

                if !swapped {
                    throw CalcError.badInput()
                }
            }

            augmentedMatrix[i] = try augmentedMatrix[i].enumerated().map { idx, value in
                let d = try div.calcComplex([value, pivot], calculatorMode)
                return d
            }

            // Eliminate other entries in the column
            for j in 0..<dimension {
                if j != i {
                    let factor = augmentedMatrix[j][i]
                    for k in 0..<(2 * dimension) {
                        let multipliedByFactor = try mult.calcComplex(
                            [factor, augmentedMatrix[i][k]], calculatorMode)
                        augmentedMatrix[j][k] = try minus.calcComplex(
                            [augmentedMatrix[j][k], multipliedByFactor], calculatorMode)
                    }
                }
            }
        }

        // Extract the inverse matrix
        let inverseValues = augmentedMatrix.map { Array($0[dimension..<(2 * dimension)]) }
        return .matrix(value: try MatrixValue(inverseValues))
    }

    private func createAugmentedMatrix(_ matrix: MatrixValue) throws -> [[ComplexValue]] {
        let n = matrix.cols
        var augmentedMatrix = matrix.values.map { row in
            row.map { $0.asComplex }
        }

        // Add the identity matrix to the right of the original matrix
        for i in 0..<n {
            augmentedMatrix[i].append(
                contentsOf: (0..<n).map { $0 == i ? ComplexValue(1, 0) : ComplexValue(0, 0) })
        }

        return augmentedMatrix
    }

    private func findPivotRow(_ matrix: [[ComplexValue]], _ col: Int) -> Int? {
        let n = matrix.count
        for i in col..<n {
            if matrix[i][col] != ComplexValue(0, 0) {
                return i
            }
        }
        return nil
    }
}

private func complexOrNumber(_ value: ComplexValue) -> ContainedValue {
    if let numValue = value.asReal?.asNumericalValue {
        return .number(value: numValue)
    } else {
        return .complex(value: value)
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
