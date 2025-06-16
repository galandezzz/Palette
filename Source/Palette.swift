import UIKit

public final class Palette {

    // MARK: - Public

    public let swatches: [Swatch]

    public var lightVibrantSwatch: Swatch? {
        swatch(for: .lightVibrant)
    }

    public var lightVibrantColor: UIColor? {
        lightVibrantSwatch?.color
    }

    public var vibrantSwatch: Swatch? {
        swatch(for: .vibrant)
    }

    public var vibrantColor: UIColor? {
        vibrantSwatch?.color
    }

    public var darkVibrantSwatch: Swatch? {
        swatch(for: .darkVibrant)
    }

    public var darkVibrantColor: UIColor? {
        darkVibrantSwatch?.color
    }

    public var lightMutedSwatch: Swatch? {
        swatch(for: .lightMuted)
    }

    public var lightMutedColor: UIColor? {
        lightMutedSwatch?.color
    }

    public var mutedSwatch: Swatch? {
        swatch(for: .muted)
    }

    public var mutedColor: UIColor? {
        mutedSwatch?.color
    }

    public var darkMutedSwatch: Swatch? {
        swatch(for: .darkMuted)
    }

    public var darkMutedColor:UIColor? {
        darkMutedSwatch?.color
    }

    public private(set) lazy var dominantSwatch: Swatch? = {
        swatches.max { $0.population < $1.population }
    }()

    public var dominantColor: UIColor? {
        dominantSwatch?.color
    }

    public class func from(image: UIImage) -> Builder {
        Builder(image: image)
    }

    public func swatch(for target: Target) -> Swatch? {
        selectedSwatches[target]
    }

    public func color(for target: Target) -> UIColor? {
        swatch(for: target)?.color
    }

    // MARK: - Internal

    init(swatches: [Swatch], targets: [Target]) {
        self.swatches = swatches
        self.targets = targets
    }

    func generate() {
        targets.forEach {
            $0.normalizeWeights()
            selectedSwatches[$0] = scoredSwatch(for: $0)
        }

        usedColors.removeAll()
    }

    // MARK: - Private

    private let targets: [Target]

    private var selectedSwatches = [Target: Swatch]()
    private var usedColors = Set<Color>()

    private func scoredSwatch(for target: Target) -> Swatch? {
        guard let swatch = maxScoredSwatch(for: target) else {
            return nil
        }

        if target.isExclusive {
            usedColors.insert(swatch._color)
        }

        return swatch
    }

    private func maxScoredSwatch(for target: Target) -> Swatch? {
        let result = swatches
            .filter { shouldBeScored($0, for: target) }
            .map { (swatch: $0, score: score($0, target: target)) }
            .max { $0.score < $1.score }

        return result?.swatch
    }

    private func shouldBeScored(_ swatch: Swatch, for target: Target) -> Bool {
        let hsl = swatch.hsl

        return (target.minimumSaturation...target.maximumSaturation).contains(hsl.s)
            && (target.minimumLightness...target.maximumLightness).contains(hsl.l)
            && !usedColors.contains(swatch._color)
    }

    private func score(_ swatch: Swatch, target: Target) -> CGFloat {
        let hsl = swatch.hsl
        let maxPopulation = CGFloat(dominantSwatch?.population ?? 1)

        let saturationScore = target.saturationWeight * (1 - abs(hsl.s - target.targetSaturation))
        let lightnessScore = target.lightnessWeight * (1 - abs(hsl.l - target.targetLightness))
        let populationScore = target.populationWeight * CGFloat(swatch.population) / maxPopulation

        return saturationScore + lightnessScore + populationScore
    }
}
