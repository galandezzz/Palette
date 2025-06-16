import Foundation

extension UIImage {

    public func createPalette() -> Palette {
        return Palette.from(image: self).generate()
    }

    public func createPalette(_ completion: @escaping (Palette) -> Void) {
        return Palette.from(image: self).generate(completion)
    }
}
