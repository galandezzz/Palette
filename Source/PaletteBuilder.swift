import CoreGraphics

extension Palette {

    public final class Builder {

        // MARK: - Public

        public func with(maximumColorsCount: Int) -> Builder {
            self.maxColorsCount = maximumColorsCount
            return self
        }

        public func with(resizeArea: CGFloat) -> Builder {
            self.resizeArea = resizeArea
            return self
        }

        public func byRemovingFilters() -> Builder {
            self.filters.removeAll()
            return self
        }

        public func byAddingFilter(_ filter: PaletteFilter) -> Builder {
            self.filters.append(filter)
            return self
        }

        public func byRemovingTargets() -> Builder {
            self.targets.removeAll()
            return self
        }

        public func byAddingTarget(_ target: Target) -> Builder {
            self.targets.append(target)
            return self
        }

        public func build() -> Palette {
            let swatches: [Swatch]
            if let image = image {
                let scaledImage = scaleDownImage(image, to: resizeArea)
                let colors = calculateColors(from: scaledImage)
                let quantizer = ColorCutQuantizer(colors: colors, maxColorsCount: maxColorsCount, filters: filters)
                swatches = quantizer.quantizedColors
            } else {
                swatches = self.swatches
            }

            let p = Palette(swatches: swatches, targets: targets)
            p.generate()

            return p
        }

        public func build(_ completion: @escaping (Palette) -> Void) {
            DispatchQueue.global(qos: .userInitiated).async {
                let palette = self.build()

                DispatchQueue.main.async {
                    completion(palette)
                }
            }
        }

        // MARK: - Internal

        init(image: CGImage) {
            self.image = image

            self.filters.append(DefaultFilter())

            self.targets.append(.lightVibrant)
            self.targets.append(.vibrant)
            self.targets.append(.darkVibrant)
            self.targets.append(.lightMuted)
            self.targets.append(.muted)
            self.targets.append(.darkMuted)
        }

        init(swatches: [Swatch]) {
            self.image = nil
            self.filters.append(DefaultFilter())
            self.swatches = swatches
        }

        // MARK: - Private

        private struct Constants {
            static let defaultMaxColorsCount = 16
            static let defaultResizeBitmapArea: CGFloat = 112.0 * 112.0
        }

        private var maxColorsCount = Constants.defaultMaxColorsCount
        private var resizeArea = Constants.defaultResizeBitmapArea

        private let image: CGImage?
        private var swatches = [Swatch]()
        private var targets = [Target]()
        private var filters = [PaletteFilter]()

        private func scaleDownImage(_ image: CGImage, to resizeArea: CGFloat) -> CGImage {
            let bitmapArea = CGFloat(image.width * image.height)
            guard bitmapArea > resizeArea else { return image }

            let ratio = sqrt(resizeArea / bitmapArea)
            let width = ceil(ratio * CGFloat(image.width))
            let height = ceil(ratio * CGFloat(image.height))

            let context = CGContext(
                data: nil,
                width: Int(width),
                height: Int(height),
                bitsPerComponent: image.bitsPerComponent,
                bytesPerRow: image.bytesPerRow,
                space: image.colorSpace ?? CGColorSpaceCreateDeviceRGB(),
                bitmapInfo: image.bitmapInfo.rawValue
            )

            let size = CGSize(width: width, height: height)
            let rect = CGRect(origin: .zero, size: size)
            context?.draw(image, in: rect)

            return context?.makeImage() ?? image
        }

        private func calculateColors(from image: CGImage) -> [ColorDescriptor] {
            let width = image.width
            let height = image.height

            let bytesPerRow = width * 4
            let bytesCount = bytesPerRow * height

            let colorSpace = CGColorSpaceCreateDeviceRGB()

            var data = Array(repeating: UInt8(0), count: bytesCount)

            let context = CGContext(
                data: &data,
                width: width,
                height: height,
                bitsPerComponent: 8,
                bytesPerRow: bytesPerRow,
                space: colorSpace,
                bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
            )

            let size = CGSize(width: width, height: height)
            let rect = CGRect(origin: .zero, size: size)

            context?.draw(image, in: rect)

            return data.chunk(into: 4).map { ColorDescriptor(reducingAlpha: $0) }
        }
    }
}
