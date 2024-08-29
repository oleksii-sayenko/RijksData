import UIKit

class ArtObjectsCollectionCoordinator {
    var navigationController: UINavigationController

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
    func openDetails(objectNumber: String) {
        let detailViewController = ArtObjectDetailViewController()
        navigationController.pushViewController(detailViewController, animated: true)
    }
}

extension ArtObjectsCollectionCoordinator: ArtObjectCategoriesViewModelDelegate {
    @MainActor
    func objectDidSlect(_ objectNumber: String) {
        print("selected \(objectNumber)")
        openDetails(objectNumber: objectNumber)
    }
}
