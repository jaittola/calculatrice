import UIKit

class Display: UIView {
    let statusRow = StatusRow(frame: .zero)
    let stackDisplay = StackDisplay(frame: .zero)
    let inputDisplay = InputDisplay(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)

        backgroundColor = Styles.displayBackgroundColor

        addSubview(statusRow)
        addSubview(stackDisplay)
        addSubview(inputDisplay)

        statusRow.snp.makeConstraints { make in
            make.top.equalToSuperview()
            make.leading.trailing.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
        }

        stackDisplay.snp.makeConstraints { make in
            make.top.equalTo(statusRow.snp.bottom)
            make.leading.trailing.equalToSuperview()
        }

        inputDisplay.snp.makeConstraints { make in
            make.top.equalTo(stackDisplay.snp.bottom)
            make.leading.trailing.equalToSuperview()
            make.bottom.equalToSuperview()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
