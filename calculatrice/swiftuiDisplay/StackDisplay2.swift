import SwiftUI

struct StackDisplay2: View {
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
                             calculatorMode: self.calculatorMode)
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

struct StackDisplay2_Previews: PreviewProvider {
    static var previews: some View {
        let stack = createPreviewStack()
        let calculatorMode = CalculatorMode()
        @State var selection: StackDisplayValueId?

        StackDisplay2(stack: stack,
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
    var calculatorMode: CalculatorMode

    var body: some View {
        HStack {
            Text("\(stackVal.index):")
                .font(Styles2.stackFont)
                .foregroundColor(Styles2.stackTextColor)
                .multilineTextAlignment(.trailing)
                .background(.clear)
            Spacer()
            StackValueView(value: stackVal.value, calculatorMode: calculatorMode)
        }
        .listRowBackground(isSelected ? Styles2.selectedRowBackgroundColor : Color.white)
        .listRowInsets(EdgeInsets(top: 0, leading: 8, bottom: 0, trailing: 8))
        .contextMenu {
            Button {
                CopyPaste.copy(stackVal, calculatorMode)
            } label: { Text("Copy") }
        }
    }
}

struct StackValueView: View {
    var value: Value
    var calculatorMode: CalculatorMode

    @State private var selectedCell = (-1, -1)

    var body: some View {
        if let matrixRows = value.asMatrix?.asMatrixRows {
            MatrixContentView(values: matrixRows,
                              calculatorMode: calculatorMode,
                              areCellsSelectable: false,
                              selectedCell: $selectedCell)
        } else {
            StackNumberView(value: value.stringValue(calculatorMode))
        }
    }
}

struct StackNumberView: View {
    var value: String
    var isSelected: Bool = false
    var onClick: (() -> Void)? = nil

    var body: some View {
        let isClickable = onClick != nil
        let view = Text(value)
            .font(Styles2.stackFont)
            .foregroundColor(Styles2.stackTextColor)
            .multilineTextAlignment(.trailing)
            .background(.clear)
            .padding(4)
            .border(isSelected ? Styles2.matrixSelectedCellBorder : .clear, width: 2)


        if isClickable {
            view.onTapGesture { self.onClick?() }
        } else {
            view
        }
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
