//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/06/28.
//

import Foundation
import simd
import CoreGraphics
import CoreText

open class VectorText {
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
    public var ctFont: CTFont
    public var calculatedPaths: [LetterPath] = []
    public var isClockwiseFont: Bool = false
    public var angleLimit: Float = 7.5 * Float.pi / 180.0
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

    public init(text: String, fontName: String = "AppleSDGothicNeo-Bold",fontSize: Float, bounds: CGSize = .zero, pivot: f2 = .zero, textAlignment: CTTextAlignment = .natural, verticalAlignment: VerticalAlignment = .center, kern: Float = 0.0, lineSpacing: Float = 0.0, isClockwiseFont: Bool = false) {
        self.text = text
        textBounds = bounds
        self.pivot = pivot
        self.textAlignment = textAlignment
        self.verticalAlignment = verticalAlignment
        self.kern = kern
        self.lineSpacing = lineSpacing
        self.isClockwiseFont = isClockwiseFont
        ctFont = CTFontCreateWithName(fontName as CFString, CGFloat(fontSize), nil)
        setupData()
    }

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
    }
    func addGlyphGeometryData(_ glyph: CGGlyph, _ glyphPosition: CGPoint, _ origin: CGPoint) {
        guard let framePivot = framePivot, let verticalOffset = verticalOffset else { return }
        if let glyphPath = CTFontCreatePathForGlyph(ctFont, glyph, nil) {
            let glyphPaths = GlyphUtil.MainFunctions.getGlyphLines(glyphPath, angleLimit, fontSize*10)
            let glyphOffset = f2(Float(glyphPosition.x + origin.x - framePivot.x), Float(glyphPosition.y + origin.y - framePivot.y - verticalOffset))
            calculatedPaths.append(LetterPath(glyphs: glyphPaths, offset: glyphOffset))
        }
        
    }
}