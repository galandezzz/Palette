//
//  Color.swift
//  Palette
//
//  Created by Egor Snitsar on 08.08.2019.
//  Copyright © 2019 Egor Snitsar. All rights reserved.
//

import UIKit

extension UIColor {

    internal convenience init(_ color: Color) {
        self.init(red: CGFloat(color.red) / 255.0,
                  green: CGFloat(color.green) / 255.0,
                  blue: CGFloat(color.blue) / 255.0,
                  alpha: 1.0)
    }
}

internal struct Color: Hashable, Comparable, CustomDebugStringConvertible {

    internal enum Width: Int {
        case normal = 8
        case quantized = 5
    }

    internal init(_ storage: Int, width: Width = .normal) {
        self.storage = storage
        self.width = width
    }

    internal init(_ components: [Int], width: Width = .normal) {
        self.storage = ColorConverter.packColor(components: components, width: width.rawValue)
        self.width = width
    }

    internal init(reducingAlpha components: [Int], width: Width = .normal) {
        let alpha = components[3]
        let cs = components[0...2].map { ColorConverter.reduceAlpha(for: $0, alpha: alpha) }
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
        return ColorConverter.colorToHSL(self)
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

    // MARK: - CustomDebugStringConvertible

    var debugDescription: String {
        return """

        Red: \(red), Green: \(green), Blue: \(blue)
        Hue: \(hsl.h), Saturation: \(hsl.s), Brightness: \(hsl.l)
        """
    }

    // MARK: - Comparable

    internal static func < (lhs: Color, rhs: Color) -> Bool {
        return lhs.storage < rhs.storage
    }

    // MARK: - Private

    private let storage: Int

    private var mask: Int {
        return (1 << width.rawValue) - 1
    }

    private func color(with width: Width) -> Color {
        let r = ColorConverter.modifyWordWidth(red, currentWidth: self.width.rawValue, targetWidth: width.rawValue)
        let g = ColorConverter.modifyWordWidth(green, currentWidth: self.width.rawValue, targetWidth: width.rawValue)
        let b = ColorConverter.modifyWordWidth(blue, currentWidth: self.width.rawValue, targetWidth: width.rawValue)

        return Color([r, g, b], width: width)
    }
}
