//
//  Sample2.swift
//  ExampleMacOSApp
//
//  Created by Yuki Kuwashima on 2023/02/02.
//

import SwiftyCreatives
import AppKit
import CoreGraphics

final class Sample2: Sketch {
    let factory = VectorTextFactory()
    
    var currentText = "H"
    
    override init() {
        super.init()
        for c in TextFactory.Template.all {
            factory.cacheCharacter(char: c)
        }
        for _ in 0...1500 {
            stored += String(wordBank.randomElement()!) + " "
        }
    }
    
    var stored = "Hello, World. This is Swifty Creatives Framework. This is Sample2. Text Factory Test."
    
    let wordBank = "Hello, World. This is Swifty Creatives Framework. This is Sample2. Text Factory Test.".split(separator: " ")
    
    override func update(camera: some MainCameraBase) {
        currentText += String(stored.removeFirst())
    }
    
    override func draw(encoder: SCEncoder) {
        color(1)
        scale(0.03)
        translate(0, -250, 0)
        spiralWord(currentText, factory: factory)
    }
    
    func spiralWord(_ str: String, factory: VectorTextFactory, radius: Float = 400, translateHeight: Float = 0.015) {
        var spacerFactor: Float = 0
        let downMultiplier: Float = 1 / radius
        for c in str {
            if c == " " {
                rotateY(spacerFactor * downMultiplier)
            } else {
                char(c, factory: factory) { [self] offset in
                    rotateY(-offset.x * downMultiplier)
                    push {
                        translate(0, -offset.y, 0)
                    }
                    pushMatrix()
                    translate(0, 0, radius)
                } applySizeAfter: { [self] size in
                    popMatrix()
                    rotateY(-size.x * downMultiplier)
                    spacerFactor = -size.x
                }
            }
            translate(0, translateHeight, 0)
        }
    }
    
    override func keyDown(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect) {
        if let c = event.characters?.first, event.specialKey == nil {
            currentText += String(c)
        }
    }
}
