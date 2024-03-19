import Foundation
import UIKit

struct Key: Identifiable {
    enum UICallbackOp {
        case showHelp
    }

    enum ResetModAfterClick {
        case keep
        case reset
    }

    enum CalcOp {
        case stackOp(_ symbol: String,
                     _ op: (_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void,
                     _ helpTextKey: String? = nil)
        case calcOp(_ symbol: String,
                    _ calc: Calculation,
                    _ helpTextKey: String? = nil)
        case uiOp(_ symbol: String,
                  _ uiCallback: UICallbackOp,
                  _ helpTextKey: String? = nil)

        var helpTextKey: String? {
            switch self {
            case .stackOp(_, _, let helpTextKey): helpTextKey
            case .calcOp(_, _, let helpTextKey): helpTextKey
            case .uiOp(_, _, let helpTextKey): helpTextKey
            }
        }

        var symbol: String? {
            switch self {
            case .stackOp(let symbol, _, _): symbol
            case .calcOp(let symbol, _, _): symbol
            case .uiOp(let symbol, _, _): symbol
            }
        }
    }

    let op: CalcOp?
    let opMod1: CalcOp?
    let opMod2: CalcOp?

    let resetModAfterClick: ResetModAfterClick

    let mainTextColor: UIColor?

    var id: String {
        "\(op?.symbol ?? "")_\(opMod1?.symbol ?? "")_\(opMod2?.symbol ?? "")"
    }

    init (op: CalcOp? = nil,
          opMod1: CalcOp? = nil,
          opMod2: CalcOp? = nil,
          resetModAfterClick: ResetModAfterClick = .reset,
          mainTextColor: UIColor? = nil) {
        self.op = op
        self.opMod1 = opMod1
        self.opMod2 = opMod2
        self.resetModAfterClick = resetModAfterClick
        self.mainTextColor = mainTextColor
    }

    func activeOp(_ calculatorMode: CalculatorMode,
                  _ stack: Stack,
                  _ handleUICallbackOp: (_ cb: UICallbackOp) -> Void) throws {
        do {
            let op = switch calculatorMode.keypadMode {
            case .Normal:
                op
            case .Mod1:
                opMod1
            case .Mod2:
                opMod2
            }

            switch op {
            case .stackOp(_, let stackOp, _): stackOp(stack, calculatorMode)
            case .calcOp(_, let calcOp, _): try stack.calculate(calcOp, calculatorMode)
            case .uiOp(_, let uiOp, _): handleUICallbackOp(uiOp)
            case nil: break
            }
        } catch {
            throw error
        }
    }

    static func makeOp (_ symbol: String?,
                        _ op: ((_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void)?,
                        _ calcOp: Calculation?,
                        _ uiOp: UICallbackOp?) -> CalcOp? {
        guard let symbol = symbol else {
            return nil
        }

        return if let uiOp = uiOp {
            .uiOp(symbol, uiOp)
        } else if let op = op {
            .stackOp(symbol, op)
        } else if let calcOP = calcOp {
            .calcOp(symbol, calcOP)
        } else {
            nil
        }
    }

    static func empty() -> Key { Key() }

    static func enter() -> Key {
        Key(op: .stackOp("Enter", { stack, _ in stack.pushInput() }, "StackEnter"),
            opMod1: .uiOp("Help", .showHelp, "Help")) }

    static func pop() -> Key {
        Key(op: .stackOp("Pop", { stack, _ in stack.pop() }, "PopStack"),
            opMod1: .stackOp("Clear", { stack, _ in stack.clear() }, "ClearStack"))}

    static func backspace() -> Key {
        Key(op: .stackOp("←", { stack, _ in stack.input.backspace() }, "Backspace")) }

    static func pick() -> Key {
        Key(op: .stackOp("Pick", { stack, _ in stack.pickSelected() }, "PickSelected"),
            opMod1: .stackOp("↺", { stack, _ in stack.undo() }, "Undo"),
            opMod2: .stackOp("↻", { stack, _ in stack.redo() }, "Redo")) }

    static func swap() -> Key {
        Key(op: .stackOp("x⇄y", { stack, _ in stack.swapTop2() }, "SwapTop2")) }

    static func zero() -> Key { numkey(0) }
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
        Key(op: .stackOp(".", { stack, _ in stack.input.dot() }),
            opMod1: .stackOp("π", { stack, _ in
            if stack.input.isEmpty {
                stack.push(Value(NumericalValue.pi))
            }
        })) }

    static func plusminus() -> Key {
        Key(op: .stackOp("±", { stack, calculatorMode in
            if !stack.input.isEmpty {
                stack.input.plusminus()
            } else {
                _ = try? stack.calculate(Neg(), calculatorMode)
            }
        }),
            opMod1: .calcOp("→∟", ToCartesian(), "ToCartesian"),
            opMod2: .calcOp("→∠", ToPolar(), "ToPolar")) }

    static func E() -> Key {
        Key(op: .stackOp("E", { stack, _ in stack.input.E() }, "InputExponent"),
            opMod1: .calcOp("→E", ToEng(), "ScientificFormat"),
            opMod2: .calcOp("→D", ToDecimal(), "DecimalFormat")) }

    static func plus() -> Key {
        Key(op: .calcOp("+", Plus(), "CalcPlus"),
            opMod1: .calcOp("Re", Re(), "RealPart"),
            opMod2: .calcOp("Im", Im(), "ImaginaryPart")) }

    static func minus() -> Key {
        Key(op: .calcOp("-", Minus(), "CalcMinus"),
            opMod1: .calcOp("Conj", Conjugate(), "ComplexConjugate")) }

    static func mult() -> Key { Key(op: .calcOp("×", Mult(), "CalcMultiply")) }

    static func div() -> Key { Key(op: .calcOp("÷", Div(), "CalcDivision")) }

    static func sin() -> Key {
        Key(op: .calcOp("sin", Sin(), "CalcSin"),
            opMod1: .calcOp("sin⁻¹", ASin(), "CalcArcSin")) }

    static func cos() -> Key {
        Key(op: .calcOp("cos", Cos(), "CalcCos"),
            opMod1: .calcOp("cos⁻¹", ACos(), "CalcArcCos")) }

    static func tan() -> Key {
        Key(op: .calcOp("tan", Tan(), "CalcTan"),
            opMod1: .calcOp("tan⁻¹", ATan(), "CalcArcTan")) }

    static func inv() -> Key {
        Key(op: .calcOp("¹/ₓ", Inv(), "CalcInv")) }

    static func pow() -> Key {
        Key(op: .calcOp("x²", Square(), "CalcSquare"),
            opMod1: .calcOp("y³", Pow3(), "CalcCube"),
            opMod2: .calcOp("yˣ", Pow(), "CalcPow")) }

    static func root() -> Key {
        Key(op: .calcOp("√x", Sqrt(), "CalcSqrt"),
            opMod1: .calcOp("³√y", Root3(), "Calc3rdRoot"),
            opMod2: .calcOp("ˣ√y", NthRoot(), "CalcNthRoot")) }

    static func log() -> Key {
        Key(op: .calcOp("ln", Log(), "CalcLn"),
            opMod1: .calcOp("eˣ", Exp(), "CalcExp")) }

    static func lg() -> Key { Key(op: .calcOp("lg", Log10(), "CalcLog10"),
                                  opMod1: .calcOp("10ˣ", Exp10(), "CalcExp10")) }

    static func complex() -> Key {
        Key(op: .calcOp("y + xi", Complex(), "MakeComplex"),
            opMod1: .calcOp("y∠x", ComplexPolar(), "MakePolarComplex"),
            opMod2: .calcOp("xi", ImaginaryNumber(), "MakeImaginary")) }

    static func numkey(_ num: Int) -> Key {
        return Key(op: .stackOp(String(num), { stack, _ in stack.input.addNum(num) }))
    }

    static func angleMode() -> Key {
        Key(op: .stackOp("⦠", { _, calculatorMode in calculatorMode.swapAngle() },
                         "SwapAngleMode"))}

    static func mod1() -> Key {
        let op: ((_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void) = { _, calculatorMode in calculatorMode.toggleMod1() }
        return Key(op: .stackOp("Alt 1", op, "Alt1"),
                   opMod1: .stackOp("", op),
                   opMod2: .stackOp("", op),
                   resetModAfterClick: .keep,
                   mainTextColor: Styles.mod1TextColor)
    }

    static func mod2() -> Key {
        let op: ((_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void) = { _, calculatorMode in calculatorMode.toggleMod2() }
        return Key(op: .stackOp("Alt 2", op, "Alt2"),
                   opMod1: .stackOp("", op),
                   opMod2: .stackOp("", op),
                   resetModAfterClick: .keep,
                   mainTextColor: Styles.mod2TextColor)
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
                       Key.empty(), Key.complex() ]),
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
