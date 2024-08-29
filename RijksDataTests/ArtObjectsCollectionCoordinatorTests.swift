import XCTest
@testable import RijksData

class ArtObjectsCollectionCoordinatorTests: XCTestCase {
    var navigationController: MockNavigationController!
    var coordinator: ArtObjectsCollectionCoordinator!

    override func setUp() {
        super.setUp()
        navigationController = MockNavigationController()
        coordinator = ArtObjectsCollectionCoordinator(navigationController: navigationController)
    }

    override func tearDown() {
        coordinator = nil
        navigationController = nil
        super.tearDown()
    }

    @MainActor
    func test_start_pushesArtObjectCategoriesViewController() {
        coordinator.start()

        XCTAssertTrue(navigationController.pushedViewController is ArtObjectCategoriesViewController)
    }

    @MainActor
    func test_openDetails_createsAndStartsDetailCoordinator() {
        let artObjectID = RijkArtObject.ID(value: "123")
        coordinator.openDetails(for: artObjectID)

        XCTAssertNotNil(navigationController.pushedViewController as? ArtObjectDetailViewController)
    }
}
