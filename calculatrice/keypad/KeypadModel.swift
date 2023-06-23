import Foundation
import UIKit

struct Key: Identifiable {
    let symbol: String
    let symbolMod1: String?
    let symbolMod2: String?

    let op: ((_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void)?
    let opMod1: ((_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void)?
    let opMod2: ((_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void)?

    let calcOp: Calculation?
    let calcOpMod1: Calculation?
    let calcOpMod2: Calculation?

    let resetModAfterClick: Bool

    let mainTextColor: UIColor?

    var id: String {
        "\(symbol)_\(symbolMod1 ?? "")_\(symbolMod2 ?? "")"
    }

    init(symbol: String,
         op: ((_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void)? = nil,
         calcOp: Calculation? = nil,
         symbolMod1: String? = nil,
         opMod1: ((_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void)? = nil,
         calcOpMod1: Calculation? = nil,
         symbolMod2: String? = nil,
         opMod2: ((_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void)? = nil,
         calcOpMod2: Calculation? = nil,
         resetModAfterClick: Bool = true,
         mainTextColor: UIColor? = nil) {
        self.symbol = symbol
        self.op = op
        self.symbolMod1 = symbolMod1
        self.opMod1 = opMod1
        self.symbolMod2 = symbolMod2
        self.opMod2 = opMod2
        self.calcOp = calcOp
        self.calcOpMod1 = calcOpMod1
        self.calcOpMod2 = calcOpMod2
        self.resetModAfterClick = resetModAfterClick
        self.mainTextColor = mainTextColor
    }

    func activeOp(_ calculatorMode: CalculatorMode, _ stack: Stack) throws {
        do {
            var stackOp: ((_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void)?
            var calculationOp: Calculation?

            switch calculatorMode.keypadMode {
            case .Normal:
                stackOp = op
                calculationOp = calcOp
            case .Mod1:
                stackOp = opMod1
                calculationOp = calcOpMod1
            case .Mod2:
                stackOp = opMod2
                calculationOp = calcOpMod2
            }

            if let stackOp = stackOp {
                stackOp(stack, calculatorMode)
            } else if let calculationOp = calculationOp {
                try stack.calculate(calculationOp, calculatorMode)
            }
        } catch {
            throw error
        }
    }

    static func empty() -> Key { Key(symbol: "") }

    static func enter() -> Key { Key(symbol: "Enter",
                                     op: { stack, _ in stack.pushInput() })}
    static func pop() -> Key { Key(symbol: "Pop",
                                   op: { stack, _ in stack.pop() },
                                   symbolMod1: "Clear",
                                   opMod1: { stack, _ in stack.clear() })}

    static func backspace() -> Key { Key(symbol: "←",
                                         op: { stack, _ in stack.input.backspace() })}
    static func pick() -> Key { Key(symbol: "Pick",
                                    op: { stack, _ in stack.pickSelected() })}

    static func swap() -> Key { Key(symbol: "x⇄y", op: { stack, _ in stack.swapTop2() }) }

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
    static func dot() -> Key { Key(symbol: ".",
                                   op: { stack, _ in stack.input.dot() },
                                   symbolMod1: "π",
                                   opMod1: { stack, _ in
        if stack.input.isEmpty {
            stack.push(Value(DoublePrecisionValue(Double.pi)))
        }
    }) }
    static func plusminus() -> Key { Key(symbol: "±",
                                         op: { stack, calculatorMode in
        if !stack.input.isEmpty {
            stack.input.plusminus()
        } else {
            _ = try? stack.calculate(Neg(), calculatorMode)
        }
    },
                                         symbolMod1: "→ ∟",
                                         calcOpMod1: ToCartesian(),
                                         symbolMod2: "→ ∠",
                                         calcOpMod2: ToPolar()) }
    static func E() -> Key { Key(symbol: "E",
                                 op: { stack, _ in stack.input.E() },
                                 symbolMod1: "→E",
                                 calcOpMod1: ToEng(),
                                 symbolMod2: "→D",
                                 calcOpMod2: ToDecimal()) }

    static func plus() -> Key { Key(symbol: "+", calcOp: Plus(),
                                    symbolMod1: "Re", calcOpMod1: Re(),
                                    symbolMod2: "Im", calcOpMod2: Im()) }
    static func minus() -> Key { Key(symbol: "-", calcOp: Minus(),
                                     symbolMod1: "Conj", calcOpMod1: Conjugate()) }
    static func mult() -> Key { Key(symbol: "×", calcOp: Mult()) }
    static func div() -> Key { Key(symbol: "÷", calcOp: Div()) }
    static func sin() -> Key { Key(symbol: "sin", calcOp: Sin(),
                                   symbolMod1: "sin⁻¹", calcOpMod1: ASin()) }
    static func cos() -> Key { Key(symbol: "cos", calcOp: Cos(),
                                   symbolMod1: "cos⁻¹", calcOpMod1: ACos()) }
    static func tan() -> Key { Key(symbol: "tan", calcOp: Tan(),
                                   symbolMod1: "tan⁻¹", calcOpMod1: ATan()) }
    static func inv() -> Key { Key(symbol: "¹/ₓ", calcOp: Inv()) }
    static func pow() -> Key { Key(symbol: "x²", calcOp: Square(),
                                   symbolMod1: "y³", calcOpMod1: Pow3(),
                                   symbolMod2: "yˣ", calcOpMod2: Pow()) }
    static func root() -> Key { Key(symbol: "√x", calcOp: Sqrt(),
                                    symbolMod1: "³√y", calcOpMod1: Root3(),
                                    symbolMod2: "ˣ√y", calcOpMod2: NthRoot()) }
    static func log() -> Key { Key(symbol: "ln", calcOp: Log(),
                                   symbolMod1: "eˣ", calcOpMod1: Exp()) }
    static func lg() -> Key { Key(symbol: "lg", calcOp: Log10(),
                                  symbolMod1: "10ˣ", calcOpMod1: Exp10()) }
    static func complex() -> Key { Key(symbol: "y + xi", calcOp: Complex(),
                                       symbolMod1: "y∠x", calcOpMod1: ComplexPolar(),
                                       symbolMod2: "xi", calcOpMod2: ImaginaryNumber()) }

    static func numkey(_ num: Int) -> Key {
        return Key(symbol: String(num),
                   op: { stack, _ in stack.input.addNum(num) },
                   resetModAfterClick: true)
    }

    static func angleMode() -> Key { Key(symbol: "⦠",
                                         op: { _, calculatorMode in calculatorMode.swapAngle() })}
    static func mod1() -> Key {
        let op: ((_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void) = { _, calculatorMode in calculatorMode.toggleMod1() }
        return Key(symbol: "Alt 1",
                   op: op,
                   opMod1: op,
                   opMod2: op,
                   resetModAfterClick: false,
                   mainTextColor: Styles.mod1TextColor)

    }

    static func mod2() -> Key {
        let op: ((_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void) = { _, calculatorMode in calculatorMode.toggleMod2() }
        return Key(symbol: "Alt 2",
                   op: op,
                   opMod1: op,
                   opMod2: op,
                   resetModAfterClick: false,
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
    var keys: [[Key?]] { get }
    var keyRows: [KeyRow] { get }

    var rowCount: Int { get }
    var columnCount: Int { get }
}

struct BasicKeypadModel: KeypadModel {
    let keys: [[Key?]] = [
        [ Key.pow(), Key.root(), Key.log(), Key.lg(), Key.inv() ],
        [ Key.sin(), Key.cos(), Key.tan(), nil, Key.complex() ],
        [ Key.mod1(), Key.mod2(), Key.angleMode(), Key.swap(), Key.backspace() ],
        [ Key.seven(), Key.eight(), Key.nine(), Key.pick(), Key.pop() ],
        [ Key.four(), Key.five(), Key.six(), Key.mult(), Key.div() ],
        [ Key.one(), Key.two(), Key.three(), Key.plus(), Key.minus() ],
        [ Key.zero(), Key.dot(), Key.E(), Key.plusminus(), Key.enter() ]
    ]

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
