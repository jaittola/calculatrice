import Foundation
import Combine

class InputController: ObservableObject {
    private(set) var calculatorMode: CalculatorMode

    private(set) var inputBuffers: [InputBuffer]

    private(set) var activeBufferIndex: Int

    // Note: this value can change so don't keep a reference to it!
    @Published
    private(set) var activeInputBuffer: InputBuffer

    @Published
    var value: Value

    @Published
    var stringValue: String

    var isEmpty: Bool {
        inputBuffers.allSatisfy(\.isEmpty)
    }

    private var stringValueCancellable: AnyCancellable?

    private var emptyValueMode: InputBuffer.EmptyValueMode

    init(_ calculatorMode: CalculatorMode = CalculatorMode(),
         emptyValueMode: InputBuffer.EmptyValueMode = .empty) {
        self.calculatorMode = calculatorMode
        self.emptyValueMode = emptyValueMode
        let buffers = [InputBuffer(emptyValueMode: emptyValueMode)]
        self.inputBuffers = buffers
        self.activeBufferIndex = 0
        self.activeInputBuffer = buffers[0]
        self.value = Value(NumericalValue(0))
        self.stringValue = ""

        subscribeToInputValues()
    }

    func clear() {
        inputBuffers = [InputBuffer(emptyValueMode: emptyValueMode)]
        activeBufferIndex = 0
        activeInputBuffer = inputBuffers[0]
        stringValue = ""
        subscribeToInputValues()
    }

    private func subscribeToInputValues() {
        stringValueCancellable = activeInputBuffer.$value.sink { [weak self] newValue in
            guard let self else { return }
            self.stringValue = newValue.currentInput
            self.value = Value(newValue.numericalValue)
        }
    }
}
