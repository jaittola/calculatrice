import SwiftUI

struct CalculatorMain: View {
    private let stack = Stack()

    @ObservedObject
    private var calculatorMode: CalculatorMode

    @ObservedObject
    private var matrixInputController = MatrixInputController()

    @ObservedObject
    private var inputController: InputController

    @State private var calcErrorOccurred = false
    @State private var calcError: Error?

    @State private var selection: StackDisplayValueId?

    @State private var showingHelp = false

    init() {
        let calculatorMode = CalculatorMode()
        self.calculatorMode = calculatorMode
        self.inputController = InputController(calculatorMode)
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack { }.frame(minHeight: 1) // Prevent stretching the status row to the safe area
            StatusRow2(calculatorMode: calculatorMode)
            StackDisplay2(stack: stack,
                          calculatorMode: calculatorMode,
                          selection: $selection)
            switch calculatorMode.mainViewMode {
            case .Matrix:
                MatrixInputView(matrixInputController: matrixInputController, calculatorMode: calculatorMode)
            case .Normal:
                InputDisplay2(inputController: inputController,
                              calculatorMode: calculatorMode,
                              stack: stack,
                              calcErrorOccurred: $calcErrorOccurred,
                              calcError: $calcError)
            }
            KeypadView2(calculatorMode: calculatorMode,
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
        .sheet(isPresented: $showingHelp) {
            HelpView(showingHelp: $showingHelp,
                     showGeneralHelpText: calculatorMode.mainViewMode == .Normal,
                     keypadModel: calculatorMode.keypadModel)
        }
    }

    private func onKeyPressed(_ key: Key) {
        stack.selectedId = selection?.valueId ?? -1 // This is a kind of a hack, maybe clean up.
        do {
            switch (calculatorMode.mainViewMode) {
            case .Matrix:
                try key.activeOp(calculatorMode,
                                 stack,
                                 matrixInputController.inputController,
                                 matrixInputController,
                                 { op in self.handleUIKeyboardOp(op) })
            case .Normal:
                try key.activeOp(calculatorMode,
                                 stack,
                                 inputController,
                                 nil,
                                 { op in self.handleUIKeyboardOp(op) })
            }

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
            calculatorMode.mainViewMode = .Matrix

        case .edit(let value):
            if let matrix = value.asMatrix {
                matrixInputController.setInputMatrix(matrix)
                calculatorMode.mainViewMode = .Matrix
            } else if case .number(let num) = value.containedValue {
                inputController.activeInputBuffer.setValue(num)
                calculatorMode.mainViewMode = .Normal
            }
            break

        case .dismissMatrix:
            calculatorMode.mainViewMode = .Normal
        }
    }
}

struct MainView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorMain()
    }
}
