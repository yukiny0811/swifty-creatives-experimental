//
//  FFTVisualizerSketch2D.swift
//  ExampleMacOSApp
//
//  Created by Yuki Kuwashima on 2023/07/04.
//

import AppKit
import SwiftyCreatives
import SCSound
import SwiftUI

final class FFTVisualizerSketch2D: Sketch {
    
    struct VIEW: View {
        let sketch = FFTVisualizerSketch2D()
        var body: some View {
            HStack {
                ConfigurableSketchView<DefaultOrthoConfig, MainDrawConfig>(sketch)
            }
        }
    }
    
    let capturer = AudioCapturer(captureDeviceFindWithName: "BlackHole")
    let fftVisualizer = FFTVisualizer()
    
    override init() {
        capturer.start()
        fftVisualizer.historyCount = 20
    }
    
    override func update(camera: some MainCameraBase) {
        fftVisualizer.updateData(capturer)
    }
    
    override func draw(encoder: SCEncoder) {
        
        color(1)
        let width: Float = 3500
        translate(-width/2, 0, 0)
        for m in fftVisualizer.averageMags {
            let boxWidth = width / Float(fftVisualizer.averageMags.count)
            box(boxWidth / 5, max(0, m) * 30, 0.1)
            translate(boxWidth, 0, 0)
        }
    }
}
