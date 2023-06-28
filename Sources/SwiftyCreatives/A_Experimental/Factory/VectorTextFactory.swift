//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/06/28.
//

import Foundation
import CoreText
import CoreGraphics
import Metal

public extension FunctionBase {
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

public class VectorTextFactory {
    
    private var fontName: String
    private var fontSize: Float
    private var bounds: CGSize
    private var pivot: f2
    private var textAlignment: CTTextAlignment
    private var verticalAlignment: VectorText.VerticalAlignment
    private var kern: Float
    private var lineSpacing: Float
    private var isClockwiseFont: Bool
    
    public var cached: [Character: LetterCache] = [:]
    
    public func cacheCharacter(char: Character) {
        let vectorText = VectorText(text: String(char), fontSize: fontSize)
        let resultTuple = GlyphUtil.MainFunctions.triangulateWithoutLetterOffset(vectorText.calculatedPaths, isClockwiseFont: isClockwiseFont)
        let path = resultTuple.paths.first!
        let offset = resultTuple.letterOffsets.first!
        
        let characterPath = path.glyphLines.flatMap { $0.map { $0 + path.offset } }
        let pathBuffer = ShaderCore.device.makeBuffer(bytes: characterPath, length: characterPath.count * f3.memorySize)!
        cached[char] = LetterCache(
            buffer: pathBuffer,
            verticeCount: characterPath.count,
            offset: f2(offset.x, offset.y),
            size: f2(
                characterPath.max(by: {$0.x > $1.x})!.x,
                characterPath.max(by: {$0.y > $1.y})!.y
            )
        )
    }
    
    public init(fontName: String = "AppleSDGothicNeo-Bold",
                fontSize: Float = 10.0,
                bounds: CGSize = .zero,
                pivot: f2 = .zero,
                textAlignment: CTTextAlignment = .natural,
                verticalAlignment: VectorText.VerticalAlignment = .center,
                kern: Float = 0.0,
                lineSpacing: Float = 0.0,
                isClockwiseFont: Bool = true
    ) {
        self.fontName = fontName
        self.fontSize = fontSize
        self.bounds = bounds
        self.pivot = pivot
        self.textAlignment = textAlignment
        self.verticalAlignment = verticalAlignment
        self.kern = kern
        self.lineSpacing = lineSpacing
        self.isClockwiseFont = isClockwiseFont
    }
}
