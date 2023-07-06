//
//  FFTVisTemplate.swift
//  ExampleMacOSApp
//
//  Created by Yuki Kuwashima on 2023/07/05.
//

import AppKit
import SwiftyCreatives
import SCSound
import SwiftUI

final class FFTVisTemplate: Sketch {
    
    struct VIEW: View {
        typealias SketchViewTemplate = ConfigurableSketchView<DefaultOrthoConfig, MainDrawConfig>
        let bandCount = 256
        var body: some View {
            HStack {
                VStack {
                    SketchViewTemplate(FFTVisTemplate(
                        fftMaxFreq: 1000000,
                        bandCalculationMethod: .linear(bandCount),
                        historyCount: 10
                    ))
                    SketchViewTemplate(FFTVisTemplate(
                        heightSize: 5,
                        fftMinFreq: 1,
                        fftMaxFreq: 1000000,
                        bandCalculationMethod: .logarithmic(24),
                        baseUpOffset: 40
                    ))
                }
            }
        }
    }
    
    let capturer = AudioCapturer(captureDeviceFindWithName: "BlackHole")
    let fftVisualizer = FFTVisualizer()
    let width: Float
    let heightSize: Float
    
    init(
        width: Float = 4000,
        heightSize: Float = 10,
        fftWindowType: TempiFFTWindowType = .hamming,
        fftMinFreq: Float = 8,
        fftMaxFreq: Float = 22000,
        bandCalculationMethod: FFTBandCalculationMethod,
        historyCount: Int = 10,
        baseUpOffset: Float = 50
    ) {
        capturer.fftWindowType = fftWindowType
        capturer.fftMinFreq = fftMinFreq
        capturer.fftMaxFreq = fftMaxFreq
        capturer.bandCalculationMethod = bandCalculationMethod
        capturer.start()
        
        fftVisualizer.historyCount = historyCount
        fftVisualizer.baseUpOffset = baseUpOffset
        
        self.width = width
        self.heightSize = heightSize
        
        super.init()
    }
    
    override func update(camera: some MainCameraBase) {
        fftVisualizer.updateData(capturer)
        if Float.random(in: 0...100) < 1 {
            print(frameRate)
        }
    }
    
    override func draw(encoder: SCEncoder) {
        color(1)
        push {
            translate(-width/2, 0, 0)
            for m in fftVisualizer.averageMags {
                let boxWidth = width / Float(fftVisualizer.averageMags.count)
                rect(f3(
                    max(boxWidth / 5, 0.5),
                    max(0, m) * heightSize,
                    1)
                )
                translate(boxWidth, 0, 0)
            }
        }
    }
}
