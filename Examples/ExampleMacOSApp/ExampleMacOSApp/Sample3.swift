//
//  Sample3.swift
//  ExampleMacOSApp
//
//  Created by Yuki Kuwashima on 2023/02/02.
//

import SwiftyCreatives
import Collections
import Algorithms
import AppKit
import CoreGraphics

final class Sample3: Sketch {
    let factory = VectorTextFactoryRaw()
    
    typealias Vertex = [f3]
    let chunked_a: [Vertex]
    let colors_a: [f4]
    let offset_a: [Float]
    
    @SCAnimatable var currentOffset = 0
    
    override init() {
        for c in TextFactory.Template.all + "桑" {
            factory.cacheCharacter(char: c)
        }
        
        chunked_a = factory.cached["桑"]!.vertices.chunks(ofCount: 3).map{$0.map{$0}}
        colors_a = chunked_a.map{ _ in f4(1, 0.8, 1, 1) }
        offset_a = chunked_a.map{ _ in Float.random(in: 0.01...3) }
        
        super.init()
    }
    
    override func update(camera: some MainCameraBase) {
        $currentOffset.update(multiplier: 0.05)
    }
    
    override func draw(encoder: SCEncoder) {
        for i in 0..<chunked_a.count {
            color(
                colors_a[i] - offset_a[i] * $currentOffset.animationValue * 0.3
            )
            mesh(
                chunked_a[i].map{
                    f3(
                        $0.x,
                        $0.y,
                        $0.z + offset_a[i] * $currentOffset.animationValue
                    )
                }
            )
        }
    }
    
    override func keyDown(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect) {
        if event.characters!.contains("a") {
            currentOffset = 1
        } else {
            currentOffset = 0
        }
    }
    
    override func postProcess(texture: MTLTexture, commandBuffer: MTLCommandBuffer) {
        <#code#>
    }
}
