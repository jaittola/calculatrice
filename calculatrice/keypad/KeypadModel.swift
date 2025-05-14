import Foundation
import UIKit

struct Key: Identifiable {
    enum UICallbackOp {
        case showHelp
        case inputMatrix
        case dismissMatrix
    }

    enum ResetModAfterClick {
        case keep
        case reset
    }
    enum CalcOp {
        case ui(
            _ symbol: String,
            _ calcOp: (
                (_ stack: Stack, _ input: InputBuffer, _ calculatorMode: CalculatorMode) throws ->
                    UICallbackOp?
            )? = nil,
            _ helpTextKey: String? = nil)
        case calc(
            _ symbol: String,
            _ calc: Calculation,
            _ HelpTextKey: String? = nil)

        var helpTextKey: String? {
            switch self {
            case .ui(_, _, let helpTextKey): return helpTextKey
            case .calc(_, _, let helpTextKey): return helpTextKey
            }
        }

        var symbol: String? {
            switch self {
            case .ui(let symbol, _, _): return symbol
            case .calc(let symbol, _, _): return symbol
            }
        }
    }

    let op: CalcOp?
    let opMod1: CalcOp?
    let opMod2: CalcOp?

    let resetModAfterClick: ResetModAfterClick

    let mainTextColor: UIColor?

    let isTightLayout: Bool

    var id: String {
        overriddenId ?? "\(op?.symbol ?? "")_\(opMod1?.symbol ?? "")_\(opMod2?.symbol ?? "")"
    }

    let overriddenId: String?

    init(
        op: CalcOp? = nil,
        opMod1: CalcOp? = nil,
        opMod2: CalcOp? = nil,
        resetModAfterClick: ResetModAfterClick = .reset,
        mainTextColor: UIColor? = nil,
        isTightLayout: Bool = false,
        overriddenId: String? = nil
    ) {
        self.op = op
        self.opMod1 = opMod1
        self.opMod2 = opMod2
        self.resetModAfterClick = resetModAfterClick
        self.mainTextColor = mainTextColor
        self.isTightLayout = isTightLayout
        self.overriddenId = overriddenId
    }

    func activeOp(
        _ calculatorMode: CalculatorMode,
        _ stack: Stack,
        _ input: InputBuffer,
        _ handleUICallbackOp: (_ cb: UICallbackOp) -> Void
    ) throws {
        let op =
            switch calculatorMode.keypadMode {
            case .Normal:
                op
            case .Mod1:
                opMod1
            case .Mod2:
                opMod2
            }

        switch op {
        case .calc(_, let calc, _):
            try stack.calculate(calc, calculatorMode)
        case .ui(_, let calcOp, _):
            if let uiCallback = try calcOp?(stack, input, calculatorMode) {
                handleUICallbackOp(uiCallback)
            }
        case nil:
            break
        }
    }

    static func empty(id: String? = nil) -> Key { Key(overriddenId: id) }

    static func enter() -> Key {
        Key(
            op: .ui(
                "Enter",
                { stack, _, _ in
                    stack.pushInput()
                    return nil
                },
                "StackEnter"),
            opMod1: .ui(
                "Help",
                { _, _, _ in .showHelp },
                "Help"))
    }

    static func pop() -> Key {
        Key(
            op: .ui(
                "Pop",
                { stack, _, _ in
                    stack.pop()
                    return nil
                },
                "PopStack"),
            opMod1: .ui(
                "Clear",
                { stack, _, _ in
                    stack.clear()
                    return nil
                },
                "ClearStack"))
    }

    static func backspace() -> Key {
        Key(
            op: .ui(
                "←",
                { _, input, _ in
                    input.backspace()
                    return nil
                },
                "Backspace"),
            opMod1: .ui(
                "Paste",
                { stack, _, _ throws in
                    if !CopyPaste.paste(stack) {
                        throw CalcError.pasteFailed()
                    }
                    return nil
                },
                "PasteValue"))
    }

    static func pick() -> Key {
        Key(
            op: .ui(
                "Pick",
                { stack, _, _ in
                    stack.pickSelected()
                    return nil
                },
                "PickSelected"),
            opMod1: .ui(
                "↺",
                { stack, _, _ in
                    stack.undo()
                    return nil
                },
                "Undo"),
            opMod2: .ui(
                "↻",
                { stack, _, _ in
                    stack.redo()
                    return nil
                },
                "Redo"))
    }

    static func swap() -> Key {
        Key(
            op: .ui(
                "x⇄y",
                { stack, _, _ in
                    stack.swapTop2()
                    return nil
                },
                "SwapTop2"),
            opMod1: .ui(
                "Copy",
                { stack, _, calculatorMode in
                    CopyPaste.copy(stack, calculatorMode, inputOnly: false)
                    return nil
                },

                "CopyValue"))
    }

    static func zero() -> Key {
        numkey(
            0,
            opMod1: .ui(
                "Matrix",
                { _, _, _ in .inputMatrix },
                "EnterMatrix"))
    }
    static func one() -> Key { numkey(1) }
    static func two() -> Key { numkey(2) }
    static func three() -> Key { numkey(3) }
    static func four() -> Key { numkey(4) }
    static func five() -> Key { numkey(5) }
    static func six() -> Key { numkey(6) }
    static func seven() -> Key { numkey(7) }
    static func eight() -> Key { numkey(8) }
    static func nine() -> Key { numkey(9) }

    static func dot() -> Key {
        Key(
            op: .ui(
                ".",
                { _, input, _ in
                    input.dot()
                    return nil
                }),
            opMod1: .ui(
                "π",
                { stack, input, _ in
                    if input.isEmpty {
                        stack.push(Value(NumericalValue.pi))
                    }
                    return nil
                }))
    }

    static func plusminus() -> Key {
        Key(
            op: .ui(
                "±",
                { stack, input, calculatorMode in
                    if !input.isEmpty {
                        input.plusminus()
                    } else {
                        _ = try? stack.calculate(Neg(), calculatorMode)
                    }
                    return nil
                }),
            opMod1: .calc("→∟", ToCartesian(), "ToCartesian"),
            opMod2: .calc("→∠", ToPolar(), "ToPolar"))
    }

    static func E() -> Key {
        Key(
            op: .ui(
                "E",
                { _, input, _ in
                    input.E()
                    return nil
                },
                "InputExponent"),
            opMod1: .calc("→E", ToEng(), "ScientificFormat"),
            opMod2: .calc("→D", ToDecimal(), "DecimalFormat"),
            isTightLayout: true)
    }

    static func plus() -> Key {
        Key(
            op: .calc("+", Plus(), "CalcPlus"),
            opMod1: .calc("Re", Re(), "RealPart"),
            opMod2: .calc("Im", Im(), "ImaginaryPart"))
    }

    static func minus() -> Key {
        Key(
            op: .calc("-", Minus(), "CalcMinus"),
            opMod1: .calc("Conj", Conjugate(), "ComplexConjugate"))
    }

    static func mult() -> Key { Key(op: .calc("×", Mult(), "CalcMultiply")) }

    static func div() -> Key { Key(op: .calc("÷", Div(), "CalcDivision")) }

    static func sin() -> Key {
        Key(
            op: .calc("sin", Sin(), "CalcSin"),
            opMod1: .calc("sin⁻¹", ASin(), "CalcArcSin"))
    }

    static func cos() -> Key {
        Key(
            op: .calc("cos", Cos(), "CalcCos"),
            opMod1: .calc("cos⁻¹", ACos(), "CalcArcCos"))
    }

    static func tan() -> Key {
        Key(
            op: .calc("tan", Tan(), "CalcTan"),
            opMod1: .calc("tan⁻¹", ATan(), "CalcArcTan"))
    }

    static func inv() -> Key {
        Key(
            op: .calc("¹/ₓ", Inv(), "CalcInv"),
            opMod1: .calc("nCr", Combinations(), "CalcCombinations"),
            opMod2: .calc("nPr", Permutations(), "CalcPermutations"),
            isTightLayout: true)
    }

    static func pow() -> Key {
        Key(
            op: .calc("x²", Square(), "CalcSquare"),
            opMod1: .calc("y³", Pow3(), "CalcCube"),
            opMod2: .calc("yˣ", Pow(), "CalcPow"))
    }

    static func root() -> Key {
        Key(
            op: .calc("√x", Sqrt(), "CalcSqrt"),
            opMod1: .calc("³√y", Root3(), "Calc3rdRoot"),
            opMod2: .calc("ˣ√y", NthRoot(), "CalcNthRoot"),
            isTightLayout: true)
    }

    static func log() -> Key {
        Key(
            op: .calc("ln", Log(), "CalcLn"),
            opMod1: .calc("eˣ", Exp(), "CalcExp"))
    }

    static func lg() -> Key {
        Key(
            op: .calc("lg", Log10(), "CalcLog10"),
            opMod1: .calc("10ˣ", Exp10(), "CalcExp10"),
            opMod2: .calc("n!", Factorial(), "CalcFactorial"))
    }

    static func complex() -> Key {
        Key(
            op: .calc("y + xi", Complex(), "MakeComplex"),
            opMod1: .calc("y∠x", ComplexPolar(), "MakePolarComplex"),
            opMod2: .calc("xi", ImaginaryNumber(), "MakeImaginary"))
    }

    static func fraction() -> Key {
        Key(
            op: .calc("ʸ⁄ₓ", RationalNumber(), "MakeRational"),
            opMod1: .calc("zʸ⁄ₓ", MixedRationalNumber(), "MakeMixedRational"),
            opMod2: .calc("→ʸ⁄ₓ", OnlyFraction(), "DisplayAsFraction"),
            isTightLayout: true)
    }

    static func numkey(
        _ num: Int,
        opMod1: CalcOp? = nil
    ) -> Key {
        return Key(
            op: .ui(
                String(num),
                { _, input, _ in
                    input.addNum(num)
                    return nil
                }),
            opMod1: opMod1)
    }

    static func matrixPi() -> Key {  // TODO
        Key(
            op: .ui(
                "π",
                { _, input, _ in
                    if input.isEmpty {
                        input.paste(NumericalValue.pi.stringValue())
                    }
                    return nil
                }))
    }

    static func matrixDot() -> Key {
        Key(
            op: .ui(
                ".",
                { _, input, _ in
                    input.dot()
                    return nil
                }))
    }

    static func matrixEnter() -> Key {
        Key(
            op: .ui("Enter", { _, _, _ in nil /* TODO */ }, "StackEnter"),
            opMod1: .ui("Help", { _, _, _ in .showHelp }, "Help"))
    }

    static func matrixCancel() -> Key {
        Key(op: .ui("Back", { _, _, _ in .dismissMatrix }, "MatrixCancel"))
    }

    static func matrixE() -> Key {
        Key(
            op: .ui(
                "E",
                { _, input, _ in
                    input.E()
                    return nil
                }, "InputExponent"))
    }

    static func matrixZero() -> Key { numkey(0) }

    static func matrixPlusminus() -> Key {
        Key(
            op: .ui(
                "±",
                { _, input, calculatorMode in
                    if !input.isEmpty {
                        input.plusminus()
                    }
                    return nil
                }))
    }

    static func matrixPaste() -> Key {
        Key(
            op: .ui(
                "Paste",
                {stack, input, _ throws in
                    if !CopyPaste.paste(stack) {
                        throw CalcError.pasteFailed()
                    }
                    return nil
                },
                "PasteValue"))
    }

    static func matrixBackspace() -> Key {
        Key(
            op: .ui(
                "←",
                { _, input, _ in
                    input.backspace()
                    return nil
                },
                "Backspace"))
    }

    static func angleMode() -> Key {
        Key(
            op: .ui(
                "⦠",
                { _, _, calculatorMode in
                    calculatorMode.swapAngle()
                    return nil
                },
                "SwapAngleMode"))
    }

    static func mod1() -> Key {
        let op:
            (
                (_ stack: Stack, _ input: InputBuffer, _ calculatorMode: CalculatorMode) ->
                    UICallbackOp?
            ) = { _, _, calculatorMode in
                calculatorMode.toggleMod1()
                return nil
            }

        return Key(
            op: .ui("Alt 1", op, "Alt1"),
            opMod1: .ui("", op),
            opMod2: .ui("", op),
            resetModAfterClick: .keep,
            mainTextColor: Styles.mod1TextColor)
    }

    static func mod2() -> Key {
        let op:
            (
                (_ stack: Stack, _ input: InputBuffer, _ calculatorMode: CalculatorMode) ->
                    UICallbackOp?
            ) = { _, _, calculatorMode in
                calculatorMode.toggleMod2()
                return nil
            }

        return Key(
            op: .ui("Alt 2", op, "Alt2"),
            opMod1: .ui("", op),
            opMod2: .ui("", op),
            resetModAfterClick: .keep,
            mainTextColor: Styles.mod2TextColor)
    }

    static private func editStackItem(_ stack: Stack) -> UICallbackOp? {
        if let selectedMatrix = stack.valueForEdit?.asMatrix {
            return .editMatrix(matrix: selectedMatrix)
        }
        return nil
    }
}

struct KeyRow: Identifiable {
    let keys: [Key]
    var id: String {
        "row_\(keys[0].id)"
    }
}

protocol KeypadModel {
    var keyRows: [KeyRow] { get }

    var rowCount: Int { get }
    var columnCount: Int { get }
}

struct BasicKeypadModel: KeypadModel {
    let keyRows: [KeyRow] = [
        KeyRow(keys: [ Key.pow(), Key.root(), Key.log(),
                       Key.lg(), Key.inv() ]),
        KeyRow(keys: [ Key.sin(), Key.cos(), Key.tan(),
                       Key.fraction(), Key.complex() ]),
        KeyRow(keys: [ Key.mod1(), Key.mod2(), Key.angleMode(),
                       Key.swap(), Key.backspace() ]),
        KeyRow(keys: [ Key.seven(), Key.eight(), Key.nine(),
                       Key.pick(), Key.pop() ]),
        KeyRow(keys: [ Key.four(), Key.five(), Key.six(),
                       Key.mult(), Key.div() ]),
        KeyRow(keys: [ Key.one(), Key.two(), Key.three(),
                       Key.plus(), Key.minus() ]),
        KeyRow(keys: [ Key.zero(), Key.dot(), Key.E(),
                       Key.plusminus(), Key.enter() ])
    ]

    var rowCount: Int {
        keyRows.count
    }

    var columnCount: Int {
        keyRows
            .map { row in row.keys.count }
            .reduce(0) { (res, count) in max(res, count) }
    }
}

struct MatrixKeypadModel: KeypadModel {

    let keyRows: [KeyRow] = [
        KeyRow(keys: [Key.mod1(), Key.empty(id: "empty1"), Key.empty(id: "empty2") ,
                      Key.empty(id: "empty3"), Key.empty(id: "empty4")]),
        KeyRow(keys: [ Key.seven(), Key.eight(), Key.nine(),
                       Key.empty(id: "empty5"), Key.matrixBackspace() ]),
        KeyRow(keys: [ Key.four(), Key.five(), Key.six(),
                       Key.empty(id: "empty6"), Key.matrixPaste() ]),
        KeyRow(keys: [ Key.one(), Key.two(), Key.three(),
                       Key.matrixPi(), Key.matrixCancel() ]),
        KeyRow(keys: [ Key.matrixZero(), Key.matrixDot(), Key.matrixE(),
                       Key.matrixPlusminus(), Key.matrixEnter() ])
    ]

    var rowCount: Int {
        keyRows.count
    }

    var columnCount: Int {
        keyRows
            .map { row in row.keys.count }
            .reduce(0) { (res, count) in max(res, count) }
    }
}
