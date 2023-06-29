//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/06/29.
//

import Foundation

// MARK: - View
#if os(macOS)
public typealias NSSketchView = KitSketchView
#elseif os(iOS)
public typealias UISketchView = KitSketchView
#endif
