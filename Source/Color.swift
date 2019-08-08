//
//  Color.swift
//  Palette
//
//  Created by Egor Snitsar on 08.08.2019.
//  Copyright © 2019 Egor Snitsar. All rights reserved.
//

import UIKit

internal extension UIColor {

    convenience init(_ color: Color) {
        self.init(red: CGFloat(color.red) / 255,
                  green: CGFloat(color.green) / 255,
                  blue: CGFloat(color.blue) / 255,
                  alpha: 1.0)
    }
}

internal struct Color: Hashable, Comparable {

    internal enum Width: Int {
        case normal = 8
        case quantized = 5
    }

    var value: Int {
        return Int(storage)
    }

    internal init(_ storage: Int, width: Width = .normal) {
        self.storage = storage
        self.width = width
    }

    internal init(_ components: [Int], width: Width = .normal) {
        self.storage = ColorUtils.packColor(components: components, width: width.rawValue)
        self.width = width
    }

    internal init(reducingAlpha components: [Int], width: Width = .normal) {
        let alpha = components[3]
        let cs = components[0...2].map { ColorUtils.reduceAlpha(for: $0, alpha: alpha) }
        self.init(cs, width: width)
    }

    internal init(_ components: [UInt8], width: Width = .normal) {
        self.init(components.map { Int($0) }, width: width)
    }

    internal init(reducingAlpha components: [UInt8], width: Width = .normal) {
        self.init(reducingAlpha: components.map { Int($0) }, width: width)
    }

    internal var red: Int {
        return (storage >> (width.rawValue * 2)) & mask
    }

    internal var green: Int {
        return (storage >> width.rawValue) & mask
    }

    internal var blue: Int {
        return storage & mask
    }

    internal var hsl: HSL {
        return ColorUtils.colorToHSL(self)
    }

    internal var rgb: RGB {
        return (red, green, blue)
    }

    internal var quantized: Color {
        return color(with: .quantized)
    }

    internal var normalized: Color {
        return color(with: .normal)
    }

    internal let width: Width

    static func < (lhs: Color, rhs: Color) -> Bool {
        return lhs.storage < rhs.storage
    }

    private let storage: Int

    private var mask: Int {
        return (1 << width.rawValue) - 1
    }

    private func color(with width: Width) -> Color {
        let r = ColorUtils.modifyWordWidth(red, currentWidth: self.width.rawValue, targetWidth: width.rawValue)
        let g = ColorUtils.modifyWordWidth(green, currentWidth: self.width.rawValue, targetWidth: width.rawValue)
        let b = ColorUtils.modifyWordWidth(blue, currentWidth: self.width.rawValue, targetWidth: width.rawValue)

        return Color([r, g, b], width: width)
    }
}

private struct ColorUtils {

    static func colorToHSL(_ color: Color) -> HSL {
        let r = CGFloat(color.red) / 255
        let g = CGFloat(color.green) / 255
        let b = CGFloat(color.blue) / 255

        let cmin = min(r, g, b)
        let cmax = max(r, g, b)
        let delta = cmax - cmin

        var h, s: CGFloat
        let l = (cmax + cmin) / 2

        if cmax == cmin {
            h = 0
            s = 0
        } else {
            if cmax == r {
                h = ((g - b) / delta).truncatingRemainder(dividingBy: 6)
            } else if cmax == g {
                h = ((b - r) / delta) + 2
            } else {
                h = ((r - g) / delta) + 4
            }

            s = delta / (1 - abs(2 * l - 1))
        }

        h = (h * 60).truncatingRemainder(dividingBy: 360)
        if h < 360 {
            h += 360
        }

        return (
            h.rounded().limited(0, 360),
            s.limited(0, 1),
            l.limited(0, 1)
        )
    }

    internal static func reduceAlpha(for value: Int, alpha: Int) -> Int {
        guard alpha > 0 else {
            return value
        }

        return Int(CGFloat(value) / CGFloat(alpha) * 255)
    }

    internal static func packColor(components: [Int], width: Int) -> Int {
        let mask: Int = (1 << width) - 1

        let r = components[0]
        let g = components[1]
        let b = components[2]

        return ((r & mask) << (width * 2)) | ((g & mask) << width) | (b & mask)
    }

    internal static func packColor(components: [UInt8], width: Int) -> Int {
        return packColor(components: components.map { Int($0) }, width: width)
    }

    internal static func modifyWordWidth(_ value: Int, currentWidth: Int, targetWidth: Int) -> Int {
        guard currentWidth != targetWidth else {
            return value
        }

        let newValue: Int
        if targetWidth > currentWidth {
            newValue = value << (targetWidth - currentWidth)
        } else {
            newValue = value >> (currentWidth - targetWidth)
        }

        return newValue & ((1 << targetWidth) - 1)
    }
}

private extension Comparable {

    func limited(_ lowerBound: Self, _ upperBound: Self) -> Self {
        return min(max(lowerBound, self), upperBound)
    }
}
