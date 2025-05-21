import Foundation

class CalculatorMode: ObservableObject {
    enum Angle {
        case Deg
        case Rad
    }

    enum KeypadMode {
        case Normal
        case Mod1
        case Mod2
    }

    enum NumberMode {
        case Decimal
        case Engineering
    }

    enum MainViewMode {
        case Normal
        case Matrix
    }

    @Published
    var angle: Angle = .Deg

    @Published
    var keypadMode: KeypadMode = .Normal

    @Published
    var mainViewMode: MainViewMode = .Normal {
        didSet {
            switch mainViewMode {
            case .Normal:
                keypadModel = BasicKeypadModel()
            case .Matrix:
                keypadModel = MatrixKeypadModel()
            }
        }
    }

    @Published
    private(set) var keypadModel: KeypadModel = BasicKeypadModel()

    func swapAngle() {
        if angle == .Deg {
            angle = .Rad
        } else {
            angle = .Deg
        }
    }

    func toggleMod1() {
        if keypadMode == .Mod1 {
            keypadMode = .Normal
        } else {
            keypadMode = .Mod1
        }
    }

    func toggleMod2() {
        if keypadMode == .Mod2 {
            keypadMode = .Normal
        } else {
            keypadMode = .Mod2
        }
    }

    func resetMods() {
        keypadMode = .Normal
    }
}
