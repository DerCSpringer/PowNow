
import Foundation
import UIKit
import MBProgressHUD

class PowderAccumulationViewController: UIViewController {
    weak var coordinator: PowderAccumulationCoordinator!
    private var viewModel: PowderHistoryViewModel

    @IBOutlet weak var timePicker: UIPickerView!
    @IBOutlet weak var snowDepth: UILabel!


    init(coordinator: PowderAccumulationCoordinator, viewModel: PowderHistoryViewModel) {
        self.coordinator = coordinator
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented.")
    }

    func setSnowDepthLabelForHoursOfAccumulation(_ hours: Int) {
        guard var decimal = viewModel.snowFallWithin24hoursInPrevious(hours: hours) else {
            return
        }
        self.snowDepth.text = NSDecimalString(&decimal, nil) + " inches \n\n Last snow depth recording: \n  \(viewModel.latestSnowReading())"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupDataForDisplay()
    }

}

private extension PowderAccumulationViewController {

    func setupDataForDisplay() {
        snowDepth.text = ""
        timePicker.dataSource = self
        timePicker.delegate = self
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
                self.timePicker.selectRow(0, inComponent: 0, animated: false)
                self.setSnowDepthLabelForHoursOfAccumulation(8)
            }
        })
    }

}

extension PowderAccumulationViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        3
    }

}

extension PowderAccumulationViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        guard row < 3 else { return nil }

        switch row {
        case 0: return "8 hours"
        case 1: return "12 hours"
        case 2: return "24 hours"
        default: return nil
        }

    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        guard row < 3 else { return }

        switch row {
        case 0: setSnowDepthLabelForHoursOfAccumulation(8)
        case 1: setSnowDepthLabelForHoursOfAccumulation(12)
        case 2: setSnowDepthLabelForHoursOfAccumulation(24)
        default: return
        }

    }

}
