import SwiftUI

class CopyPaste {
    static func copy(
        _ stack: Stack,
        _ calculatorMode: CalculatorMode,
        inputOnly: Bool
    ) {
        if let copiedString = stack.copy(calculatorMode, inputOnly: inputOnly) {
            UIPasteboard.general.string = copiedString
        }
    }

    static func copy(_ stackVal: StackValueWithPosition,
                     _ calculatorMode: CalculatorMode) {
        UIPasteboard.general.string = stackVal.value.stringValue(calculatorMode)
    }

    static func paste(_ stack: Stack) -> Bool {
        guard UIPasteboard.general.hasStrings,
              let val = UIPasteboard.general.string else {
            return false
        }
        return handlePaste(val, stack)
    }
}
