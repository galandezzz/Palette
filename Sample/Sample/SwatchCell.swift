import Palette
import UIKit

final class SwatchCell: UICollectionViewCell {

    static let identifier = "SwatchCell"

    private let labelContentView = UIView()
    private lazy var titleLabel = makeLabel(font: .boldSystemFont(ofSize: 20))
    private lazy var bodyLabel = makeLabel(font: .systemFont(ofSize: 14))

    private func makeLabel(font: UIFont) -> UILabel {
        let result = UILabel()
        result.numberOfLines = 1
        result.font = font
        result.textAlignment = .center
        result.lineBreakMode = .byWordWrapping
        result.translatesAutoresizingMaskIntoConstraints = false
        return result
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        labelContentView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(labelContentView)
        labelContentView.addSubview(titleLabel)
        labelContentView.addSubview(bodyLabel)

        NSLayoutConstraint.activate([
            labelContentView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            labelContentView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            labelContentView.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor),
            labelContentView.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor),

            titleLabel.topAnchor.constraint(equalTo: labelContentView.topAnchor),
            titleLabel.leadingAnchor.constraint(equalTo: labelContentView.leadingAnchor),
            titleLabel.trailingAnchor.constraint(equalTo: labelContentView.trailingAnchor),

            bodyLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8.0),
            bodyLabel.leadingAnchor.constraint(equalTo: labelContentView.leadingAnchor),
            bodyLabel.trailingAnchor.constraint(equalTo: labelContentView.trailingAnchor),
            bodyLabel.bottomAnchor.constraint(equalTo: labelContentView.bottomAnchor)
        ])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(with swatch: Palette.Swatch) {
        contentView.backgroundColor = swatch.color
        titleLabel.textColor = swatch.titleTextColor
        titleLabel.text = swatch.titleTextColor.toHexString()
        bodyLabel.textColor = swatch.bodyTextColor
        bodyLabel.text = swatch.bodyTextColor.toHexString()
    }
}
