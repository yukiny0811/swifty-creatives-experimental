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
    
    let textFactory = VectorTextFactory()
    
//    let capturer = AudioCapturer(captureDeviceFindWithName: "BlackHole")
//    let capturer2 = AudioCapturer(captureDeviceFindWithName: "BlackHole")
    let capturer = AudioCapturer()
    let capturer2 = AudioCapturer()
    let fftVisualizer = FFTVisualizer()
    let fftVisualizer2 = FFTVisualizer()
    
    override init() {
        
        for c in TextFactory.Template.all {
            textFactory.cacheCharacter(char: c)
        }
        
        capturer.fftWindowType = .hamming
        capturer.fftMinFreq = 8
        capturer.fftMaxFreq = 30000
        capturer.bandCalculationMethod = .linear(512)
        capturer.fftNoiseExtractionMethod = .none
        capturer.start()
        
        capturer2.fftWindowType = .hamming
        capturer2.fftMinFreq = 8
        capturer2.fftMaxFreq = 30000
        capturer2.bandCalculationMethod = .logarithmic(32)
        capturer2.fftNoiseExtractionMethod = .none
        capturer2.start()
        
        fftVisualizer.historyCount = 12
        fftVisualizer.baseUpOffset = 40
        
        fftVisualizer2.historyCount = 12
        fftVisualizer2.baseUpOffset = 40
    }
    
    override func update(camera: some MainCameraBase) {
        fftVisualizer.updateData(capturer)
        fftVisualizer2.updateData(capturer2)
    }
    
    override func draw(encoder: SCEncoder) {
        
        color(1)
        push {
            translate(1000, 1000, 0)
            scale(10)
            word(String(Int(frameRate)), factory: textFactory)
        }
        
        translate(0, 300, 0)
        
        color(1)
        push {
            let width: Float = 3500
            translate(-width/2, 0, 0)
            for m in fftVisualizer.averageMags {
                let boxWidth = width / Float(fftVisualizer.averageMags.count)
                rect(f3(boxWidth / 5, max(0, m) * 10, 0.1))
                translate(boxWidth, 0, 0)
            }
        }
        
        translate(0, -600, 0)
        
        color(1, 0, 1, 1)
        push {
            let width: Float = 3500
            translate(-width/2, 0, 0)
            
            for m in fftVisualizer2.averageMags {
                let boxWidth = width / Float(fftVisualizer2.averageMags.count)
                rect(f3(boxWidth / 5, max(0, m) * 10, 0.1))
                translate(boxWidth, 0, 0)
            }
        }
        
    }
}
