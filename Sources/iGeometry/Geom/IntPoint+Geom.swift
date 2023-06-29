//
//  IntPoint+Math.swift
//  iGeometry
//
//  Created by Nail Sharipov on 04/10/2019.
//  Copyright © 2019 iShape. All rights reserved.
//

public extension IntPoint {
    
    @inlinable
    static func +(left: IntPoint, right: IntPoint) -> IntPoint {
        IntPoint(x: left.x + right.x, y: left.y + right.y)
    }

    @inlinable
    static func -(left: IntPoint, right: IntPoint) -> IntPoint {
        IntPoint(x: left.x - right.x, y: left.y - right.y)
    }
    
    @inlinable
    func scalarMultiply(point: IntPoint) -> Int64 { // dot product (cos)
        self.x * point.x + point.y * self.y
    }
    
    @inlinable
    func crossProduct(point: IntPoint) -> Int64 { // cross product
        self.x * point.y - self.y * point.x
    }
    
    @inlinable
    func normal(iGeom: IntGeom) -> IntPoint {
        let p = iGeom.float(point: self)
        let l = (p.x * p.x + p.y * p.y).squareRoot()
        let k = 1 / l
        let x = k * p.x
        let y = k * p.y
        
        return iGeom.int(point: Point(x: x, y: y))
    }
    
    @inlinable
    func sqrDistance(point: IntPoint) -> Int64 {
        let dx = point.x - self.x
        let dy = point.y - self.y

        return dx * dx + dy * dy
    }
    
    @inlinable
    static func isSameLine(a: IntPoint, b: IntPoint, c: IntPoint) -> Bool {
        let dxBA = b.x - a.x
        let dxCA = c.x - a.x
        
        if dxBA == 0 && dxCA == 0 {
            return true
        }

        let dyBA = b.y - a.y
        let dyCA = c.y - a.y
        
        if dyBA == 0 && dyCA == 0 {
            return true
        }
        
        let kBA = Double(dxBA) / Double(dyBA)
        let kCA = Double(dxCA) / Double(dyCA)
        
        let dif = abs(kBA - kCA)
        
        return dif < 0.000_000_000_000_000_0001
    }
}
