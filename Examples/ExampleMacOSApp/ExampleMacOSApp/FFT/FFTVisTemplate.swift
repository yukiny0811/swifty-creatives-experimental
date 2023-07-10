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
import simd

final class FFTVisTemplate: Sketch {
    
    struct VIEW: View {
        typealias SketchViewTemplate = ConfigurableSketchView<DefaultOrthoConfig, MainDrawConfig>
        let bandCount = 64
        let bandsPerOctave = 12
        var body: some View {
            HStack {
                VStack {
                    SketchViewTemplate(FFTVisTemplate(
                        capturer: FastAudioCapturer(captureDeviceFindWithName: "BlackHole"),
                        fftMaxFreq: 1000000,
                        bandCalculationMethod: .linear(bandCount),
                        historyCount: 10
                    ))
                    SketchViewTemplate(FFTVisTemplate(
                        capturer: FastAudioCapturer(captureDeviceFindWithName: "BlackHole"),
                        heightSize: 20,
                        fftMinFreq: 1,
                        fftMaxFreq: 1000000,
                        bandCalculationMethod: .logarithmic(bandsPerOctave),
                        historyCount: 12,
                        baseUpOffset: 20
                    ))
                }
            }
        }
    }
    
    var capturer: AudioCapturer
    let fftVisualizer = FFTVisualizer()
    let width: Float
    let heightSize: Float
    
    init(
        capturer: AudioCapturer,
        width: Float = 4000,
        heightSize: Float = 10,
        fftWindowType: TempiFFTWindowType = .hamming,
        fftMinFreq: Float = 8,
        fftMaxFreq: Float = 22000,
        bandCalculationMethod: FFTBandCalculationMethod,
        historyCount: Int = 10,
        baseUpOffset: Float = 50
    ) {
        self.capturer = capturer
        self.capturer.fftWindowType = fftWindowType
        self.capturer.fftMinFreq = fftMinFreq
        self.capturer.fftMaxFreq = fftMaxFreq
        self.capturer.bandCalculationMethod = bandCalculationMethod
        self.capturer.start()
        
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
        $flashIntensity.update(multiplier: 0.1)
        flashIntensity = 0
    }
    
    override func draw(encoder: SCEncoder) {
        
        color($flashIntensity.animationValue, 0.8)
        rect(metalDrawableSize.x, metalDrawableSize.y)
        
        color(1, 0, 0, 1)
        rect(boxPos, 1)
        
        let boxWidth = width / Float(fftVisualizer.averageMags.count)
        color(0, 1, 0, 1)
        boldline(-metalDrawableSize.x, boxPos.y, 0, metalDrawableSize.x, boxPos.y, 0, width: 2)
        color(0, 1, 0, 0.3)
        rect(Float(Int(boxPos.x / boxWidth)) * boxWidth, boxPos.y, 0, boxWidth/2, 10000)
        
        color(1)
        push {
            translate(-width/2, 0, 0)
            for m in fftVisualizer.averageMags {
                let xSize = max(boxWidth / 5, 0.5)
                let height = max(0, m) * heightSize
                
                let thresholdPosf4 = getCustomMatrix() * f4(0, 0, 0, 1)
                let thresholdPos = f2(thresholdPosf4.x, height)
                if thresholdPos.x - boxWidth/2 < boxPos.x && boxPos.x < thresholdPos.x + boxWidth/2 && thresholdPos.y > abs(boxPos.y) {
                    $flashIntensity.directSet(1)
                }
                rect(f3(
                    xSize,
                    height,
                    1)
                )
                translate(boxWidth, 0, 0)
            }
        }
    }
    
    var boxPos: f3 = .zero
    @SCAnimatable var flashIntensity: Float = 0
    override func mouseMoved(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect) {
        let mPos = mousePos(event: event, viewFrame: viewFrame, isPerspective: false)
        boxPos = f3(mPos.x, mPos.y, 0)
    }
}
