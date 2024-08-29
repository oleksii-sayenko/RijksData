import UIKit

class ArtObjectDetailCoordinator {
    var navigationController: UINavigationController

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    @MainActor
    func start(for id: RijkArtObject.ID) {
        let viewController = ArtObjectDetailViewController()
        let requestManager = ServiceProvider.shared.apiRequestManager
        let viewModel = ArtObjectDetailViewModel(id: id, requestManager: requestManager)
        viewController.configure(with: viewModel)
        navigationController.pushViewController(viewController, animated: true)
    }
}
