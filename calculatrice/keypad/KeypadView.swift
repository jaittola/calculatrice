import UIKit
import SnapKit

class KeypadView: UIView {
    var onKeyPressed: ((Key) -> Void)?

    private let keyMargin = 5

    override init(frame: CGRect) {
        super.init(frame: frame)
    }

    func render(_ keypadModel: KeypadModel) {
        let rows = keypadModel.keys.map { row in renderButtonRow(row) }

        var previousRow: UIView?
        rows.enumerated().forEach { idx, row in
            addSubview(row)
            switch idx {
            case 0:
                row.snp.makeConstraints { make in
                    make.top.leading.trailing.equalToSuperview()
                }
            case rows.count - 1:
                row.snp.makeConstraints { make in
                    make.leading.trailing.bottom.equalToSuperview()
                    make.top.equalTo(previousRow!.snp.bottom).offset(keyMargin)
                    make.height.equalTo(previousRow!.snp.height)
                }
            default:
                row.snp.makeConstraints { make in
                    make.leading.trailing.equalToSuperview()
                    make.top.equalTo(previousRow!.snp.bottom).offset(keyMargin)
                    make.height.equalTo(previousRow!.snp.height)
                }
            }
            previousRow = row
        }
    }

    private func renderButtonRow(_ keyRow: [Key?]) -> UIView {
        let buttonRow = UIView()

        let keyCount = keyRow.count

        var prevKey: UIView?
        keyRow.enumerated().forEach { idx, key in
            let b = makeKey(key)
            buttonRow.addSubview(b)
            if prevKey != nil {
                b.snp.makeConstraints { make in
                    make.top.bottom.equalToSuperview()
                    make.leading.equalTo(prevKey!.snp.trailing).offset(keyMargin)
                    make.width.equalTo(prevKey!.snp.width)
                    if idx == keyCount - 1 {
                        make.trailing.equalToSuperview()
                    }
                }
            } else {
                b.snp.makeConstraints { make in
                    make.leading.top.bottom.equalToSuperview()
                }
            }
            prevKey = b
        }
        return buttonRow
    }

    private func makeKey(_ key: Key?) -> UIView {
        if let key = key {
            return KeypadKey(key) { [weak self] key in self?.onKeyPressed?(key) }
        } else {
            return UIView()
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
