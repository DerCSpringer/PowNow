
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        let containerViewController = UIViewController()
        let appCoordinator = AppCoordinator(containerViewController: containerViewController)
        appCoordinator.start()

        window = UIWindow()
        window?.rootViewController = containerViewController
        window?.makeKeyAndVisible()
        return true
    }

}
