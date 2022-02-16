
import UIKit
import MBProgressHUD

class PowderHistoryViewController: UITableViewController {

    weak var coordinator: PowderHistoryCoordinator!

    private var viewModel: PowderHistoryViewModel

    init(coordinator: PowderHistoryCoordinator, viewModel: PowderHistoryViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(style: .plain)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented.")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getPowderData()
    }

    func getPowderData() {
        MBProgressHUD.showAdded(to: coordinator.navigationController.view, animated: true)
        viewModel.downloadCSVData(completion: { [weak self] error in
            guard let self = self else { return }
            MBProgressHUD.hide(for: self.coordinator.navigationController.view, animated: true)
            if let error = error {
                print(error)
            } else {
                self.tableView.reloadData()
            }
        })
    }


}

extension PowderHistoryViewController {

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfRows()
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 {
            let headerView = UITableViewCell(style: .value1, reuseIdentifier: nil)
            headerView.textLabel?.text = "Date"
            headerView.detailTextLabel?.text = "Snow Depth(inches)"
            headerView.detailTextLabel?.textColor = .black
            headerView.backgroundColor = .lightGray
            return headerView
        }
        return nil
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .value1, reuseIdentifier: nil)
        cell.textLabel?.text = viewModel.getSnowDepthDateForRow(indexPath.row)
        cell.detailTextLabel?.text = viewModel.totalSnowDepthForRow(indexPath.row)
        cell.selectionStyle = .none
        return cell
    }
}
