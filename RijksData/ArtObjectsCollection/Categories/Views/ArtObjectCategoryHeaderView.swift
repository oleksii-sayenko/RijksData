import UIKit

class ArtObjectCategoryHeaderView: UICollectionReusableView {
    // TODO: Add extension
    static let reuseIdentifier = "ArtObjectCategoryHeaderView"

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.monospacedSystemFont(ofSize: Constants.titleFontSize, weight: .bold)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupView() {
        addSubview(titleLabel)

        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Constants.titleMargin.leading),
            titleLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: Constants.titleMargin.trailing),
            titleLabel.topAnchor.constraint(equalTo: topAnchor, constant: Constants.titleMargin.top),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: Constants.titleMargin.bottom)
        ])

        titleLabel.textColor = .orange
    }

    func configure(with title: String) {
        titleLabel.text = title.capitalized
    }
}

extension ArtObjectCategoryHeaderView {
    enum Constants {
        static let titleFontSize: CGFloat = 18
        static let titleMargin: NSDirectionalEdgeInsets = .init(top: 8, leading: 16, bottom: -8, trailing: -16)
    }
}
