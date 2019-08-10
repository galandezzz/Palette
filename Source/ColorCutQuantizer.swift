//
//  ColorCutQuantizer.swift
//  Palette
//
//  Created by Egor Snitsar on 06.08.2019.
//  Copyright © 2019 Egor Snitsar. All rights reserved.
//

import UIKit

internal final class ColorCutQuantizer {

    internal var quantizedColors = [Palette.Swatch]()

    internal init(colors: [Color], maxColorsCount: Int, filters: [PaletteFilter]) {
        self.filters = filters

        let hist = CountedSet(
            colors
                .map { $0.quantized }
                .filter { !shouldIgnoreColor($0.normalized) }
        )

        var distinctColors = hist.allObjects

        if distinctColors.count <= maxColorsCount {
            quantizedColors = distinctColors.map { Palette.Swatch(color: $0.normalized, population: hist.count(for: $0)) }
        } else {
            quantizedColors = quantizePixels(maxColorsCount: maxColorsCount, colors: &distinctColors, histogram: hist)
        }
    }

    private let filters: [PaletteFilter]

    private func shouldIgnoreColor(_ swatch: Palette.Swatch) -> Bool {
        return shouldIgnoreColor(swatch._color)
    }

    private func shouldIgnoreColor(_ color: Color) -> Bool {
        return filters.contains { !$0.isAllowed(rgb: color.rgb, hsl: color.hsl) }
    }

    private func quantizePixels(maxColorsCount: Int, colors: inout [Color], histogram: CountedSet<Color>) -> [Palette.Swatch] {
        var queue = PriorityQueue<VBox>() { $0.volume > $1.volume }
        queue.enqueue(VBox(lowerIndex: colors.startIndex, upperIndex: colors.index(before: colors.endIndex), colors: colors, histogram: histogram))
        splitBoxes(queue: &queue, maxSize: maxColorsCount, colors: &colors, histogram: histogram)

        return generateAverageColors(from: queue.elements, colors: colors, histogram: histogram)
    }

    private func splitBoxes(queue: inout PriorityQueue<VBox>, maxSize: Int, colors: inout [Color], histogram: CountedSet<Color>) {
        while queue.count < maxSize {
            if let vbox = queue.dequeue(), vbox.canSplit {
                if let newBox = vbox.splitBox(colors: &colors, histogram: histogram)  {
                    queue.enqueue(newBox)
                }
                queue.enqueue(vbox)
            } else {
                return
            }
        }
    }

    private func generateAverageColors(from boxes: [VBox], colors: [Color], histogram: CountedSet<Color>) -> [Palette.Swatch] {
        return boxes.compactMap {
            let swatch = $0.averageColor(colors: colors, histogram: histogram)

            guard !shouldIgnoreColor(swatch) else {
                return nil
            }

            return swatch
        }
    }

    private class VBox {

        internal init(lowerIndex: Int, upperIndex: Int, colors: [Color], histogram: CountedSet<Color>) {
            self.lowerIndex = lowerIndex
            self.upperIndex = upperIndex
            fitBox(colors: colors, histogram: histogram)
        }

        internal var volume: Int {
            return (maxRed - minRed + 1) * (maxGreen - minGreen + 1) * (maxBlue - minBlue + 1)
        }

        internal var canSplit: Bool {
            return colorCount > 1
        }

        internal func splitBox(colors: inout [Color], histogram: CountedSet<Color>) -> VBox? {
            guard canSplit else {
                return nil
            }

            let splitPoint = findSplitPoint(colors: &colors, histogram: histogram)
            let newBox = VBox(lowerIndex: splitPoint + 1, upperIndex: upperIndex, colors: colors, histogram: histogram)

            upperIndex = splitPoint
            fitBox(colors: colors, histogram: histogram)

            return newBox
        }

        internal func averageColor(colors: [Color], histogram: CountedSet<Color>) -> Palette.Swatch {
            var redSum = 0, greenSum = 0, blueSum = 0, totalCount = 0

            colors[lowerIndex...upperIndex].forEach {
                let (r, g, b) = $0.rgb
                let count = histogram.count(for: $0)

                totalCount += count
                redSum += count * Int(r)
                greenSum += count * Int(g)
                blueSum += count * Int(b)
            }

            let mean: (Int) -> Int = { Int((CGFloat($0) / CGFloat(totalCount)).rounded()) }

            let redMean = mean(redSum)
            let greenMean = mean(greenSum)
            let blueMean = mean(blueSum)

            let color = Color([redMean, greenMean, blueMean], width: .quantized)

            return Palette.Swatch(color: color.normalized, population: totalCount)
        }

        // MARK: - Private

        private enum Component {
            case red
            case green
            case blue
        }

        private let lowerIndex: Int
        private var upperIndex: Int

        private var population = 0

        private var minRed = 0, maxRed = 0
        private var minGreen = 0, maxGreen = 0
        private var minBlue = 0, maxBlue = 0

        private var colorCount: Int {
            return upperIndex - lowerIndex + 1
        }

        private func fitBox(colors: [Color], histogram: CountedSet<Color>) {
            minRed = Int.max
            minGreen = Int.max
            minBlue = Int.max
            maxRed = Int.min
            maxGreen = Int.min
            maxBlue = Int.min

            for i in (lowerIndex...upperIndex) {
                let color = colors[i]
                population += histogram.count(for: color)

                let r = Int(color.red)
                let g = Int(color.green)
                let b = Int(color.blue)

                if r > maxRed { maxRed = r }
                if r < minRed { minRed = r }

                if g > maxGreen { maxGreen = g }
                if g < minGreen { minGreen = g }

                if b > maxBlue { maxBlue = b }
                if b < minBlue { minBlue = b }
            }
        }

        private func findLongestComponent() -> Component {
            let redLength = maxRed - minRed
            let greenLength = maxGreen - minGreen
            let blueLength = maxBlue - minBlue

            if redLength >= greenLength && redLength >= blueLength {
                return .red
            } else if greenLength >= redLength && greenLength >= blueLength {
                return .green
            } else {
                return .blue
            }
        }

        private func findSplitPoint(colors: inout [Color], histogram: CountedSet<Color>) -> Int {
            let longestComponent = findLongestComponent()

            modifySignificantOctet(for: &colors, component: longestComponent, lower: lowerIndex, upper: upperIndex)

            colors[lowerIndex...upperIndex].sort()

            modifySignificantOctet(for: &colors, component: longestComponent, lower: lowerIndex, upper: upperIndex)

            let midPoint = population / 2
            var count = 0

            for i in (lowerIndex...upperIndex) {
                count += histogram.count(for: colors[i])

                if count >= midPoint {
                    return min(upperIndex - 1, i)
                }
            }

            return lowerIndex
        }

        private func modifySignificantOctet(for colors: inout [Color], component: Component, lower: Int, upper: Int) {
            switch component {
            case .red:
                break

            case .green:
                for i in (lower...upper) {
                    let (r, g, b) = colors[i].rgb
                    colors[i] = Color([g, r, b], width: colors[i].width)
                }

            case .blue:
                for i in (lower...upper) {
                    let (r, g, b) = colors[i].rgb
                    colors[i] = Color([b, g, r], width: colors[i].width)
                }
            }
        }
    }
}
