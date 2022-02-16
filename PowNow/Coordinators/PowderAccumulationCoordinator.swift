
import Foundation
import UIKit

class PowderAccumulationCoordinator: Coordinator {

    var childCoordinators = [Coordinator]()
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let viewModel = PowderHistoryViewModel()
        let powderAccumulationVC = PowderAccumulationViewController(coordinator: self, viewModel: viewModel)
        navigationController.setNavigationBarHidden(true, animated: false)
        navigationController.pushViewController(powderAccumulationVC, animated: true)
    }

}
