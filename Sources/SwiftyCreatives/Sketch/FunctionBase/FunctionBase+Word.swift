//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/06/29.
//

import CommonEntity
import Metal

public extension FunctionBase {
    func polytext(_ vectorWord: VectorWord, primitiveType: MTLPrimitiveType = .triangle) {
        privateEncoder?.setVertexBuffer(vectorWord.posBuffer!, offset: 0, index: VertexBufferIndex.Position.rawValue)
        privateEncoder?.setVertexBytes([f3.one], length: f3.memorySize, index: VertexBufferIndex.ModelScale.rawValue)
        privateEncoder?.setFragmentBytes([false], length: Bool.memorySize, index: FragmentBufferIndex.HasTexture.rawValue)
        privateEncoder?.drawPrimitives(type: primitiveType, vertexStart: 0, vertexCount: vectorWord.finalVertices.count)
    }
    func char(_ character: Character, factory: VectorTextFactory, primitiveType: MTLPrimitiveType = .triangle, applyOffsetBefore: ((f2) -> ())? = nil, applySizeAfter: ((f2) -> ())? = nil) {
        if let cached = factory.cached[character] {
            applyOffsetBefore?(cached.offset)
            privateEncoder?.setVertexBuffer(cached.buffer, offset: 0, index: VertexBufferIndex.Position.rawValue)
            privateEncoder?.setVertexBytes([f3.one], length: f3.memorySize, index: VertexBufferIndex.ModelScale.rawValue)
            privateEncoder?.setFragmentBytes([false], length: Bool.memorySize, index: FragmentBufferIndex.HasTexture.rawValue)
            privateEncoder?.drawPrimitives(type: primitiveType, vertexStart: 0, vertexCount: cached.verticeCount)
            applySizeAfter?(cached.size)
        } else {
            print("no caches for \(character)")
        }
    }
    func word(_ str: String, factory: VectorTextFactory) {
        var spacerFactor: Float = 0
        for c in str {
            if c == " " {
                translate(spacerFactor, 0, 0)
                continue
            }
            char(c, factory: factory) { [self] offset in
                translate(-offset.x, 0, 0)
                push {
                    translate(0, -offset.y, 0)
                }
            } applySizeAfter: { [self] size in
                translate(-size.x, 0, 0)
                spacerFactor = -size.x
            }
        }
    }
}
