import CoreGraphics

public typealias RGB = (r: Int, g: Int, b: Int)
public typealias HSL = (h: CGFloat, s: CGFloat, l: CGFloat)

extension Palette {

    public final class Swatch: CustomDebugStringConvertible {

        public private(set) lazy var color = Color(_color)
        
        public private(set) lazy var hsl: HSL = _color.hsl
        public private(set) lazy var rgb: RGB = _color.rgb

        public let population: Int

        public var debugDescription: String {
            """
            Color: \(String(describing: _color))
            Population: \(population)
            """
        }

        init(color: ColorDescriptor, population: Int) {
            self._color = color
            self.population = population
        }

        let _color: ColorDescriptor
    }
}
