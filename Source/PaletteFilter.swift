//
//  PaletteFilter.swift
//  Palette
//
//  Created by Egor Snitsar on 06.08.2019.
//  Copyright © 2019 Egor Snitsar. All rights reserved.
//

import Foundation

public protocol PaletteFilter {
    func isAllowed(rgb: RGB, hsl: HSL) -> Bool
}

internal struct DefaultFilter: PaletteFilter {

    private struct Constants {
        static let blackMaxLightness: CGFloat = 0.05
        static let whiteMinLightness: CGFloat = 0.95
        static let iLineHueRange: ClosedRange<CGFloat> = (10...37)
        static let iLineSaturationRange: ClosedRange<CGFloat> = (0...0.82)
    }

    func isAllowed(rgb: RGB, hsl: HSL) -> Bool {
        return !isWhite(hsl) && !isBlack(hsl) && !isNearRedILine(hsl)
    }

    private func isBlack(_ hsl: HSL) -> Bool {
        return hsl.l <= Constants.blackMaxLightness
    }

    private func isWhite(_ hsl: HSL) -> Bool {
        return hsl.l >= Constants.whiteMinLightness
    }

    private func isNearRedILine(_ hsl: HSL) -> Bool {
        return Constants.iLineHueRange.contains(hsl.h) && Constants.iLineSaturationRange.contains(hsl.s)
    }
}
