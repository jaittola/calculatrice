import UIKit
import SnapKit

class InputDisplay: UIView {

    private let inputTextView = UILabel()
    var text: String = " " {
        didSet {
            inputTextView.text = text
        }
    }

    var onPaste: ((String?) -> Void)?

    override public var canBecomeFirstResponder: Bool {
        true
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(inputTextView)

        inputTextView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(Styles.margin)
        }
        backgroundColor = Styles.displayBackgroundColor

        inputTextView.textColor = Styles.stackTextColor
        inputTextView.numberOfLines = 1
        inputTextView.adjustsFontForContentSizeCategory = true
        inputTextView.font = Styles.stackFont

        addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(showMenu(sender:))
        ))
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = inputTextView.text
        UIMenuController.shared.hideMenu()
    }

    override func paste(_ sender: Any?) {
        onPaste?(UIPasteboard.general.string)
        UIMenuController.shared.hideMenu()
    }

    @objc func showMenu(sender: Any?) {
        becomeFirstResponder()
        let menu = UIMenuController.shared
        if !menu.isMenuVisible {
            UIMenuController.shared.showMenu(from: self, rect: bounds)
        }
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        let isInputEmpty = inputTextView.text?.trimmingCharacters(in: .whitespaces).isEmpty ?? true
        let isPasteboardEmpty = UIPasteboard.general.string?.isEmpty ?? true

        return ((action == #selector(copy(_:)) && !isInputEmpty) ||
                (action == #selector(paste(_:)) && !isPasteboardEmpty))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
