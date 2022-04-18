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
private let MinAlphaSearchPrecision: CGFloat = 1.0/255

extension UIColor {
    var coreImageColor: CIColor {
        return CIColor(color: self)
    }
    var hex: UInt {
        let alpha = UInt(coreImageColor.alpha * 255 + 0.5)
        let red = UInt(coreImageColor.red * 255 + 0.5)
        let green = UInt(coreImageColor.green * 255 + 0.5)
        let blue = UInt(coreImageColor.blue * 255 + 0.5)
        return (alpha << 24) | (red << 16) | (green << 8) | blue
    }
}

final class ColorUtils {
    
    private class func compositeColors(forgroundColor: UIColor, backgroundColor: UIColor) -> UIColor {
        
        let fgColor = forgroundColor.coreImageColor
        let bgColor = backgroundColor.coreImageColor
        
        let fgAlpha = fgColor.alpha
        let bgAlpha = bgColor.alpha
        
        let compositeAlpha = compositeAlpha(foregroundAlpha: fgAlpha, backgroundAlpha: bgAlpha)
        
        let r = compositeComponent(fgChannel: fgColor.red, fgAlpha: fgAlpha, bgChannel: bgColor.red, bgAlpha: bgAlpha, compositeAlpha: compositeAlpha)
        let g = compositeComponent(fgChannel: fgColor.green, fgAlpha: fgAlpha, bgChannel: bgColor.green, bgAlpha: bgAlpha, compositeAlpha: compositeAlpha)
        let b = compositeComponent(fgChannel: fgColor.blue, fgAlpha: fgAlpha, bgChannel: bgColor.blue, bgAlpha: bgAlpha, compositeAlpha: compositeAlpha)
        
        return UIColor(red: r, green: g, blue: b, alpha: compositeAlpha)
    }
    
    private class func compositeAlpha(foregroundAlpha:CGFloat, backgroundAlpha:CGFloat) -> CGFloat {
        // 0xFF - (((0xFF - bgAlpha) * (0xFF - fgAlpha)) / 0xFF)
        return 1.0 - ((1.0 - backgroundAlpha) * (1.0 - foregroundAlpha))
    }
    
    
    private class func compositeComponent(fgChannel:CGFloat, fgAlpha:CGFloat, bgChannel:CGFloat, bgAlpha:CGFloat, compositeAlpha:CGFloat) -> CGFloat {
        if (compositeAlpha == 0) {
            return 0.0
        }
        // ((0xFF * fgC * fgA) + (bgC * bgA * (0xFF - fgA))) / (a * 0xFF)
        return ((fgChannel * fgAlpha) + (bgChannel * bgAlpha * (1.0 - fgAlpha)))/compositeAlpha
    }
    
    private class func calculateLuminance(color: UIColor) -> CGFloat {
        
        let r = color.coreImageColor.red
        let g = color.coreImageColor.green
        let b = color.coreImageColor.blue
        
        let sr = r < 0.04045 ? r / 12.92 : pow((r + 0.055) / 1.055, 2.4)
        let sg = g < 0.04045 ? g / 12.92 : pow((g + 0.055) / 1.055, 2.4)
        let sb = b < 0.04045 ? b / 12.92 : pow((b + 0.055) / 1.055, 2.4)
        
        //outXyz[0] = 100 * (sr * 0.4124 + sg * 0.3576 + sb * 0.1805)
        //outXyz[1] = 100 * (sr * 0.2126 + sg * 0.7152 + sb * 0.0722)
        //outXyz[2] = 100 * (sr * 0.0193 + sg * 0.1192 + sb * 0.9505)
        return sr * 0.2126 + sg * 0.7152 + sb * 0.0722
    }
    
    private class func calculateContrast(foreground: UIColor, background: UIColor) -> CGFloat {
        // background can not be translucent
        if (background.coreImageColor.alpha != 1.0){
            return -1
        }
        
        let newForegroundColor:UIColor
        if(foreground.coreImageColor.alpha < 1.0) {
            // If the foreground is translucent, composite the foreground over the background
            newForegroundColor = compositeColors(forgroundColor : foreground, backgroundColor  : background)
        }
        else {
            newForegroundColor = foreground
        }
        
        let luminance1 = calculateLuminance(color: newForegroundColor) + 0.05
        let luminance2 = calculateLuminance(color: background) + 0.05
        
        // Now return the lighter luminance divided by the darker luminance
        return max(luminance1, luminance2) / min(luminance1, luminance2)
    }
    
    class func calculateMinimumAlpha(foreground: UIColor, background: UIColor, minContrastRatio: CGFloat) -> CGFloat {
        let alpha = background.coreImageColor.alpha
        
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
            
            let testAlpha = (minAlpha + maxAlpha) / 2.0
            
            testForeground = modifyAlpha(color: foreground, alpha: testAlpha)
            testRatio = calculateContrast(foreground: testForeground, background: background)
            
            if (testRatio < minContrastRatio) {
                minAlpha = testAlpha
            }
            else {
                maxAlpha = testAlpha
            }
            
            numIterations += 1
        }
        
        // Conservatively return the max of the range of possible alphas, which is known to pass.
        return maxAlpha
    }
    
    class func modifyAlpha(color: UIColor, alpha: CGFloat) -> UIColor {
        return color.withAlphaComponent(alpha)
    }
}
