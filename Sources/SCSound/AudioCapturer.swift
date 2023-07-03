//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/07/03.
//

import AVFoundation

public class AudioCapturer: NSObject, AVCaptureAudioDataOutputSampleBufferDelegate {
    
    let settings = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey : 1,
        AVSampleRateKey : 44100]
    let captureSession = AVCaptureSession()
    let captureQueue = DispatchQueue(label: "audioQueue")
    
    public var fftResult: [(frequency: Float, magnitude: Float)] = []
    
    public override init() {
        super.init()
        
        let captureDevice = AVCaptureDevice.default(.builtInMicrophone, for: .audio, position: .unspecified)!
        let audioInput = try! AVCaptureDeviceInput(device: captureDevice)
        let audioOutput = AVCaptureAudioDataOutput()
        audioOutput.setSampleBufferDelegate(self, queue: captureQueue)
        audioOutput.audioSettings = [
            AVFormatIDKey: kAudioFormatLinearPCM,
            AVLinearPCMIsFloatKey: true,
            AVLinearPCMBitDepthKey: 32,
            AVNumberOfChannelsKey: 1
        ]
        
        captureSession.beginConfiguration()
        captureSession.addInput(audioInput)
        captureSession.addOutput(audioOutput)
        captureSession.commitConfiguration()
        
        captureQueue.async {
            self.captureSession.startRunning()
        }
    }
    
    public func captureOutput(_ output: AVCaptureOutput,
                       didOutput sampleBuffer: CMSampleBuffer,
                       from connection: AVCaptureConnection) {
        
        guard connection.audioChannels.count > 0 else {
            print(#function, #line, "no audio channel")
            return
        }
        
        guard sampleBuffer.dataReadiness == .ready else {
            print(#function, #line, "sampleBuffer not ready")
            return
        }
        
        let numFrames = sampleBuffer.numSamples
//        print(#function, #line, "numFrames", numFrames)
        
        let pcmBuffer = try! sampleBuffer.withAudioBufferList { audioBufferList, blockBuffer -> AVAudioPCMBuffer? in
            guard let absd = sampleBuffer.formatDescription?.audioStreamBasicDescription else {
                print(#function, #line, "absd is nil")
                return nil
            }
            guard let format = AVAudioFormat(standardFormatWithSampleRate: absd.mSampleRate, channels: absd.mChannelsPerFrame) else {
                print(#function, #line, "format is nil")
                return nil
            }
            return AVAudioPCMBuffer(pcmFormat: format, bufferListNoCopy: audioBufferList.unsafePointer)
        }
        
        guard let pcmBuffer = pcmBuffer else {
            print(#function, #line, "pcmBuffer is nil")
            return
        }
        
//        print("pcmBuffer frameLength", pcmBuffer.frameLength)
//        print("pcmBuffer format sampleRate", pcmBuffer.format.sampleRate)
//        print("pcmBuffer format channelCount", pcmBuffer.format.channelCount)
//        print("pcmBuffer frameCapacity", pcmBuffer.frameCapacity)
        let floatArrayRaw = Array(UnsafeBufferPointer(start: pcmBuffer.floatChannelData?.pointee, count: Int(pcmBuffer.frameLength)))
        let floatArray = floatArrayRaw.map { f in
            var result: Float = 0
            if f < 0 || f.isNaN {
                result = 0
            } else {
                result = f
            }
            return result
        }
        
        let fft = TempiFFT(withSize: Int(pcmBuffer.frameLength), sampleRate: Float(pcmBuffer.format.sampleRate))

//        // Setting a window type reduces errors
        fft.windowType = TempiFFTWindowType.hanning

        // Perform the FFT
        fft.fftForward(floatArray)

        // Map FFT data to logical bands. This gives 4 bands per octave across 7 octaves = 28 bands.
        fft.calculateLogarithmicBands(minFrequency: 100, maxFrequency: 11025, bandsPerOctave: 16)
        
        // Process some data
        for i in 0..<fft.numberOfBands {
            let f = fft.frequencyAtBand(i)
            let m = fft.magnitudeAtBand(i)
            if fftResult.count-1 < i {
                fftResult.append((f, m))
            } else {
                fftResult[i] = (f, m)
            }
//            print(m)
//            if m > 0 {
//                print(m)
//            }
        }
    }
}
