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
}
