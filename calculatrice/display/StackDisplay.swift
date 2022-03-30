import UIKit
import SnapKit

class StackDisplay: UIView, UITableViewDelegate {
    private let tableview = UITableView()
    private var datasource: UITableViewDiffableDataSource<Int, StackDisplayRowItem>?
    private var data: [StackDisplayRowItem] = []

    var selectedItem: StackValue? {
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

    func setStack(_ content: [StackValue]) {
        data = content
            .enumerated()
            .reversed()
            .map { row, value in
                StackDisplayRowItem(row: row + 1, value: value)
            }

        var snapshot = NSDiffableDataSourceSnapshot<Int, StackDisplayRowItem>()
        snapshot.appendSections([1])
        snapshot.appendItems(data)
        datasource?.apply(snapshot, animatingDifferences: false)

        if !data.isEmpty {
            let scrollPosition = IndexPath(item: data.count - 1, section: 0)
            tableview.scrollToRow(at: scrollPosition, at: .bottom, animated: false)
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }

    private func setupTableview() {
        tableview.backgroundColor = UIColor(hex: "e0e0e0")
        tableview.allowsSelection = true
        tableview.allowsMultipleSelection = false
        tableview.separatorStyle = .none

        tableview.delegate = self
        tableview.register(StackRow.self, forCellReuseIdentifier: StackRow.reuseIdentifier)

        datasource = UITableViewDiffableDataSource(tableView: tableview) { tableView, _, item -> UITableViewCell? in
            let cell = tableView.dequeueReusableCell(withIdentifier: StackRow.reuseIdentifier) as! StackRow
            cell.item = item
            return cell
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct StackDisplayRowItem: Hashable {
    let row: Int
    let value: StackValue

    func hash(into hasher: inout Hasher) {
        hasher.combine(row)
        hasher.combine(value.id)
    }

    static func == (lhs: StackDisplayRowItem, rhs: StackDisplayRowItem) -> Bool {
        lhs.row == rhs.row && lhs.value.id == rhs.value.id
    }
}
