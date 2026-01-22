import CoreGraphics

extension Color {

    convenience init(_ color: ColorDescriptor) {
        self.init(
            red: CGFloat(color.red) / 255.0,
            green: CGFloat(color.green) / 255.0,
            blue: CGFloat(color.blue) / 255.0,
            alpha: 1.0
        )
    }

    func minAlpha(comparedTo color: Color, minimumContrastRatio: CGFloat) -> CGFloat? {
        guard color.components.alpha == 1.0 else {
            // Background can not be translucent
            return nil
        }
        // First lets check that the fully opaque foreground has sufficient contrast
        guard
            let testRatio = withAlphaComponent(1.0).contrast(to: color),
            testRatio >= minimumContrastRatio
        else {
            return nil
        }

        // Binary search to find value with the minimum value which provides sufficient contrast
        let maxIterationsCount = 10
        let searchPrecision: CGFloat = 1.0 / 255.0
        var currentIterationsCount = 0
        var minAlpha: CGFloat = 0.0
        var maxAlpha: CGFloat = 1.0
        while currentIterationsCount <= maxIterationsCount, (maxAlpha - minAlpha) > searchPrecision {
            let testAlpha = (minAlpha + maxAlpha) / 2.0
            let testForeground = withAlphaComponent(testAlpha)
            if let testRatio = testForeground.contrast(to: color) {
                if testRatio < minimumContrastRatio {
                    minAlpha = testAlpha
                } else {
                    maxAlpha = testAlpha
                }
            }
            currentIterationsCount += 1
        }

        // Conservatively return the max of the range of possible alphas, which is known to pass
        return maxAlpha
    }

    private var luminance: CGFloat {
        // Luminance is the Y component
        ColorConverter.colorToXYZ(self).y / 100
    }

    private func contrast(to color: Color) -> CGFloat? {
        if color.components.alpha != 1.0 {
            // Background can not be translucent
            return nil
        }

        var foreground = self
        if foreground.components.alpha < 1.0 {
            // If the foreground is translucent, blend foreground over the background
            foreground = foreground.blended(with: color) ?? .clear
        }
        
        let foregroundLuminance = foreground.luminance + 0.05
        let backgroundLuminance = color.luminance + 0.05
        
        // Return the lighter luminance divided by the darker luminance
        return max(foregroundLuminance, backgroundLuminance) / min(foregroundLuminance, backgroundLuminance)
    }

    private func blended(with color: Color) -> Color? {
        let base = components
        let overlay = color.components
        let blendedAlpha = 1.0 - (1.0 - base.alpha) * (1.0 - overlay.alpha)
        guard blendedAlpha > .zero else {
            return nil
        }
        let blendComponent = { (baseComponent: CGFloat, overlayComponent: CGFloat) -> CGFloat in
            (baseComponent * base.alpha) + (overlayComponent * overlay.alpha * (1.0 - base.alpha)) / blendedAlpha
        }

        return Color(
            red: blendComponent(base.red, overlay.red),
            green: blendComponent(base.green, overlay.green),
            blue: blendComponent(base.blue, overlay.blue),
            alpha: blendedAlpha
        )
    }
}
