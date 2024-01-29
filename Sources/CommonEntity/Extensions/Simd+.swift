//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/07/20.
//

public extension f4x4 {
    static var memorySize: Int {
        return MemoryLayout<Self>.stride
    }
}

public extension f2 {
    static func randomPoint(_ range: ClosedRange<Float>) -> Self {
        return Self(Float.random(in: range), Float.random(in: range))
    }
    static var memorySize: Int {
        return MemoryLayout<Self>.stride
    }
}


public extension f3 {
    static func randomPoint(_ range: ClosedRange<Float>) -> Self {
        return Self(Float.random(in: range), Float.random(in: range), Float.random(in: range))
    }
    static var memorySize: Int {
        return MemoryLayout<Self>.stride
    }
}

public extension f4 {
    static func randomPoint(_ range: ClosedRange<Float>) -> Self {
        return Self(Float.random(in: range), Float.random(in: range), Float.random(in: range), Float.random(in: range))
    }
    static var memorySize: Int {
        return MemoryLayout<Self>.stride
    }
}

public extension f4x4 {
    static func createTransform(_ x: Float, _ y: Float, _ z: Float) -> f4x4 {
        return Self.init(
            f4(1, 0, 0, 0),
            f4(0, 1, 0, 0),
            f4(0, 0, 1, 0),
            f4(x, y, z, 1)
        )
    }
    static func createRotation(angle: Float, axis: f3) -> f4x4 {
        return Self.init(
            simd_quatf(angle: angle, axis: axis)
        )
    }
    static func createScale(_ x: Float, _ y: Float, _ z: Float) -> f4x4 {
        return Self.init(
            f4(x, 0, 0, 0),
            f4(0, y, 0, 0),
            f4(0, 0, z, 0),
            f4(0, 0, 0, 1)
        )
    }
    static func createPerspective(fov: Float, aspect: Float, near: Float, far: Float) -> f4x4 {
        let f: Float = 1.0 / (tan(fov / 2.0))
        return Self.init(
            f4(f / aspect, 0, 0, 0),
            f4(0, f, 0, 0),
            f4(0, 0, (near+far)/(near-far), -1),
            f4(0, 0, (2 * near * far) / (near - far), 0)
        )
    }
    static func createOrthographic(_ l: Float, _ r: Float, _ b: Float, _ t: Float, _ n: Float, _ f: Float) -> f4x4 {
        return Self.init(
            f4(2/(r-l), 0, 0, 0),
            f4(0, 2 / (t-b), 0, 0),
            f4(0, 0, -2 / (f-n), 0),
            f4(-1 * (r+l) / (r-l), -1 * (t+b) / (t-b), -1 * (f+n)/(f-n), 1)
        )
    }
    static func createIdentity() -> f4x4 {
        return Self.init(
            f4(1, 0, 0, 0),
            f4(0, 1, 0, 0),
            f4(0, 0, 1, 0),
            f4(0, 0, 0, 1)
        )
    }
    
    static func mock_createRotationX(angle: Float) -> f4x4 {
        let cosX = cos(angle)
        let sinX = sin(angle)
        return Self.init(
            f4(1.0, 0.0, 0.0, 0.0),
            f4(0.0, cosX, -sinX, 0.0),
            f4(0.0, sinX, cosX, 0.0),
            f4(0.0, 0.0, 0.0, 1.0)
        )
    }
    
    static func mock_createRotationY(angle: Float) -> f4x4 {
        let cosY = cos(angle)
        let sinY = sin(angle)
        return Self.init(
            f4(cosY, 0.0, sinY, 0.0),
            f4(0.0, 1.0, 0.0, 0.0),
            f4(-sinY, 0.0, cosY, 0.0),
            f4(0.0, 0.0, 0.0, 1.0)
        )
    }
    
    static func mock_createRotationZ(angle: Float) -> f4x4 {
        let cosZ = cos(angle)
        let sinZ = sin(angle)
        return Self.init(
            f4(cosZ, -sinZ, 0.0, 0.0),
            f4(sinZ, cosZ, 0.0, 0.0),
            f4(0.0, 0.0, 1.0, 0.0),
            f4(0.0, 0.0, 0.0, 1.0)
        )
    }
}
