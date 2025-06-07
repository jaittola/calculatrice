import UIKit
import SwiftUI

class StylesUIKit {
    static let margin: CGFloat = 8.0
    static let keypadMargin: CGFloat = 2.0

    static let stackFont = font(.body, size: 24, weight: .semibold)
    static let inputDisplayLabelFont = font(.body, size: 18, weight: .semibold)
    static let keypadMainFont = font(.body, size: 24, weight: .semibold)
    static let keypadModFont = font(.body, size: 18, weight: .semibold)

    static let maxContentSize: UIContentSizeCategory = .large

    static let mod1TextColor = UIColor(hex: "ffff00")
    static let mod2TextColor = UIColor(hex: "93f500")
    static let keypadMainTextColor = UIColor.white
    static let keyBackgroundColor = UIColor(hex: "3c3c47")
    static let keyPressedBackgroundColor = UIColor(hex: "303038")
    static let keypadBackgroundColor = UIColor(hex: "1c1c21")

    static let activeLabelColor = UIColor.white
    static let inactiveLabelColor = UIColor(hex: "2e22ff")

    static let windowBackgroundColor = UIColor.black

    static let displayBackgroundColor = UIColor.white
    static let selectedRowBackgroundColor = UIColor(hex: "f6ff00")
    static let stackTextColor = UIColor.black
    static let stackSeparatorColor = UIColor(hex: "dedede")
    static let matrixSelectedCellBorder = UIColor.blue

    private static func font(_ style: UIFont.TextStyle,
                             size: CGFloat,
                             weight: UIFont.Weight? = nil) -> UIFont {
        let base = weight == nil ? UIFont.systemFont(ofSize: size) : UIFont.systemFont(ofSize: size, weight: weight!)
        return UIFontMetrics(forTextStyle: style).scaledFont(for: base)
    }
}

extension UIFont {
    func asFont() -> Font {
        return Font(self as CTFont)
    }
}

extension UIColor {
    func asColor() -> Color {
        Color(self)
    }
}

struct Styles {
    static let stackFont = StylesUIKit.stackFont.asFont()
    static let inputDisplayLabelFont = StylesUIKit.inputDisplayLabelFont.asFont()
    static let keypadMainFont = StylesUIKit.keypadMainFont.asFont()
    static let keypadModFont = StylesUIKit.keypadModFont.asFont()

    static let mod1TextColor = StylesUIKit.mod1TextColor.asColor()
    static let mod2TextColor = StylesUIKit.mod2TextColor.asColor()
    static let keypadMainTextColor = StylesUIKit.keypadMainTextColor.asColor()
    static let keyBackgroundColor = StylesUIKit.keyBackgroundColor.asColor()
    static let keyPressedBackgroundColor = StylesUIKit.keyPressedBackgroundColor.asColor()
    static let keypadBackgroundColor = StylesUIKit.keypadBackgroundColor.asColor()

    static let activeLabelColor = StylesUIKit.activeLabelColor.asColor()
    static let inactiveLabelColor = StylesUIKit.inactiveLabelColor.asColor()

    static let windowBackgroundColor = StylesUIKit.windowBackgroundColor.asColor()

    static let displayBackgroundColor = StylesUIKit.displayBackgroundColor.asColor()
    static let selectedRowBackgroundColor = StylesUIKit.selectedRowBackgroundColor.asColor()
    static let stackTextColor = StylesUIKit.stackTextColor.asColor()
    static let stackSeparatorColor = StylesUIKit.stackSeparatorColor.asColor()
    static let matrixSelectedCellBorder = StylesUIKit.matrixSelectedCellBorder.asColor()
}
