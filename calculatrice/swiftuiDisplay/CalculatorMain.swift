import SwiftUI

struct CalculatorMain: View {
    private let stack = Stack()
    private let calculatorMode = CalculatorMode()

    private let keypadModel = BasicKeypadModel()

    @State private var calcErrorOccurred = false
    @State private var calcError: Error?

    @State private var selection: StackDisplayValueId?

    @State private var showingHelp = false

    var body: some View {
        VStack(spacing: 0) {
            ZStack { }.frame(minHeight: 1) // Prevent stretching the status row to the safe area
            StatusRow2(calculatorMode: calculatorMode)
            StackDisplay2(stack: stack,
                          calculatorMode: calculatorMode,
                          selection: $selection)
            InputDisplay2(inputBuffer: stack.input)
            KeypadView2(model: keypadModel,
                        onKeyPressed: { key in onKeyPressed(key) })
            ZStack { }.frame(minHeight: 1) // Prevent stretching the keyboard to the safe area
        }
        .preferredColorScheme(.light)
        .background(Styles2.windowBackgroundColor)
        .alert("Error",
               isPresented: $calcErrorOccurred,
               presenting: calcError) {
            _ in Button(role: .cancel,
                        action: { calcErrorOccurred = false },
                        label: { Text("Ok") })
        } message: { details in
            Text(errorMessage(for: details))
        }
        .sheet(isPresented: $showingHelp) {
            HelpView(keypadModel: keypadModel)
        }
    }

    private func onKeyPressed(_ key: Key) {
        stack.selectedId = selection?.valueId ?? -1 // This is a kind of a hack, maybe clean up.
        do {
            try key.activeOp(calculatorMode, stack, { op in self.handleUIKeyboardOp(op) })
            if key.resetModAfterClick == .reset {
                calculatorMode.resetMods()
            }
        } catch {
            calcError = error
            calcErrorOccurred = true
        }
    }

    private func errorMessage(for details: any Error) -> String {
        // TODO, improve the error codes and messages
        switch details {
        case CalcError.divisionByZero:
            return "Division by zero"
        case CalcError.unsupportedValueType:
            return "This calculation cannot be performed with the provided input values."
        default:
            return "Bad calculation"
        }
    }

    private func handleUIKeyboardOp(_ op: Key.UICallbackOp) {
        switch op {
        case .showHelp:
            showingHelp = true
        }
    }
}

struct Display2_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorMain()
    }
}
