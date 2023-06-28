//
//  FunctionBase+Text.swift
//  
//
//  Created by Yuki Kuwashima on 2023/03/27.
//

import AppKit

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
    func polytext(_ textGeometry: MyTextGeometry, primitiveType: MTLPrimitiveType = .triangle) {
        privateEncoder?.setVertexBuffer(textGeometry.posBuffer!, offset: 0, index: VertexBufferIndex.Position.rawValue)
        privateEncoder?.setVertexBytes([f3.one], length: f3.memorySize, index: VertexBufferIndex.ModelScale.rawValue)
        privateEncoder?.setFragmentBytes([false], length: Bool.memorySize, index: FragmentBufferIndex.HasTexture.rawValue)
        privateEncoder?.drawPrimitives(type: primitiveType, vertexStart: 0, vertexCount: textGeometry.finalVertices.count)
    }
}

import CoreText
import CoreGraphics
import simd
import Foundation
import iShapeTriangulation
import Metal
import iGeometry

open class MyTextGeometry {
    public enum VerticalAlignment: Int, Codable {
        case top = 0
        case center = 1
        case bottom = 2
    }
    public var verticalAlignment: VerticalAlignment = .center
    public var textAlignment: CTTextAlignment = .natural
    public var text = ""
    public var pivot = f2(0.0, 0.0)
    public var textBounds = CGSize(width: -1, height: -1)
    public var kern: Float = 0.0
    public var lineSpacing: Float = 0.0
    public var fontSize: Float = 1
    public var lineHeight: Float { ascent + descent + leading }
    public var ascent: Float { Float(CTFontGetAscent(ctFont)) }
    public var descent: Float { Float(CTFontGetDescent(ctFont)) }
    public var leading: Float { Float(CTFontGetLeading(ctFont)) }
    public var unitsPerEm: Float { Float(CTFontGetUnitsPerEm(ctFont)) }
    public var glyphCount: Float { Float(CTFontGetGlyphCount(ctFont)) }
    public var underlinePosition: Float { Float(CTFontGetUnderlinePosition(ctFont)) }
    public var underlineThickness: Float { Float(CTFontGetUnderlineThickness(ctFont)) }
    public var slantAngle: Float { Float(CTFontGetSlantAngle(ctFont)) }
    public var capHeight: Float { Float(CTFontGetCapHeight(ctFont)) }
    public var xHeight: Float { Float(CTFontGetXHeight(ctFont)) }
    public var suggestFrameSize: CGSize? {
        guard let frameSetter = frameSetter else { return nil }
        var bnds = textBounds
        if bnds.width <= 0 {
            bnds.width = CGFloat.greatestFiniteMagnitude
        }
        if bnds.height <= 0 {
            bnds.height = CGFloat.greatestFiniteMagnitude
        }
        return CTFramesetterSuggestFrameSizeWithConstraints(frameSetter, CFRangeMake(0, text.count), nil, bnds, nil)
    }
    var verticalOffset: CGFloat? {
        guard let suggestFrameSize = suggestFrameSize else { return nil }
        var verticalOffset: CGFloat
        switch verticalAlignment {
        case .top:
            verticalOffset = 0
        case .center:
            verticalOffset = ((textBounds.height <= 0 ? suggestFrameSize.height : textBounds.height) - suggestFrameSize.height) * 0.5
        case .bottom:
            verticalOffset = (textBounds.height <= 0 ? suggestFrameSize.height : textBounds.height) - suggestFrameSize.height
        }
        return verticalOffset
    }
    var framePivot: CGPoint? {
        guard let suggestFrameSize = suggestFrameSize else { return nil }
        let pt = pivot * 0.5 + 0.5
        let px: CGFloat = (textBounds.width <= 0 ? suggestFrameSize.width : textBounds.width) * CGFloat(pt.x)
        let py: CGFloat = (textBounds.height <= 0 ? suggestFrameSize.height : textBounds.height) * CGFloat(pt.y)
        return CGPoint(x: px, y: py)
    }
    var frameSetter: CTFramesetter? {
        guard let attributedText = attributedText else { return nil }
        return CTFramesetterCreateWithAttributedString(attributedText)
    }
    var frame: CTFrame? {
        guard let suggestFrameSize = suggestFrameSize, let frameSetter = frameSetter else { return nil }
        let framePath = CGMutablePath()
        let constraints = CGRect(x: 0.0, y: 0.0, width: textBounds.width <= 0.0 ? suggestFrameSize.width : textBounds.width, height: textBounds.height <= 0.0 ? suggestFrameSize.height : textBounds.height)
        framePath.addRect(constraints)
        return CTFramesetterCreateFrame(frameSetter, CFRangeMake(0, text.count), framePath, nil)
    }
    var lines: [CTLine] {
        guard let frame = frame else { return [] }
        return CTFrameGetLines(frame) as! [CTLine]
    }
    var origins: [CGPoint] {
        guard lines.count > 0, let frame = frame else { return [] }
        var origins: [CGPoint] = Array(repeating: CGPoint(), count: lines.count)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &origins)
        return origins
    }
    var attributedText: CFAttributedString? {
        // Text Attributes
        let attributes: [NSAttributedString.Key: Any] = [
            .font: ctFont,
            .kern: NSNumber(value: kern),
        ]
        let attributedText = CFAttributedStringCreateMutable(kCFAllocatorDefault, 0)
        CFAttributedStringReplaceString(attributedText, CFRangeMake(0, 0), text as CFString)
        CFAttributedStringSetAttributes(attributedText, CFRangeMake(0, text.count), attributes as CFDictionary, false)
        // Paragraph Attributes
        let alignment = UnsafeMutablePointer<CTTextAlignment>.allocate(capacity: 1)
        alignment.pointee = textAlignment
        let lineSpace = UnsafeMutablePointer<Float>.allocate(capacity: 1)
        lineSpace.pointee = lineSpacing
        let settings = [
            CTParagraphStyleSetting(spec: .alignment, valueSize: MemoryLayout<CTTextAlignment>.size, value: alignment),
            CTParagraphStyleSetting(spec: .lineSpacingAdjustment, valueSize: MemoryLayout<Float>.size, value: lineSpace),
        ]
        let style = CTParagraphStyleCreate(settings, settings.count)
        CFAttributedStringSetAttribute(attributedText, CFRangeMake(0, text.count), kCTParagraphStyleAttributeName, style)
        alignment.deallocate()
        lineSpace.deallocate()
        return attributedText
    }
    var ctFont: CTFont
    
    public var calculatedPaths: [(glyph: [GlyphLine], offset: f2)] = []
    public var triangulatedPaths: [(glyph: [[f3]], offset: f3)] = []
    
    public var isClockwiseFont: Bool = false

    public init(text: String, fontName: String = "AppleSDGothicNeo-Bold",fontSize: Float, bounds: CGSize = .zero, pivot: f2 = .zero, textAlignment: CTTextAlignment = .natural, verticalAlignment: VerticalAlignment = .center, kern: Float = 0.0, lineSpacing: Float = 0.0, isClockwiseCont: Bool = false) {
        self.text = text
        textBounds = bounds
        self.pivot = pivot
        self.textAlignment = textAlignment
        self.verticalAlignment = verticalAlignment
        self.kern = kern
        self.lineSpacing = lineSpacing
        self.isClockwiseFont = isClockwiseCont
        ctFont = CTFontCreateWithName(fontName as CFString, CGFloat(fontSize), nil)
        updateData()
    }

    private func updateData() {
        setupData()
    }
    var angleLimit: Float = 7.5 * Float.pi / 180.0;

    func setupData() {

        var charOffset = 0
        for (lineIndex, line) in lines.enumerated() {
            let origin = origins[lineIndex]
            let runs: [CTRun] = CTLineGetGlyphRuns(line) as! [CTRun]
            for run in runs {
                let glyphCount = CTRunGetGlyphCount(run)
                let glyphPositions = UnsafeMutablePointer<CGPoint>.allocate(capacity: glyphCount)
                CTRunGetPositions(run, CFRangeMake(0, 0), glyphPositions)
                let glyphs = UnsafeMutablePointer<CGGlyph>.allocate(capacity: glyphCount)
                CTRunGetGlyphs(run, CFRangeMake(0, 0), glyphs)
                for glyphIndex in 0 ..< glyphCount {
                    let glyph = glyphs[glyphIndex]
                    let glyphPosition = glyphPositions[glyphIndex]
                    addGlyphGeometryData(glyph, glyphPosition, origin)
                    charOffset += 1
                }
                glyphPositions.deallocate()
                glyphs.deallocate()
            }
        }
        
        cacheVertices()
        createBuffer()
    }
    
    public var posBuffer: MTLBuffer?
    public var finalVertices: [f3] = []
    
    func createBuffer() {
        finalVertices = []
        for letter in self.triangulatedPaths {
            for portion in letter.glyph {
                finalVertices += portion
            }
        }
        posBuffer = ShaderCore.device.makeBuffer(bytes: finalVertices, length: finalVertices.count * f3.memorySize)
    }

    func addGlyphGeometryData(_ glyph: CGGlyph, _ glyphPosition: CGPoint, _ origin: CGPoint) {
        guard let framePivot = framePivot, let verticalOffset = verticalOffset else { return }
        if let glyphPath = CTFontCreatePathForGlyph(ctFont, glyph, nil) {
            let glyphPaths = getPolylines(glyphPath, angleLimit, fontSize)
            let glyphOffset = f2(Float(glyphPosition.x + origin.x - framePivot.x), Float(glyphPosition.y + origin.y - framePivot.y - verticalOffset))
            calculatedPaths.append((glyphPaths, glyphOffset))
        }
        
    }

    func getPolylines(_ glyphPath: CGPath, _ angleLimit: Float, _ distanceLimit: Float) -> [GlyphLine] {
        var myPath = GlyphLine()
        var myGlyphPaths = [GlyphLine]()
        glyphPath.applyWithBlock { (elementPtr: UnsafePointer<CGPathElement>) in
            let element = elementPtr.pointee
            var pointsPtr = element.points
            let pt = simd_make_float2(Float(pointsPtr.pointee.x), Float(pointsPtr.pointee.y))

            switch element.type {
            case .moveToPoint:
                myPath.append(pt) //ADD
            case .addLineToPoint:
                let myA = myPath.last!
                let length = simd_length(pt - myA)
                var data: [simd_float2] = []
                if length > distanceLimit {
                    let sections = Int(max(ceil(length / distanceLimit), 2))
                    let inc = 1.0 / Float(sections - 1)
                    var t = simd_float2(0.0, 0.0)
                    for _ in 0..<sections {
                        data.append(simd_mix(myA, pt, t))
                        t += inc
                        t = min(max(t, 0.0), 1.0)
                    }
                } else {
                    data.append(myA)
                    data.append(pt)
                }
                data.removeFirst()
                myPath += data
            case .addQuadCurveToPoint:
                let myB = pt
                pointsPtr += 1
                let myA = myPath.last!
                let myC = simd_make_float2(Float(pointsPtr.pointee.x), Float(pointsPtr.pointee.y))
                let aVel = simd_normalize(GlyphUtil.HelperFunctions.quadraticBezierVelocity2(myA, myB, myC, 0.0))
                let bVel = simd_normalize(GlyphUtil.HelperFunctions.quadraticBezierVelocity2(myA, myB, myC, 0.5))
                let cVel = simd_normalize(GlyphUtil.HelperFunctions.quadraticBezierVelocity2(myA, myB, myC, 1.0))
                var data: [simd_float2] = []
                data.append(myA)
                GlyphUtil.MainFunctions.adaptiveQuadraticBezierCurve2(a: myA, b: myB, c: myC, aVel: aVel, bVel: bVel, cVel: cVel, angleLimit: angleLimit, depth: 0, line: &data)
                data.append(myC)
                data.removeFirst()
                myPath += data
            case .addCurveToPoint:
                let myA = myPath.last!
                let myB = pt
                pointsPtr += 1
                let myC = simd_make_float2(Float(pointsPtr.pointee.x), Float(pointsPtr.pointee.y))
                pointsPtr += 1
                let myD = simd_make_float2(Float(pointsPtr.pointee.x), Float(pointsPtr.pointee.y))
                
                let aVel = simd_normalize(GlyphUtil.HelperFunctions.cubicBezierVelocity2(myA, myB, myC, myD, 0.0))
                let bVel = simd_normalize(GlyphUtil.HelperFunctions.cubicBezierVelocity2(myA, myB, myC, myD, 0.5))
                let cVel = simd_normalize(GlyphUtil.HelperFunctions.cubicBezierVelocity2(myA, myB, myC, myD, 1.0))
                var data: [simd_float2] = []
                data.append(myA)
                GlyphUtil.MainFunctions.adaptiveQubicBezierCurve2(a: myA, b: myB, c: myC, d: myD, aVel: aVel, bVel: bVel, cVel: cVel, angleLimit: angleLimit, depth: 0, line: &data)
                data.append(myD)
                data.removeFirst()
                myPath += data
            case .closeSubpath:
                if myPath.first! == myPath.last! {
                    myPath.removeLast()
                }
                let myA = myPath.last!
                let length = simd_length(pt - myA)
                var data: [simd_float2] = []
                if length > distanceLimit {
                    let sections = Int(max(ceil(length / distanceLimit), 2))
                    let inc = 1.0 / Float(sections - 1)
                    var t = simd_float2(0.0, 0.0)
                    for _ in 0..<sections {
                        data.append(simd_mix(myA, pt, t))
                        t += inc
                        t = min(max(t, 0.0), 1.0)
                    }
                } else {
                    data.append(myA)
                    data.append(pt)
                }
                data.removeLast()
                data.removeFirst()
                myPath += data
                myGlyphPaths.append(myPath)
                myPath.removeAll()
            default:
                break
            }
        }
        return myGlyphPaths
    }
    
    public var textBuffer: MTLBuffer?
    public var vertexCount: Int?
    let triangulator = Triangulator()
    func cacheVertices() {
        for letter in calculatedPaths {
            triangulatedPaths.append(([], f3(letter.offset.x, letter.offset.y, 0)))
            var temp: [(path: [Point], hole: [[Point]])] = []
            for portion in letter.glyph {
                if temp.isEmpty {
                    temp.append(([], []))
                    if isClockwiseFont {
                        temp[temp.count-1].path = portion.map{$0.shapePoint}.reversed()
                    } else {
                        temp[temp.count-1].path = portion.map{$0.shapePoint}
                    }
                } else {
                    if isClockwiseFont {
                        temp[temp.count-1].hole.append(portion.map{$0.shapePoint}.reversed())
                    } else {
                        temp[temp.count-1].hole.append(portion.map{$0.shapePoint})
                    }
                }
            }
            
            
            
            for t in temp {
                
                let allPath: [Point] = t.path + t.hole.reduce([], +)
                
                var slices: [ArraySlice<Point>] = []
                var currentIndex = t.path.count
                for h in t.hole {
                    slices.append(allPath[currentIndex..<currentIndex+h.count])
                    currentIndex += h.count
                }
                if let triangles = try? triangulator.triangulateDelaunay(
                    points: allPath,
                    hull: allPath[0..<t.path.count],
                    holes: slices,
                    extraPoints: nil) {
                    triangulatedPaths[triangulatedPaths.count-1].glyph.append( triangles.map{
                        f3(allPath[$0].x, allPath[$0].y, 0) + f3(letter.offset.x, letter.offset.y, 0)
                    })
                }
            }
        }
    }
}
