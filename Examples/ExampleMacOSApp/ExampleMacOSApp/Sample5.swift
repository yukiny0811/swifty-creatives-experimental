//
//  Sample5.swift
//  ExampleMacOSApp
//
//  Created by Yuki Kuwashima on 2023/02/02.
//

import AppKit
import SwiftyCreatives
import CoreGraphics
import simd

struct MyWordBlob {
    var vector: VectorWord3DDetailed
    var colors: [f4] = []
    var translations: [f3] = []
    var rotations: [f3] = []
//    f4(0.8, 0.6 + Float.random(in: 0...0.2), 0.6 + Float.random(in: 0...0.2), 0.9)
    //f4(Float.random(in: 0.1...0.5), 0.1, Float.random(in: 0.3...0.8), 0.9)
    init(_ w: String) {
        self.vector = VectorWord3DDetailed(text: w, fontName: "SF Condensed Medium", isClockwiseFont: false)
        for _ in self.vector.chunkedBlobs {
            colors.append(f4(0.9, 0.5, 1, 1))
            translations.append(f3.randomPoint(-3...3))
            rotations.append(f3.randomPoint(-3...3))
        }
        self.vector.extrude(1)
    }
    static let fonts = [
        ("mericanTypewriter-CondensedBold", false),
//        ("AppleSDGothicNeo-Bold", false),
//        ("AppleSDGothicNeo-Thin", false),
//        ("ArialHebrew", false)
    ]
    mutating func reset(_ w: String, _ f: (String, Bool)) {
        self.vector = VectorWord3DDetailed(text: w)
        colors = []
        translations = []
        rotations = []
        for _ in self.vector.chunkedBlobs {
            colors.append(f4(1, 0.5, 1, 1))
            translations.append(f3.randomPoint(-3...3))
            rotations.append(f3.randomPoint(-3...3))
        }
        self.vector.extrude(1)
    }
}

final class Sample5: Sketch {
    
    @SCAnimatable var currentAnim = 0
    var blobs: [MyWordBlob] = []
    var blobs2: [MyWordBlob] = []
    var offset: Float = 0
    var isWireframe = false
    
    var elapsed: Float = 0
    var elapsedAnim: Float = 0
    var elapsedCamera: Float = 0
    var elapsedFont: Float = 0
    
    override init() {
        blobs.append(.init("D"))
        blobs.append(.init("E"))
        blobs.append(.init("P"))
        blobs.append(.init("S"))
        blobs.append(.init("E"))
        
        super.init()
//        blobs.append(.init("発"))
//        blobs.append(.init("i"))
//        blobs.append(.init("n"))
//        blobs.append(.init("a"))
//        blobs2.append(.init("c"))
//        blobs2.append(.init("o"))
//        blobs2.append(.init("d"))
//        blobs2.append(.init("i"))
//        blobs2.append(.init("n"))
//        blobs2.append(.init("g"))
    }
    func toggleCurrentAnim() {
        if currentAnim > 0.9 {
            currentAnim = 0
        } else {
            currentAnim = 1
        }
    }
    override func update(camera: some MainCameraBase) {
        $currentAnim.update(multiplier: 0.08)
        camera.rotateAroundY(sin(elapsedCamera) * 0.001)
        camera.rotateAroundX(sin(elapsedCamera) * 0.002)
        elapsed += deltaTime
        elapsedAnim += deltaTime
        elapsedCamera += deltaTime
        elapsedFont += deltaTime
        if elapsed > 10 {
            isWireframe.toggle()
            elapsed = 0
        }
        if elapsedAnim > 14 {
            toggleCurrentAnim()
            elapsedAnim = 0
        }
        if elapsedFont > 20 {
            let rand = MyWordBlob.fonts.randomElement()!
            blobs[0].reset("D", rand)
            blobs[1].reset("E", rand)
            blobs[2].reset("P", rand)
            blobs[3].reset("S", rand)
            blobs[4].reset("E", rand)
            elapsedFont = 0
        }
    }
    override func draw(encoder: SCEncoder) {
        let spacing: Float = 7
        scale(3, 3, 3)
        translate(offset, 0, 0)
        push {
            translate(-spacing*Float(blobs.count)/2, 0, 0)
            for blob in blobs {
                for (index, value) in zip(blob.vector.chunkedBlobs.indices, blob.vector.chunkedBlobs) {
                    let average = value.reduce(f3.zero, +) / Float(value.count)
                    push {
                        translate(average * $currentAnim.animationValue)
                        push {
                            rotateY(blob.rotations[index].y * $currentAnim.animationValue)
                            rotateX(blob.rotations[index].x * $currentAnim.animationValue)
                            rotateZ(blob.rotations[index].z * $currentAnim.animationValue)
                            translate(blob.translations[index] * $currentAnim.animationValue)
                            color(blob.colors[index])
                            var newValue = value.map{$0-average * $currentAnim.animationValue}
                            if isWireframe {
                                newValue = [newValue[0], newValue[1], newValue[2]]
                                let wid: Float = 0.03
                                boldline(newValue[0], newValue[1], width: wid)
                                boldline(newValue[1], newValue[2], width: wid)
                                boldline(newValue[2], newValue[0], width: wid)
                                boldline(newValue[0], newValue[0] + f3(0, 0, blob.vector.extrudingValue), width: wid)
                                boldline(newValue[1], newValue[1] + f3(0, 0, blob.vector.extrudingValue), width: wid)
                                boldline(newValue[2], newValue[2] + f3(0, 0, blob.vector.extrudingValue), width: wid)
                                boldline(newValue[0] + f3(0, 0, blob.vector.extrudingValue), newValue[1] + f3(0, 0, blob.vector.extrudingValue), width: wid)
                                boldline(newValue[1] + f3(0, 0, blob.vector.extrudingValue), newValue[2] + f3(0, 0, blob.vector.extrudingValue), width: wid)
                                boldline(newValue[2] + f3(0, 0, blob.vector.extrudingValue), newValue[0] + f3(0, 0, blob.vector.extrudingValue), width: wid)
                                
                            } else {
                                mesh(value.map{$0-average * $currentAnim.animationValue})
                                
                                //delete from here
//                                color(0.3, 0, 0.3, 1)
//                                newValue = [newValue[0], newValue[1], newValue[2]]
//                                let wid: Float = 0.03
//                                boldline(newValue[0], newValue[1], width: wid)
//                                boldline(newValue[1], newValue[2], width: wid)
//                                boldline(newValue[2], newValue[0], width: wid)
//                                boldline(newValue[0], newValue[0] + f3(0, 0, blob.vector.extrudingValue), width: wid)
//                                boldline(newValue[1], newValue[1] + f3(0, 0, blob.vector.extrudingValue), width: wid)
//                                boldline(newValue[2], newValue[2] + f3(0, 0, blob.vector.extrudingValue), width: wid)
//                                boldline(newValue[0] + f3(0, 0, blob.vector.extrudingValue), newValue[1] + f3(0, 0, blob.vector.extrudingValue), width: wid)
//                                boldline(newValue[1] + f3(0, 0, blob.vector.extrudingValue), newValue[2] + f3(0, 0, blob.vector.extrudingValue), width: wid)
//                                boldline(newValue[2] + f3(0, 0, blob.vector.extrudingValue), newValue[0] + f3(0, 0, blob.vector.extrudingValue), width: wid)
                                //
                            }
                        }
                    }
                }
                translate(spacing, 0, 0)
            }
        }
    }
    
    let bloomPP = BloomPP()
    override func postProcess(texture: MTLTexture, commandBuffer: MTLCommandBuffer) {
        bloomPP.postProcess(commandBuffer: commandBuffer, texture: texture, threshold: 0, intensity: 50)
    }
    
    override func keyDown(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect) {
        if event.keyCode == 124 {
            //rightArrow
            offset += 1
        }
        if event.keyCode == 123 {
            //leftArrow
            offset -= 1
        }
        guard let chars = event.characters else { return }
        guard let c = chars.first else { return }
        guard event.specialKey == nil else { return }
        if c == "a" {
            currentAnim = 1
        } else if c == "b" {
            currentAnim += 0.01
        } else if c == "w" {
            isWireframe.toggle()
        } else {
            currentAnim = 0
        }
    }
    override func mouseDown(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect) {
//        audioTest.printFFT()
    }
}
