import Foundation

class PasteParser {

    func parsePastedInput(_ text: String) -> ContainedValue? {
        let parserAdapter = ParserAdapter()
        parserAdapter.parse(text)

        if let errorMessage = parserAdapter.parsingError {
            NSLog("Parsing pasted value failed: \(errorMessage)")
            return nil
        }

        guard let parsedExpression = parserAdapter.parsedExpression else {
            NSLog("No parsed value found")
            return nil
        }

        return convertParsedExpression(parsedExpression)
    }

    private func convertParsedExpression(_ expression: ParsedExpression) -> ContainedValue? {
        var typedSiblings: [ContainedValue] = []
        var numSiblings: [Num] = []

        if let siblings = expression.siblings as? [ParsedExpression] {
            typedSiblings = siblings.compactMap { convertParsedExpression($0) }
            numSiblings = typedSiblings.compactMap { $0.asNum }
        }

        switch expression.kind {
        case e_double, e_int:
            let inputBuffer = InputBuffer()
            guard let expressionText = expression.text,
                  inputBuffer.paste(expressionText) else {
                return nil
            }
            return inputBuffer.asContainedValue

        case e_complex_cart:
            guard numSiblings.count == 2 else {
                NSLog("Invalid number of arguments for complex number literal")
                return nil
            }
            return ContainedValue.complex(value: ComplexValue(realValue: numSiblings[0], imagValue: numSiblings[1]))

        case e_complex_polar:
            guard numSiblings.count == 2 else {
                NSLog("Invalid number of arguments for complex number literal")
                return nil
            }
            let argument = expression.angle_unit == e_au_deg ?
                NumericalValue(Utils.deg2Rad([numSiblings[1]], CalculatorMode())[0]) :
                numSiblings[1]
            return ContainedValue.complex(value: ComplexValue(absolute: numSiblings[0],
                                                              argument: argument))

        case e_fraction:
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

        case e_matrix:
            let matrixElements =
                typedSiblings
                .compactMap { sib in sib.asMatrix }
                .compactMap { row in
                    if row.rows == 1 {
                        return row.values[0]
                    } else {
                        return nil
                    }
                }

            guard typedSiblings.count >= 1,
                matrixElements.count == typedSiblings.count
            else {
                NSLog(
                    "Invalid pasted matrix: it must have at least one row and number of rows must match contained values. Found \(matrixElements.count) rows."
                )
                return nil
            }

            guard let matrix = try? MatrixValue(matrixElements) else {
                NSLog("Invalid matrix")
                return nil
            }
            return ContainedValue.matrix(value: matrix)

        case e_matrix_row:
            let rowContent =
                typedSiblings
                .compactMap { $0.asMatrixElement }

            guard typedSiblings.count >= 1,
                rowContent.count == typedSiblings.count
            else {
                NSLog(
                    "Invalid row in pasted matrix. It must have at least one column and number of columns must match contained values. Found \(rowContent.count) columns, input was \(typedSiblings.count)."
                )
                return nil
            }

            guard let matrix = try? MatrixValue([rowContent]) else {
                NSLog("Invalid matrix row")
                return nil
            }
            return ContainedValue.matrix(value: matrix)

        default:
            return nil
        }
    }
}
