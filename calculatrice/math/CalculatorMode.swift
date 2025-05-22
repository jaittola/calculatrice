import Foundation

struct ValueMode {
    var angle: CalculatorMode.Angle = .Deg
}

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

    enum MainViewMode {
        case Normal
        case Matrix
    }

    @Published
    var valueMode: ValueMode = ValueMode(angle: .Deg)

    @Published
    var angle: Angle = .Deg {
        didSet {
            valueMode = ValueMode(angle: angle)
        }
    }

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

    convenience init(initialMainMode: MainViewMode) {
        self.init()
        self.mainViewMode = initialMainMode
    }

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
