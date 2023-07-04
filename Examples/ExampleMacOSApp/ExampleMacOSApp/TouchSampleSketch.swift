//
//  TouchSampleSketch.swift
//  ExampleMacOSApp
//
//  Created by Yuki Kuwashima on 2023/07/04.
//

import SwiftyCreatives
import AppKit
import CoreGraphics
import SwiftUI

class TouchSampleSketch: Sketch {
    
    var boxPos: f3 = .zero
    
    struct VIEW: View {
        var body: some View {
            SketchView(TouchSampleSketch())
        }
    }
    
    override func draw(encoder: SCEncoder) {
        
        color(0.1)
        rect(100, 100)
        
        color(1)
        box(boxPos, f3.one)
    }
    
    override func mouseMoved(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect) {
        let location = mousePos(event: event, viewFrame: viewFrame)
        let ray = camera.screenToWorldDirection(x: location.x, y: location.y, width: Float(viewFrame.width), height: Float(viewFrame.height))
        
        let rayLength: Float = 1000
        let origin = ray.origin
        let far = ray.origin + ray.direction * rayLength
        
        if origin.z.sign == far.z.sign { return }
        
        let ratio: Float = origin.z / (abs(origin.z) + abs(far.z))
        let interceptingFar = ray.origin + ray.direction * rayLength * ratio
        boxPos = interceptingFar
    }
}
