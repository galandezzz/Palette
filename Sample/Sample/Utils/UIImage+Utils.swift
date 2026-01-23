import UIKit

extension UIImage {

    static func withText(
        _ text: String,
        attributes: [NSAttributedString.Key: Any],
        paddings: UIEdgeInsets = UIEdgeInsets(all: 16.0)
    ) -> UIImage {
        let attributedText = NSAttributedString(string: text, attributes: attributes)
        let bounds = CGRect(origin: .zero, size: attributedText.size()).inset(by: paddings.inverted)
        return UIGraphicsImageRenderer(bounds: bounds).image { _ in
            attributedText.draw(in: bounds.inset(by: paddings))
        }
    }
}
