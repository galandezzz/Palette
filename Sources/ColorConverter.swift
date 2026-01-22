import Foundation

typealias XYZ = (x: CGFloat, y: CGFloat, z: CGFloat)

struct ColorConverter {

    static func colorToHSL(_ color: Color) -> HSL {
        let components = color.components
        let r = components.red
        let g = components.green
        let b = components.blue

        let cmin = min(r, g, b)
        let cmax = max(r, g, b)
        let delta = cmax - cmin

        var h: CGFloat = 0.0
        var s: CGFloat = 0.0
        let l = (cmax + cmin) / 2.0

        if cmax != cmin {
            switch cmax {
            case r:
                h = ((g - b) / delta).truncatingRemainder(dividingBy: 6.0)
            case g:
                h = ((b - r) / delta) + 2.0
            default:
                h = ((r - g) / delta) + 4.0
            }

            s = delta / (1 - abs(2 * l - 1))
        }

        h = (h * 60.0).truncatingRemainder(dividingBy: 360.0)
        if h.isLess(than: .zero) {
            h += 360.0
        }

        return (
            h.rounded().limited(.zero, 360.0),
            s.limited(.zero, 1.0),
            l.limited(.zero, 1.0)
        )
    }

    static func colorToXYZ(_ color: Color) -> XYZ {
        let components = color.components
        let getComponent = { (component: CGFloat) -> CGFloat in
            component < 0.04045 ? component / 12.92 : pow((component + 0.055) / 1.055, 2.4)
        }
        let r = getComponent(components.red)
        let g = getComponent(components.green)
        let b = getComponent(components.blue)

        return (
            100.0 * (r * 0.4124 + g * 0.3576 + b * 0.1805),
            100.0 * (r * 0.2126 + g * 0.7152 + b * 0.0722),
            100.0 * (r * 0.0193 + g * 0.1192 + b * 0.9505)
        )
    }

    static func reduceAlpha(for value: Int, alpha: Int) -> Int {
        guard alpha > .zero else { return value }
        return Int(CGFloat(value) / CGFloat(alpha) * 255.0)
    }

    static func packColor(components: [Int], width: Int) -> Int {
        let mask: Int = (1 << width) - 1

        let r = components[0]
        let g = components[1]
        let b = components[2]

        return ((r & mask) << (width * 2)) | ((g & mask) << width) | (b & mask)
    }

    static func packColor(components: [UInt8], width: Int) -> Int {
        packColor(components: components.map { Int($0) }, width: width)
    }

    static func modifyWordWidth(_ value: Int, currentWidth: Int, targetWidth: Int) -> Int {
        guard currentWidth != targetWidth else { return value }

        let newValue: Int
        if targetWidth > currentWidth {
            newValue = value << (targetWidth - currentWidth)
        } else {
            newValue = value >> (currentWidth - targetWidth)
        }

        return newValue & ((1 << targetWidth) - 1)
    }
}
