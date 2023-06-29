//
//  RingSet.swift
//  
//
//  Created by Nail Sharipov on 19.09.2022.
//

public struct RingSet {
    
    @usableFromInline
    struct Node {
        
        @usableFromInline
        static let empty = Node(prev: .empty, next: .empty)
        
        @usableFromInline
        var prev: Int
        
        @usableFromInline
        var next: Int
        
        @inlinable
        init(prev: Int, next: Int) {
            self.prev = prev
            self.next = next
        }
    }

    @usableFromInline
    var buffer: [Node]
    
    @usableFromInline
    var firstIndex: Int
    
    @usableFromInline
    var count: Int
    
    @inlinable
    public var isEmpty: Bool { count == 0 }
    
    @inlinable
    public var first: Int {
        firstIndex
    }

    @inlinable
    public var sequence: [Int] {
        var result = [Int]()
        result.reserveCapacity(count)
        var index = firstIndex
        var i = 0
        while i < count {
            result.append(index)
            index = buffer[index].next
            i += 1
        }
        return result
    }

    @inlinable
    public init(size: Int) {
        buffer = [Node](repeating: .empty, count: size)
        count = size
        guard count > 0 else {
            firstIndex = .empty
            return
        }
        
        firstIndex = 0

        for i in 0..<count {
            let prev = (i + count - 1) % count
            let next = (i + 1) % count
            buffer[i] = Node(prev: prev, next: next)
        }
    }
    
    @inlinable
    public func next(_ element: Int) -> Int {
        assert(element < buffer.count)
        let node = buffer[element]
        return node.next
    }
    
    @inlinable
    public func prev(_ element: Int) -> Int {
        assert(element < buffer.count)
        let node = buffer[element]
        return node.prev
    }
    
    @inlinable
    public func contains(_ element: Int) -> Bool {
        assert(element < buffer.count)
        let node = buffer[element]
        let isExist = node.prev != .empty
        return isExist
    }

    @inlinable
    public mutating func remove(_ element: Int) {
        assert(element < buffer.count)
        let node = buffer[element]
        guard self.contains(element) else { return }
        count -= 1
        
        buffer[element] = .empty

        if count > 0 {
            buffer[node.prev].next = node.next
            buffer[node.next].prev = node.prev
        }
        
        if firstIndex == element {
            firstIndex = node.next
        }
    }

    @inlinable
    public func forEach(_ body: (Int) -> ()) {
        var index = firstIndex
        var i = 0
        while i < count {
            body(index)
            index = buffer[index].next
            i += 1
        }
    }

    @inlinable
    public mutating func removeAll() {
        var index = firstIndex
        var i = 0
        while i < count {
            let nextIndex = buffer[index].next
            buffer[index] = .empty
            index = nextIndex
            i += 1
        }
        count = 0
        firstIndex = .empty
    }

}
