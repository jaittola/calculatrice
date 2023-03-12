import UIKit

class StatusRow: UIView {
    private let labelContainer = UIView()

    private let degLabel = UILabel()
    private let radLabel = UILabel()
    private let mod1Label = UILabel()
    private let mod2Label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)

        degLabel.font = Styles.inputDisplayLabelFont
        radLabel.font = Styles.inputDisplayLabelFont
        mod1Label.font = Styles.inputDisplayLabelFont
        mod2Label.font = Styles.inputDisplayLabelFont

        degLabel.adjustsFontForContentSizeCategory = true
        radLabel.adjustsFontForContentSizeCategory = true
        mod1Label.adjustsFontForContentSizeCategory = true
        mod1Label.adjustsFontForContentSizeCategory = true

        degLabel.text = "DEG"
        radLabel.text = "RAD"
        mod1Label.text = "Alt 1"
        mod2Label.text = "Alt 2"

        addSubview(labelContainer)

        labelContainer.addSubview(degLabel)
        labelContainer.addSubview(radLabel)
        labelContainer.addSubview(mod1Label)
        labelContainer.addSubview(mod2Label)

        labelContainer.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
        }

        degLabel.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }
        radLabel.snp.makeConstraints { make in
            make.top.bottom.equalTo(degLabel)
            make.leading.equalTo(degLabel.snp.trailing).offset(12)
        }
        mod1Label.snp.makeConstraints { make in
            make.top.bottom.equalTo(degLabel)
            make.leading.equalTo(radLabel.snp.trailing).offset(12)
        }
        mod2Label.snp.makeConstraints { make in
            make.top.bottom.equalTo(degLabel)
            make.leading.equalTo(mod1Label.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
        }
    }

    func setMode(_ calculatorMode: CalculatorMode) {
        degLabel.textColor = calculatorMode.angle == .Deg ? Styles.activeLabelColor : Styles.inactiveLabelColor
        radLabel.textColor = calculatorMode.angle == .Rad ? Styles.activeLabelColor : Styles.inactiveLabelColor
        mod1Label.textColor = calculatorMode.keypadMode == .Mod1 ? Styles.activeLabelColor : Styles.inactiveLabelColor
        mod2Label.textColor = calculatorMode.keypadMode == .Mod2 ? Styles.activeLabelColor : Styles.inactiveLabelColor
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
