//
//  Target.swift
//  Palette
//
//  Created by Egor Snitsar on 05.08.2019.
//  Copyright © 2019 Egor Snitsar. All rights reserved.
//

import UIKit

public class Target: Hashable {

    // MARK: - Public

    public var saturationWeight: CGFloat {
        return weights.saturation
    }

    public var lightnessWeight: CGFloat {
        return weights.lightness
    }

    public var populationWeight: CGFloat {
        return weights.population
    }

    public var minimumSaturation: CGFloat {
        return saturation.min
    }

    public var targetSaturation: CGFloat {
        return saturation.target
    }

    public var maximumSaturation: CGFloat {
        return saturation.max
    }

    public var minimumLightness: CGFloat {
        return lightness.min
    }

    public var targetLightness: CGFloat {
        return lightness.target
    }

    public var maximumLightness: CGFloat {
        return lightness.max
    }

    public internal(set) var isExclusive: Bool = true

    // MARK: - Hashable

    public static func == (lhs: Target, rhs: Target) -> Bool {
        return lhs.saturation == rhs.saturation
            && lhs.lightness == rhs.lightness
            && lhs.weights == rhs.weights
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(saturation)
        hasher.combine(lightness)
        hasher.combine(weights)
    }

    // MARK: - Internal

    internal func normalizeWeights() {
        let sum: CGFloat = weights.values.reduce(0.0, +)

        guard sum != 0 else {
            return
        }

        weights.values = weights.values.map { $0 / sum }
    }

    // MARK: - Private

    private struct Value: Hashable {
        var min: CGFloat = 0.0
        var target: CGFloat = 0.5
        var max: CGFloat = 1.0
    }

    private struct Weights: Hashable {
        var saturation: CGFloat = 0.24
        var lightness: CGFloat = 0.52
        var population: CGFloat = 0.24

        var values: [CGFloat] {
            get {
                return [saturation, lightness, population]
            }
            set {
                guard newValue.count == 3 else {
                    fatalError("Expected three components")
                }

                saturation = newValue[0]
                lightness = newValue[1]
                population = newValue[2]
            }
        }
    }

    private var saturation = Value()
    private var lightness = Value()
    private var weights = Weights()
}

extension Target {

    public static let lightVibrant: Target = {
        var result = Target()
        result.setDefaultLightLightnessValues()
        result.setDefaultVibrantSaturationValues()

        return result
    }()

    public static let vibrant: Target = {
        var result = Target()
        result.setDefaultNormalLightnessValues()
        result.setDefaultVibrantSaturationValues()

        return result
    }()

    public static let darkVibrant: Target = {
        var result = Target()
        result.setDefaultDarkLightnessValues()
        result.setDefaultVibrantSaturationValues()

        return result
    }()

    public static let lightMuted: Target = {
        var result = Target()
        result.setDefaultLightLightnessValues()
        result.setDefaultMutedSaturationValues()

        return result
    }()

    public static let muted: Target = {
        var result = Target()
        result.setDefaultNormalLightnessValues()
        result.setDefaultMutedSaturationValues()

        return result
    }()

    public static let darkMuted: Target = {
        var result = Target()
        result.setDefaultDarkLightnessValues()
        result.setDefaultMutedSaturationValues()

        return result
    }()

    // MARK: - Private

    private func setDefaultLightLightnessValues() {
        lightness.min = 0.55
        lightness.target = 0.74
    }

    private func setDefaultNormalLightnessValues() {
        lightness.min = 0.3
        lightness.target = 0.5
        lightness.max = 0.7
    }

    private func setDefaultDarkLightnessValues() {
        lightness.target = 0.26
        lightness.max = 0.45
    }

    private func setDefaultVibrantSaturationValues() {
        saturation.min = 0.35
        saturation.target = 1.0
    }

    private func setDefaultMutedSaturationValues() {
        saturation.target = 0.3
        saturation.max = 0.4
    }
}
