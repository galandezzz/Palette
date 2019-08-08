//
//  CountedSet.swift
//  Palette
//
//  Created by Egor Snitsar on 08.08.2019.
//  Copyright © 2019 Egor Snitsar. All rights reserved.
//

import Foundation

internal struct CountedSet<T: Hashable> {

    internal init(_ array: [T] = []) {
        self.storage = NSCountedSet(array: array)
    }

    internal var allObjects: [T] {
        return storage.allObjects as! [T]
    }

    internal var countedObjects: [T: Int] {
        let values = allObjects.map { ($0, count(for: $0)) }

        return Dictionary(uniqueKeysWithValues: values)
    }

    internal func contains(_ object: T) -> Bool {
        return storage.contains(object)
    }

    internal func insert(_ object: T) {
        storage.add(object)
    }

    internal func remove(_ object: T) {
        storage.remove(object)
    }

    internal func removeFromSet(_ object: T) {
        for _ in 0..<count(for: object) {
            remove(object)
        }
    }

    internal func count(for object: T) -> Int {
        return storage.count(for: object)
    }

    private let storage: NSCountedSet
}
