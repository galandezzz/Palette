#if canImport(AppKit) && !targetEnvironment(macCatalyst)
import AppKit
public typealias Color = NSColor
#else
import UIKit
public typealias Color = UIColor
#endif
