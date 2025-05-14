import SwiftUI

struct MatrixEntryView: View {
    var stack: Stack
    var calculatorMode: CalculatorMode

    private let matrixKeypadModel = MatrixKeypadModel()

    @Binding var showingMatrixUi: Bool

    @Binding var calcErrorOccurred: Bool
    @Binding var calcError: Error?
    @Binding var showingHelp: Bool

    var body: some View {
        VStack {
            VStack {}
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            KeypadView2(model: matrixKeypadModel,
                        onKeyPressed: { key in onKeyPressed(key) })
        }
    }

    private func onKeyPressed(_ key: Key) {
        do {
            try key.activeOp(calculatorMode, stack, matrixEditController.inputBuffer, { op in self.handleUIKeyboardOp(op) })
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

        var body: some View {
            return MatrixEntryView(stack: Stack(),
                                   calculatorMode: CalculatorMode(),
                                   showingMatrixUi: $showingMatrixUi,
                                   calcErrorOccurred: $calcErrorOccurred,
                                   calcError: $calcError,
                                   showingHelp: $showingHelp)
        }
    }

    return MatrixEntryViewPreview()
}
