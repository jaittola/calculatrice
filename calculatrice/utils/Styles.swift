import UIKit

class Styles {
    static let margin: CGFloat = 8.0
    static let keypadMargin: CGFloat = 2.0

    static let stackFont = font(.body, size: 20, weight: .semibold)
    static let inputDisplayLabelFont = font(.body, size: 14, weight: .semibold)
    static let keypadMainFont = font(.body, size: 20, weight: .semibold)
    static let keypadModFont = font(.body, size: 13, weight: .semibold)

    static let mod1TextColor = UIColor(hex: "ffff00")
    static let mod2TextColor = UIColor(hex: "93f500")
    static let keypadMainTextColor = UIColor.white
    static let keyBackgroundColor = UIColor(hex: "2b2b40")
    static let keyPressedBackgroundColor = UIColor(hex: "7f7f7f")

    static let activeLabelColor = UIColor.white
    static let inactiveLabelColor = UIColor(hex: "2e22ff")

    static let windowBackgroundColor = UIColor.black

    static let displayBackgroundColor = UIColor.white
    static let selectedRowBackgroundColor = UIColor(hex: "f6ff00")
    static let stackTextColor = UIColor.black
    static let stackSeparatorColor = UIColor(hex: "dedede")

    private static func font(_ style: UIFont.TextStyle,
                             size: CGFloat,
                             weight: UIFont.Weight? = nil) -> UIFont {
        let base = weight == nil ? UIFont.systemFont(ofSize: size) : UIFont.systemFont(ofSize: size, weight: weight!)
        return UIFontMetrics(forTextStyle: style).scaledFont(for: base)
    }
}
