//
//  UIImage+Palette.swift
//  Palette
//
//  Created by Egor Snitsar on 09.08.2019.
//  Copyright © 2019 Egor Snitsar. All rights reserved.
//

import Foundation

extension UIImage {

    public func createPalette() -> Palette {
        return Palette.from(image: self).generate()
    }

    public func createPalette(_ completion: @escaping (Palette) -> Void) {
        return Palette.from(image: self).generate(completion)
    }
}
