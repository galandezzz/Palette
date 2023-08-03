//
//  PaletteSwatch.swift
//  Palette
//
//  Created by Egor Snitsar on 06.08.2019.
//  Copyright © 2019 Egor Snitsar. All rights reserved.
//

#if os(iOS)
import UIKit
#else
import AppKit
#endif

public typealias RGB = (r: Int, g: Int, b: Int)
public typealias HSL = (h: CGFloat, s: CGFloat, l: CGFloat)

extension Palette {

    public final class Swatch: CustomDebugStringConvertible {

        #if os(iOS)
        public private(set) lazy var color = UIColor(_color)
        #else
        public private(set) lazy var color = NSColor(_color)
        #endif

        public private(set) lazy var hsl: HSL = _color.hsl
        public private(set) lazy var rgb: RGB = _color.rgb

        public let population: Int

        public var debugDescription: String {
            return """

            Color: \(String(describing: _color))
            Population: \(population)
            """
        }

        internal init(color: Color, population: Int) {
            self._color = color
            self.population = population
        }

        internal let _color: Color
    }
}
