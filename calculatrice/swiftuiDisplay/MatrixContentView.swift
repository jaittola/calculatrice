import SwiftUI

struct MatrixContentView: View {
    var values: [MatrixRow]
    var valueMode: ValueMode

    var inputController: InputController?

    var areCellsSelectable: Bool = true
    @Binding var selectedCell: (Int, Int)

    @State private var matrixSize: CGSize?

    var body: some View {
        VStack(alignment: .leading) {
            Spacer()
            HStack {
                MatrixBraceView(height: matrixSize?.height ?? 0)
                Grid(alignment: .center,
                     horizontalSpacing: 12,
                     verticalSpacing: 4) {
                    ForEach(values) { row in
                        GridRow {
                            ForEach(row.values) { value in
                                let isSelected = (areCellsSelectable &&
                                                  selectedCell.0 == row.rowIndex &&
                                                  selectedCell.1 == value.columnIndex)
                                let elementValue = if isSelected, let inputController = inputController {
                                    inputController.stringValue
                                } else {
                                    value.value.stringValue(precision: realDefaultPrecision, valueMode: valueMode)
                                }
                                let numberView = StackNumberView(value: elementValue,
                                                                 isSelected: isSelected)
                                if areCellsSelectable {
                                    numberView.onTapGesture { toggleSelection(row.rowIndex, value.columnIndex) }
                                } else {
                                    numberView
                                }
                            }
                        }
                    }
                }.background(GeometryReader { proxy in
                    Color.clear.onGeometryChange(for: CGSize.self) { geometry in
                        geometry.size
                    } action: { newSize in
                        matrixSize = newSize
                    }
                })
                MatrixBraceView(side: .right, height: matrixSize?.height ?? 0)
            }
            Spacer()
        }
    }

    private func toggleSelection(_ rowIndex: Int, _ columnIndex: Int) {
        selectedCell = if (selectedCell.0 == rowIndex && selectedCell.1 == columnIndex) {
            (-1, -1)
        } else {
            (rowIndex, columnIndex)
        }
    }
}

struct MatrixBraceView: View {
    enum BraceSide { case left, right }

    var side: BraceSide = .left
    var height: CGFloat
    var color = Color.black

    private let width: CGFloat = 10
    private let baseXOffset: CGFloat = 8
    private let baseCurveOffset: CGFloat = 6
    private let offsetHeightPortion: CGFloat = 0.15
    private let thickness: CGFloat = 2

    private var xOffsetEnds: CGFloat {
        side == .left ? baseXOffset : width - baseXOffset
    }

    private var xOffsetControls: CGFloat {
        side == .left ? xOffsetEnds - baseCurveOffset : xOffsetEnds + baseCurveOffset
    }

    private var highControlY: CGFloat {
        offsetHeightPortion * height
    }

    private var lowControlY: CGFloat {
        (1 - offsetHeightPortion) * height
    }


    var body: some View {
        Path { path in
            path.move(to: CGPoint(x: xOffsetEnds + thickness, y: 0))
            path.addCurve(to: CGPoint(x: xOffsetEnds + thickness, y: height),
                          control1: CGPoint(x: xOffsetControls + thickness, y: highControlY),
                          control2: CGPoint(x: xOffsetControls + thickness, y: lowControlY))
            path.addLine(to: CGPoint(x: xOffsetEnds, y: height))
            path.addCurve(to: CGPoint(x: xOffsetEnds, y: 0),
                          control1: CGPoint(x: xOffsetControls, y: lowControlY),
                          control2: CGPoint(x: xOffsetControls, y: highControlY))

            path.closeSubpath()
        }
        .fill(color)
        .frame(width: width, height: height)
    }
}

struct MatrixLeftBraceView_Previews: PreviewProvider {
    static var previews: some View {
        MatrixBraceView(height: 40)
            .background(.green.opacity(0.5))
    }
}

struct MatrixRightBraceView_Previews: PreviewProvider {
    static var previews: some View {
        MatrixBraceView(side: .right, height: 40)
            .background(.green.opacity(0.5))
    }
}


struct MatrixContentView_Previews: PreviewProvider {

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
                              valueMode: ValueMode(),
                              selectedCell: $selectedCell)
        }
    }

    static var previews = MatrixContentViewPreview()
}
