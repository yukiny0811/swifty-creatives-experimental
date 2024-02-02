//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/06/29.
//

import Foundation
import CoreText
import CoreGraphics
import Metal
import SimpleSimdSwift
import FontVertexBuilder

public class VectorTextFactoryRaw {
    
    private var fontName: String
    private var fontSize: Float
    private var bounds: CGSize
    private var pivot: f2
    private var textAlignment: CTTextAlignment
    private var verticalAlignment: PathText.VerticalAlignment
    private var kern: Float
    private var lineSpacing: Float
    private var isClockwiseFont: Bool
    
    public var cached: [Character: LetterCacheRaw] = [:]
    public var cachedBuffer: [Character: LetterCache] = [:]
    
    public func cacheCharacter(char: Character) {
        let vectorText = PathText(text: String(char), fontName: fontName, fontSize: fontSize, bounds: bounds, pivot: pivot, textAlignment: textAlignment, verticalAlignment: verticalAlignment, kern: kern, lineSpacing: lineSpacing, isClockwiseFont: isClockwiseFont)
        let resultTuple = GlyphUtil.MainFunctions.triangulateWithoutLetterOffset(vectorText.calculatedPaths, isClockwiseFont: isClockwiseFont)
        let path = resultTuple.paths.first!
        guard let offset = resultTuple.letterOffsets.first else {
            print("failed to cache \(char)")
            return
        }
        
        let characterPath = path.glyphLines.flatMap { $0.map { $0 + path.offset } }
        let pathBuffer = ShaderCore.device.makeBuffer(bytes: characterPath, length: characterPath.count * f3.memorySize)!
        cached[char] = LetterCacheRaw(
            vertices: characterPath,
            offset: f2(offset.x, offset.y),
            size: f2(
                characterPath.max(by: {$0.x > $1.x})!.x,
                characterPath.max(by: {$0.y > $1.y})!.y
            )
        )
        cachedBuffer[char] = LetterCache(
            buffer: pathBuffer,
            verticeCount: characterPath.count,
            offset: f2(offset.x, offset.y),
            size: f2(
                characterPath.max(by: {$0.x > $1.x})!.x,
                characterPath.max(by: {$0.y > $1.y})!.y
            )
        )
    }
    
    public func resetCache(_ char: Character) {
        cacheCharacter(char: char)
    }
    
    public func updateCache(_ char: Character, f: (_ vertices: inout [f3]) -> ()) {
        f(&cached[char]!.vertices)
        cachedBuffer[char]!.buffer.contents().copyMemory(from: cached[char]!.vertices, byteCount: f3.memorySize * cached[char]!.vertices.count)
    }
    
    public init(fontName: String = "AppleSDGothicNeo-Bold",
                fontSize: Float = 10.0,
                bounds: CGSize = .zero,
                pivot: f2 = .zero,
                textAlignment: CTTextAlignment = .natural,
                verticalAlignment: PathText.VerticalAlignment = .center,
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
