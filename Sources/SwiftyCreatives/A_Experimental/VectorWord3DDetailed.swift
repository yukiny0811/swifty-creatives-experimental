//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/06/30.
//

import Metal
import CoreText
import CommonEntity
import FontVertexBuilder
import Algorithms

open class VectorWord3DDetailed: VectorText {
    public var finalVertices: [f3] = []
    public var extrudingIndices: [Int] = []
    private var extrudingValue: Float = 0
    
    public var chunkedBlobs: [[f3]] = []
    
    func updateChunks() {
        chunkedBlobs = finalVertices.chunks(ofCount: 24).map {$0.map{$0}}
    }
    
    public func extrude(_ value: Float) {
        for i in extrudingIndices {
            finalVertices[i].z += value
        }
        updateChunks()
    }
    func createAndSetBuffer(from triangulatedPaths: [TriangulatedLetterPath]) {
        finalVertices = []
        extrudingIndices = []
        
        var tempFinalVertices: [f3] = []
        for letter in triangulatedPaths {
            for portion in letter.glyphLines {
                tempFinalVertices += portion
            }
        }
        for i in 0..<tempFinalVertices.count {
            if i.isMultiple(of: 3) {
                finalVertices.append(tempFinalVertices[i])
                finalVertices.append(tempFinalVertices[i+1])
                finalVertices.append(tempFinalVertices[i+2])
                
                extrudingIndices.append(finalVertices.count)
                finalVertices.append(tempFinalVertices[i] + f3(0, 0, extrudingValue))
                extrudingIndices.append(finalVertices.count)
                finalVertices.append(tempFinalVertices[i+1] + f3(0, 0, extrudingValue))
                extrudingIndices.append(finalVertices.count)
                finalVertices.append(tempFinalVertices[i+2] + f3(0, 0, extrudingValue))
            }
            if i.isMultiple(of: 3) || (i-1).isMultiple(of: 3) {
                finalVertices.append(tempFinalVertices[i])
                
                extrudingIndices.append(finalVertices.count)
                finalVertices.append(tempFinalVertices[i] + f3(0, 0, extrudingValue))
                
                extrudingIndices.append(finalVertices.count)
                finalVertices.append(tempFinalVertices[i+1] + f3(0, 0, extrudingValue))
                
                finalVertices.append(tempFinalVertices[i])
                
                finalVertices.append(tempFinalVertices[i+1])
                
                extrudingIndices.append(finalVertices.count)
                finalVertices.append(tempFinalVertices[i+1] + f3(0, 0, extrudingValue))
            } else {
                finalVertices.append(tempFinalVertices[i])
                
                extrudingIndices.append(finalVertices.count)
                finalVertices.append(tempFinalVertices[i] + f3(0, 0, extrudingValue))
                
                extrudingIndices.append(finalVertices.count)
                finalVertices.append(tempFinalVertices[i-2] + f3(0, 0, extrudingValue))
                
                finalVertices.append(tempFinalVertices[i])
                
                finalVertices.append(tempFinalVertices[i-2])
                
                extrudingIndices.append(finalVertices.count)
                finalVertices.append(tempFinalVertices[i-2] + f3(0, 0, extrudingValue))
            }
        }
        updateChunks()
    }
    public init(text: String, fontName: String = "AppleSDGothicNeo-Bold", fontSize: Float = 10.0, bounds: CGSize = .zero, pivot: f2 = .zero, textAlignment: CTTextAlignment = .natural, verticalAlignment: VectorText.VerticalAlignment = .center, kern: Float = 0.0, lineSpacing: Float = 0.0, isClockwiseFont: Bool = true, extrudingValue: Float = 0) {
        self.extrudingValue = extrudingValue
        super.init(text: text, fontName: fontName, fontSize: fontSize, bounds: bounds, pivot: pivot, textAlignment: textAlignment, verticalAlignment: verticalAlignment, kern: kern, lineSpacing: lineSpacing, isClockwiseFont: isClockwiseFont)
        let triangulatedPaths = GlyphUtil.MainFunctions.triangulate(self.calculatedPaths, isClockwiseFont: isClockwiseFont)
        createAndSetBuffer(from: triangulatedPaths)
    }
}
