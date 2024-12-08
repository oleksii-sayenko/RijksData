import Combine
import XCTest
@testable import RijksData
@testable import NetworkCore


class ArtObjectDetailViewModelTests: XCTestCase {
    var viewModel: ArtObjectDetailViewModel!
    var requestManager: MockAPIRequestManager!
    var cancellables: Set<AnyCancellable>!

    @MainActor
    override func setUp() {
        super.setUp()
        requestManager = MockAPIRequestManager()
        viewModel = ArtObjectDetailViewModel(id: .init(value: "123"), requestManager: requestManager)
        cancellables = []
    }

    override func tearDown() {
        viewModel = nil
        requestManager = nil
        cancellables = nil
        super.tearDown()
    }

    @MainActor
    func test_loadData_emitsLoadingAndLoadedStates() async {
        // Given
        let expectedStates: [ArtObjectDetailViewModel.State] = [
            .initial,
            .loading,
            .loaded(RijkArtObjectDetail(objectNumber: "123", title: "The Night Watch", label: .init(description: nil), webImage: nil))
        ]
        var receivedStates = [ArtObjectDetailViewModel.State]()
        let expectation = XCTestExpectation(description: "State publisher should emit loading and loaded states.")
        viewModel.statePublisher
            .sink { state in
                receivedStates.append(state)
                if receivedStates.count == expectedStates.count {
                    XCTAssertEqual(receivedStates.map { "\($0)" }, expectedStates.map { "\($0)" })
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        requestManager.result = RijkArtObjectDetailResult(artObject: .init(objectNumber: "123", title: "The Night Watch", label: .init(description: nil), webImage: nil))

        // When
        await viewModel.loadData()

        // Then
        await fulfillment(of: [expectation], timeout: 5.0)
    }

    @MainActor
    func test_loadData_emitsLoadingAndErrorStates() async {
        // Given
        let expectedStates: [ArtObjectDetailViewModel.State] = [
            .initial,
            .loading,
            .error(NSError(domain: "TestError", code: 404, userInfo: nil))
        ]
        var receivedStates = [ArtObjectDetailViewModel.State]()
        let expectation = XCTestExpectation(description: "State publisher should emit loading and error states.")
        viewModel.statePublisher
            .sink { state in
                receivedStates.append(state)
                if receivedStates.count == expectedStates.count {
                    XCTAssertEqual(receivedStates.map { "\($0)" }, expectedStates.map { "\($0)" })
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)
        requestManager.error = NSError(domain: "TestError", code: 404, userInfo: nil)

        // When
        await viewModel.loadData()

        // Then
        await fulfillment(of: [expectation], timeout: 5.0)
    }
}
