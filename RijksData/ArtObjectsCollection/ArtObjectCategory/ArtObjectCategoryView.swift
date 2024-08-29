import Combine
import UIKit

struct ArtObjectCollectionViewItem: Hashable {
    enum State: Hashable {
        case standart(title: String, imageURL: URL?, number: String)
        case loading
        case loadingError
    }
    let id: String
    let state: State
}

class ArtObjectCategoryView: UICollectionViewCell {
    enum Section {
        case main
    }

    private lazy var collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
    private lazy var layout = {
        let layout = TwoRowGridLayout()
        layout.scrollDirection = .horizontal
        layout.minimumInteritemSpacing = 10
        layout.minimumLineSpacing = 10
        return layout
    }()
    // swiftlint:disable implicitly_unwrapped_optional
    private var dataSource: UICollectionViewDiffableDataSource<Section, ArtObjectCollectionViewItem>!
    private var viewModel: (any ArtObjectCategoryViewModelProtocol)!
    // swiftlint:enable implicitly_unwrapped_optional
    private var cancellables = Set<AnyCancellable>()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCollectionView()
        setupDataSource()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: any ArtObjectCategoryViewModelProtocol) {
        self.viewModel = viewModel
        setupBindings()
        viewModel.loadInitialData()
    }

    private func setupCollectionView() {
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.register(ArtObjectItemCell.self, forCellWithReuseIdentifier: "ArtObjectItemCell")
        collectionView.register(LoadingCell.self, forCellWithReuseIdentifier: "LoadingCell")
        collectionView.register(TryAgainCell.self, forCellWithReuseIdentifier: "TryAgainCell")
        collectionView.prefetchDataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.backgroundColor = .systemGray6

        contentView.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: contentView.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    private func setupBindings() {
        viewModel.itemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.applySnapshot(items: items)
            }
            .store(in: &cancellables)

        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.updateState(state: state)
            }
            .store(in: &cancellables)
    }

    private func setupDataSource() {
        // swiftlint:disable line_length
        dataSource = UICollectionViewDiffableDataSource<Section, ArtObjectCollectionViewItem>(collectionView: collectionView) {collectionView, indexPath, item -> UICollectionViewCell? in
            if item.state == .loading {
                // swiftlint:disable:next force_cast
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LoadingCell", for: indexPath) as! LoadingCell
                cell.startAnimating()
                return cell
            } else if item.state == .loadingError {
                // swiftlint:disable:next force_cast
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TryAgainCell", for: indexPath) as! TryAgainCell
                return cell
            } else {
                // swiftlint:disable:next force_cast
                let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ArtObjectItemCell", for: indexPath) as! ArtObjectItemCell
                guard case let .standart(title, imageURL, _) = item.state else {
                    return cell
                }
                cell.configure(with: title, imageURL: imageURL)
                return cell
            }
        }
        // swiftlint:enable line_length
    }

    private func applySnapshot(items: [RijkArtObject]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, ArtObjectCollectionViewItem>()
        snapshot.appendSections([.main])
        snapshot.appendItems(items.map({
            ArtObjectCollectionViewItem(
                id: $0.objectNumber,
                state: .standart(title: $0.title, imageURL: $0.headerImage.url, number: $0.objectNumber)
            )
        }))
        if viewModel.state == .loading {
            snapshot.appendItems([.init(id: UUID().uuidString, state: .loading)])
        }
        if viewModel.state == .loadingError {
            snapshot.appendItems([.init(id: UUID().uuidString, state: .loadingError)])
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }

    private func updateState(state: ArtObjectCategoryViewModel.State) {
        var snapshot = dataSource.snapshot()
        switch state {
        case .loading:
            snapshot.deleteItems(snapshot.itemIdentifiers.filter { $0.state == .loadingError })
            if !snapshot.itemIdentifiers.contains(where: { $0.state == .loading }) {
                snapshot.appendItems([.init(id: UUID().uuidString, state: .loading)])
            }
        case .loadingError:
            snapshot.deleteItems(snapshot.itemIdentifiers.filter { $0.state == .loading })
            if !snapshot.itemIdentifiers.contains(where: { $0.state == .loadingError }) {
                snapshot.appendItems([.init(id: UUID().uuidString, state: .loadingError)])
            }
        case .loaded, .initial:
            snapshot.deleteItems(snapshot.itemIdentifiers.filter { $0.state == .loading })
            snapshot.deleteItems(snapshot.itemIdentifiers.filter { $0.state == .loadingError })
        }
        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ArtObjectCategoryView: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if dataSource.itemIdentifier(for: indexPath)?.state == .loadingError {
            viewModel.loadMoreData()
        }

        if case let .standart(_, _, number) = dataSource.itemIdentifier(for: indexPath)?.state {
            viewModel.ojectDidSelect(number)
        }
    }
}

extension ArtObjectCategoryView: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let thresholdIndex = viewModel.items.count - 5
        if indexPaths.contains(where: { $0.item > thresholdIndex }) {
            viewModel.loadMoreData()
        }
    }
}
