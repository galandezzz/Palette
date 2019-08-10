//
//  Target.swift
//  Palette
//
//  Created by Egor Snitsar on 05.08.2019.
//  Copyright © 2019 Egor Snitsar. All rights reserved.
//

import UIKit

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
}

public final class Target: Hashable {

    // MARK: - Public

    public internal(set) var minimumSaturation: CGFloat {
        get {
            return saturation.min
        }
        set {
            saturation.min = newValue
        }
    }

    public internal(set) var targetSaturation: CGFloat {
        get {
            return saturation.target
        }
        set {
            saturation.target = newValue
        }
    }

    public internal(set) var maximumSaturation: CGFloat {
        get {
            return saturation.max
        }
        set {
            saturation.max = newValue
        }
    }

    public internal(set) var minimumLightness: CGFloat {
        get {
            return lightness.min
        }
        set {
            lightness.min = newValue
        }
    }

    public internal(set) var targetLightness: CGFloat {
        get {
            return lightness.target
        }
        set {
            lightness.target = newValue
        }
    }

    public internal(set) var maximumLightness: CGFloat {
        get {
            return lightness.max
        }
        set {
            lightness.max = newValue
        }
    }

    public internal(set) var saturationWeight: CGFloat {
        get {
            return weights.saturation
        }
        set {
            weights.saturation = newValue
        }
    }

    public internal(set) var lightnessWeight: CGFloat {
        get {
            return weights.lightness
        }
        set {
            weights.lightness = newValue
        }
    }

    public internal(set) var populationWeight: CGFloat {
        get {
            return weights.population
        }
        set {
            weights.population = newValue
        }
    }

    public internal(set) var isExclusive: Bool = true

    // MARK: - Internal

    internal init() {}

    internal init(_ other: Target) {
        self.saturation = other.saturation
        self.lightness = other.lightness
        self.weights = other.weights
    }

    // MARK: - Hashable

    public static func == (lhs: Target, rhs: Target) -> Bool {
        return lhs.saturation == rhs.saturation && lhs.lightness == rhs.lightness
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(saturation)
        hasher.combine(lightness)
    }

    // MARK: - Internal

    internal func normalizeWeights() {
        let sum = weights.saturation + weights.lightness + weights.population

        guard sum > 0 else {
            return
        }

        weights.saturation /= sum
        weights.lightness /= sum
        weights.population /= sum
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
    }

    private var saturation = Value()
    private var lightness = Value()
    private var weights = Weights()

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
