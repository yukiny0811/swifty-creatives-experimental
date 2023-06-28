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
    
    var currentText = "a"
    
    override init() {
        super.init()
        for c in TextFactory.Template.all {
            factory.cacheCharacter(char: c)
        }
    }
    
    override func draw(encoder: SCEncoder) {
        color(1)
        word(currentText, factory: factory)
    }
    
    override func keyDown(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect) {
        if let c = event.characters?.first, event.specialKey == nil {
            currentText += String(c)
        }
    }
}
