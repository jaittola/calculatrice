import SwiftUI

struct InputDisplay2: View {
    @ObservedObject
    var inputBuffer: InputBuffer

    var calculatorMode: CalculatorMode

    var stack: Stack

    @Binding var calcErrorOccurred: Bool
    @Binding var calcError: Error?

    var body: some View {
        let value = inputBuffer.isEmpty ? " " : inputBuffer.stringValue

        StackNumberView(value: value)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .background(.white)
            .contextMenu {
                Button {
                    CopyPaste.copy(stack, calculatorMode.valueMode, inputOnly: true)
                } label: {
                    Text("Copy")
                }
                PasteButton(payloadType: String.self) { _ in
                    if !CopyPaste.paste(stack) {
                        calcError = CalcError.pasteFailed()
                        calcErrorOccurred = true
                    }
                }
            }
    }
}

#Preview {
    struct Preview: View {

        @State private var calcErrorOccurred = false
        @State private var calcError: Error?

        var body: some View {
            let ib = makeInput()
            HStack {
                InputDisplay2(
                    inputBuffer: ib,
                    calculatorMode: CalculatorMode(),
                    stack: Stack(),
                    calcErrorOccurred: $calcErrorOccurred,
                    calcError: $calcError
                )
            }.padding(.vertical, 10).background(.red)
            HStack {
                InputDisplay2(
                    inputBuffer: InputBuffer(),
                    calculatorMode: CalculatorMode(),
                    stack: Stack(),
                    calcErrorOccurred: $calcErrorOccurred,
                    calcError: $calcError)
            }.padding(.vertical, 10).background(.green)
        }

        func makeInput() -> InputBuffer {
            let ib = InputBuffer()
            ib.addNum(3)
            ib.dot()
            ib.addNum(1)
            ib.addNum(4)

            return ib
        }
    }

    return Preview()
}
