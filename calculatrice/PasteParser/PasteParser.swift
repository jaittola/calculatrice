import Foundation

func handlePaste(_ text: String, _ stack: Stack) -> Bool {
    let pasteParser = PasteParser()

    guard let pasted = pasteParser.parsePastedInput(text) else {
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

    func parsePastedInput(_ text: String) -> ContainedValue? {
        let parserAdapter = ParserAdapter()
        parserAdapter.parse(text)

        if let errorMessage = parserAdapter.parsingError {
            NSLog("Parsing pasted value failed: \(errorMessage)")
            return nil
        }

        guard let parsedExpression = parserAdapter.parsedExpression else {
            NSLog("No parsed value found");
            return nil
        }

        return convertParsedExpression(parsedExpression)
    }

    private func convertParsedExpression(_ expression: ParsedExpression) -> ContainedValue? {
        var typedSiblings: [ContainedValue] = []

        if let siblings = expression.siblings as? [ParsedExpression] {
            typedSiblings = siblings.compactMap { convertParsedExpression($0) }

        }

        switch expression.kind {
        case e_double, e_int:
            let inputBuffer = InputBuffer()
            guard let expressionText = expression.text,
                  inputBuffer.paste(expressionText) else {
                return nil
            }
            return inputBuffer.value

        case e_complex_cart:
            let numSiblings = typedSiblings.compactMap { $0.asNum }
            guard numSiblings.count == 2 else {
                NSLog("Invalid number of arguments for complex number literal")
                return nil
            }
            return ContainedValue.complex(value: ComplexValue(realValue: numSiblings[0], imagValue: numSiblings[1]))

        case e_fraction:
            let numSiblings = typedSiblings.compactMap { $0.asNum }
            let rational: RationalValue? = switch numSiblings.count {
            case 2:
                try? RationalValue(numerator: numSiblings[0],
                                   denominator: numSiblings[1])

            case 3:
                try? RationalValue(whole: numSiblings[0],
                                   numerator: numSiblings[1],
                                   denominator: numSiblings[2])

            default:
                nil
            }

            guard let rational = rational else {
                return nil
            }
            return ContainedValue.rational(value: rational)

        default:
            return nil
        }
    }
}
