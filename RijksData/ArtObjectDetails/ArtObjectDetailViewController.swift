import UIKit
import Combine
import Nuke

final class ArtObjectDetailViewController: UIViewController {
    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let activityIndicator = UIActivityIndicatorView()

    // swiftlint:disable:next implicitly_unwrapped_optional
    private var viewModel: ArtObjectDetailViewModelProtocol!

    private var cancellables = Set<AnyCancellable>()

    init() {
        super.init(nibName: nil, bundle: nil)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with viewModel: ArtObjectDetailViewModelProtocol) {
        self.viewModel = viewModel
        setupBinding()
    }

    override func viewDidLoad() {
        Task {
            await self.viewModel.loadData()
        }
    }

    // MARK: Setup UI

    private func setupUI() {
        view.backgroundColor = .gray

        setupTitle()
        setupImage()
        setupDescription()
        setupActivityIndicator()

        view.sendSubviewToBack(imageView)
    }

    func setupImage() {
        view.addSubview(imageView)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            imageView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray4
    }

    func setupTitle() {
        view.addSubview(titleLabel)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor)
        ])

        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel.textColor = .white
        titleLabel.font = .boldSystemFont(ofSize: Constants.titleFontSize)
        titleLabel.setContentCompressionResistancePriority(.required, for: .vertical)
    }

    func setupDescription() {
        view.addSubview(descriptionLabel)

        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            descriptionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            descriptionLabel.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])

        descriptionLabel.backgroundColor = .black.withAlphaComponent(0.3)
        descriptionLabel.numberOfLines = 0
        descriptionLabel.textAlignment = .justified
        descriptionLabel.textColor = .white
    }

    func setupActivityIndicator() {
        view.addSubview(activityIndicator)

        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])

        activityIndicator.isHidden = true
        activityIndicator.style = .large
    }

    func setupBinding() {
        viewModel.statePublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] state in
                switch state {
                case .initial, .loading:
                    self?.startLoading()
                case let .loaded(detail):
                    self?.showDetail(detail)
                case let .error(error):
                    self?.showError(error)
                }
            }
            .store(in: &cancellables)
    }

    // MARK: Update UI

    private func startLoading() {
        imageView.image = .init(systemName: "photo")
        activityIndicator.startAnimating()
        titleLabel.isHidden = false
        descriptionLabel.isHidden = true
    }

    private func showDetail(_ detail: RijkArtObjectDetail) {
        activityIndicator.stopAnimating()

        titleLabel.isHidden = false
        titleLabel.text = detail.title

        detail.label.description.map {
            descriptionLabel.isHidden = false
            descriptionLabel.font = .italicSystemFont(ofSize: Constants.decriptionFontSize)
            descriptionLabel.text = $0
        }

        guard let url = detail.webImage?.url else {
            return
        }

        Task {
            let imageTask = ImagePipeline.shared.imageTask(with: url)
            imageView.image = try await imageTask.image
        }
    }

    private func showError(_ error: Error) {
        activityIndicator.stopAnimating()
        imageView.image = .init(systemName: "photo")
        titleLabel.isHidden = false
        descriptionLabel.isHidden = false
        descriptionLabel.font = .systemFont(ofSize: Constants.errorFontSize)
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = "\(Text.errorHeader)\n\(error.localizedDescription)"
    }
}

extension ArtObjectDetailViewController {
    enum Constants {
        static let titleFontSize: CGFloat = 18
        static let decriptionFontSize: CGFloat = 14
        static let errorFontSize: CGFloat = 14
    }
    enum Text {
        static let errorHeader = "⚠️\nError occured"
    }
}
