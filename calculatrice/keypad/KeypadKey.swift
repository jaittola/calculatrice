import UIKit

class KeypadKey: UIControl {
    private let mainLabel = UILabel()
    private let mod1Label = UILabel()
    private let mod2Label = UILabel()

    private let key: Key
    private let onPressed: (Key) -> Void

    override var isHighlighted: Bool {
        didSet {
            backgroundColor = isHighlighted ?
            Styles.keyPressedBackgroundColor : Styles.keyBackgroundColor
        }
    }

    init(_ key: Key, onPressed: @escaping (Key) -> Void) {
        self.key = key
        self.onPressed = onPressed

        super.init(frame: .zero)

        addSubview(mod1Label)
        addSubview(mod2Label)
        addSubview(mainLabel)

        mod1Label.snp.makeConstraints { make in
            make.leading.top.equalToSuperview().inset(4)
            make.trailing.lessThanOrEqualToSuperview().inset(4)
            if key.symbolMod1 != nil {
                make.width.greaterThanOrEqualToSuperview().dividedBy(2.3)
            }
        }
        mod2Label.snp.makeConstraints { make in
            make.trailing.top.equalToSuperview().inset(4)
            make.leading.greaterThanOrEqualTo(mod1Label.snp.trailing)
            if key.symbolMod2 != nil {
                make.width.greaterThanOrEqualToSuperview().dividedBy(2.3)
            }
        }
        mainLabel.snp.makeConstraints { make in
            make.top.greaterThanOrEqualTo(mod1Label.snp.bottom)
            make.leading.trailing.equalToSuperview().inset(4)
            make.bottom.equalToSuperview().inset(6)
        }

        mainLabel.textColor = key.mainTextColor ?? Styles.keypadMainTextColor
        mainLabel.font = Styles.keypadMainFont
        mainLabel.text = key.symbol
        mainLabel.textAlignment = .center
        mainLabel.adjustsFontForContentSizeCategory = true
        mainLabel.maximumContentSizeCategory = Styles.maxContentSize

        mod1Label.textColor = Styles.mod1TextColor
        mod1Label.font = Styles.keypadModFont
        mod1Label.text = key.symbolMod1 ?? " "
        mod1Label.textAlignment = .center
        mod1Label.adjustsFontForContentSizeCategory = true
        mod1Label.maximumContentSizeCategory = Styles.maxContentSize

        mod2Label.textColor = Styles.mod2TextColor
        mod2Label.font = Styles.keypadModFont
        mod2Label.text = key.symbolMod2 ?? " "
        mod2Label.textAlignment = .center
        mod2Label.adjustsFontForContentSizeCategory = true
        mod2Label.maximumContentSizeCategory = Styles.maxContentSize

        addTarget(self, action: #selector(onClicked), for: .touchUpInside)

        isHighlighted = false
    }

     @objc private func onClicked() {
         self.onPressed(key)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
