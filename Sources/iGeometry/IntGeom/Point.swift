//
//  Point.swift
//  iGeometry
//
//  Created by Nail Sharipov on 23/09/2019.
//  Copyright © 2019 iShape. All rights reserved.
//

public struct Point: Equatable {
    
    public static let zero = Point(x: 0, y: 0)
    
    public let x: Float
    public let y: Float
    
    public init(x: Float, y: Float) {
        self.x = x
        self.y = y
    }
    
    
    public func sqrDistance(point: Point) -> Float {
        let dx = point.x - self.x
        let dy = point.y - self.y

        return dx * dx + dy * dy
    }
    
    
    public var normal: Point {
        let l = (x * x + y * y).squareRoot()
        let k = 1 / l
        let x = k * x
        let y = k * y
        
        return Point(x: x, y: y)
    }
    
    
    public func dotProduct(_ vector: Point) -> Float { // cos
        self.x * vector.x + vector.y * self.y
    }
    
    
    public func crossProduct(_ vector: Point) -> Float {
        self.x * vector.y - self.y * vector.x
    }

    
    static func +(left: Point, right: Point) -> Point {
        Point(x: left.x + right.x, y: left.y + right.y)
    }

    
    static func -(left: Point, right: Point) -> Point {
        Point(x: left.x - right.x, y: left.y - right.y)
    }
    
    
    public static func == (lhs: Point, rhs: Point) -> Bool {
        lhs.x == rhs.x && lhs.y == rhs.y
    }
    
}
