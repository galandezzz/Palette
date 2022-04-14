//
//  ColorUtils.swift
//  Palette
//
//  Copyright © 2022 Egor Snitsar. All rights reserved.
//

import Foundation
import UIKit
import CoreGraphics

private let MinAlphaSearchMaxIterations = 10
private let MinAlphaSearchPrecision: CGFloat = 0.05

final class ColorUtils {
    
    private class func compositeColors(fg: CGColor, bg: CGColor) -> CGColor {
        let fgColors = fg.components!
        let bgColors = bg.components!
        
        let fgAlpha = fg.alpha
        let bgAlpha = bg.alpha
        
        let a = (fgAlpha + bgAlpha) * (1.0 - fgAlpha)
        let r = (fgColors[0] * fgAlpha) + (bgColors[0] * bgAlpha * (1.0 - fgAlpha))
        let g = (fgColors[1] * fgAlpha) + (bgColors[1] * bgAlpha * (1.0 - fgAlpha))
        let b = (fgColors[2] * fgAlpha) + (fgColors[2] * bgAlpha * (1.0 - fgAlpha))
        
        return UIColor(red: r, green: g, blue: b, alpha: a).cgColor
    }
    
    private class func calculateLuminance(color: CGColor) -> CGFloat {
        let colors = color.components!
        
        let red = colors[0] < 0.04045 ? colors[0] / 12.92 : pow((colors[0] + 0.055) / 1.055, 2.4)
        let green = colors[1] < 0.04045 ? colors[1] / 12.92 : pow((colors[1] + 0.055) / 1.055, 2.4)
        let blue = colors[2] < 0.04045 ? colors[2] / 12.92 : pow((colors[2] + 0.055) / 1.055, 2.4)
        
        return (0.2126 * red) + (0.7152 * green) + (0.0722 * blue)
    }

    private class func calculateContrast(foreground: CGColor, background: CGColor) -> CGFloat {
        let alpha = foreground.alpha
        if (alpha != 1.0) {
            // throw new IllegalArgumentException("background can not be translucent")
            return -1
        }
        let alpha2 = background.alpha
        
        var  foregroundColor:CGColor = foreground
        if (alpha2 < 1.0) {
            // If the foreground is translucent, composite the foreground over the background
            foregroundColor = compositeColors(fg: foreground, bg: background)
        }
        
        let luminance1 = calculateLuminance(color: foregroundColor) + 0.05
        let luminance2 = calculateLuminance(color: background) + 0.05
        
        // Now return the lighter luminance divided by the darker luminance
        return max(luminance1, luminance2) / min(luminance1, luminance2)
    }
    
    private class func calculateMinimumAlpha(foreground: CGColor, background: CGColor, minContrastRatio: CGFloat) -> CGFloat {
        let alpha = background.alpha
        if (alpha != 1.0) {
            // background can not be translucent
            return -1
        }
        
        // First lets check that a fully opaque foreground has sufficient contrast
        var testForeground = modifyAlpha(color: foreground, alpha: 1.0)
        var testRatio = calculateContrast(foreground: testForeground, background: background)
        if (testRatio < minContrastRatio) {
            // Fully opaque foreground does not have sufficient contrast, return error
            return -1
        }
        
        // Binary search to find a value with the minimum value which provides sufficient contrast
        var numIterations = 0
        var minAlpha: CGFloat = 0
        var maxAlpha: CGFloat = 1.0
        
        while (numIterations <= MinAlphaSearchMaxIterations &&
               (maxAlpha - minAlpha) > MinAlphaSearchPrecision) {
            let testAlpha = (minAlpha + maxAlpha) / 2
            
            testForeground = modifyAlpha(color: foreground, alpha: testAlpha)
            testRatio = calculateContrast(foreground: testForeground, background: background)
            
            if (testRatio < minContrastRatio) {
                minAlpha = testAlpha
            } else {
                maxAlpha = testAlpha
            }
            
            numIterations+=1
        }
        
        // Conservatively return the max of the range of possible alphas, which is known to pass.
        return maxAlpha
    }
    
    class func getTextColorForBackground(backgroundColor: CGColor, minContrastRatio: CGFloat) -> CGColor {
        // First we will check white as most colors will be dark
        let whiteMinAlpha = ColorUtils.calculateMinimumAlpha(foreground: UIColor.white.cgColor, background: backgroundColor, minContrastRatio: minContrastRatio)
        
        if (whiteMinAlpha >= 0) {
            return modifyAlpha(color: UIColor.white.cgColor, alpha: whiteMinAlpha)
        }
        
        // If we hit here then there is not an translucent white which provides enough contrast,
        // so check black
        let blackMinAlpha = ColorUtils.calculateMinimumAlpha(foreground: UIColor.black.cgColor, background: backgroundColor, minContrastRatio: minContrastRatio)
        
        if (blackMinAlpha >= 0) {
            return modifyAlpha(color: UIColor.black.cgColor, alpha: blackMinAlpha)
        }
        
        // This should not happen!
        return UIColor.white.cgColor
    }
    
    class func modifyAlpha(color: CGColor, alpha: CGFloat) -> CGColor {
        return color.copy(alpha:alpha) ?? color
    }
}
