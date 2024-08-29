import OSLog
import UIKit
import NetworkCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else {
            return
        }

        window = .init(windowScene: scene)

        let viewController = ArtObjectCategoriesViewController()
        let requestManager = ServiceProvider.shared.apiRequestManager
        let viewModel = ArtObjectCategoriesViewModel(requestManager: requestManager, maker: "Rembrandt van Rijn")
        viewController.configure(with: viewModel)

        window?.rootViewController = UINavigationController(rootViewController: viewController)
        window?.makeKeyAndVisible()
    }
}
