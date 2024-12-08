import OSLog
import UIKit
import NetworkCore

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?
    var appCoordinator: ArtObjectsCollectionCoordinator?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let scene = (scene as? UIWindowScene) else {
            return
        }

        window = .init(windowScene: scene)
        let navigationController = UINavigationController()

        appCoordinator = ArtObjectsCollectionCoordinator(navigationController: navigationController)
        appCoordinator?.start()

        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
    }
}
