//
//  FunctionBase+Text.swift
//  
//
//  Created by Yuki Kuwashima on 2023/03/27.
//

import AppKit
import CommonEntity

public extension FunctionBase {
    func text(_ textObj: TextObject) {
        privateEncoder?.setVertexBytes(RectShapeInfo.vertices, length: RectShapeInfo.vertices.count * f3.memorySize, index: VertexBufferIndex.Position.rawValue)
        privateEncoder?.setVertexBytes(textObj._mScale, length: f3.memorySize, index: VertexBufferIndex.ModelScale.rawValue)
        privateEncoder?.setVertexBytes(RectShapeInfo.uvs, length: RectShapeInfo.uvs.count * f2.memorySize, index: VertexBufferIndex.UV.rawValue)
        privateEncoder?.setVertexBytes(RectShapeInfo.normals, length: RectShapeInfo.normals.count * f3.memorySize, index: VertexBufferIndex.Normal.rawValue)
        privateEncoder?.setFragmentBytes([true], length: Bool.memorySize, index: FragmentBufferIndex.HasTexture.rawValue)
        privateEncoder?.setFragmentTexture(textObj.texture, index: FragmentTextureIndex.MainTexture.rawValue)
        privateEncoder?.drawPrimitives(type: RectShapeInfo.primitiveType, vertexStart: 0, vertexCount: RectShapeInfo.vertices.count)
    }
    func polytext(_ vectorWord: VectorWord, primitiveType: MTLPrimitiveType = .triangle) {
        privateEncoder?.setVertexBuffer(vectorWord.posBuffer!, offset: 0, index: VertexBufferIndex.Position.rawValue)
        privateEncoder?.setVertexBytes([f3.one], length: f3.memorySize, index: VertexBufferIndex.ModelScale.rawValue)
        privateEncoder?.setFragmentBytes([false], length: Bool.memorySize, index: FragmentBufferIndex.HasTexture.rawValue)
        privateEncoder?.drawPrimitives(type: primitiveType, vertexStart: 0, vertexCount: vectorWord.finalVertices.count)
    }
}
