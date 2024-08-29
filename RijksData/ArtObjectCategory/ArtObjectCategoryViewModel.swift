import Foundation
import Combine
import NetworkCore

protocol ArtObjectCategoryViewModelProtocol: Hashable, AnyObject {
    var title: String { get }
    var items: [RijkArtObject] { get }
    var state: ArtObjectCategoryViewModel.State { get }
    var itemsPublisher: AnyPublisher<[RijkArtObject], Never> { get }
    var statePublisher: AnyPublisher<ArtObjectCategoryViewModel.State, Never> { get }
    func loadInitialData()
    func loadMoreData()
}

final class ArtObjectCategoryViewModel: ArtObjectCategoryViewModelProtocol {
    enum State {
        case initial
        case loading
        case loaded
        case loadingError
    }

    @Published private(set) var items: [RijkArtObject] = []
    var itemsPublisher: AnyPublisher<[RijkArtObject], Never> {
        $items.eraseToAnyPublisher()
    }
    @Published private(set) var state: ArtObjectCategoryViewModel.State = .initial
    var statePublisher: AnyPublisher<ArtObjectCategoryViewModel.State, Never> {
        $state.eraseToAnyPublisher()
    }

    private let requestManager: APIRequestManager
    private var page = 0
    private let pageSize = 10 // TODO: Magic number
    private let maker: String
    private let technique: String

    init(requestManager: APIRequestManager, maker: String, technique: String) {
        self.requestManager = requestManager
        self.maker = maker
        self.technique = technique
    }

    var title: String {
        technique
    }

    func loadInitialData() {
        guard state == .initial else {
            return
        }
        loadMoreData()
    }

    func loadMoreData() {
        guard state != .loading && state != .loaded else {
            return
        }

        state = .loading
        page += 1

        Task {
            do {
                let request = RijksAPIRequest.collection(
                    page: page,
                    pageSize: pageSize,
                    involvedMaker: maker,
                    technique: technique
                )
                let result: RijksCollection = try await requestManager.perform(request)
                self.items.append(contentsOf: result.artObjects)

                if result.artObjects.isEmpty {
                    self.state = .loaded
                } else {
                    self.state = .initial
                }
            } catch {
                print(technique, error)
                self.state = .loadingError
                self.page -= 1
            }
        }
    }
}

extension ArtObjectCategoryViewModel: Hashable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(title)
    }
    static func == (lhs: ArtObjectCategoryViewModel, rhs: ArtObjectCategoryViewModel) -> Bool {
        lhs.title == rhs.title
    }
}
