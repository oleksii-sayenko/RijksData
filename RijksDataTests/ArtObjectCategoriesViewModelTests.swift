import XCTest
import Combine
@testable import RijksData
@testable import NetworkCore

class ArtObjectCategoriesViewModelTests: XCTestCase {
    var viewModel: ArtObjectCategoriesViewModel!
    var requestManager: MockAPIRequestManager!
    var cancellables: Set<AnyCancellable>!

    @MainActor
    override func setUp() {
        super.setUp()
        requestManager = MockAPIRequestManager()
        viewModel = ArtObjectCategoriesViewModel(requestManager: requestManager, maker: "Rembrandt")
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        requestManager = nil
        cancellables = nil
        super.tearDown()
    }

    @MainActor
    func test_statePublisher_initialLoad_emitsCorrectStates() async {
        let expectedStates: [ArtObjectCategoriesViewModel.State] = [
            .initial,
            .initialLoading,
            .readyForLoadMore,
            .loading,
            .readyForLoadMore
        ]

        var receivedStates = [ArtObjectCategoriesViewModel.State]()
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

        requestManager.result = RijksCollection(artObjects: [], facets: [.init(facets: [.init(key: "painting", value: 10)], name: "technique")])

        await viewModel.loadInitialData()

        await fulfillment(of: [expectation], timeout: 5.0)
    }

    @MainActor
    func test_statePublisher_noObjects_emitsCorrectStates() async {
        let expectedStates: [ArtObjectCategoriesViewModel.State] = [
            .initial,
            .initialLoading,
            .empty
        ]

        var receivedStates = [ArtObjectCategoriesViewModel.State]()
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

        requestManager.result = RijksCollection(artObjects: [], facets: [])

        await viewModel.loadMoreData()
        await viewModel.loadMoreData()

        await fulfillment(of: [expectation], timeout: 5.0)
    }

    @MainActor
    func test_statePublisher_moreThenOnePage_emitsCorrectStates() async {
        let expectedStates: [ArtObjectCategoriesViewModel.State] = [
            .initial,
            .initialLoading,
            .readyForLoadMore,
            .loading,
            .readyForLoadMore,
            .loading,
            .readyForLoadMore
        ]

        var receivedStates = [ArtObjectCategoriesViewModel.State]()
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


        let items = (1...25).map({ i in
            RijksCollection.Facet.FacetItem(key: "Item \(i)", value: i)
        })
        requestManager.result = RijksCollection(
            artObjects: [],
            facets: [.init(facets: items, name: "technique")]
        )

        await viewModel.loadMoreData()
        await viewModel.loadMoreData()

        await fulfillment(of: [expectation], timeout: 5.0)
    }

    @MainActor
    func test_loadInitialData_failure_setsStateToInitialLoadingError() async {
        let expectedStates: [ArtObjectCategoriesViewModel.State] = [
            .initial,
            .initialLoading,
            .initialLoadingError(NSError(domain: "TestError", code: 0, userInfo: nil)),
        ]

        var receivedStates = [ArtObjectCategoriesViewModel.State]()
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

        requestManager.error = NSError(domain: "TestError", code: 0, userInfo: nil)

        await viewModel.loadInitialData()

        await fulfillment(of: [expectation], timeout: 5.0)
    }

    @MainActor
    func test_objectDidSelect_notifiesDelegate() {
        let delegate = MockArtObjectCategoriesViewModelDelegate()
        viewModel.delegate = delegate
        viewModel.objectDidSlect(.init(value: "123"))
        XCTAssertEqual(delegate.selectedObjectNumber, .init(value: "123"))
    }
}

class MockArtObjectCategoriesViewModelDelegate: ArtObjectCategoriesViewModelDelegate {
    var selectedObjectNumber: RijkArtObject.ID?

    func objectDidSlect(_ objectNumber: RijkArtObject.ID) {
        selectedObjectNumber = objectNumber
    }
}

