import Foundation
import Combine
import NetworkCore

@MainActor
protocol ArtObjectDetailViewModelProtocol {
    var statePublisher: AnyPublisher<ArtObjectDetailViewModel.State, Never> { get }
    func loadData() async
}

class ArtObjectDetailViewModel: ArtObjectDetailViewModelProtocol {
    enum State {
        case initial
        case loading
        case error(Error)
        case loaded(RijkArtObjectDetail)
    }

    @Published private(set) var state: ArtObjectDetailViewModel.State = .initial
    var statePublisher: AnyPublisher<ArtObjectDetailViewModel.State, Never> {
        $state.eraseToAnyPublisher()
    }

    private let objectID: RijkArtObject.ID
    private let requestManager: APIRequestManager

    init(id: RijkArtObject.ID, requestManager: APIRequestManager) {
        objectID = id
        self.requestManager = requestManager
    }

    func loadData() async {
        guard state != .loading else {
            return
        }

        state = .loading
        print(objectID)
        let request = RijksAPIRequest.detail(id: objectID)

        do {
            let detailResult: RijkArtObjectDetailResult = try await requestManager.perform(request)
            state = .loaded(detailResult.artObject)
        } catch {
            state = .error(error)
        }
    }
}

extension ArtObjectDetailViewModel.State: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial),
            (.loading, .loading),
            (.error, .error),
            (.loaded, .loaded):
            return true
        default:
            return false
        }
    }
}
