//
//  ColorUtils.swift
//  Palette
//
//  Created by Egor Snitsar on 10.08.2019.
//  Copyright © 2019 Egor Snitsar. All rights reserved.
//

import Foundation

internal struct ColorConverter {

    internal static func colorToHSL(_ color: Color) -> HSL {
        let r = CGFloat(color.red) / 255.0
        let g = CGFloat(color.green) / 255.0
        let b = CGFloat(color.blue) / 255.0

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

    internal static func reduceAlpha(for value: Int, alpha: Int) -> Int {
        guard alpha > .zero else {
            return value
        }

        return Int(CGFloat(value) / CGFloat(alpha) * 255.0)
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
