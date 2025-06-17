struct ColorDescriptor: Hashable, Comparable, CustomDebugStringConvertible {

    enum Width: Int {
        case normal = 8
        case quantized = 5
    }

    init(_ storage: Int, width: Width = .normal) {
        self.storage = storage
        self.width = width
    }

    init(_ components: [Int], width: Width = .normal) {
        self.storage = ColorConverter.packColor(components: components, width: width.rawValue)
        self.width = width
    }

    init(reducingAlpha components: [Int], width: Width = .normal) {
        let alpha = components[3]
        let cs = components[0...2].map {
            ColorConverter.reduceAlpha(for: $0, alpha: alpha)
        }
        self.init(cs, width: width)
    }

    init(_ components: [UInt8], width: Width = .normal) {
        self.init(components.map(Int.init), width: width)
    }

    init(reducingAlpha components: [UInt8], width: Width = .normal) {
        self.init(reducingAlpha: components.map(Int.init), width: width)
    }

    var red: Int {
        (storage >> (width.rawValue * 2)) & mask
    }

    var green: Int {
        (storage >> width.rawValue) & mask
    }

    var blue: Int {
        storage & mask
    }

    var hsl: HSL {
        ColorConverter.colorToHSL(self)
    }

    var rgb: RGB {
        (red, green, blue)
    }

    var quantized: ColorDescriptor {
        color(with: .quantized)
    }

    var normalized: ColorDescriptor {
        color(with: .normal)
    }

    let width: Width

    // MARK: - CustomDebugStringConvertible

    var debugDescription: String {
        """
        Red: \(red), Green: \(green), Blue: \(blue)
        Hue: \(hsl.h), Saturation: \(hsl.s), Brightness: \(hsl.l)
        """
    }

    // MARK: - Comparable

    static func < (lhs: ColorDescriptor, rhs: ColorDescriptor) -> Bool {
        return lhs.storage < rhs.storage
    }

    // MARK: - Private

    private let storage: Int

    private var mask: Int {
        (1 << width.rawValue) - 1
    }

    private func color(with width: Width) -> ColorDescriptor {
        let r = ColorConverter.modifyWordWidth(
            red,
            currentWidth: self.width.rawValue,
            targetWidth: width.rawValue
        )
        let g = ColorConverter.modifyWordWidth(
            green,
            currentWidth: self.width.rawValue,
            targetWidth: width.rawValue
        )
        let b = ColorConverter.modifyWordWidth(
            blue,
            currentWidth: self.width.rawValue,
            targetWidth: width.rawValue
        )

        return ColorDescriptor([r, g, b], width: width)
    }
}
