//
//  UIImage+Palette.swift
//  Palette
//
//  Created by Egor Snitsar on 09.08.2019.
//  Copyright © 2019 Egor Snitsar. All rights reserved.
//

import Foundation

#if os(iOS)

import UIKit

extension UIImage {

    public func createPalette() -> Palette? {
        return Palette.from(image: self)?.generate()
    }

    public func createPalette(_ completion: @escaping (Palette) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let palette = Palette.from(image: self) else {
                completion(nil)
                return
            }
            
            let generated = palette.generate()

            DispatchQueue.main.async {
                completion(generated)
            }
        }
    }
}

#else

import AppKit

extension NSImage {

    public func createPalette() -> Palette? {
        return Palette.from(image: self)?.generate()
    }

    public func createPalette(_ completion: @escaping (Palette?) -> Void) {
        DispatchQueue.global(qos: .userInitiated).async {
            guard let palette = Palette.from(image: self) else {
                completion(nil)
                return
            }
            
            let generated = palette.generate()

            DispatchQueue.main.async {
                completion(generated)
            }
        }
    }
}

#endif
