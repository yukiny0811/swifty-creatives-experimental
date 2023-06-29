//
//  Sample4.swift
//  ExampleMacOSApp
//
//  Created by Yuki Kuwashima on 2023/02/02.
//

import SwiftyCreatives
import AppKit
import MetalKit

struct Uni {
    var pos: f3
    var color: f4
}

final class InnerSketch: Sketch {
    var cached: MTLTexture?
    let vectorWord = VectorWord(text: "Hello,World!")
    var unis: [Uni] = []
    
    override init() {
        super.init()
        for y in -10...10 {
            for z in -10...10 {
                for x in -3...3 {
                    unis.append(Uni(pos: f3(Float(x) * 50, Float(y)*20, Float(z)*20), color: f4(1, Float.random(in: 0...1), Float.random(in: 0...1), 1)))
                }
            }
        }
    }
    override func update(camera: some MainCameraBase) {
        camera.rotateAroundY(0.001)
        camera.rotateAroundX(0.00111)
        camera.rotateAroundZ(0.00099)
    }
    override func draw(encoder: SCEncoder) {
        color(1)
        scale(0.1)
        for u in unis {
            push {
                translate(u.pos)
                color(u.color)
                polytext(vectorWord)
            }
        }
    }
    override func postProcess(texture: MTLTexture, commandBuffer: MTLCommandBuffer) {
        cached = texture
    }
}

final class Sample4: Sketch {
    
    let inner: InnerSketch
    
    let modelObj = ModelObject().loadModel(name: "sphere", extensionName: "obj")
    
    init(inner: InnerSketch) {
        self.inner = inner
        super.init()
    }
    override func draw(encoder: SCEncoder) {
        color(1)
        if let cached = inner.cached {
            modelObj.setTexture(cached)
            modelObj.draw(encoder)
        }
    }
}
