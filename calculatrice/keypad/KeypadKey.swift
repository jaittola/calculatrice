import UIKit

class KeypadKey: UIControl {
    private let mainLabel = UILabel()
    private let mod1Label = UILabel()

    private let normalBackground = UIColor(hex: "dedede")
    private let pressedBackground = UIColor(hex: "aaaaaa")

    private let key: Key
    private let onPressed: (Key) -> Void

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ? pressedBackground : normalBackground
        }
    }

    init(_ key: Key, onPressed: @escaping (Key) -> Void) {
        self.key = key
        self.onPressed = onPressed

        super.init(frame: .zero)

        layer.cornerRadius = 5

        addSubview(mod1Label)
        addSubview(mainLabel)

        mod1Label.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(4)
        }
        mainLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(mod1Label.snp.bottom)
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().inset(6)
        }

        mainLabel.textColor = key.mainTextColor ??  Styles.keypadMainTextColor
        mainLabel.font = Styles.keypadMainFont
        mainLabel.text = key.symbol

        mod1Label.textColor = Styles.mod1TextColor
        mod1Label.font = Styles.keypadModFont
        mod1Label.text = key.symbolMod1 ?? " "

        backgroundColor = normalBackground

        addTarget(self, action: #selector(onClicked), for: .touchUpInside)
    }

     @objc private func onClicked() {
         self.onPressed(key)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
