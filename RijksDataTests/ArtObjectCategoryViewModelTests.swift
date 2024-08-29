import XCTest
import Combine
@testable import NetworkCore
@testable import RijksData

class ArtObjectCategoryViewModelTests: XCTestCase {
    var viewModel: ArtObjectCategoryViewModel!
    var requestManager: MockAPIRequestManager!
    var cancellables: Set<AnyCancellable>!

    @MainActor
    override func setUp() {
        super.setUp()
        requestManager = MockAPIRequestManager()
        viewModel = ArtObjectCategoryViewModel(requestManager: requestManager, maker: "Rembrandt", technique: "Oil Painting")
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        requestManager = nil
        cancellables = nil
        super.tearDown()
    }

    @MainActor
    func test_loadOnePageCollection_emitsStates() async {
        // Given
        let expectedStates: [ArtObjectCategoryViewModel.State] = [.initial, .loading, .loaded]
        var receivedStates = [ArtObjectCategoryViewModel.State]()
        let expectation = XCTestExpectation(description: "State publisher should emit the expected states.")
        viewModel.statePublisher
            .sink { state in
                receivedStates.append(state)
                if receivedStates.count == expectedStates.count {
                    XCTAssertEqual(receivedStates, expectedStates)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        requestManager.result = RijksCollection(artObjects: [], facets: [.init(facets: [.init(key: "painting", value: 10)], name: "techniq")])

        // When
        await viewModel.loadMoreData()

        // Then
        await fulfillment(of: [expectation], timeout: 5.0)
    }

    @MainActor
    func test_loadMoreData_allTwoPagesLoaded_emitsStates() async {
        // Given
        let expectedStates: [ArtObjectCategoryViewModel.State] = [.initial, .loading, .initial, .loading, .loaded]
        var receivedStates = [ArtObjectCategoryViewModel.State]()
        let expectation = XCTestExpectation(description: "State publisher should emit the expected states.")
        viewModel.statePublisher
            .sink { state in
                receivedStates.append(state)
                if receivedStates.count == expectedStates.count {
                    XCTAssertEqual(receivedStates, expectedStates)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        let items = (1...3).map({ i in
            RijkArtObject(objectNumber: "\(i)", title: "\(i)", webImage: nil, headerImage: .init(url: nil))
        })
        requestManager.result = RijksCollection(artObjects: items, facets: [])

        // When
        await viewModel.loadMoreData()
        requestManager.result = RijksCollection(artObjects: [], facets: [])
        await viewModel.loadMoreData()

        // Then
        await fulfillment(of: [expectation], timeout: 5.0)
    }

    @MainActor
    func test_loadMoreData_failure_emitsErrorState() async {
        // Given
        let expectedStates: [ArtObjectCategoryViewModel.State] = [.initial, .loading, .loadingError]
        var receivedStates = [ArtObjectCategoryViewModel.State]()
        let expectation = XCTestExpectation(description: "State publisher should emit the expected states.")
        viewModel.statePublisher
            .sink { state in
                receivedStates.append(state)
                if receivedStates.count == expectedStates.count {
                    XCTAssertEqual(receivedStates, expectedStates)
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        requestManager.error = NSError(domain: "TestError", code: 1, userInfo: nil)

        // When
        await viewModel.loadMoreData()

        // Then
        await fulfillment(of: [expectation], timeout: 5.0)
    }

    @MainActor
    func test_objectDidSelect_notifiesDelegate() {
        // Given
        let delegate = MockArtObjectCategoryViewModelDelegate()
        viewModel.delegate = delegate
        let expectedID = RijkArtObject.ID(value: "123")

        // When
        viewModel.ojectDidSelect(expectedID)

        // Then
        XCTAssertEqual(delegate.selectedObjectID, expectedID)
    }
}

class MockArtObjectCategoryViewModelDelegate: ArtObjectCategoryViewModelDelegate {
    var selectedObjectID: RijkArtObject.ID?

    func objectDidSlect(_ id: RijkArtObject.ID) {
        selectedObjectID = id
    }
}
