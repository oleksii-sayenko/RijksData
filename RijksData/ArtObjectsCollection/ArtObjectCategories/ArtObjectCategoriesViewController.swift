import OSLog
import Combine
import UIKit
import NetworkCore

// Thomas Worlidge (w/o images)

final class ArtObjectCategoriesViewController: UIViewController, UICollectionViewDelegate {
    // swiftlint:disable implicitly_unwrapped_optional
    private var collectionView: UICollectionView!
    private var activityIndicator: UIActivityIndicatorView!
    private var errorLabel: UILabel!

    private var dataSource: UICollectionViewDiffableDataSource<Section, AnyArtObjectCategoryViewModel>!

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

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
    }

    func configure(with viewModel: ArtObjectCategoriesViewModelProtocol) {
        self.viewModel = viewModel
        setupBindings()
        viewModel.loadMoreData()
    }

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

    private func createSectionLayout() -> NSCollectionLayoutSection {
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

    private func createHeaderSupplementaryItem() -> NSCollectionLayoutBoundarySupplementaryItem {
        let headerSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .estimated(44))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: headerSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top
        )
        return header
    }

    private func setupDataSource() {
        // swiftlint:disable:next line_length
        dataSource = UICollectionViewDiffableDataSource<Section, AnyArtObjectCategoryViewModel>(collectionView: collectionView) { collectionView, indexPath, viewModel in
            let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: "ArtObjectCategoryView",
                for: indexPath
            // swiftlint:disable:next force_cast
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
            // swiftlint:disable:next force_cast
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

    func showError(_ error: Error) {
        errorLabel.isHidden = false
        errorLabel.text = error.localizedDescription
    }

    private func applySnapshot(sections: [any ArtObjectCategoryViewModelProtocol]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, AnyArtObjectCategoryViewModel>()

        sections.forEach { sectionModel in
            snapshot.appendSections([.category(sectionModel)])
            snapshot.appendItems([.init(sectionModel)])
        }

        dataSource.apply(snapshot, animatingDifferences: true)
    }
}

extension ArtObjectCategoriesViewController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        let thresholdIndex = viewModel.items.count - 5
        if indexPaths.contains(where: { $0.section > thresholdIndex }) {
            viewModel.loadMoreData()
        }
    }
}

struct AnyArtObjectCategoryViewModel: Hashable, Sendable {
    let viewModel: any ArtObjectCategoryViewModelProtocol

    init(_ viewModel: any ArtObjectCategoryViewModelProtocol) {
        self.viewModel = viewModel
    }

    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.viewModel === rhs.viewModel // Reference equality
    }

   func hash(into hasher: inout Hasher) {
        hasher.combine(ObjectIdentifier(type(of: viewModel))) // Use the type identifier for hashing
        hasher.combine(viewModel) // Delegate to underlying viewModel's hash function
    }
}

extension ArtObjectCategoriesViewController {
    enum Section: Hashable, Sendable {
        case category(any ArtObjectCategoryViewModelProtocol)

        func hash(into hasher: inout Hasher) {
            switch self {
            case .category(let viewModel):
                hasher.combine(viewModel.title)
            }
        }

        static func == (lhs: Self, rhs: Self) -> Bool {
            switch (lhs, rhs) {
            case let (.category(lhsViewModel), .category(rhsViewModel)):
                return lhsViewModel === rhsViewModel
            }
        }

        var title: String {
            switch self {
            case .category(let viewModel):
                return viewModel.title
            }
        }
    }
}
