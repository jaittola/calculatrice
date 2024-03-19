import Foundation
import BigNum

class InputBuffer: ObservableObject {
    var value: NumericalValue {
        buildValue()
    }

    var isEmpty: Bool {
        inputs.isEmpty
    }

    var isFull: Bool {
        inputs.count >= 100
    }

    @Published
    var inputs: [InputElement] = []

    @Published
    private var signum: BigFloat = 1.0

    @Published
    private var exponentSignum: BigFloat = 1.0

    func addNum(_ number: Int) {
        let v = mantissaExpValue
        if (number != 0 || inputs.isEmpty || v.value != 0 || isInputtingDecimals) && !isFull && v.exponent < 10000 && v.exponent > -10000 {
            inputs.append(.Number(number))
        }
    }

    func paste(_ text: String) {
        text.forEach { c in
            if c == "." || c == "," {
                dot()
            } else if c.isNumber, let intv = Int(String(c)) {
                addNum(intv)
            }
        }
    }

    func dot() {
        if !isInputtingDecimals && !isInputtingExponent {
            inputs.append(.Dot)
        }
    }

    func E() {
        if !isInputtingExponent && !isEmpty {
            inputs.append(.E)
        }
    }

    func plusminus() {
        if isInputtingExponent {
            exponentSignum = swapSignum(exponentSignum)
        } else {
            signum = swapSignum(signum)
        }
    }

    func backspace() {
        if !inputs.isEmpty {
            inputs.removeLast()
            if !isInputtingExponent {
                exponentSignum = 1.0
            }
        }
    }

    func clear() {
        inputs = []
        signum = 1.0
        exponentSignum = 1.0
    }

    private func swapSignum(_ sign: BigFloat) -> BigFloat {
        sign < 0 ? 1.0 : -1.0
    }

    private func buildValue() -> NumericalValue {
        NumericalValue(numericalValue,
                       originalStringValue: stringValue)
    }

    private var isInputtingDecimals: Bool {
        inputs.contains { ie in
            if case .Dot = ie {
                return true
            } else {
                return false
            }
        }
    }

    private var isInputtingExponent: Bool {
        inputs.contains { ie in
            if case .E = ie {
                return true
            } else {
                return false
            }
        }
    }

    private var mantissaExpValue: MantissaExponent {
        var inputState: InputState = .Whole()
        return inputs.reduce(
            MantissaExponent(sign: signum, expoSign: exponentSignum)) { (_ acc: MantissaExponent,
                                                                         _ input: InputElement) -> MantissaExponent in
            switch input {
            case .Dot:
                if case .Whole = inputState {
                    inputState = .Decimal()
                }
                return acc
            case .E:
                switch inputState {
                case .Decimal, .Whole:
                    inputState = .Exponent()
                case .Exponent:
                    break
                }
                return acc
            case .Number(let num):
                switch inputState {
                case .Whole(let coeff):
                    return MantissaExponent(mant: coeff * acc.mantissa + BigFloat(num),
                                            expo: acc.exponent,
                                            sign: acc.signum,
                                            expoSign: acc.exponentSignum)
                case .Decimal(let coeff):
                    let result = MantissaExponent(mant: acc.mantissa + coeff * BigFloat(num),
                                                  expo: acc.exponent,
                                                  sign: acc.signum,
                                                  expoSign: acc.exponentSignum)
                    inputState = .Decimal(coeff * 0.1)
                    return result
                case .Exponent(let coeff):
                    return MantissaExponent(mant: acc.mantissa,
                                            expo: coeff * acc.exponent + BigFloat(num),
                                            sign: acc.signum,
                                            expoSign: acc.exponentSignum)
                }
            }
        }
    }

    private var numericalValue: BigFloat {
        mantissaExpValue.value
    }

    private var stringValue: String {
        var startValue = signum > 0 ? "" : "-"
        if inputs.count == 0 {
            startValue.append("0")
        } else if case .Dot = inputs[0] {
            startValue.append("0")
        }

        return inputs.reduce(startValue) { (buffer, input) in
            var b = buffer
            switch input {
            case .Dot:
                b.append(".")
            case .Number(let n):
                b.append(String(n))
            case .E:
                b.append("E")
                if exponentSignum < 0 {
                    b.append("-")
                }
            }
            return b
        }
    }

    enum InputElement {
        case Number(_ number: Int)
        case Dot
        case E
    }

    private enum InputState {
        case Whole(_ coeff: BigFloat = 10.0)
        case Decimal(_ coeff: BigFloat = 0.1)
        case Exponent(_ coeff: BigFloat = 10.0)
    }
}

struct MantissaExponent {
    var mantissa: BigFloat
    var exponent: BigFloat
    var signum: BigFloat
    var exponentSignum: BigFloat

    init(mant: BigFloat = 0.0,
         expo: BigFloat = 0.0,
         sign: BigFloat = 1.0,
         expoSign: BigFloat = 1.0) {
        mantissa = mant
        exponent = expo
        signum = sign
        exponentSignum = expoSign
    }

    var value: BigFloat {
        signum * mantissa * BigFloat.pow(10.0, exponent * exponentSignum)
    }
}
