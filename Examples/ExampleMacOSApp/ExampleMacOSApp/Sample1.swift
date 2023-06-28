//
//  Sample1.swift
//  ExampleMacOSApp
//
//  Created by Yuki Kuwashima on 2023/02/02.
//

import SwiftyCreatives
import Metal
import AppKit
import CoreGraphics

class MyText: MyTextGeometry {
    var rotationValue: Float = Float.random(in: 0...10)
    var height: Float = Float.random(in: -30...30)
    var rad: Float = Float.random(in: 1...30)
    var rotationSpeed = Float.random(in: -0.01...0.01)
}

final class Sample1: Sketch {
    var texts: [MyText?] = []
    let count = 1000
    override init() {
        super.init()
        for _ in 0..<count {
            texts.append(nil)
        }
        Task {
            await withTaskGroup(of: Void.self) { group in
                for i in 0..<count {
                    group.addTask { [self] in
                        texts[i] = MyText(text: String("こんにちはabcde"),fontName: "AppleSDGothicNeo-Bold", fontSize: 1, isClockwiseCont: true)
                        print(i)
                    }
                }
            }
            start = true
        }
    }
    
    var start: Bool = false
    override func draw(encoder: SCEncoder) {
        if start == false { return }
        color(1, 1, 1, 0.8)
        for t in texts {
            t!.rotationValue += t!.rotationSpeed
            push {
                rotateY(t!.rotationValue)
                translate(0, t!.height, t!.rad)
                polytext(t!)
            }
        }
    }
}
