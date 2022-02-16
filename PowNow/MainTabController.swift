
import UIKit
import MBProgressHUD

class MainTabController: UITabBarController {

    let powderHistoryCoordinator: PowderHistoryCoordinator
    let powderAccumulationCoordinator: PowderAccumulationCoordinator

    init(parentCoordinator: AppCoordinator) {
        powderHistoryCoordinator = PowderHistoryCoordinator(navigationController: UINavigationController())
        powderAccumulationCoordinator = PowderAccumulationCoordinator(navigationController: UINavigationController())
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabs()
    }

    func setupTabs() {
        // Pow history
        powderHistoryCoordinator.start()
        powderHistoryCoordinator.visibleViewController?.tabBarItem = UITabBarItem(
            tabBarSystemItem: .history,
            tag: 1
        )

        powderAccumulationCoordinator.start()
        powderAccumulationCoordinator.visibleViewController?.tabBarItem = UITabBarItem(
            title: "Pow Accumulation",
            image: UIImage(systemName: "clock.arrow.2.circlepath"),
            selectedImage: nil
        )

        // Assign viewcontrollers
        viewControllers = [
            powderHistoryCoordinator.navigationController,
            powderAccumulationCoordinator.navigationController
        ]
    }

}

