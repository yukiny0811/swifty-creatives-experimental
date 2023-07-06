//
//  Sample7.swift
//  ExampleMacOSApp
//
//  Created by Yuki Kuwashima on 2023/02/02.
//

import AppKit
import SwiftyCreatives
import SCSound
import SwiftUI

final class FFTVisualizerSketch: Sketch {
    
    struct VIEW: View {
        @State var sketch = FFTVisualizerSketch()
        @State var bandsPerOctave: Float = 32
        @State var noiseExtractionThreshold: Double = 0.01
        @State var historyCount: Float = 5
        var body: some View {
            HStack {
                SketchView(sketch)
                VStack {
                    Slider(value: $noiseExtractionThreshold, in: 0.001...1) {
                        Text("noiseExtractionThreshold")
                    }
                    Menu {
                        Button("none") {
                            sketch.capturer.fftNoiseExtractionMethod = .none
                        }
                        Button("freqDomain") {
                            sketch.capturer.fftNoiseExtractionMethod = .freqDomain(noiseExtractionThreshold)
                        }
                        Button("timeDomain") {
                            sketch.capturer.fftNoiseExtractionMethod = .timeDomain(noiseExtractionThreshold)
                        }
                    } label: {
                        Text("fftNoiseExtractionMethod")
                    }
                    Menu {
                        Button("none") {
                            sketch.capturer.fftWindowType = .none
                        }
                        Button("hamming") {
                            sketch.capturer.fftWindowType = .hamming
                        }
                        Button("hanning") {
                            sketch.capturer.fftWindowType = .hanning
                        }
                    } label: {
                        Text("fftWindowType")
                    }
                    Slider(value: $historyCount, in: 1...30) {
                        Text("historyCount")
                    } onEditingChanged: { changed in
                        sketch.fftVisualizer.historyCount = Int(historyCount)
                    }
                }
                .frame(width: 300)
            }
        }
    }
    
    let capturer = FastAudioCapturer(captureDeviceFindWithName: "BlackHole")
    let fftVisualizer = FFTVisualizer()
    
    override init() {
        capturer.start()
    }
    
    override func update(camera: some MainCameraBase) {
        fftVisualizer.updateData(capturer)
    }
    
    override func draw(encoder: SCEncoder) {
        
        color(1, 0, 1, 0.75)
        box(max(0, fftVisualizer.averageMags[0]) * 0.05)
        
        color(1, 1, 0, 0.98)
        box(max(0, fftVisualizer.averageMags[35]) * 0.1)
        
        color(1)
        let width: Float = 50
        translate(-width/2, 0, 0)
        for m in fftVisualizer.averageMags {
            let boxWidth = width / Float(fftVisualizer.averageMags.count)
            box(boxWidth / 5, max(0, m * 0.1), 0.1)
            translate(boxWidth, 0, 0)
        }
    }
}
