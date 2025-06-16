import Foundation

extension Image {

    public func createPalette() -> Palette {
        Palette.Builder(self).build()
    }

    public func createPalette(_ completion: @escaping (Palette) -> Void) {
        Palette.Builder(self).build(completion)
    }
}
