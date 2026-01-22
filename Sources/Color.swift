protocol ColorProtocol {
    typealias Components = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    var components: Components { get }
    func withAlphaComponent(_ alpha: CGFloat) -> Color
}

#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
public typealias Color = NSColor

extension Color: ColorProtocol {
    
    var components: Components {
        (redComponent, greenComponent, blueComponent, alphaComponent)
    }
}
#else
import UIKit
public typealias Color = UIColor

extension Color: ColorProtocol {

    var components: Components {
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        return (red, green, blue, alpha)
    }
}
#endif
