import SwiftUI

struct MatrixContentView: View {
    var values: [MatrixRow]
    var calculatorMode: CalculatorMode

    @Binding var selectedCell: (Int, Int)

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            Grid(alignment: .center,
                 horizontalSpacing: 12,
                 verticalSpacing: 4) {
                ForEach(values) { row in
                    GridRow {
                        ForEach(row.values) { value in
                            let isSelected = (selectedCell.0 == row.rowIndex && selectedCell.1 == value.columnIndex)
                            StackNumberView(value: value.value.stringValue(precision: realDefaultPrecision,
                                                                           calculatorMode: calculatorMode),
                                            isSelected: isSelected,
                                            onClick: {
                                toggleSelection(row.rowIndex, value.columnIndex)
                            })
                        }
                    }
                }
            }
            Spacer()
        }
        .frame(maxWidth: .infinity)
        .background(.white)
    }

    private func toggleSelection(_ rowIndex: Int, _ columnIndex: Int) {
        selectedCell = if (selectedCell.0 == rowIndex && selectedCell.1 == columnIndex) {
            (-1, -1)
        } else {
            (rowIndex, columnIndex)
        }
    }
}

#Preview {
    struct MatrixContentViewPreview: View {
        let matrix = try! MatrixValue([[
            ComplexValue(1, -3),
            NumericalValue(2),
        ], [
            NumericalValue(3),
            NumericalValue(4),
        ]])
        @State private var selectedCell: (Int, Int) = (-1, -1)

        var body: some View {
            MatrixContentView(values: matrix.asMatrixRows,
                              calculatorMode: CalculatorMode(),
                              selectedCell: $selectedCell)
        }
    }

    return MatrixContentViewPreview()
}
