import SwiftUI

struct MatrixEntryView: View {
    var stack: Stack
    var calculatorMode: CalculatorMode

    private let matrixKeypadModel = MatrixKeypadModel()

    @ObservedObject
    private var matrixEditController = MatrixEditController()

    @Binding var showingMatrixUi: Bool
    @Binding var matrixToEdit: MatrixValue?

    @Binding var calcErrorOccurred: Bool
    @Binding var calcError: Error?
    @Binding var showingHelp: Bool

    var body: some View {
        VStack(spacing: 16) {
            ZStack { }.frame(minHeight: 1) // Prevent stretching the status row to the safe area
            HStack {
                Spacer()
                MatrixContentView(
                    values: matrixEditController.matrix,
                    calculatorMode: calculatorMode,
                    selectedCell: $matrixEditController.selectedCell
                )
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.top, 16)
            .background(.white)
            KeypadView2(model: matrixKeypadModel,
                        onKeyPressed: { key in onKeyPressed(key) })
            ZStack { }.frame(minHeight: 1) // Prevent stretching the status row to the safe area
        }
        .background(Styles2.windowBackgroundColor)
        .onAppear {
            matrixEditController.setInputMatrix(matrixToEdit)
        }
    }

    private func onKeyPressed(_ key: Key) {
        do {
            try key.activeOp(
                calculatorMode, stack, matrixEditController.inputBuffer, matrixEditController,
                { op in self.handleUIKeyboardOp(op) })
        } catch {
            calcError = error
            calcErrorOccurred = true
        }
    }

    private func handleUIKeyboardOp(_ op: Key.UICallbackOp) {
        switch op {
        case .showHelp:
            showingMatrixUi = false
            showingHelp = true
        case .inputMatrix:
            fatalError("MatrixEntryView: Unsupported UI keyboard op: .inputMatrix")
        case .editMatrix:
            fatalError("MatrixEntryView: Unsupported UI keyboard op: .editMatrix")
        case .dismissMatrix:
            showingMatrixUi = false
        }
    }
}

#Preview {
    struct MatrixEntryViewPreview: View {
        @State var showingMatrixUi: Bool = true
        @State var calcErrorOccurred: Bool = false
        @State var calcError: Error? = nil
        @State var showingHelp: Bool = false
        @State var matrixToEdit: MatrixValue? = try! MatrixValue([
            [
                ComplexValue(1, -3),
                NumericalValue(2),
            ],
            [
                NumericalValue(3),
                NumericalValue(4),
            ],
        ])

        var body: some View {
            return MatrixEntryView(stack: Stack(),
                                   calculatorMode: CalculatorMode(),
                                   showingMatrixUi: $showingMatrixUi,
                                   matrixToEdit: $matrixToEdit,
                                   calcErrorOccurred: $calcErrorOccurred,
                                   calcError: $calcError,
                                   showingHelp: $showingHelp)
        }
    }

    return MatrixEntryViewPreview()
}
