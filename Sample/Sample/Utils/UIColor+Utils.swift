import UIKit

extension UIColor {

    func toHexString() -> String? {
        var r: CGFloat = 0.0
        var g: CGFloat = 0.0
        var b: CGFloat = 0.0
        var a: CGFloat = 0.0
        getRed(&r, green: &g, blue: &b, alpha: &a)

        let value = [r, g, b, a]
            .map {
                String(format: "%02lX", Int($0 * 255)).uppercased()
            }
            .joined()

        return "#\(value)"
    }
}
