import SwiftUI

struct InputDisplay: View {
    @ObservedObject
    var inputController: InputController

    var calculatorMode: CalculatorMode

    var stack: Stack

    @Binding var calcErrorOccurred: Bool
    @Binding var calcError: Error?

    var body: some View {
        let value = inputController.stringValue

        HStack(spacing: 0) {
            Spacer()
            StackNumberView(value: value)
                .frame(alignment: .trailing)
                .background(Styles.inputBackgroundColor)
                .contextMenu {
                    Button {
                        CopyPaste.copy(inputController, stack, calculatorMode.valueMode, inputOnly: true)
                    } label: {
                        Text("Copy")
                    }
                    PasteButton(payloadType: String.self) { _ in
                        if !CopyPaste.paste(stack, inputController) {
                            calcError = CalcError.pasteFailed()
                            calcErrorOccurred = true
                        }
                    }
                }
        }
        .frame(maxWidth: .infinity)
        .padding(2)
        .background(.white)
    }
}

#Preview {
    struct Preview: View {

        @State private var calcErrorOccurred = false
        @State private var calcError: Error?

        var body: some View {
            let calculatorMode = CalculatorMode()
            let ic = makeInput(calculatorMode)

            HStack {
                InputDisplay(
                    inputController: ic,
                    calculatorMode: CalculatorMode(),
                    stack: Stack(),
                    calcErrorOccurred: $calcErrorOccurred,
                    calcError: $calcError
                )
            }.padding(.vertical, 10).background(.red)
            HStack {
                InputDisplay(
                    inputController: InputController(calculatorMode),
                    calculatorMode: calculatorMode,
                    stack: Stack(),
                    calcErrorOccurred: $calcErrorOccurred,
                    calcError: $calcError)
            }.padding(.vertical, 10).background(.green)
        }

        func makeInput(_ calculatorMode: CalculatorMode) -> InputController {
            let ic = InputController(calculatorMode)
            ic.activeInputBuffer.addNum(3)
            ic.activeInputBuffer.dot()
            ic.activeInputBuffer.addNum(1)
            ic.activeInputBuffer.addNum(4)

            return ic
        }
    }

    return Preview()
}
