//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/06/29.
//

import Foundation
import SCSound

// MARK: - View
#if os(macOS)
public typealias NSSketchView = KitSketchView
#elseif os(iOS)
public typealias UISketchView = KitSketchView
#endif

#if os(macOS)
public typealias FastAudioCapturer = SCSound.FastAudioCapturer
public typealias DetailedAudioCapturer = SCSound.DetailedAudioCapturer
#endif
