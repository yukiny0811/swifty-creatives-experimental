//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/06/29.
//

import Foundation
import SCSound

import SwiftUI

@_exported import SimpleSimdSwift

#if os(macOS)
public typealias ViewRepresentable = NSViewRepresentable
#elseif os(iOS)
public typealias ViewRepresentable = UIViewRepresentable
#endif

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

// MARK: - Metal
import Metal
public typealias SCEncoder = MTLRenderCommandEncoder
public typealias SCCommandBuffer = MTLCommandBuffer

// MARK: - Font
#if os(macOS)
public typealias FontAlias = NSFont
#elseif os(iOS) || os(visionOS)
public typealias FontAlias = UIFont
#endif

// MARK: - Color
#if os(macOS)
public typealias ColorAlias = NSColor
#elseif os(iOS) || os(visionOS)
public typealias ColorAlias = UIColor
#endif
