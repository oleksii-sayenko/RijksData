import UIKit
import Nuke

class ArtObjectItemCell: UICollectionViewCell {
    private let label = UILabel()
    private let imageView = UIImageView()
    private let titleBackground = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.addSubview(imageView)
        contentView.addSubview(titleBackground)
        contentView.addSubview(label)

        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleBackground.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            titleBackground.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            titleBackground.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            titleBackground.topAnchor.constraint(equalTo: label.topAnchor, constant: -10),
            titleBackground.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            // TODO: magic number
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),

            imageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        contentView.backgroundColor = .systemGray5
        contentView.layer.cornerRadius = 8

        imageView.tintColor = .gray
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 8

        titleBackground.backgroundColor = .black.withAlphaComponent(0.4)
        titleBackground.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        titleBackground.layer.cornerRadius = 8

        label.font = .italicSystemFont(ofSize: 12)
        label.textColor = .white
        label.numberOfLines = 2
    }

    func configure(with text: String, imageURL: URL?) {
        label.text = text
        guard let imageURL else {
            return
        }

        Task {
            try await loadImage(url: imageURL)
        }
    }

    private func loadImage(url: URL) async throws {
        let imageTask = ImagePipeline.shared.imageTask(with: url)
        imageView.image = try await imageTask.image
        imageView.contentMode = .scaleAspectFill
    }

    override func prepareForReuse() {
        imageView.image = .init(systemName: "photo")
        imageView.contentMode = .scaleAspectFit
    }
}
