import UIKit

class StackRow: UITableViewCell {
    static let reuseIdentifier = "StackRowReuseIdentifier"

    override public var canBecomeFirstResponder: Bool {
        return true
    }

    var item: StackDisplayRowItem? {
        didSet {
            if let item = item {
                rowNum.text = "\(item.row): "
                value.text = "\(item.value.stringValue)"
            } else {
                rowNum.text = ""
                value.text = ""
            }
        }
    }

    private let rowNum = UILabel()
    private let value = UILabel()
    private let selectedBackground = UIView()
    private let cellBackgroundColor = UIColor(hex: "e0e0e0")
    private let cellSelectedBackgroundColor = UIColor(hex: "ff0000")
    private let textBackgroundColor = UIColor(hex: "f0f0f0", alpha: 0.9)
    private let textColor = UIColor.blue

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = cellBackgroundColor
        selectedBackground.backgroundColor = cellSelectedBackgroundColor
        selectedBackgroundView = selectedBackground

        rowNum.numberOfLines = 1
        rowNum.textColor = textColor
        rowNum.backgroundColor = textBackgroundColor
        rowNum.translatesAutoresizingMaskIntoConstraints = false
        rowNum.adjustsFontForContentSizeCategory = true

        value.numberOfLines = 1
        value.textColor = textColor
        value.backgroundColor = textBackgroundColor
        value.translatesAutoresizingMaskIntoConstraints = false
        value.adjustsFontForContentSizeCategory = true
        value.textAlignment = .right

        contentView.addSubview(rowNum)
        contentView.addSubview(value)

        rowNum.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.leading.equalToSuperview().inset(2)
            make.width.greaterThanOrEqualToSuperview().dividedBy(8)
        }

        value.snp.makeConstraints { make in
            make.top.bottom.equalTo(rowNum)
            make.leading.equalTo(rowNum.snp.trailing)
            make.trailing.equalToSuperview().inset(2)
        }

        addGestureRecognizer(UILongPressGestureRecognizer(
            target: self,
            action: #selector(showMenu(sender:))
        ))
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = value.text
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
        return (action == #selector(copy(_:)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
