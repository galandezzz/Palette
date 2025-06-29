import CoreGraphics

public protocol PaletteFilter {
    func isAllowed(rgb: RGB, hsl: HSL) -> Bool
}

struct DefaultFilter: PaletteFilter {

    private struct Constants {
        static let blackMaxLightness: CGFloat = 0.05
        static let whiteMinLightness: CGFloat = 0.95
        static let iLineHueRange: ClosedRange<CGFloat> = (10...37)
        static let iLineSaturationRange: ClosedRange<CGFloat> = (0...0.82)
    }

    func isAllowed(rgb: RGB, hsl: HSL) -> Bool {
        !isWhite(hsl) && !isBlack(hsl) && !isNearRedILine(hsl)
    }

    private func isBlack(_ hsl: HSL) -> Bool {
        hsl.l <= Constants.blackMaxLightness
    }

    private func isWhite(_ hsl: HSL) -> Bool {
        hsl.l >= Constants.whiteMinLightness
    }

    private func isNearRedILine(_ hsl: HSL) -> Bool {
        Constants.iLineHueRange.contains(hsl.h) &&
        Constants.iLineSaturationRange.contains(hsl.s)
    }
}
