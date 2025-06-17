#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
public typealias Image = NSImage

extension Palette.Builder {

    class func from(image: NSImage) -> Palette.Builder {
        guard let image = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
            return Palette.Builder(swatches: [])
        }
        return Palette.Builder(image: image)
    }
}
#else
import UIKit
public typealias Image = UIImage

extension Palette {

    class func from(image: UIImage) -> Palette.Builder {
        guard let image = image.cgImage else {
            return Palette.Builder(swatches: [])
        }
        return Palette.Builder(image: image)
    }
}
#endif
