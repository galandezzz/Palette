//
//  PaletteSwatch.swift
//  Palette
//
//  Created by Egor Snitsar on 06.08.2019.
//  Copyright © 2019 Egor Snitsar. All rights reserved.
//

import UIKit

public typealias RGB = (r: Int, g: Int, b: Int)
public typealias HSL = (h: CGFloat, s: CGFloat, l: CGFloat)

private let MinContrastTitleText: CGFloat = 3.0
private let MinContrastBodyText: CGFloat = 4.5

extension Palette {
    public final class Swatch: CustomDebugStringConvertible {

        public private(set) lazy var color = UIColor(_color)

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
        
        public lazy var titleTextColor: UIColor = {
            var c = ColorUtils.getTextColorForBackground(backgroundColor: color.cgColor, minContrastRatio: MinContrastTitleText)
            return UIColor(cgColor: c)
        }()
        
        public lazy var bodyTextColor: UIColor = {
            var c = ColorUtils.getTextColorForBackground(backgroundColor: color.cgColor, minContrastRatio: MinContrastBodyText)
            return UIColor(cgColor: c)
        }()
        
    }
}
