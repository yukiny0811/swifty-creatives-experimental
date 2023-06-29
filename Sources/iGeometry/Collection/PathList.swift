//
//  PathList.swift
//  
//
//  Created by Nail Sharipov on 19.09.2022.
//

public struct PathList<T> {
    
    private struct Node<T> {
        var prev: Int
        var next: Int
        var value: T
    }
    
    public struct Item<T> {
        public let index: Int
        public let value: T
        
        @inlinable
        init(index: Int, value: T) {
            self.index = index
            self.value = value
        }
    }
    
    @usableFromInline
    let empty: T
    
    @usableFromInline
    var set: RingSet
    
    @usableFromInline
    var buffer: [T]

    @inlinable
    public var count: Int { self.set.count }
    
    @inlinable
    public var first: Item<T> {
        let index = set.first
        return Item(index: index, value: buffer[index])
    }

    @inlinable
    public var sequence: [T] {
        var result = [T]()
        result.reserveCapacity(count)
        set.forEach { index in
            result.append(buffer[index])
        }
        return result
    }

    @inlinable
    public var indices: [Int] { self.set.sequence }

    @inlinable
    public subscript(index: Int) -> T {
        get {
            return buffer[index]
        }
    }
    
    @inlinable
    public init(size: Int, empty: T) {
        self.empty = empty
        self.set = RingSet(size: size)
        buffer = .init(repeating: empty, count: size)
    }

    @inlinable
    public init(array: [T], empty: T) {
        let size = array.count
        self.empty = empty
        self.set = RingSet(size: size)
        buffer = array
    }
    
    @inlinable
    public func next(_ index: Int) -> Item<T> {
        assert(index < buffer.count)
        let nextIndex = set.next(index)
        if nextIndex != .empty {
            return Item(index: nextIndex, value: buffer[nextIndex])
        } else {
            return Item(index: .empty, value: empty)
        }
    }
    
    @inlinable
    public func prev(_ index: Int) -> Item<T> {
        assert(index < buffer.count)
        let prevIndex = set.prev(index)
        if prevIndex != .empty {
            return Item(index: prevIndex, value: buffer[prevIndex])
        } else {
            return Item(index: .empty, value: empty)
        }
    }
    
    @inlinable
    public func contains(_ index: Int) -> Bool { set.contains(index) }

    @inlinable
    public func contains(where predicate: (T) -> Bool) -> Bool {
        for index in set.sequence {
            if predicate(buffer[index]) {
                return true
            }
        }
        return false
    }
    
    @inlinable
    public func contains(where predicate: (Int, T) -> (Bool)) -> Bool {
        for index in set.sequence {
            if predicate(index, buffer[index]) {
                return true
            }
        }

        return false
    }

    @inlinable
    public mutating func remove(_ index: Int) {
        assert(index < buffer.count)
        guard set.contains(index) else { return }
        
        buffer[index] = empty
     
        set.remove(index)
    }
    
    @inlinable
    public mutating func removeAll() {
        set.removeAll()
        for i in 0..<buffer.count {
            buffer[i] = empty
        }
    }
    
    @inlinable
    public func firstIndex(where predicate: (T) -> (Bool)) -> Int {
        for index in set.sequence {
            if predicate(buffer[index]) {
                return index
            }
        }

        return .empty
    }
    
    @inlinable
    public func firstIndex(where predicate: (Int, T) -> (Bool)) -> Int {
        for index in set.sequence {
            if predicate(index, buffer[index]) {
                return index
            }
        }

        return .empty
    }
    
    @inlinable
    public func first(where predicate: (T) -> (Bool)) -> T? {
        for index in set.sequence {
            let value = buffer[index]
            if predicate(value) {
                return value
            }
        }

        return nil
    }
    
    @inlinable
    public func forEachIndex(_ body: (Int) -> ()) {
        self.set.forEach(body)
    }

}
