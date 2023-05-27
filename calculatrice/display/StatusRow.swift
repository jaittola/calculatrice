import UIKit

class StatusRow: UIView {
    private let labelContainer = UIView()

    private let degLabel = UILabel()
    private let radLabel = UILabel()
    private let mod1Label = UILabel()
    private let mod2Label = UILabel()

    private let degLabelContainer = UIView()
    private let radLabelContainer = UIView()
    private let mod1LabelContainer = UIView()
    private let mod2LabelContainer = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)

        degLabel.font = Styles.inputDisplayLabelFont
        radLabel.font = Styles.inputDisplayLabelFont
        mod1Label.font = Styles.inputDisplayLabelFont
        mod2Label.font = Styles.inputDisplayLabelFont

        degLabel.adjustsFontForContentSizeCategory = true
        radLabel.adjustsFontForContentSizeCategory = true
        mod1Label.adjustsFontForContentSizeCategory = true
        mod2Label.adjustsFontForContentSizeCategory = true

        degLabel.maximumContentSizeCategory = Styles.maxContentSize
        radLabel.maximumContentSizeCategory = Styles.maxContentSize
        mod1Label.maximumContentSizeCategory = Styles.maxContentSize
        mod2Label.maximumContentSizeCategory = Styles.maxContentSize

        degLabel.text = "DEG"
        radLabel.text = "RAD"
        mod1Label.text = "Alt 1"
        mod2Label.text = "Alt 2"

        addSubview(labelContainer)

        [ degLabelContainer, radLabelContainer,
          mod1LabelContainer, mod2LabelContainer].forEach { v in
            labelContainer.addSubview(v)
        }

        degLabelContainer.addSubview(degLabel)
        radLabelContainer.addSubview(radLabel)
        mod1LabelContainer.addSubview(mod1Label)
        mod2LabelContainer.addSubview(mod2Label)

        labelContainer.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview()
            make.leading.greaterThanOrEqualToSuperview()
            make.trailing.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
        }

        degLabelContainer.snp.makeConstraints { make in
            make.top.bottom.leading.equalToSuperview()
        }
        radLabelContainer.snp.makeConstraints { make in
            make.top.bottom.equalTo(degLabelContainer)
            make.leading.equalTo(degLabelContainer.snp.trailing).offset(12)
        }
        mod1LabelContainer.snp.makeConstraints { make in
            make.top.bottom.equalTo(degLabelContainer)
            make.leading.equalTo(radLabelContainer.snp.trailing).offset(12)
        }
        mod2LabelContainer.snp.makeConstraints { make in
            make.top.bottom.equalTo(degLabelContainer)
            make.leading.equalTo(mod1LabelContainer.snp.trailing).offset(12)
            make.trailing.equalToSuperview()
        }

        [degLabel, radLabel, mod1Label, mod2Label].forEach { label in
            label.snp.makeConstraints { make in
                make.verticalEdges.equalToSuperview().inset(1)
                make.horizontalEdges.equalToSuperview().inset(2)
            }
        }
    }

    func setMode(_ calculatorMode: CalculatorMode) {
        degLabel.textColor = calculatorMode.angle == .Deg ? Styles.activeLabelColor : Styles.inactiveLabelColor
        radLabel.textColor = calculatorMode.angle == .Rad ? Styles.activeLabelColor : Styles.inactiveLabelColor
        mod1Label.textColor = calculatorMode.keypadMode == .Mod1 ? Styles.mod1TextColor : Styles.inactiveLabelColor
        mod2Label.textColor = calculatorMode.keypadMode == .Mod2 ? Styles.mod2TextColor : Styles.inactiveLabelColor

        degLabelContainer.backgroundColor = calculatorMode.angle == .Deg ? Styles.keyBackgroundColor : .white
        radLabelContainer.backgroundColor = calculatorMode.angle == .Rad ? Styles.keyBackgroundColor : .white
        mod1LabelContainer.backgroundColor = calculatorMode.keypadMode == .Mod1 ? Styles.keyBackgroundColor : .white
        mod2LabelContainer.backgroundColor = calculatorMode.keypadMode == .Mod2 ? Styles.keyBackgroundColor : .white
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
