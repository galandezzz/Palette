#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
public typealias Image = NSImage

extension Palette.Builder {

    convenience init(_ image: NSImage) {
        if let image = image.cgImage(forProposedRect: nil, context: nil, hints: nil) {
            self.init(image: image)
        } else {
            self.init(swatches: [])
        }
    }
}
#else
import UIKit
public typealias Image = UIImage

extension Palette.Builder {

    convenience init(_ image: UIImage) {
        if let image = image.cgImage {
            self.init(image: image)
        } else {
            self.init(swatches: [])
        }
    }
}
#endif
