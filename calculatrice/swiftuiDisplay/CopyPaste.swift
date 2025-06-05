import SwiftUI

class CopyPaste {
    static func copy(
        _ inputController: InputController,
        _ stack: Stack,
        _ valueMode: ValueMode,
        inputOnly: Bool
    ) {
        if let copiedString = handleCopy(inputController, stack, valueMode, inputOnly: inputOnly) {
            UIPasteboard.general.string = copiedString
        }
    }

    static func copy(_ stackVal: StackValueWithPosition,
                     _ valueMode: ValueMode) {
        UIPasteboard.general.string = stackVal.value.stringValue(valueMode)
    }

    static func handleCopy(
        _ inputController: InputController,
        _ stack: Stack,
        _ valueMode: ValueMode,
        inputOnly: Bool
    ) -> String? {
        if inputOnly {
            return !inputController.isEmpty ? inputController.stringValue : nil
        }

        return if let selectedStackValue = stack.selectedValue() {
            selectedStackValue.stringValue(valueMode)
        } else if !inputController.isEmpty {
            inputController.stringValue
        } else if !stack.content.isEmpty {
            stack.content[0].stringValue(valueMode)
        } else {
            nil
        }
   }

    static func paste(_ stack: Stack, _ inputController: InputController) -> Bool {
        guard UIPasteboard.general.hasStrings,
              let val = UIPasteboard.general.string else {
            return false
        }
        return handlePaste(val, stack, inputController)
    }

    static func handlePaste(_ text: String, _ stack: Stack, _ inputController: InputController) -> Bool {
        let pasteParser = PasteParser()

        guard let pasted = pasteParser.parsePastedInput(text) else {
            return false
        }

        if case .number = pasted {
            inputController.activeInputBuffer.paste(text)
            return true
        } else {
            stack.push(Value(pasted))
            return true
        }
    }
}
