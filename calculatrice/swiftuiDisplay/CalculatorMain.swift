import SwiftUI

struct CalculatorMain: View {
    private let stack = Stack()
    private let calculatorMode = CalculatorMode()

    private let keypadModel = BasicKeypadModel()

    @State private var calcErrorOccurred = false
    @State private var calcError: Error?

    @State private var selection: StackDisplayValueId?

    @State private var showingHelp = false

    @State private var showingMatrixUi = false
    @State private var matrixToEdit: MatrixValue?

    var body: some View {
        VStack(spacing: 0) {
            ZStack { }.frame(minHeight: 1) // Prevent stretching the status row to the safe area
            StatusRow2(calculatorMode: calculatorMode)
            StackDisplay2(stack: stack,
                          calculatorMode: calculatorMode,
                          selection: $selection)
            InputDisplay2(inputBuffer: stack.input,
                          calculatorMode: calculatorMode,
                          stack: stack,
                          calcErrorOccurred: $calcErrorOccurred,
                          calcError: $calcError)
            KeypadView2(model: keypadModel,
                        onKeyPressed: { key in onKeyPressed(key) })
            ZStack { }.frame(minHeight: 1) // Prevent stretching the keyboard to the safe area
        }
        .preferredColorScheme(.light)
        .background(Styles2.windowBackgroundColor)
        .alert(LocalizedStringKey("Error"),
               isPresented: $calcErrorOccurred,
               presenting: calcError) {
            _ in Button(role: .cancel,
                        action: { calcErrorOccurred = false },
                        label: { Text("Ok") })
        } message: { details in
            Text(LocalizedStringKey(errorMessage(for: details)))
        }
        .sheet(isPresented: $showingMatrixUi) {
            MatrixEntryView(stack: stack,
                            calculatorMode: calculatorMode,
                            showingMatrixUi: $showingMatrixUi,
                            matrixToEdit: $matrixToEdit,
                            calcErrorOccurred: $calcErrorOccurred,
                            calcError: $calcError,
                            showingHelp: $showingHelp)
        }
        .sheet(isPresented: $showingHelp) {
            HelpView(showingHelp: $showingHelp, keypadModel: keypadModel)
        }
    }

    private func onKeyPressed(_ key: Key) {
        stack.selectedId = selection?.valueId ?? -1 // This is a kind of a hack, maybe clean up.
        do {
            try key.activeOp(calculatorMode, stack, stack.input, nil, { op in self.handleUIKeyboardOp(op) })
            if key.resetModAfterClick == .reset {
                calculatorMode.resetMods()
                selection = nil
            }
        } catch {
            calcError = error
            calcErrorOccurred = true
        }
    }

    private func errorMessage(for details: any Error) -> String {
        switch details {
        case CalcError.divisionByZero(let msgKey),
            CalcError.badInput(let msgKey),
            CalcError.unsupportedValueType(let msgKey),
            CalcError.badCalculationOp(let msgKey),
            CalcError.nonIntegerInputToRational(let msgKey),
            CalcError.arithmeticOverflow(let msgKey),
            CalcError.pasteFailed(let msgKey),
            CalcError.unequalMatrixRowsCols(let msgKey),
            CalcError.errInputsMustBeMatrixes(let msgKey),
            CalcError.errBadMatrixDimensionsForMult(let msgKey),
            CalcError.errMatrixMustBeSquare(let msgKey):
            return msgKey
        default:
            return "ErrBadCalculationOp"
        }
    }

    private func handleUIKeyboardOp(_ op: Key.UICallbackOp) {
        switch op {
        case .showHelp:
            showingHelp = true
        case .inputMatrix:
            matrixToEdit = nil
            showingMatrixUi = true
        case .editMatrix(let matrix):
            matrixToEdit = matrix
            showingMatrixUi = true
        case .dismissMatrix:
            fatalError("CalculatorMain: Unsupported UI keybaord op .dismissMatrix")
        }
    }
}

struct Display2_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorMain()
    }
}
