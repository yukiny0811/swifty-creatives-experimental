//
//  TouchSampleSketch2D.swift
//  ExampleMacOSApp
//
//  Created by Yuki Kuwashima on 2023/07/04.
//

import SwiftyCreatives
import AppKit
import CoreGraphics
import SwiftUI

class TouchSampleSketch2D: Sketch {
    
    var boxPos: f3 = .zero
    
    struct VIEW: View {
        var body: some View {
            ConfigurableSketchView<DefaultOrthoConfig, MainDrawConfig>(TouchSampleSketch2D())
        }
    }
    
    override func setupCamera(camera: some MainCameraBase) {
        camera.setTranslate(0, 0, -100)
    }
    
    override func draw(encoder: SCEncoder) {
        
        color(0.1)
        rect(1000, 1000)
        
        color(1)
        box(boxPos, f3.one * 5)
    }
    
    override func mouseMoved(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect) {
        let mPos = mousePos(event: event, viewFrame: viewFrame, isPerspective: false)
        boxPos = f3(mPos.x, mPos.y, 0)
    }
}
