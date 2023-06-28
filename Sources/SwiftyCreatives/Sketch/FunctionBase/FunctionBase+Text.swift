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
    
//    func polytext(_ textGeometry: MyTextGeometry) {
//        for letter in textGeometry.triangulatedPaths {
//            for portion in letter.glyph {
//                let posBuffer = ShaderCore.device.makeBuffer(bytes: portion, length: portion.count * f3.memorySize)
//                privateEncoder?.setVertexBuffer(posBuffer, offset: 0, index: VertexBufferIndex.Position.rawValue)
//                
//                let uvBuffer = ShaderCore.device.makeBuffer(bytes: Array<f2>(repeating: f2.zero, count: portion.count), length: portion.count * f2.memorySize)
//                privateEncoder?.setVertexBuffer(uvBuffer, offset: 0, index: VertexBufferIndex.UV.rawValue)
//                
//                let normalBuffer = ShaderCore.device.makeBuffer(bytes: Array<f3>(repeating: f3(0, 0, 1), count: portion.count), length: portion.count * f3.memorySize)
//                privateEncoder?.setVertexBuffer(normalBuffer, offset: 0, index: VertexBufferIndex.Normal.rawValue)
//                
//                privateEncoder?.setVertexBytes([f3.one], length: f3.memorySize, index: VertexBufferIndex.ModelScale.rawValue)
//                privateEncoder?.setFragmentBytes([false], length: Bool.memorySize, index: FragmentBufferIndex.HasTexture.rawValue)
//                privateEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: portion.count)
//            }
//        }
//    }
    
    func polytext(_ textGeometry: MyTextGeometry, primitiveType: MTLPrimitiveType = .triangle) {
        privateEncoder?.setVertexBuffer(textGeometry.posBuffer!, offset: 0, index: VertexBufferIndex.Position.rawValue)
//        privateEncoder?.setVertexBuffer(textGeometry.uvBuffer, offset: 0, index: VertexBufferIndex.UV.rawValue)
//        privateEncoder?.setVertexBuffer(textGeometry.normalBuffer, offset: 0, index: VertexBufferIndex.Normal.rawValue)
                
        privateEncoder?.setVertexBytes([f3.one], length: f3.memorySize, index: VertexBufferIndex.ModelScale.rawValue)
        privateEncoder?.setFragmentBytes([false], length: Bool.memorySize, index: FragmentBufferIndex.HasTexture.rawValue)
        privateEncoder?.drawPrimitives(type: primitiveType, vertexStart: 0, vertexCount: textGeometry.finalVertices.count)
    }
    
    func polytext(_ textBuffer: MTLBuffer, count: Int, primitiveType: MTLPrimitiveType = .triangle) {
        privateEncoder?.setVertexBuffer(textBuffer, offset: 0, index: VertexBufferIndex.Position.rawValue)
        privateEncoder?.setVertexBytes([f3.one], length: f3.memorySize, index: VertexBufferIndex.ModelScale.rawValue)
        privateEncoder?.setFragmentBytes([false], length: Bool.memorySize, index: FragmentBufferIndex.HasTexture.rawValue)
        privateEncoder?.drawPrimitives(type: primitiveType, vertexStart: 0, vertexCount: count)
    }
}

import CoreText
import CoreGraphics
import simd
import Foundation
import iShapeTriangulation
import Metal
import iGeometry

public struct MyPolyLine2D {
    public var data: [f2] = []
}

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
    
    public var calculatedPaths: [(glyph: [MyPolyLine2D], offset: f2)] = []
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

    func getPolylines(_ glyphPath: CGPath, _ angleLimit: Float, _ distanceLimit: Float) -> [MyPolyLine2D] {
        var myPath = MyPolyLine2D()
        var myGlyphPaths = [MyPolyLine2D]()
        glyphPath.applyWithBlock { (elementPtr: UnsafePointer<CGPathElement>) in
            let element = elementPtr.pointee
            var pointsPtr = element.points
            let pt = simd_make_float2(Float(pointsPtr.pointee.x), Float(pointsPtr.pointee.y))

            switch element.type {
            case .moveToPoint:
                myPath.data.append(pt) //ADD
            case .addLineToPoint:
                let myA = myPath.data.last!
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
                myPath.data += data
            case .addQuadCurveToPoint:
                let myB = pt
                pointsPtr += 1
                let myA = myPath.data.last!
                let myC = simd_make_float2(Float(pointsPtr.pointee.x), Float(pointsPtr.pointee.y))
                let aVel = simd_normalize(quadraticBezierVelocity2(myA, myB, myC, 0.0))
                let bVel = simd_normalize(quadraticBezierVelocity2(myA, myB, myC, 0.5))
                let cVel = simd_normalize(quadraticBezierVelocity2(myA, myB, myC, 1.0))
                var data: [simd_float2] = []
                data.append(myA)
                _adaptiveQuadraticBezierCurve2(a: myA, b: myB, c: myC, aVel: aVel, bVel: bVel, cVel: cVel, angleLimit: angleLimit, depth: 0, line: &data)
                data.append(myC)
                data.removeFirst()
                myPath.data += data
            case .addCurveToPoint:
                let myA = myPath.data.last!
                let myB = pt
                pointsPtr += 1
                let myC = simd_make_float2(Float(pointsPtr.pointee.x), Float(pointsPtr.pointee.y))
                pointsPtr += 1
                let myD = simd_make_float2(Float(pointsPtr.pointee.x), Float(pointsPtr.pointee.y))
                
                let aVel = simd_normalize(cubicBezierVelocity2(myA, myB, myC, myD, 0.0))
                let bVel = simd_normalize(cubicBezierVelocity2(myA, myB, myC, myD, 0.5))
                let cVel = simd_normalize(cubicBezierVelocity2(myA, myB, myC, myD, 1.0))
                var data: [simd_float2] = []
                data.append(myA)
                _adaptiveQubicBezierCurve2(a: myA, b: myB, c: myC, d: myD, aVel: aVel, bVel: bVel, cVel: cVel, angleLimit: angleLimit, depth: 0, line: &data)
                data.append(myD)
                data.removeFirst()
                myPath.data += data
            case .closeSubpath:
                if myPath.data.first! == myPath.data.last! {
                    myPath.data.removeLast()
                }
                let myA = myPath.data.last!
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
                myPath.data += data
                myGlyphPaths.append(MyPolyLine2D(data: myPath.data))
                myPath.data.removeAll()
            default:
                break
            }
        }
        return myGlyphPaths
    }
    
    func cubicBezierVelocity2(_ a: f2, _ b: f2, _ c: f2, _ d: f2, _ t: Float) -> f2 {
        let oneMinusT = 1.0 - t
        let oneMinusT2 = oneMinusT * oneMinusT
        
        let temp1 = 3.0 * oneMinusT2 * (b - a)
        let temp2 = 6.0 * oneMinusT * t * (c - b)
        let temp3 = 3.0 * t * t * (d - c)
        return temp1 + temp2 + temp3
    }
    
    
    func quadraticBezierVelocity2(_ a: f2, _ b: f2, _ c: f2, _ t: Float) -> f2 {
        let oneMinusT: Float = 1.0 - t
        return 2 * oneMinusT * (b-a) + 2 * t * (c-b)
    }
    
    func _adaptiveQuadraticBezierCurve2(
        a: simd_float2,
        b: simd_float2,
        c: simd_float2,
        aVel: simd_float2,
        bVel: simd_float2,
        cVel: simd_float2,
        angleLimit: Float,
        depth: Int,
        line: inout [simd_float2]
    ) {
        if depth > 8 { return }
        let startMiddleAngle: Float = acos(simd_dot(aVel, bVel))
        let middleEndAngle: Float = acos(simd_dot(bVel, cVel))
        if startMiddleAngle + middleEndAngle > angleLimit {
            let ab = (a+b) * 0.5
            let bc = (b+c) * 0.5
            let abc = (ab + bc) * 0.5
            let sVel = simd_normalize(quadraticBezierVelocity2(a, ab, abc, 0.5))
            _adaptiveQuadraticBezierCurve2(a: a, b: ab, c: abc, aVel: aVel, bVel: sVel, cVel: bVel, angleLimit: angleLimit, depth: depth+1, line: &line)
            line.append(abc)
            let eVel = simd_normalize(quadraticBezierVelocity2(abc, bc, c, 0.5))
            _adaptiveQuadraticBezierCurve2(a: abc, b: bc, c: c, aVel: bVel, bVel: eVel, cVel: cVel, angleLimit: angleLimit, depth: depth+1, line: &line)
        }
    }
    
    func _adaptiveQubicBezierCurve2(
        a: simd_float2,
        b: simd_float2,
        c: simd_float2,
        d: simd_float2,
        aVel: simd_float2,
        bVel: simd_float2,
        cVel: simd_float2,
        angleLimit: Float,
        depth: Int,
        line: inout [simd_float2]
    ) {
        if depth > 8 { return }
        let startMiddleAngle: Float = acos(simd_dot(aVel, bVel))
        let middleEndAngle: Float = acos(simd_dot(bVel, cVel))
        if startMiddleAngle + middleEndAngle > angleLimit {
            let ab = (a+b) * 0.5
            let bc = (b+c) * 0.5
            let cd = (c+d) * 0.5
            let abc = (ab + bc) * 0.5
            let bcd = (bc + cd) * 0.5
            let abcd = (abc + bcd) * 0.5
            let sVel = simd_normalize(cubicBezierVelocity2(a, ab, abc, abcd, 0.5))
            _adaptiveQubicBezierCurve2(a: a, b: ab, c: abc, d: abcd, aVel: aVel, bVel: sVel, cVel: bVel, angleLimit: angleLimit, depth: depth+1, line: &line)
            line.append(abcd)
            let eVel = simd_normalize(cubicBezierVelocity2(abcd, bcd, cd, d, 0.5))
            _adaptiveQubicBezierCurve2(a: abcd, b: bcd, c: cd, d: d, aVel: bVel, bVel: eVel, cVel: cVel, angleLimit: angleLimit, depth: depth+1, line: &line)
        }
    }
    
//    public var caches: [String: MTLBuffer] = [:]
//    public var cacheSpacing: [String: Float] = [:]
    public var textBuffer: MTLBuffer?
    public var vertexCount: Int?
    let triangulator = Triangulator()
    func cacheVertices() {
        for letter in calculatedPaths {
            triangulatedPaths.append(([], f3(letter.offset.x, letter.offset.y, 0)))
            var temp: [(path: [Point], hole: [[Point]])] = []
            for portion in letter.glyph {
                
//                if isVertexStructureClockwise(data: portion.data) {
//                    temp.append((portion.data.map{$0.shapePoint}, []))
//                } else {
//                    if temp.isEmpty {
//                        temp.append(([], []))
//                        temp[temp.count-1].path = portion.data.map{$0.shapePoint}
//                    } else {
//                        temp[temp.count-1].hole.append(portion.data.map{$0.shapePoint})
//                    }
//                }
                if temp.isEmpty {
                    temp.append(([], []))
                    if isClockwiseFont {
                        temp[temp.count-1].path = portion.data.map{$0.shapePoint}.reversed()
                    } else {
                        temp[temp.count-1].path = portion.data.map{$0.shapePoint}
                    }
                } else {
                    if isClockwiseFont {
                        temp[temp.count-1].hole.append(portion.data.map{$0.shapePoint}.reversed())
                    } else {
                        temp[temp.count-1].hole.append(portion.data.map{$0.shapePoint})
                    }
                }
//                if !isClockwiseFont {
//                    
//                } else {
//                    if temp.isEmpty {
//                        temp.append(([], []))
//                        temp[temp.count-1].path = portion.data.map{$0.shapePoint}.reversed()
//                    } else {
//                        temp[temp.count-1].hole.append(portion.data.map{$0.shapePoint}.reversed())
//                    }
//                }
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
                    //                    textBuffer = ShaderCore.device.makeBuffer(bytes: triangles.map{
                    //                        f3(portion.data[$0].x, portion.data[$0].y, 0)
                    //                    }, length: f3.memorySize * triangles.count)
                    //                    vertexCount = triangles.count
                    triangulatedPaths[triangulatedPaths.count-1].glyph.append( triangles.map{
                        f3(allPath[$0].x, allPath[$0].y, 0) + f3(letter.offset.x, letter.offset.y, 0)
                    })
                }
            }
        }
    }
    
    func isVertexStructureClockwise(data: [f2]) -> Bool {
        var area: Float = 0
        for i in 0..<data.count {
            let i0 = i
            let i1 = (i+1) % data.count
            let a = data[i0]
            let b = data[i1]
            area += (b.x - a.x) * (b.y + a.y)
        }
        return area >= 0 ? false : true
//        return false
    }
    
//    bool isVertexStructureClockwise(tsVertex *vertices, int length)
//    {
//        float area = 0;
//        for (int i = 0; i < length; i++) {
//            int i0 = i;
//            int i1 = (i + 1) % length;
//            simd_float2 a = vertices[i0].v;
//            simd_float2 b = vertices[i1].v;
//            area += (b.x - a.x) * (b.y + a.y);
//        }
//        return !signbit(area);
//    }
}

public extension f2 {
    var shapePoint: iGeometry.Point {
        Point(x: self.x, y: self.y)
    }
}
