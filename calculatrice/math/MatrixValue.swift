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
        precision: Int = realDefaultPrecision, valueMode: ValueMode = ValueMode()
    ) -> String {
        let res =
            values
            .map { row in
                row.map { val in
                    val.stringValue(precision: precision, valueMode: valueMode)
                }.joined(
                    separator: "  ")
            }
            .joined(separator: "\n")

        return "[\(res)]"
    }

    override var description: String {
        "Matrix \(stringValue())"
    }

    var asMatrixRows: [MatrixRow] {
        values.enumerated().map { MatrixRow($0.offset, $0.element) }
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

// Needed for the matrix content view's Grid, which requires
// identifiable values.
struct MatrixRow: Identifiable {
    let id: UInt64
    let rowIndex: Int
    let values: [MatrixRowElement]

    init(_ rowIndex: Int,_ values: [MatrixElement]) {
        // Note, not thread safe at all but used for UIs only.
        MatrixRow.idSequence += 1
        self.id = MatrixRow.idSequence
        self.rowIndex = rowIndex
        self.values = values.enumerated().map { MatrixRowElement($0.offset, $0.element) }
    }

    private static var idSequence: UInt64 = 0
}

struct MatrixRowElement: Identifiable {
    let id: UInt64
    let columnIndex: Int
    let value: MatrixElement

    init(_ columnIndex: Int, _ value: MatrixElement) {
        // Note, not thread safe at all but used for UIs only.
        MatrixRowElement.idSequence += 1
        self.id = MatrixRowElement.idSequence
        self.columnIndex = columnIndex
        self.value = value
    }

    private static var idSequence: UInt64 = 0
}
