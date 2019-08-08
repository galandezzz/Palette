//
//  PriorityQueue.swift
//  Palette
//
//  Created by Egor Snitsar on 07.08.2019.
//  Copyright © 2019 Egor Snitsar. All rights reserved.
//

import Foundation

internal struct PriorityQueue<T> {

    private var heap: Heap<T>

    internal var elements: [T] {
        return heap.nodes
    }

    /*
     To create a max-priority queue, supply a > sort function. For a min-priority
     queue, use <.
     */
    internal init(sort: @escaping (T, T) -> Bool) {
        heap = Heap(sort: sort)
    }

    internal var isEmpty: Bool {
        return heap.isEmpty
    }

    internal var count: Int {
        return heap.count
    }

    internal func peek() -> T? {
        return heap.peek()
    }

    internal mutating func enqueue(_ element: T) {
        heap.insert(element)
    }

    internal mutating func dequeue() -> T? {
        return heap.remove()
    }

    /*
     Allows you to change the priority of an element. In a max-priority queue,
     the new priority should be larger than the old one; in a min-priority queue
     it should be smaller.
     */
    internal mutating func changePriority(index i: Int, value: T) {
        return heap.replace(index: i, value: value)
    }
}

extension PriorityQueue where T: Equatable {

    internal func index(of element: T) -> Int? {
        return heap.index(of: element)
    }
}
