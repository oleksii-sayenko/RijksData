import OSLog
import Combine
import UIKit
import NetworkCore

final class ArtObjectCategoriesViewController: UIViewController, UICollectionViewDelegate {
    enum Section {
        case category(any ArtObjectCategoryViewModelProtocol)
    }

    struct Item: Sendable {
        let viewModel: any ArtObjectCategoryViewModelProtocol
    }

    // swiftlint:disable implicitly_unwrapped_optional
    private var collectionView: UICollectionView!
    private var activityIndicator: UIActivityIndicatorView!
    private var errorLabel: UILabel!

    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>!

    private var cancellables = Set<AnyCancellable>()

    var viewModel: ArtObjectCategoriesViewModelProtocol!
    // swiftlint:enable implicitly_unwrapped_optional

    init() {
        super.init(nibName: nil, bundle: nil)
        setupUI()
        setupDataSource()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: ArtObjectCategoriesViewModelProtocol) {
        self.viewModel = viewModel
        setupBindings()
        Task {
            await viewModel.loadMoreData()
        }
    }

    // MARK: Setup UI

    private func setupUI() {
        setupCollectionView()
        setupActivityIndicator()

        errorLabel = UILabel()
        errorLabel.isHidden = true
        errorLabel.numberOfLines = 2
        view.addSubview(errorLabel)
        errorLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            errorLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10), // TODO: Magic number
            errorLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10),
            errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupCollectionView() {
        let layout = UICollectionViewCompositionalLayout { _, _ in
            self.createSectionLayout()
        }
        collectionView = UICollectionView(frame: view.bounds, collectionViewLayout: layout)

        view.addSubview(collectionView)

        collectionView.register(ArtObjectCategoryView.self, forCellWithReuseIdentifier: "ArtObjectCategoryView")
        collectionView.register(
            ArtObjectCategoryHeaderView.self,
            forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
            withReuseIdentifier: "ArtObjectCategoryHeaderView"
        )
        collectionView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        collectionView.delegate = self
        collectionView.prefetchDataSource = self
        collectionView.backgroundColor = .systemGray6
    }

    private func createSectionLayout() -> NSCollectionLayoutSection {
        func createHeaderSupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
            let headerSize = NSCollectionLayoutSize(
                widthDimension: .fractionalWidth(1.0),
                heightDimension: .estimated(44)
            )
            let header = NSCollectionLayoutBoundarySupplementaryItem(
                layoutSize: headerSize,
                elementKind: UICollectionView.elementKindSectionHeader,
                alignment: .top
            )
            return header
        }

        let itemSize = NSCollectionLayoutSize(
            widthDimension: .fractionalWidth(1.0),
            heightDimension: .fractionalHeight(1.0)
        )
        let item = NSCollectionLayoutItem(layoutSize: itemSize)

        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(200))
        let group = NSCollectionLayoutGroup.horizontal(layoutSize: groupSize, subitems: [item])

        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [createHeaderSupplementaryItem()]
        section.interGroupSpacing = 10

        return section
    }

    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .large)
        view.addSubview(activityIndicator)

        activityIndicator.isHidden = true
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupDataSource() {
        // swiftlint:disable:next line_length
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) { collectionView, indexPath, viewModel in
            // TODO: Add extension
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ArtObjectCategoryView",
                for: indexPath
            ) as! ArtObjectCategoryView
            cell.configure(with: viewModel.viewModel)
            return cell
        }

        dataSource.supplementaryViewProvider = { collectionView, kind, indexPath in
            let section = self.dataSource.snapshot().sectionIdentifiers[indexPath.section]
            let headerView = collectionView.dequeueReusableSupplementaryView(
                ofKind: kind,
                withReuseIdentifier: ArtObjectCategoryHeaderView.reuseIdentifier,
                for: indexPath
            ) as! ArtObjectCategoryHeaderView
            headerView.configure(with: section.title) // TODO: Section title
            return headerView
        }
    }

    private func setupBindings() {
        viewModel.itemsPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] items in
                self?.applySnapshot(sections: items)
            }
            .store(in: &cancellables)

        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                self?.activityIndicator.isHidden = state != .initialLoading
                self?.errorLabel.isHidden = true
                if case let .initialLoadingError(error) = state {
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: Update UI

    private func showError(_ error: Error) {
        errorLabel.isHidden = false
        errorLabel.text = error.localizedDescription
    }

    private func applySnapshot(sections: [any ArtObjectCategoryViewModelProtocol]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Item>()

        sections.forEach { sectionModel in
            snapshot.appendSections([.category(sectionModel)])
            snapshot.appendItems([.init(viewModel: sectionModel)])
        }

        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ArtObjectCategoriesViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let thresholdIndex = viewModel.items.count - 5
        if indexPaths.contains(where: { $0.section > thresholdIndex }) {
            Task {
                await viewModel.loadMoreData()
            }
        }
    }
}

extension ArtObjectCategoriesViewController.Item: Hashable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.viewModel.id == rhs.viewModel.id
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(viewModel.id)
    }
}

extension ArtObjectCategoriesViewController.Section: Hashable {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .category(let viewModel):
            hasher.combine(viewModel.id)
        }
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        switch (lhs, rhs) {
        case let (.category(lhsViewModel), .category(rhsViewModel)):
            return lhsViewModel.id == rhsViewModel.id
        }
    }

    @MainActor
    var title: String {
        switch self {
        case .category(let viewModel):
            return viewModel.title
        }
    }
}
