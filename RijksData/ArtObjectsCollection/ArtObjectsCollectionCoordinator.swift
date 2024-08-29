import UIKit

class ArtObjectsCollectionCoordinator {
    var navigationController: UINavigationController
    var detailCoordinator: ArtObjectDetailCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    @MainActor
    func start() {
        let viewController = ArtObjectCategoriesViewController()
        let requestManager = ServiceProvider.shared.apiRequestManager
        let viewModel = ArtObjectCategoriesViewModel(requestManager: requestManager, maker: "Rembrandt van Rijn")
        viewModel.delegate = self
        viewController.configure(with: viewModel)

        navigationController.pushViewController(viewController, animated: false)
    }

    @MainActor
    func openDetails(for id: RijkArtObject.ID) {
        detailCoordinator = ArtObjectDetailCoordinator(navigationController: navigationController)
        detailCoordinator?.start(for: id)
    }
}

extension ArtObjectsCollectionCoordinator: ArtObjectCategoriesViewModelDelegate {
    @MainActor
    func objectDidSlect(_ id: RijkArtObject.ID) {
        openDetails(for: id)
    }
}
