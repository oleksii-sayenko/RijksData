import Foundation
import Combine
import NetworkCore

@MainActor
protocol ArtObjectCategoryViewModelProtocol: AnyObject, Sendable {
    nonisolated var id: String { get }
    var title: String { get }
    var items: [RijkArtObject] { get }
    var state: ArtObjectCategoryViewModel.State { get }
    var itemsPublisher: AnyPublisher<[RijkArtObject], Never> { get }
    var statePublisher: AnyPublisher<ArtObjectCategoryViewModel.State, Never> { get }
    func loadMoreData() async
    func ojectDidSelect(_ id: RijkArtObject.ID)
}

@MainActor
protocol ArtObjectCategoryViewModelDelegate: AnyObject {
    func objectDidSlect(_ id: RijkArtObject.ID)
}

@MainActor
final class ArtObjectCategoryViewModel: ArtObjectCategoryViewModelProtocol {
    enum State {
        case initial
        case loading
        case loaded
        case loadingError
    }

    private(set) var items: [RijkArtObject] = []
    var itemsPublisher: AnyPublisher<[RijkArtObject], Never> {
        itemsSubject.eraseToAnyPublisher()
    }
    @Published private(set) var state: ArtObjectCategoryViewModel.State = .initial
    var statePublisher: AnyPublisher<ArtObjectCategoryViewModel.State, Never> {
        $state.eraseToAnyPublisher()
    }

    private let itemsSubject = CurrentValueSubject<[RijkArtObject], Never>([])

    private let requestManager: APIRequestManagerProtocol
    weak var delegate: ArtObjectCategoryViewModelDelegate?

    private var page = 0
    private let pageSize = 10
    private let maker: String
    private let technique: String
    nonisolated let id: String

    init(requestManager: APIRequestManagerProtocol, maker: String, technique: String) {
        self.requestManager = requestManager
        self.maker = maker
        self.technique = technique
        self.id = technique
        Task {
            await loadMoreData()
        }
    }

    var title: String {
        technique
    }

    func loadMoreData() async {
        guard state != .loading && state != .loaded else {
            return
        }

        state = .loading
        page += 1

        let request = RijksAPIRequest.collection(
            page: page,
            pageSize: pageSize,
            involvedMaker: maker,
            technique: technique
        )

        do {
            let result: RijksCollection = try await requestManager.perform(request)
            itemsSubject.send(itemsSubject.value + result.artObjects)
            self.items.append(contentsOf: result.artObjects)

            self.state = result.artObjects.isEmpty
                ? .loaded
                : .initial
        } catch {
            self.state = .loadingError
            self.page -= 1
        }
    }

    func ojectDidSelect(_ id: RijkArtObject.ID) {
        delegate?.objectDidSlect(id)
    }
}
