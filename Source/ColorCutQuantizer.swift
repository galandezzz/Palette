final class ColorCutQuantizer {

    private let filters: [PaletteFilter]

    private(set) var quantizedColors = [Palette.Swatch]()

    init(colors: [ColorDescriptor], maxColorsCount: Int, filters: [PaletteFilter]) {
        self.filters = filters

        let hist = CountedSet(
            colors
                .map(\.quantized)
                .filter { !shouldIgnoreColor($0.normalized) }
        )

        var distinctColors = hist.elements

        if distinctColors.count <= maxColorsCount {
            quantizedColors = distinctColors.map {
                Palette.Swatch(
                    color: $0.normalized,
                    population: hist.count(for: $0)
                )
            }
        } else {
            quantizedColors = quantizePixels(
                maxColorsCount: maxColorsCount,
                colors: &distinctColors,
                histogram: hist
            )
        }
    }

    private func shouldIgnoreColor(_ swatch: Palette.Swatch) -> Bool {
        shouldIgnoreColor(swatch._color)
    }

    private func shouldIgnoreColor(_ color: ColorDescriptor) -> Bool {
        filters.contains { !$0.isAllowed(rgb: color.rgb, hsl: color.hsl) }
    }

    private func quantizePixels(
        maxColorsCount: Int,
        colors: inout [ColorDescriptor],
        histogram: CountedSet<ColorDescriptor>
    ) -> [Palette.Swatch] {
        var queue = PriorityQueue<VBox>() { $0.volume > $1.volume }
        let vbox = VBox(
            range: ClosedRange(colors.indices),
            colors: colors,
            histogram: histogram
        )
        queue.enqueue(vbox)
        splitBoxes(queue: &queue, maxSize: maxColorsCount, colors: &colors, histogram: histogram)

        return generateAverageColors(from: queue.elements, colors: colors, histogram: histogram)
    }

    private func splitBoxes(
        queue: inout PriorityQueue<VBox>,
        maxSize: Int,
        colors: inout [ColorDescriptor],
        histogram: CountedSet<ColorDescriptor>
    ) {
        while queue.count < maxSize {
            guard let vbox = queue.dequeue(), vbox.canSplit else {
                return
            }
            if let newBox = vbox.splitBox(colors: &colors, histogram: histogram)  {
                queue.enqueue(newBox)
            }
            queue.enqueue(vbox)
        }
    }

    private func generateAverageColors(
        from boxes: [VBox],
        colors: [ColorDescriptor],
        histogram: CountedSet<ColorDescriptor>
    ) -> [Palette.Swatch] {
        boxes.compactMap {
            let swatch = $0.averageColor(colors: colors, histogram: histogram)
            return shouldIgnoreColor(swatch) ? nil : swatch
        }
    }

    private final class VBox {

        init(
            range: ClosedRange<Int>,
            colors: [ColorDescriptor],
            histogram: CountedSet<ColorDescriptor>
        ) {
            self.range = range
            fitBox(colors: colors, histogram: histogram)
        }

        var volume: Int {
            (maxRed - minRed + 1) * (maxGreen - minGreen + 1) * (maxBlue - minBlue + 1)
        }

        var canSplit: Bool {
            colorCount > 1
        }

        func splitBox(
            colors: inout [ColorDescriptor],
            histogram: CountedSet<ColorDescriptor>
        ) -> VBox? {
            guard canSplit else { return nil }

            let splitPoint = findSplitPoint(colors: &colors, histogram: histogram)
            let range = splitPoint + 1...range.upperBound
            let newBox = VBox(range: range, colors: colors, histogram: histogram)

            self.range = self.range.lowerBound...splitPoint
            fitBox(colors: colors, histogram: histogram)

            return newBox
        }

        func averageColor(
            colors: [ColorDescriptor],
            histogram: CountedSet<ColorDescriptor>
        ) -> Palette.Swatch {
            var redSum = 0, greenSum = 0, blueSum = 0, totalCount = 0

            colors[range].forEach {
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

            let color = ColorDescriptor([redMean, greenMean, blueMean], width: .quantized)

            return Palette.Swatch(color: color.normalized, population: totalCount)
        }

        // MARK: - Private

        private enum Component {
            case red
            case green
            case blue
        }

        private var range: ClosedRange<Int>

        private var population = 0

        private var minRed = 0, maxRed = 0
        private var minGreen = 0, maxGreen = 0
        private var minBlue = 0, maxBlue = 0

        private var colorCount: Int {
            range.count
        }

        private func fitBox(
            colors: [ColorDescriptor],
            histogram: CountedSet<ColorDescriptor>
        ) {
            minRed = Int.max
            minGreen = Int.max
            minBlue = Int.max

            maxRed = Int.min
            maxGreen = Int.min
            maxBlue = Int.min

            for i in range {
                let color = colors[i]
                population += histogram.count(for: color)

                let r = Int(color.red)
                let g = Int(color.green)
                let b = Int(color.blue)

                maxRed = max(maxRed, r)
                minRed = min(minRed, r)

                maxGreen = max(maxGreen, g)
                minGreen = min(minGreen, g)

                maxBlue = max(maxBlue, b)
                minBlue = min(minBlue, b)
            }
        }

        private func findLongestComponent() -> Component {
            let redLength = maxRed - minRed
            let greenLength = maxGreen - minGreen
            let blueLength = maxBlue - minBlue

            if redLength >= greenLength, redLength >= blueLength {
                return .red
            } else if greenLength >= redLength, greenLength >= blueLength {
                return .green
            } else {
                return .blue
            }
        }

        private func findSplitPoint(
            colors: inout [ColorDescriptor],
            histogram: CountedSet<ColorDescriptor>
        ) -> Int {
            let longestComponent = findLongestComponent()

            modifySignificantOctet(for: &colors, component: longestComponent, range: range)
            colors[range].sort()
            modifySignificantOctet(for: &colors, component: longestComponent, range: range)

            let midPoint = population / 2
            var count = 0

            for i in range {
                count += histogram.count(for: colors[i])

                if count >= midPoint {
                    return min(range.upperBound - 1, i)
                }
            }

            return range.lowerBound
        }

        private func modifySignificantOctet(
            for colors: inout [ColorDescriptor],
            component: Component,
            range: ClosedRange<Int>
        ) {
            switch component {
            case .red:
                break

            case .green:
                for i in range {
                    let (r, g, b) = colors[i].rgb
                    colors[i] = ColorDescriptor([g, r, b], width: colors[i].width)
                }

            case .blue:
                for i in range {
                    let (r, g, b) = colors[i].rgb
                    colors[i] = ColorDescriptor([b, g, r], width: colors[i].width)
                }
            }
        }
    }
}
