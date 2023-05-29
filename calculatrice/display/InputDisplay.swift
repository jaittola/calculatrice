import UIKit
import SnapKit

class InputDisplay: UIView, UIEditMenuInteractionDelegate {

    private let inputTextView = UILabel()

    private var editMenuInteraction: UIEditMenuInteraction?

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

        editMenuInteraction = UIEditMenuInteraction(delegate: self)
        self.addInteraction(editMenuInteraction!)

        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(showMenu(_:))
        )
        longPress.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        addGestureRecognizer(longPress)
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = inputTextView.text
        editMenuInteraction?.dismissMenu()
    }

    override func paste(_ sender: Any?) {
        onPaste?(UIPasteboard.general.string)
        editMenuInteraction?.dismissMenu()
    }

    @objc func showMenu(_ recognizer: UIGestureRecognizer) {
        becomeFirstResponder()

        let location = recognizer.location(in: self)
        let configuration = UIEditMenuConfiguration(identifier: nil,
                                                    sourcePoint: location)

        editMenuInteraction?.presentEditMenu(with: configuration)
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
