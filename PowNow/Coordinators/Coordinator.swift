
import Foundation
import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {

    var visibleViewController: UIViewController? {
        return navigationController.visibleViewController
    }

    func releaseViewControllers() {
        navigationController.viewControllers = [UIViewController]()
    }

    func remove(childCoordinator: Coordinator) {
        for (index, coordinator) in childCoordinators.enumerated() where coordinator === childCoordinator {
            childCoordinators.remove(at: index)
            break
        }
    }

}

// MARK: -

protocol AppContainer {
    var containerViewController: UIViewController { get set }
}

extension AppContainer {

    func addChildViewController(_ viewController: UIViewController) {
        containerViewController.addChild(viewController)
        viewController.view.frame = containerViewController.view.bounds
        containerViewController.view.addSubview(viewController.view)
        viewController.didMove(toParent: containerViewController)
    }

    func removeChildViewController(_ viewController: UIViewController) {
        viewController.willMove(toParent: nil)
        viewController.view.removeFromSuperview()
        viewController.removeFromParent()
    }

    func transition(to newViewController: UIViewController, completion: (() -> Void)? = nil) {

        guard let currentViewController = containerViewController.children.first else { return }

        currentViewController.willMove(toParent: nil)
        addChildViewController(newViewController)

        containerViewController.transition(
            from: currentViewController,
            to: newViewController,
            duration: 0.3,
            options: .transitionCrossDissolve,
            animations: {
                // ...
            },
            completion: { _ in
                currentViewController.removeFromParent()
                newViewController.didMove(toParent: self.containerViewController)
                completion?()
        })

    }
}
