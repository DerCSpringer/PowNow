
import Foundation
import UIKit

class PowderHistoryCoordinator: Coordinator {

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = PowderHistoryViewModel()
        let powderHistoryVC = PowderHistoryViewController(coordinator: self, viewModel: viewModel)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(powderHistoryVC, animated: true)
    }

}

