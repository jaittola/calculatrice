import SwiftUI

struct StackDisplay: View {
    @ObservedObject
    var stack: Stack

    @ObservedObject
    var calculatorMode: CalculatorMode

    @Binding
    var selection: StackDisplayValueId?

    var body: some View {
        let values = StackValueWithPosition.make(valuesFrom: stack)
        ScrollViewReader { scrollViewProxy in
            List(selection: $selection) {
                ForEach(values) { stackVal in
                    StackRow(stackVal: stackVal,
                             isSelected: selection == stackVal.id,
                             valueMode: calculatorMode.valueMode)
                }
            }
            .listStyle(.plain)
            .background(.white)
            .onChange(of: stack.content) { _, newContent in
                if let value = newContent.first {
                    let val = StackValueWithPosition(0, value)
                    scrollViewProxy.scrollTo(val.id)
                }
            }
        }
    }
}

struct StackDisplayValueId: Identifiable, Equatable, Hashable {
    let stackPosition: Int
    let valueId: Int

    var id: String { "\(valueId)_\(stackPosition)"}
}

struct StackValueWithPosition: Identifiable, Equatable {
    let id: StackDisplayValueId
    let index: Int
    let value: Value

    init(_ index: Int, _ value: Value) {
        let stackPosition = index + 1

        self.id = StackDisplayValueId(stackPosition: stackPosition, valueId: value.id)
        self.index = stackPosition
        self.value = value
    }

    static func == (lhs: StackValueWithPosition, rhs: StackValueWithPosition) -> Bool {
        lhs.id == rhs.id
    }

    static func make(valuesFrom stack: Stack) -> [StackValueWithPosition] {
        let result = stack.content
            .enumerated()
            .reversed()
            .map { (idx, value) in
                return StackValueWithPosition(idx, value)
            }
        return result
    }
}

struct StackDisplay_Previews: PreviewProvider {
    static var previews: some View {
        let stack = createPreviewStack()
        let calculatorMode = CalculatorMode()
        @State var selection: StackDisplayValueId?

        StackDisplay(stack: stack,
                      calculatorMode: calculatorMode,
                      selection: $selection)
    }

    static func createPreviewStack() -> Stack {
        let stack = Stack()
        stack.push(Value(NumericalValue(2.25)))
        stack.push(Value(ComplexValue(1.2256, 0.362)))
        return stack
    }
}

struct StackRow: View {
    var stackVal: StackValueWithPosition
    var isSelected: Bool
    var valueMode: ValueMode

    var body: some View {
        HStack {
            Text("\(stackVal.index):")
                .font(Styles.stackFont)
                .foregroundColor(Styles.stackTextColor)
                .multilineTextAlignment(.trailing)
                .background(.clear)
            Spacer()
            StackValueView(value: stackVal.value, valueMode: valueMode)
        }
        .listRowBackground(isSelected ? Styles.selectedRowBackgroundColor : Color.white)
        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        .contextMenu {
            Button {
                CopyPaste.copy(stackVal, valueMode)
            } label: { Text("Copy") }
        }
    }
}

struct StackValueView: View {
    var value: Value
    var valueMode: ValueMode

    @State private var selectedCell = (-1, -1)

    var body: some View {
        if let matrixRows = value.asMatrix?.asMatrixRows {
            ScrollView(.horizontal) {
                MatrixContentView(values: matrixRows,
                                  valueMode: valueMode,
                                  areCellsSelectable: false,
                                  selectedCell: $selectedCell)
            }
            .defaultScrollAnchor(.trailing)
            .scrollBounceBehavior(.basedOnSize)
        } else {
            StackNumberView(value: value.stringValue(valueMode))
        }
    }
}

struct StackNumberView: View {
    var value: String
    var isSelected: Bool = false

    var body: some View {
        Text(value)
            .frame(minWidth: 20, minHeight: 28)
            .font(Styles.stackFont)
            .foregroundColor(Styles.stackTextColor)
            .multilineTextAlignment(.trailing)
            .padding(4)
            .border(isSelected ? Styles.matrixSelectedCellBorder : .clear, width: 2)
    }
}

struct StackNumberView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            StackNumberView(value: "123.345")
                .frame(maxWidth: .infinity)
            Spacer()
        }
    }
}

struct SelectedStackNumberView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            Spacer()
            StackNumberView(value: "123.345", isSelected: true)
                .frame(maxWidth: .infinity)
            Spacer()
        }
    }
}
