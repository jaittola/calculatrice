import UIKit
import SnapKit

class StackDisplay: UIView, UITableViewDelegate {
    private let tableview = UITableView()
    private var datasource: UITableViewDiffableDataSource<Int, StackDisplayRowItem>?
    private var data: [StackDisplayRowItem] = []

    var selectedItem: Value? {
        guard let selectedIndexPath = tableview.indexPathsForSelectedRows?.first,
              selectedIndexPath.row < data.count else {
            return nil
        }
        return data[selectedIndexPath.row].value
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        addSubview(tableview)
        tableview.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        setupTableview()
    }

    func setStack(_ content: [Value], _ calculatorMode: CalculatorMode) {
        data = content
            .enumerated()
            .reversed()
            .map { row, value in
                StackDisplayRowItem(row: row + 1,
                                    value: value,
                                    calculatorMode: calculatorMode)
            }

        var snapshot = NSDiffableDataSourceSnapshot<Int, StackDisplayRowItem>()
        snapshot.appendSections([1])
        snapshot.appendItems(data)
        datasource?.applySnapshotUsingReloadData(snapshot)

        if !data.isEmpty {
            let scrollPosition = IndexPath(item: data.count - 1, section: 0)
            tableview.scrollToRow(at: scrollPosition, at: .bottom, animated: false)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    private func setupTableview() {
        tableview.backgroundColor = Styles.displayBackgroundColor
        tableview.allowsSelection = true
        tableview.allowsMultipleSelection = false
        tableview.separatorStyle = .singleLine
        tableview.separatorColor = Styles.stackSeparatorColor
        tableview.separatorInset = UIEdgeInsets(top: 0, left: Styles.margin,
                                                bottom: 0, right: Styles.margin)
        tableview.fillerRowHeight = UITableView.automaticDimension

        tableview.delegate = self
        tableview.register(StackRow.self, forCellReuseIdentifier: StackRow.reuseIdentifier)

        datasource = UITableViewDiffableDataSource(tableView: tableview) { tableView, _, item -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: StackRow.reuseIdentifier) as! StackRow
            cell.setItem(item)
            return cell
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct StackDisplayRowItem: Hashable {
    let row: Int
    let value: Value
    let calculatorMode: CalculatorMode

    func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        hasher.combine(value.id)
        hasher.combine(calculatorMode.angle)
    }

    static func == (lhs: StackDisplayRowItem, rhs: StackDisplayRowItem) -> Bool {
        lhs.row == rhs.row && lhs.value.id == rhs.value.id &&
        lhs.calculatorMode.angle == rhs.calculatorMode.angle
    }
}
