import UIKit
import SnapKit

class InputDisplay: UIView {

    private let inputTextView = UILabel()

    private let degLabel = UILabel()
    private let radLabel = UILabel()
    private let mod1Label = UILabel()

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

        let labelContainer = UIView()

        addSubview(inputTextView)
        addSubview(labelContainer)

        labelContainer.addSubview(degLabel)
        labelContainer.addSubview(radLabel)
        labelContainer.addSubview(mod1Label)

        inputTextView.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview().inset(2)
        }
        labelContainer.snp.makeConstraints { make in
            make.top.equalTo(inputTextView.snp.bottom).offset(2)
            make.bottom.equalToSuperview().inset(2)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualToSuperview()
        }

        degLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }
        radLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(degLabel)
            make.leading.equalTo(degLabel.snp.trailing).offset(2)
        }
        mod1Label.snp.makeConstraints { make in
            make.top.bottom.equalTo(degLabel)
            make.trailing.equalToSuperview()
            make.leading.equalTo(radLabel.snp.trailing).offset(5)
        }

        backgroundColor = UIColor.init(hex: "f0f0f0")

        inputTextView.textColor = .blue
        inputTextView.numberOfLines = 1

        degLabel.font = Styles.inputDisplayLabelFont
        radLabel.font = Styles.inputDisplayLabelFont
        mod1Label.font = Styles.inputDisplayLabelFont

        degLabel.text = "DEG"
        radLabel.text = "RAD"
        mod1Label.text = "MOD1"

        addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(showMenu(sender:))
        ))
    }

    func setMode(_ calculatorMode: CalculatorMode) {
        degLabel.textColor = calculatorMode.angle == .Deg ? Styles.activeLabelColor : Styles.inactiveLabelColor
        radLabel.textColor = calculatorMode.angle == .Rad ? Styles.activeLabelColor : Styles.inactiveLabelColor
        mod1Label.textColor = calculatorMode.keypadMode == .Mod1 ? Styles.mod1TextColor : Styles.inactiveLabelColor
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
