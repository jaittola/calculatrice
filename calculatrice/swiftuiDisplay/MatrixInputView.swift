import SwiftUI

struct MatrixInputView: View {
    @ObservedObject
    var matrixEditController: MatrixEditController

    @ObservedObject
    var calculatorMode: CalculatorMode

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Styles2.stackSeparatorColor)
                .frame(height: 1)
            ScrollView([.horizontal, .vertical]) {
                MatrixContentView(
                    values: matrixEditController.matrix,
                    valueMode: calculatorMode.valueMode,
                    selectedCell: $matrixEditController.selectedCell
                )
            }
            .background(.white)
        }
    }
}

