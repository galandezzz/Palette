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
private let MinAlphaSearchMaxIterations = 10
private let MinAlphaSearchPrecision: CGFloat = 0.05

extension Palette {
    public final class Swatch: CustomDebugStringConvertible {

        public private(set) lazy var color = UIColor(_color)

        public private(set) lazy var hsl: HSL = _color.hsl
        public private(set) lazy var rgb: RGB = _color.rgb

        public let population: Int
        public var calculateColors: Bool = false
        
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
        
        private var titleTextColor: UIColor!
        private var bodyTextColor: UIColor!
        
        
        public func getTitleTextColor() -> UIColor{
            ensureTextColorsGenerated()
            return titleTextColor
        }
        
        public func getBodyTextColor() -> UIColor{
            ensureTextColorsGenerated()
            return bodyTextColor
        }
        
        private func ensureTextColorsGenerated() -> () {
            if (!calculateColors) {
                
                var bodyColor:UIColor
                var titleColor:UIColor
                
                // First check white, as most colors will be dark
                let lightBodyAlpha = ColorUtils.calculateMinimumAlpha(foreground: UIColor.white, background: color, minContrastRatio: MinContrastBodyText)
                let lightTitleAlpha = ColorUtils.calculateMinimumAlpha(foreground: UIColor.white, background: color, minContrastRatio: MinContrastTitleText)
                
                
                if (lightBodyAlpha != -1 && lightTitleAlpha != -1) {
                    // If we found valid light values, use them and return
                    bodyColor = ColorUtils.modifyAlpha(color: UIColor.white, alpha: lightBodyAlpha)
                    titleColor = ColorUtils.modifyAlpha(color: UIColor.white, alpha: lightTitleAlpha)
                    bodyTextColor = bodyColor
                    titleTextColor = titleColor
                    calculateColors = true
                    return
                }
                
                let darkBodyAlpha = ColorUtils.calculateMinimumAlpha(foreground: UIColor.black, background: color, minContrastRatio: MinContrastBodyText)
                let darkTitleAlpha = ColorUtils.calculateMinimumAlpha(foreground: UIColor.black, background: color, minContrastRatio: MinContrastTitleText)
                
                if (darkBodyAlpha != -1 && darkTitleAlpha != -1) {
                    // If we found valid dark values, use them and return
                    bodyColor = ColorUtils.modifyAlpha(color: UIColor.black, alpha: darkBodyAlpha)
                    titleColor  = ColorUtils.modifyAlpha(color: UIColor.black, alpha: darkTitleAlpha)
                    bodyTextColor = bodyColor
                    titleTextColor = titleColor
                    calculateColors = true
                    return
                }
                
                // If we reach here then we can not find title and body values which use the same
                // lightness, we need to use mismatched values
                if(lightBodyAlpha != -1){
                    bodyColor = ColorUtils.modifyAlpha(color: UIColor.white, alpha: lightBodyAlpha)
                }
                else {
                    bodyColor = ColorUtils.modifyAlpha(color: UIColor.black, alpha: lightBodyAlpha)
                }
                
                
                if(lightTitleAlpha != -1){
                    titleColor = ColorUtils.modifyAlpha(color: UIColor.white, alpha: lightTitleAlpha)
                }
                else {
                    titleColor = ColorUtils.modifyAlpha(color: UIColor.black, alpha: lightTitleAlpha)
                }
                
                bodyTextColor = bodyColor
                titleTextColor = titleColor
                calculateColors = true
            }
        }
        
    }
}
