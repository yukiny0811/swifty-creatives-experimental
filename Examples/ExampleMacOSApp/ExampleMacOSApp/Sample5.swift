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
    init(_ w: String) {
        self.vector = VectorWord3DDetailed(text: w, fontName: "HiraginoSans-W6")
        for _ in self.vector.chunkedBlobs {
            colors.append(f4(0.8, 0.6 + Float.random(in: 0...0.2), 0.6 + Float.random(in: 0...0.2), 0.9))
            translations.append(f3.randomPoint(-3...3))
            rotations.append(f3.randomPoint(-3...3))
        }
        self.vector.extrude(1)
    }
}

final class Sample5: Sketch {
    
    @SCAnimatable var currentAnim = 0
    var blobs: [MyWordBlob] = []
    var offset: Float = 0
    
    override init() {
        super.init()
        blobs.append(.init("開"))
        blobs.append(.init("発"))
        
    }
    override func update(camera: some MainCameraBase) {
        $currentAnim.update(multiplier: 0.05)
        camera.rotateAroundY(0.001)
    }
    override func draw(encoder: SCEncoder) {
        let spacing: Float = 10
        scale(3)
        translate(offset, 0, 0)
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
                        mesh(value.map{$0-average * $currentAnim.animationValue})
                    }
                }
            }
            translate(spacing, 0, 0)
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
        } else {
            currentAnim = 0
        }
    }
}
