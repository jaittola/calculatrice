import Foundation

class InputBuffer {
    var value: DoublePrecisionValue {
        buildValue()
    }

    var isEmpty: Bool {
        inputs.isEmpty
    }

    var isFull: Bool {
        inputs.count >= 24
    }

    private var inputs: [InputElement] = []
    private var signum: Double = 1.0
    private var exponentSignum: Double = 1.0

    func addNum(_ number: Int) {
        let v = mantissaExpValue
        if (number != 0 || inputs.isEmpty || v.value != 0 || isInputtingDecimals) && !isFull && v.exponent < 10 && v.exponent > -10 {
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

    private func swapSignum(_ sign: Double) -> Double {
        sign < 0 ? 1.0 : -1.0
    }

    private func buildValue() -> DoublePrecisionValue {
        DoublePrecisionValue(doubleValue,
                             stringValue)
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
        return inputs.reduce(MantissaExponent(sign: signum, expoSign: exponentSignum)) { (_ acc: MantissaExponent, _ input: InputElement) -> MantissaExponent in
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
                    return MantissaExponent(mant: coeff * acc.mantissa + Double(num),
                                            expo: acc.exponent,
                                            sign: acc.signum,
                                            expoSign: acc.exponentSignum)
                case .Decimal(let coeff):
                    let result = MantissaExponent(mant: acc.mantissa + coeff * Double(num),
                                                  expo: acc.exponent,
                                                  sign: acc.signum,
                                                  expoSign: acc.exponentSignum)
                    inputState = .Decimal(coeff * 0.1)
                    return result
                case .Exponent(let coeff):
                    return MantissaExponent(mant: acc.mantissa,
                                            expo: coeff * acc.exponent + Double(num),
                                            sign: acc.signum,
                                            expoSign: acc.exponentSignum)
                }
            }
        }
    }

    private var doubleValue: Double {
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

    private enum InputElement {
        case Number(_ number: Int)
        case Dot
        case E
    }

    private enum InputState {
        case Whole(_ coeff: Double = 10.0)
        case Decimal(_ coeff: Double = 0.1)
        case Exponent(_ coeff: Double = 10.0)
    }
}

struct MantissaExponent {
    var mantissa: Double
    var exponent: Double
    var signum: Double
    var exponentSignum: Double

    init(mant: Double = 0.0, expo: Double = 0.0,
         sign: Double = 1.0,
         expoSign: Double = 1.0) {
        mantissa = mant
        exponent = expo
        signum = sign
        exponentSignum = expoSign
    }

    var value: Double {
        signum * mantissa * powl(10.0, exponent * exponentSignum)
    }
}
