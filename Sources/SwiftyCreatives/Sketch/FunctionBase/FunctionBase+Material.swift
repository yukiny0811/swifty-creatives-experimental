//
//  File.swift
//  
//
//  Created by Yuki Kuwashima on 2023/06/30.
//

import Foundation

public extension FunctionBase {
    func material(_ v: Material) {
        privateEncoder?.setFragmentBytes([v], length: Material.memorySize, index: FragmentBufferIndex.Material.rawValue)
    }
}
