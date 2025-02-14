import UIKit

class TryAgainCell: UICollectionViewCell {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        contentView.backgroundColor = .systemGray4
        contentView.layer.cornerRadius = Constants.cornerRadius

        setupLabel()
    }

    private func setupLabel() {
        contentView.addSubview(label)
        label.numberOfLines = 5
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            label.topAnchor.constraint(equalTo: contentView.topAnchor),
            label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])

        label.text = Text.tapToRetry
    }
}

extension TryAgainCell {
    enum Constants {
        static let cornerRadius: CGFloat = 8
    }

    enum Text {
        static let tapToRetry = "⚠️\nError occured\nTap to retry"
    }
}
