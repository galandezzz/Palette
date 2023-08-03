//
//  Palette.swift
//  Palette
//
//  Created by Egor Snitsar on 05.08.2019.
//  Copyright © 2019 Egor Snitsar. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import AppKit
#endif

public final class Palette {

    // MARK: - Public

    public let swatches: [Swatch]

    #if os(iOS)
    public class func from(image: UIImage) -> Builder? {
        guard let cgImage = image.cgImage else { return nil }
        return Builder(image: cgImage)
    }
    #else
    public class func from(image: NSImage) -> Builder? {
        guard let cgImage = image.cgImage(forProposedRect: nil, context: nil, hints: nil) else { return nil }
        return Builder(image: cgImage)
    }
    #endif

    public var lightVibrantSwatch: Swatch? {
        return swatch(for: .lightVibrant)
    }

    #if os(iOS)
    public var lightVibrantColor: UIColor? {
        return lightVibrantSwatch?.color
    }
    #else
    public var lightVibrantColor: NSColor? {
        return lightVibrantSwatch?.color
    }
    #endif

    public var vibrantSwatch: Swatch? {
        return swatch(for: .vibrant)
    }

    #if os(iOS)
    public var vibrantColor: UIColor? {
        return vibrantSwatch?.color
    }
    #else
    public var vibrantColor: NSColor? {
        return vibrantSwatch?.color
    }
    #endif

    public var darkVibrantSwatch: Swatch? {
        return swatch(for: .darkVibrant)
    }

    #if os(iOS)
    public var darkVibrantColor: UIColor? {
        return darkVibrantSwatch?.color
    }
    #else
    public var darkVibrantColor: NSColor? {
        return darkVibrantSwatch?.color
    }
    #endif

    public var lightMutedSwatch: Swatch? {
        return swatch(for: .lightMuted)
    }

    #if os(iOS)
    public var lightMutedColor: UIColor? {
        return lightMutedSwatch?.color
    }
    #else
    public var lightMutedColor: NSColor? {
        return lightMutedSwatch?.color
    }
    #endif

    public var mutedSwatch: Swatch? {
        return swatch(for: .muted)
    }

    #if os(iOS)
    public var mutedColor: UIColor? {
        return mutedSwatch?.color
    }
    #else
    public var mutedColor: NSColor? {
        return mutedSwatch?.color
    }
    #endif

    public var darkMutedSwatch: Swatch? {
        return swatch(for: .darkMuted)
    }

    #if os(iOS)
    public var darkMutedColor: UIColor? {
        return darkMutedSwatch?.color
    }
    #else
    public var darkMutedColor: NSColor? {
        return darkMutedSwatch?.color
    }
    #endif

    public private(set) lazy var dominantSwatch: Swatch? = {
        return swatches.max { $0.population < $1.population }
    }()

    #if os(iOS)
    public var dominantColor: UIColor? {
        return dominantSwatch?.color
    }
    #else
    public var dominantColor: NSColor? {
        return dominantSwatch?.color
    }
    #endif

    public func swatch(for target: Target) -> Swatch? {
        return selectedSwatches[target]
    }

    #if os(iOS)
    public func color(for target: Target) -> UIColor? {
        return swatch(for: target)?.color
    }
    #else
    public func color(for target: Target) -> NSColor? {
        return swatch(for: target)?.color
    }
    #endif

    // MARK: - Internal

    internal init(swatches: [Swatch], targets: [Target]) {
        self.swatches = swatches
        self.targets = targets
    }

    internal func generate() {
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
