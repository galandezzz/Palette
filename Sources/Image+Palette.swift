import Foundation

extension Image {

    public func createPalette() -> Palette {
        Palette.from(image: self).build()
    }

    public func createPalette(_ completion: @escaping (Palette) -> Void) {
        Palette.from(image: self).build(completion)
    }

    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public func createPalette() async -> Palette {
        await Palette.from(image: self).build()
    }
}
