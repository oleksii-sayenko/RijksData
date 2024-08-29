import Foundation
import OSLog
import Combine
import NetworkCore

protocol ArtObjectCategoriesViewModelProtocol {
    var items: [any ArtObjectCategoryViewModelProtocol] { get }
    var itemsPublisher: AnyPublisher<[any ArtObjectCategoryViewModelProtocol], Never> { get }
    var statePublisher: AnyPublisher<ArtObjectCategoriesViewModel.State, Never> { get }
    func loadMoreData()
}

final class ArtObjectCategoriesViewModel: ArtObjectCategoriesViewModelProtocol {
    enum State {
        case initial
        case initialLoading
        case initialLoadingError(Error)
        case readyForLoadMore
        case loading
        case loaded
    }
    private var collection: RijksCollection = .init(artObjects: [], facets: [])
    @Published private(set) var items: [any ArtObjectCategoryViewModelProtocol] = []
    var itemsPublisher: AnyPublisher<[any ArtObjectCategoryViewModelProtocol], Never> {
        $items.eraseToAnyPublisher()
    }
    @Published private(set) var state: ArtObjectCategoriesViewModel.State = .initial
    var statePublisher: AnyPublisher<ArtObjectCategoriesViewModel.State, Never> {
        $state.eraseToAnyPublisher()
    }

    private let requestManager: APIRequestManager

    private let maker: String
    private var page = -1
    private let pageSize = 10 // TODO: Magic number

    init(requestManager: APIRequestManager, maker: String) {
        self.requestManager = requestManager
        self.maker = maker
    }

    func loadMoreData() {
        guard state != .initial else {
            loadInitialData()
            return
        }

        guard state != .loading && state != .loaded else {
            return
        }

        state = .loading
        page += 1

        let techniques = collection.techniques

        guard page * pageSize < techniques.count else {
            state = .loaded
            return
        }

        let lowerBound = min((page + 1) * pageSize, techniques.count)

        let categoryViewModels = techniques[page * pageSize..<lowerBound].map {
            ArtObjectCategoryViewModel(requestManager: requestManager, maker: maker, technique: $0.key)
        }
        self.items.append(contentsOf: categoryViewModels)

        state = .readyForLoadMore
    }

    func loadInitialData() {
        guard state == .initial else {
            return
        }

        state = .initialLoading

        Task {
            do {
                let request = RijksAPIRequest.collection(
                    page: 1,
                    pageSize: 1,
                    involvedMaker: self.maker,
                    technique: nil
                ) // TODO: looks no so good
                self.collection = try await self.requestManager.perform(request)
                self.state = .readyForLoadMore
                self.loadMoreData()
            } catch {
                self.state = .initialLoadingError(error)
            }
        }
    }
}

extension ArtObjectCategoriesViewModel.State: Equatable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case (.initial, .initial),
            (.initialLoading, .initialLoading),
            (.readyForLoadMore, .readyForLoadMore),
            (.loading, .loading),
            (.loaded, .loaded):
            return true
        case (.initialLoadingError, .initialLoadingError):
            return true
        default:
            return false
        }
    }
}
