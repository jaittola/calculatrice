import SwiftUI

struct MatrixInputView: View {
    @ObservedObject
    var matrixInputController: MatrixInputController

    @ObservedObject
    var calculatorMode: CalculatorMode

    var body: some View {
        VStack(spacing: 0) {
            Rectangle()
                .fill(Styles2.stackSeparatorColor)
                .frame(height: 1)
            ScrollView([.horizontal, .vertical]) {
                MatrixContentView(
                    values: matrixInputController.matrix,
                    valueMode: calculatorMode.valueMode,
                    inputController: matrixInputController.inputController,
                    selectedCell: $matrixInputController.selectedCell
                )
            }
            .background(.white)
        }
    }
}

