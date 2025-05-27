import Combine
import Foundation

class MatrixEditController: ObservableObject {
    @Published
    private(set) var matrix: [MatrixRow] = MatrixEditController.defaultMatrix()

    @Published
    var selectedCell: (Int, Int) = (0, 0) {
        didSet {
            setupInputControllerFor(rowIndex: selectedCell.0, columnIndex: selectedCell.1)
        }
    }

    var matrixValue: MatrixValue {
        let values = matrix.map { row in
            row.values.map { column in
                column.value
            }
        }
        return try! MatrixValue(values)
    }

    let inputController = InputController(emptyValueMode: .zero)

    private var inputBufferCancellable: AnyCancellable?

    init() {
        inputBufferCancellable = inputController.$value.sink { [weak self] newValue in
            guard let self = self else {
                return
            }
            if let (selectedRow, selectedColumn) = self.getValidSelectedCell() {
                matrix = matrix.map { row in
                    let newRow = row.values.map { column in
                        if column.columnIndex == selectedColumn && row.rowIndex == selectedRow {
                            newValue.asNum ?? Self.zero
                        } else {
                            column.value
                        }
                    }
                    return MatrixRow(row.rowIndex, newRow)
                }
            }
        }
    }

    func setInputMatrix(_ inputMatrix: MatrixValue?) {
        if let inputMatrix = inputMatrix {
            self.matrix = inputMatrix.asMatrixRows
        } else {
            self.matrix = MatrixEditController.defaultMatrix()
        }
        selectedCell = (0, 0)
    }

    func adjustColumns(_ delta: Int) {
        guard delta == 1 || delta == -1,
            matrix.count > 0
        else {
            return
        }

        let newColumnCount = matrix[0].values.count + delta

        guard newColumnCount > 0 else {
            return
        }

        let newMatrix = matrix.map { row in
            let columnCount = row.values.count
            let columns = (0..<newColumnCount).map { columnIndex in
                if columnIndex < columnCount {
                    row.values[columnIndex].value
                } else {
                    Self.zero
                }
            }
            return MatrixRow(row.rowIndex, columns)
        }

        matrix = newMatrix
    }

    func adjustRows(_ delta: Int) {
        guard delta == 1 || delta == -1, matrix.count > 0
        else {
            return
        }

        let newRowCount = matrix.count + delta
        guard newRowCount > 0 else {
            return
        }

        let columnCount = matrix[0].values.count
        let newMatrix = (0..<newRowCount).map { rowIndex in
            if rowIndex < matrix.count {
                return matrix[rowIndex]
            } else {
                let columns = (0..<columnCount).map { columnIndex in
                    Self.zero
                }
                return MatrixRow(rowIndex, columns)
            }
        }

        matrix = newMatrix
    }

    private func getValidSelectedCell() -> (Int, Int)? {
        guard areIndexesValid(selectedCell.0, selectedCell.1) else {
            return nil
        }
        return selectedCell
    }

    private func setupInputControllerFor(rowIndex: Int, columnIndex: Int) {
        guard areIndexesValid(rowIndex, columnIndex) else {
            inputController.clear()
            return
        }

        guard let val = matrix[rowIndex].values[columnIndex].value as? NumericalValue else {
            return
        }

        inputController.activeInputBuffer.paste(val.stringValue())
    }

    private func areIndexesValid(_ rowIndex: Int, _ columnIndex: Int) -> Bool {
        guard rowIndex >= 0 && rowIndex < matrix.count else {
            return false
        }

        let row = matrix[rowIndex]
        return columnIndex >= 0 && columnIndex < row.values.count
    }

    static func defaultMatrix() -> [MatrixRow] {
        return try! MatrixValue([
            [zero, zero], [zero, zero],
        ]).asMatrixRows
    }

    static let zero = NumericalValue(0, originalStringValue: "0")
}
