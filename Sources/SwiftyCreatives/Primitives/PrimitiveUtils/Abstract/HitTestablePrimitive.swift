//
//  HitTestablePrimitive.swift
//  
//
//  Created by Yuki Kuwashima on 2023/01/31.
//

import simd
import CommonEntity

open class HitTestablePrimitive<Info: PrimitiveInfo>: Primitive<Info> {
    override init() { super.init() }
    public var cachedCustomMatrix: f4x4 = f4x4.createIdentity()
    
    public func drawWithCache(encoder: SCEncoder, customMatrix: f4x4) {
        draw(encoder)
        cachedCustomMatrix = customMatrix
    }
    public func drawWithCache(packet: SCPacket) {
        draw(packet.privateEncoder!)
        cachedCustomMatrix = packet.customMatrix.reduce(f4x4.createIdentity(), *)
    }
}
