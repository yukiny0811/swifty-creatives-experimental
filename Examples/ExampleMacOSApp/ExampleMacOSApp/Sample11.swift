//
//  Sample11.swift
//  ExampleMacOSApp
//
//  Created by Yuki Kuwashima on 2023/02/19.
//

import SwiftyCreatives
import CoreGraphics
import AppKit

final class Sample11: Sketch {
    
    let box = HitTestableBox().setScale(f3(2, 3, 4))
    var boxColor: f4 = .one
    var testBoxPos: f3 = .zero
    
    override func setupCamera(camera: some MainCameraBase) {
        camera.setTranslate(0, 0, -20)
    }
    
    override func draw(encoder: SCEncoder) {
        color(1, 0, 0, 1)
        box(testBoxPos, f3.one * 0.1)
        translate(0, 3, 0)
        color(boxColor)
        drawHitTestableBox(box: box)
    }
    
    override func mouseMoved(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect) {
        let location = mousePos(event: event, viewFrame: viewFrame)
        let ray = camera.screenToWorldDirection(x: Float(location.x), y: Float(location.y), width: Float(viewFrame.width), height: Float(viewFrame.height))
        if let hitPos = box.hitTest(origin: ray.origin, direction: ray.direction) {
            boxColor = f4(0, 1, 0, 1)
            testBoxPos = hitPos
        } else {
            boxColor = .one
        }
    }
}
