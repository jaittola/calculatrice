import Foundation

class CalculatorMode {
    enum Angle {
        case Deg
        case Rad
    }

    enum KeypadMode {
        case Normal
        case Mod1
    }

    var angle: Angle = .Deg
    var keypadMode: KeypadMode = .Normal

    func swapAngle() {
        if angle == .Deg {
            angle = .Rad
        } else {
            angle = .Deg
        }
    }

    func toggleMod1() {
        if keypadMode == .Normal {
            keypadMode = .Mod1
        } else {
            keypadMode = .Normal
        }
    }

    func resetMods() {
        keypadMode = .Normal
    }
}
