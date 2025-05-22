import SwiftUI

class CopyPaste {
    static func copy(
        _ stack: Stack,
        _ valueMode: ValueMode,
        inputOnly: Bool
    ) {
        if let copiedString = stack.copy(valueMode, inputOnly: inputOnly) {
            UIPasteboard.general.string = copiedString
        }
    }

    static func copy(_ stackVal: StackValueWithPosition,
                     _ valueMode: ValueMode) {
        UIPasteboard.general.string = stackVal.value.stringValue(valueMode)
    }

    static func paste(_ stack: Stack) -> Bool {
        guard UIPasteboard.general.hasStrings,
              let val = UIPasteboard.general.string else {
            return false
        }
        return handlePaste(val, stack)
    }
}
