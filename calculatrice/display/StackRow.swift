import UIKit

class StackRow: UITableViewCell, UIEditMenuInteractionDelegate {
    static let reuseIdentifier = "StackRowReuseIdentifier"

    override public var canBecomeFirstResponder: Bool {
        return true
    }

    private (set) var item: StackDisplayRowItem?

    private let rowNum = UILabel()
    private let value = UILabel()
    private let selectedBackground = UIView()
    private let textColor = Styles.stackTextColor

    private var editMenuInteraction: UIEditMenuInteraction?

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        backgroundColor = Styles.displayBackgroundColor
        selectedBackground.backgroundColor = Styles.selectedRowBackgroundColor
        selectedBackgroundView = selectedBackground

        rowNum.numberOfLines = 1
        rowNum.textColor = textColor
        rowNum.font = Styles.stackFont
        rowNum.translatesAutoresizingMaskIntoConstraints = false
        rowNum.adjustsFontForContentSizeCategory = true
        rowNum.maximumContentSizeCategory = Styles.maxContentSize

        value.numberOfLines = 2
        value.textColor = textColor
        value.font = Styles.stackFont
        value.translatesAutoresizingMaskIntoConstraints = false
        value.adjustsFontForContentSizeCategory = true
        value.textAlignment = .right
        value.maximumContentSizeCategory = Styles.maxContentSize

        contentView.addSubview(rowNum)
        contentView.addSubview(value)

        rowNum.snp.makeConstraints { make in
            make.top.bottom.equalToSuperview().inset(2)
            make.leading.equalToSuperview().inset(Styles.margin)
            make.width.greaterThanOrEqualToSuperview().dividedBy(8)
        }

        value.snp.makeConstraints { make in
            make.top.bottom.equalTo(rowNum)
            make.leading.equalTo(rowNum.snp.trailing)
            make.trailing.equalToSuperview().inset(Styles.margin)
        }

        editMenuInteraction = UIEditMenuInteraction(delegate: self)
        self.addInteraction(editMenuInteraction!)

        let longPress = UILongPressGestureRecognizer(
            target: self,
            action: #selector(showMenu(_:))
        )
        longPress.allowedTouchTypes = [UITouch.TouchType.direct.rawValue as NSNumber]
        addGestureRecognizer(longPress)
    }

    func setItem(_ item: StackDisplayRowItem?) {
        self.item = item

        if let item = item {
            rowNum.text = "\(item.row): "
            value.text = "\(item.value.stringValue(item.calculatorMode))"
        } else {
            rowNum.text = ""
            value.text = ""
        }
    }

    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = value.text
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
        return (action == #selector(copy(_:)))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
