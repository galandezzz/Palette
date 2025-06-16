import Foundation

struct PriorityQueue<T> {

    private var heap: Heap<T>

    var elements: [T] {
        heap.elements
    }

    /// To create a max-priority queue, supply a > sort function.
    /// For a min-priority queue, use <.
    init(sort: @escaping (T, T) -> Bool) {
        heap = Heap(sort: sort)
    }

    var isEmpty: Bool {
        heap.isEmpty
    }

    var count: Int {
        heap.count
    }

    func peek() -> T? {
        heap.peek()
    }

    mutating func enqueue(_ element: T) {
        heap.insert(element)
    }

    mutating func dequeue() -> T? {
        heap.remove()
    }

    /// Allows you to change the priority of an element. In a max-priority queue,
    /// the new priority should be larger than the old one; in a min-priority queue
    /// it should be smaller.
    mutating func changePriority(index i: Int, value: T) {
        heap.replace(index: i, value: value)
    }
}

extension PriorityQueue where T: Equatable {

    func index(of element: T) -> Int? {
        heap.index(of: element)
    }
}
