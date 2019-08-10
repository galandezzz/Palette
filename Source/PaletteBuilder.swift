//
//  PaletteBuilder.swift
//  Palette
//
//  Created by Egor Snitsar on 05.08.2019.
//  Copyright © 2019 Egor Snitsar. All rights reserved.
//

import UIKit

extension Palette {

    public class Builder {

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

        public func generate() -> Palette {
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

        public func generate(_ completion: @escaping (Palette) -> Void) {
            DispatchQueue.global(qos: .userInitiated).async {
                let palette = self.generate()

                DispatchQueue.main.async {
                    completion(palette)
                }
            }
        }

        // MARK: - Internal

        internal init(image: UIImage) {
            self.image = image

            self.filters.append(DefaultFilter())

            self.targets.append(.lightVibrant)
            self.targets.append(.vibrant)
            self.targets.append(.darkVibrant)
            self.targets.append(.lightMuted)
            self.targets.append(.muted)
            self.targets.append(.darkMuted)
        }

        internal init(swatches: [Swatch]) {
            self.image = nil
            self.filters.append(DefaultFilter())
            self.swatches = swatches
        }

        // MARK: - Private

        private struct Constants {
            static let defaultMaxColorsCount = 16
            static let defaultResizeBitmapArea: CGFloat = 112 * 112
        }

        private var maxColorsCount = Constants.defaultMaxColorsCount
        private var resizeArea = Constants.defaultResizeBitmapArea

        private let image: UIImage?
        private var swatches = [Swatch]()
        private var targets = [Target]()
        private var filters = [PaletteFilter]()

        private func scaleDownImage(_ image: UIImage, to resizeArea: CGFloat) -> UIImage {
            var scaleRatio: CGFloat?

            let size = image.size
            let bitmapArea = size.width * size.height

            if bitmapArea > resizeArea {
                scaleRatio = sqrt(resizeArea / bitmapArea)
            }

            guard let ratio = scaleRatio else {
                return image
            }

            let width = ceil(ratio * size.width)
            let height = ceil(ratio * size.height)
            let rect = CGRect(origin: .zero, size: CGSize(width: width, height: height))

            UIGraphicsBeginImageContext(rect.size)
            image.draw(in: rect)

            let resultImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()

            return resultImage ?? image
        }

        private func calculateColors(from image: UIImage) -> [Color] {
            guard let cgImage = image.cgImage else {
                return []
            }

            let width = cgImage.width
            let height = cgImage.height

            let bytesPerRow = width * 4
            let bytesCount = bytesPerRow * height

            let colorSpace = CGColorSpaceCreateDeviceRGB()

            var data = Array(repeating: UInt8(0), count: bytesCount)

            let context = CGContext(data: &data,
                                    width: width,
                                    height: height,
                                    bitsPerComponent: 8,
                                    bytesPerRow: bytesPerRow,
                                    space: colorSpace,
                                    bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)

            let size = CGSize(width: width, height: height)
            let rect = CGRect(origin: .zero, size: size)

            context?.draw(cgImage, in: rect)

            return data.chunk(into: 4).map { Color(reducingAlpha: $0) }
        }
    }
}

private extension Collection where Index: Strideable {

    func chunk(into size: Index.Stride) -> [[Element]] {
        return stride(from: startIndex, to: endIndex, by: size).map {
            Array(self[$0 ..< Swift.min($0.advanced(by: size), endIndex)])
        }
    }
}
