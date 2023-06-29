//
//  IntPoint.swift
//  iGeometry
//
//  Created by Nail Sharipov on 23/09/2019.
//  Copyright © 2019 iShape. All rights reserved.
//

public struct IntPoint {
    
    public static let zero = IntPoint(x: 0, y: 0)
    public static let empty = IntPoint(x: Int64.min, y: Int64.min)
    
    public let x: Int64
    public let y: Int64
    
#if DEBUG
    public let X: Float
    public let Y: Float
#endif
    
    @inlinable
    public var bitPack: Int64 {
        (x << IntGeom.maxBits) + y
    }
    
    @inlinable
    public init(x: Int64, y: Int64) {
        self.x = x
        self.y = y
#if DEBUG
        self.X = IntGeom.defGeom.float(int: x)
        self.Y = IntGeom.defGeom.float(int: y)
#endif
    }
    
}

extension IntPoint: Equatable {
    @inlinable
    public static func == (lhs: IntPoint, rhs: IntPoint) -> Bool {
        return lhs.x == rhs.x && lhs.y == rhs.y
    }
}

#if DEBUG
extension IntPoint: CustomStringConvertible {
    
    public var description: String {
        return "(\(X), \(Y))"
    }
    
}
#endif
