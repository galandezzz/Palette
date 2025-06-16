import Foundation

struct CountedSet<T: Hashable> {

    private let storage: NSCountedSet

    init(_ array: [T] = []) {
        self.storage = NSCountedSet(array: array)
    }

    var elements: [T] {
        storage.allObjects as! [T]
    }

    var countedElements: [T: Int] {
        let values = elements.map { ($0, count(for: $0)) }
        return Dictionary(uniqueKeysWithValues: values)
    }

    func contains(_ object: T) -> Bool {
        storage.contains(object)
    }

    func insert(_ object: T) {
        storage.add(object)
    }

    func remove(_ object: T) {
        storage.remove(object)
    }

    func count(for object: T) -> Int {
        storage.count(for: object)
    }
}
