import Foundation

class MatrixValue: NSObject, MatrixCalcValue {

    private(set) var values: [[MatrixElement]]
    private(set) var cols: Int

    var rows: Int {
        values.count
    }

    var dimensions: (Int, Int) {
        (rows, cols)
    }

    var isVector: Bool {
        rows == 1 || cols == 1
    }

    func stringValue(
        precision: Int = realDefaultPrecision, calculatorMode: CalculatorMode = CalculatorMode()
    ) -> String {
        let res =
            values
            .map { row in
                row.map { val in
                    val.stringValue(precision: precision, calculatorMode: calculatorMode)
                }.joined(
                    separator: "  ")
            }
            .joined(separator: "\n")

        return "[\(res)]"
    }

    override var description: String {
        "Matrix \(stringValue())"
    }

    func duplicateForStack() -> MatrixValue {
        return self
    }

    init(_ values: [[MatrixElement]]) throws {
        let cols = try values.reduce(-1) { (previousRowElementCount, v) in
            let count = v.count
            if previousRowElementCount != -1 && previousRowElementCount != count {
                throw CalcError.unequalMatrixRowsCols()
            }
            return count
        }

        self.values = values
        self.cols = cols == -1 ? 0 : cols

        super.init()
    }

    override func isEqual(_ to: (Any)?) -> Bool {
        guard let other = to as? MatrixValue,
            other.dimensions == self.dimensions
        else {
            return false
        }

        return values.enumerated().reduce(true) { soFarEqual, rowParams in
            let (rowIndex, row) = rowParams
            return soFarEqual
                && row.enumerated().reduce(true) { soFarEqual2, colParams in
                    let (colIndex, item) = colParams
                    let v = other.values[rowIndex][colIndex]
                    return soFarEqual2 && item.isEqual(v)
                }
        }
    }

    static func == (lhs: MatrixValue, rhs: MatrixValue) -> Bool {
        return lhs.isEqual(rhs)
    }
}
