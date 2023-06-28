//
//  SketchSample2.swift
//  ExampleiOSApp
//
//  Created by Yuki Kuwashima on 2022/12/27.
//

import SwiftyCreatives
import UIKit

class RotatingViewObject: UIViewObject {
    @SCAnimatable var rotation: Float = 0
}

final class SketchSample2: Sketch {
    
    let postProcessor = CornerRadiusPP().radius(100)
    var viewObj = RotatingViewObject()
    
    override init() {
        super.init()
        let view: TestView = TestView.fromNib(type: TestView.self)
        view.onHit = {
            self.viewObj.rotation += Float.pi / 2
        }
        viewObj.load(view: view)
        viewObj.multiplyScale(6)
    }
    
    override func update(camera: some MainCameraBase) {
        viewObj.$rotation.update(multiplier: deltaTime * 5)
    }
    
    override func draw(encoder: SCEncoder) {
        rotateZ(viewObj.$rotation.animationValue)
        viewObj.drawWithCache(encoder: encoder, customMatrix: getCustomMatrix())
    }
    
    override func postProcess(texture: MTLTexture, commandBuffer: MTLCommandBuffer) {
        postProcessor.postProcess(commandBuffer: commandBuffer, texture: viewObj.texture!)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, camera: some MainCameraBase, view: UIView) {
        let touch = touches.first!
        let location = touch.location(in: view)
        let processed = camera.screenToWorldDirection(x: Float(location.x), y: Float(location.y), width: Float(view.frame.width), height: Float(view.frame.height))
        let origin = processed.origin
        let direction = processed.direction
        viewObj.buttonTest(origin: origin, direction: direction)
    }
}

class TestView: UIView {
    
    var onHit: (() -> Void)?
    
    @IBAction func onButtonTap() {
        if let onHit = onHit {
            onHit()
        }
    }
}
