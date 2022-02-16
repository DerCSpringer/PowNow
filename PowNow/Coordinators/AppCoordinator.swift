
import Foundation
import UIKit

class AppCoordinator: Coordinator, AppContainer {
    var navigationController: UINavigationController
    var childCoordinators: [Coordinator]
    var containerViewController: UIViewController

    var mainTabController: MainTabController?

    init(containerViewController: UIViewController) {
        self.navigationController = UINavigationController()
        self.childCoordinators = [Coordinator]()
        self.containerViewController = containerViewController
    }

    var presentedViewControllerAccessedFromMainTabBar: UIViewController? {
        guard let visableNavigationController = mainTabController?.selectedViewController as? UINavigationController else { return nil }
        let presentedViewController = visableNavigationController.topViewController
        return presentedViewController
    }

    func start() {
        showMainTabs()
    }
}

private extension AppCoordinator {

    func showMainTabs() {
        mainTabController = MainTabController(parentCoordinator: self)
        childCoordinators.append(mainTabController!.powderHistoryCoordinator)
        addChildViewController(mainTabController!)
    }

}
