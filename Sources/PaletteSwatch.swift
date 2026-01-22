import CoreGraphics

public typealias RGB = (r: Int, g: Int, b: Int)
public typealias HSL = (h: CGFloat, s: CGFloat, l: CGFloat)

extension Palette {

    public final class Swatch: CustomDebugStringConvertible {

        public private(set) lazy var color = Color(_color)
        public private(set) lazy var hsl: HSL = _color.hsl
        public private(set) lazy var rgb: RGB = _color.rgb

        public var titleTextColor: Color {
            textColors.title
        }

        public var bodyTextColor: Color {
            textColors.body
        }

        public let population: Int

        public var debugDescription: String {
            """
            Color: \(String(describing: _color))
            Population: \(population)
            Title Text Color: \(String(describing: titleTextColor))
            Body Text Color: \(String(describing: bodyTextColor))
            """
        }

        init(color: ColorDescriptor, population: Int) {
            self._color = color
            self.population = population
        }

        let _color: ColorDescriptor

        private typealias TextColors = (title: Color, body: Color)
        private lazy var textColors: TextColors = generateTextColors()

        private func generateTextColors() -> TextColors {
            let titleMinimumContrast: CGFloat = 3.0
            let bodyMinimumContrast: CGFloat = 4.5

            typealias Params = (titleAlpha: CGFloat?, bodyAlpha: CGFloat?, colors: TextColors?, foreground: Color)
            let processColor = { [self] (foreground: Color) -> Params in
                let titleAlpha = foreground.minAlpha(comparedTo: color, minimumContrastRatio: titleMinimumContrast)
                let bodyAlpha = foreground.minAlpha(comparedTo: color, minimumContrastRatio: bodyMinimumContrast)

                let colors: TextColors? = if let titleAlpha, let bodyAlpha {
                    TextColors(
                        foreground.withAlphaComponent(titleAlpha),
                        foreground.withAlphaComponent(bodyAlpha)
                    )
                } else {
                    nil
                }

                return (titleAlpha, bodyAlpha, colors, foreground)
            }

            // First check white, as most colors will be dark
            let lightParams = processColor(.white)
            if let lightColors = lightParams.colors {
                // If we found valid light values, use them and return
                return lightColors
            }

            let darkParams = processColor(.black)
            if let darkColors = darkParams.colors {
                // If we found valid dark values, use them and return
                return darkColors
            }

            // If we reach here then we can not find title and body values which use the same
            // lightness, we need to use mismatched values
            let getColor = { (keyPath: KeyPath<Params, CGFloat?>) -> Color in
                if let lightAlpha = lightParams[keyPath: keyPath] {
                    lightParams.foreground.withAlphaComponent(lightAlpha)
                } else {
                    darkParams.foreground.withAlphaComponent(darkParams[keyPath: keyPath] ?? 1.0)
                }
            }

            return (getColor(\.titleAlpha), getColor(\.bodyAlpha))
        }
    }
}
