import Foundation
import UIKit

protocol KeypadModel {
    var keys: [[Key?]] { get }
}

struct Key {
    let symbol: String
    let op: (_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void

    let symbolMod1: String?
    let opMod1: ((_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void)?

    let resetModAfterClick: Bool

    let mainTextColor: UIColor?

    init(symbol: String,
         op: @escaping (_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void,
         symbolMod1: String? = nil,
         opMod1: ((_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void)? = nil,
         resetModAfterClick: Bool = true,
         mainTextColor: UIColor? = nil) {
        self.symbol = symbol
        self.op = op
        self.symbolMod1 = symbolMod1
        self.opMod1 = opMod1
        self.resetModAfterClick = resetModAfterClick
        self.mainTextColor = mainTextColor
    }

    init(symbol: String,
         calcOp: Calculation,
         symbolMod1: String? = nil,
         calcOpMod1: Calculation? = nil) {
        self.init(symbol: symbol,
                  op: { stack, calculatorMode in stack.calculate(calcOp, calculatorMode)},
                  symbolMod1: symbolMod1,
                  opMod1: calcOpMod1 != nil  ? { stack, calculatorMode in stack.calculate(calcOpMod1!, calculatorMode)} : nil)
    }

    func activeOp(_ calculatorMode: CalculatorMode) -> ((_ stack: Stack, _ calculatorMode: CalculatorMode) -> Void) {
        if calculatorMode.keypadMode == .Mod1,
           let opMod1 = opMod1 {
            return opMod1
        }
        return op
    }

    static func enter() -> Key { Key(symbol: "ENTER",
                                     op: { stack, _ in stack.pushInput() })}
    static func pop() -> Key { Key(symbol: "POP",
                                   op: { stack, _ in stack.pop() },
                                   symbolMod1: "CLEAR",
                                   opMod1: { stack, _ in stack.clear() })}

    static func backspace() -> Key { Key(symbol: "￩",
                                         op: { stack, _ in stack.input.backspace() })}
    static func pick() -> Key { Key(symbol: "PICK",
                                    op: { stack, _ in stack.pickSelected() },
                                    symbolMod1: "x⇄y",
                                    opMod1: { stack, _ in stack.swapTop2() })}

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
                                   op: { stack, _ in stack.input.dot() }) }
    static func pi() -> Key { Key(symbol: "π",
                                  op: { stack, _ in
        if stack.input.isEmpty {
            stack.push(CalculatedStackValue(Double.pi))
        }
    }) }
    static func plusminus() -> Key { Key(symbol: "±",
                                         op: { stack, calculatorMode in
        if !stack.input.isEmpty {
            stack.input.plusminus()
        } else {
            stack.calculate(Neg(), calculatorMode)
        }
    }) }
    static func plus() -> Key { Key(symbol: "+", calcOp: Plus()) }
    static func minus() -> Key { Key(symbol: "-", calcOp: Minus()) }
    static func mult() -> Key { Key(symbol: "×", calcOp: Mult()) }
    static func div() -> Key { Key(symbol: "÷", calcOp: Div()) }
    static func sin() -> Key { Key(symbol: "sin", calcOp: Sin(),
                                   symbolMod1: "sin⁻¹", calcOpMod1: ASin()) }
    static func cos() -> Key { Key(symbol: "cos", calcOp: Cos(),
                                   symbolMod1: "cos⁻¹", calcOpMod1: ACos()) }
    static func tan() -> Key { Key(symbol: "tan", calcOp: Tan(),
                                   symbolMod1: "tan⁻¹", calcOpMod1: ATan()) }
    static func inv() -> Key { Key(symbol: "¹/ₓ", calcOp: Inv()) }
    static func pow() -> Key { Key(symbol: "x^2", calcOp: Square() ,
                                   symbolMod1: "y^x", calcOpMod1: Pow()) }
    static func root() -> Key { Key(symbol: "SQRT(x)", calcOp: Sqrt(),
                                    symbolMod1: "NRT(x)", calcOpMod1: NthRoot()) }
    static func log() -> Key { Key(symbol: "ln", calcOp: Log(),
                                   symbolMod1: "e^x", calcOpMod1: Exp())}

    static func numkey(_ num: Int) -> Key {
        Key(symbol: String(num),
            op: { stack, _ in stack.input.addNum(num) },
            resetModAfterClick: false)
    }

    static func angleMode() -> Key { Key(symbol: "⦠",
                                         op: { _, calculatorMode in calculatorMode.swapAngle() })}
    static func mod1() -> Key { Key(symbol: "MOD1",
                                    op: { _, calculatorMode in calculatorMode.toggleMod1() },
                                    resetModAfterClick: false,
                                    mainTextColor: Styles.mod1TextColor)}
}

class BasicKeypadModel: NSObject, KeypadModel {
    let keys: [[Key?]] = [
        [ nil, Key.pow(), Key.root(), Key.log(), nil ],
        [ nil, Key.sin(), Key.cos(), Key.tan(), Key.inv() ],
        [ nil, Key.enter(), Key.pick(), Key.pop(), Key.backspace() ],
        [ nil, Key.seven(), Key.eight(), Key.nine(), Key.div() ],
        [ Key.mod1(), Key.four(), Key.five(), Key.six(), Key.mult() ],
        [ Key.angleMode(), Key.one(), Key.two(), Key.three(), Key.minus() ],
        [ Key.pi(), Key.zero(), Key.dot(), Key.plusminus(), Key.plus() ]
    ]
}
