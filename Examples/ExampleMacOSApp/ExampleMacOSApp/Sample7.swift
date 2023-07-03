//
//  Sample7.swift
//  ExampleMacOSApp
//
//  Created by Yuki Kuwashima on 2023/02/02.
//

import AppKit
import SwiftyCreatives
import SCSound

final class Sample7: Sketch {
    
    let capturer = AudioCapturer()
    
    override func draw(encoder: SCEncoder) {
        color(1)
        
        let mags = capturer.fftResult.map {
            var db = TempiFFT.toDB($0.magnitude)
            if db.isNaN {
                db = 0
            }
            return db
        }
        
        let width: Float = 50
        
        translate(-width/2, 0, 0)
        
        for m in mags {
            let boxWidth = width / Float(mags.count)
            box(boxWidth / 5, m * 0.1, 0.1)
            translate(boxWidth, 0, 0)
        }
    }
//
//    var colors: [f4] = []
//    var scales: [f3] = []
//    var elapsed: Float = 0.0
//    var text = TextObject()
//    
//    override init() {
//        for _ in 0...8 {
//            colors.append(f4.randomPoint(0...1))
//            scales.append(f3.one * Float.random(in: 0.1...0.5))
//        }
//        text
//            .setText("Loading...", font: NSFont.systemFont(ofSize: 120))
//            .multiplyScale(5)
//        
//    }
//    override func update(camera: some MainCameraBase) {
//        camera.rotateAroundY(0.03)
//        elapsed += 0.01
//    }
//    
//    override func draw(encoder: SCEncoder) {
//        for i in 0..<8 {
//            let elapsedSin = sin(elapsed * Float(i+1))
//            let elapsedCos = cos(elapsed * Float(i+1))
//            color(elapsedSin, colors[i].y, colors[i].z)
//            pushMatrix()
//            translate(elapsedCos * 5, elapsedSin * 5, 0)
//            box(scales[i])
//            popMatrix()
//        }
//        text(text)
//    }
}
