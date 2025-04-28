import Foundation

func handlePaste(_ text: String, _ stack: Stack) -> Bool {
    let pasteParser = try? PasteParser()

    guard let pasted = pasteParser?.parsePastedInput(text) else {
        return false
    }

    switch pasted {
    case .number:
        stack.input.paste(text)
        return true
    case .complex(let value):
        stack.push(Value(value))
        return true
    default:
        break
    }
    return false
}

class PasteParser {

    private let floatingPointRegexp: NSRegularExpression
    private let complexCartesianRegexp: NSRegularExpression
    private let imaginaryRegexp: NSRegularExpression

    init() throws {
        let unsignedFloatingPointPattern = "\\d+(\\.\\d+)?([eE][+-]?\\d+)?"
        let floatingPointBasePattern = "[+-]?\(unsignedFloatingPointPattern)"
        let complexPattern = "^(\(floatingPointBasePattern))([+-]\(unsignedFloatingPointPattern))i$"
        let imaginaryPattern = "^(\(floatingPointBasePattern))i$"

        try self.floatingPointRegexp = NSRegularExpression(pattern: "^\(floatingPointBasePattern)$")
        try self.complexCartesianRegexp = NSRegularExpression(pattern: complexPattern)
        try self.imaginaryRegexp = NSRegularExpression(pattern: imaginaryPattern)
    }

    func parsePastedInput(_ text: String) -> ContainedValue? {
        var textWithoutSpace = text
        textWithoutSpace.removeAll { c in c.isWhitespace }

        guard textWithoutSpace.count > 0 else {
            return nil
        }

        let range = NSRange(location: 0, length: textWithoutSpace.count)

        if let floatingPointValue = tryParseFloatingPointValue(textWithoutSpace, range) {
            return floatingPointValue
        } else if let imaginaryValue = tryParseImaginaryValue(textWithoutSpace, range) {
            return imaginaryValue
        } else if let complexValue = tryParseComplexValue(textWithoutSpace, range) {
            return complexValue
        } else {
            return nil
        }
    }

    private func tryParseFloatingPointValue(_ text: String, _ range: NSRange) -> ContainedValue? {
        let inputBuffer = InputBuffer()

        if floatingPointRegexp.firstMatch(in: text, options: [], range: range) != nil
            && inputBuffer.paste(text)
        {
            return inputBuffer.value
        }
        return nil
    }

    private func tryParseImaginaryValue(_ text: String, _ range: NSRange) -> ContainedValue? {
        let inputBuffer = InputBuffer()

        if let match = imaginaryRegexp.firstMatch(in: text, options: [], range: range),
            match.numberOfRanges >= 1,
            match.range(at: 1).location != NSNotFound
        {
            let imaginaryPart = (text as NSString).substring(
                with: match.range(at: 1))
            if inputBuffer.paste(imaginaryPart) {
                return ContainedValue.complex(
                    value: ComplexValue(
                        0,
                        inputBuffer.value.asNumericalValue!.floatingPoint))
            }
        }

        return nil
    }

    private func tryParseComplexValue(_ text: String, _ range: NSRange) -> ContainedValue? {

        let complexCartesianMatch = complexCartesianRegexp.matches(
            in: text, options: [], range: range)

        guard complexCartesianMatch.count == 1, complexCartesianMatch[0].numberOfRanges >= 5,
            complexCartesianMatch[0].range(at: 1).location != NSNotFound,
            complexCartesianMatch[0].range(at: 4).location != NSNotFound
        else {
            return nil
        }

        let realPart = (text as NSString).substring(
            with: complexCartesianMatch[0].range(at: 1))
        let imaginaryPart = (text as NSString).substring(
            with: complexCartesianMatch[0].range(at: 4))

        let realInput = InputBuffer()
        let imaginaryInput = InputBuffer()

        return
            if realInput.paste(realPart), imaginaryInput.paste(imaginaryPart),
            let realValue = realInput.value.asNum,
            let imaginaryVal = imaginaryInput.value.asNum
        {
            ContainedValue.complex(
                value: ComplexValue(realValue: realValue, imagValue: imaginaryVal))

        } else {
            nil
        }
    }
}
