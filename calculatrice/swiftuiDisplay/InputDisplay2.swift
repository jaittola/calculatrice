import SwiftUI

struct InputDisplay2: View {
    @ObservedObject
    var inputBuffer: InputBuffer

    var body: some View {
        let value = inputBuffer.isEmpty ? " " : inputBuffer.stringValue

        Text(value)
            .font(Styles2.stackFont)
            .foregroundColor(Styles2.stackTextColor)
            .multilineTextAlignment(.trailing)
            .frame(maxWidth: .infinity, alignment: .trailing)
            .background(.white)
            .contextMenu {
                Button {
                    UIPasteboard.general.string = inputBuffer.stringValue
                } label: { Text("Copy") }
                PasteButton(payloadType: String.self) { strings in
                    inputBuffer.paste(strings[0])
                }
            }
    }
}

struct InputDisplay2_Previews: PreviewProvider {
    static var previews: some View {
        let ib = makeInput()
        HStack {
            InputDisplay2(inputBuffer: ib)
        }.padding(.vertical, 10).background(.red)
        HStack {
            InputDisplay2(inputBuffer: InputBuffer())
        }.padding(.vertical, 10).background(.green)
    }

    static func makeInput() -> InputBuffer {
        let ib = InputBuffer()
        ib.addNum(3)
        ib.dot()
        ib.addNum(1)
        ib.addNum(4)

        return ib
    }
}
