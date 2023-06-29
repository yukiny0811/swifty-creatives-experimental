//
//  FunctionBase+Fog.swift
//  
//
//  Created by Yuki Kuwashima on 2023/03/08.
//

import simd
import CommonEntity

public extension FunctionBase {
    func setFog(color: f4, density: Float) {
        privateEncoder?.setFragmentBytes([density], length: Float.memorySize, index: FragmentBufferIndex.FogDensity.rawValue)
        privateEncoder?.setFragmentBytes([color], length: f4.memorySize, index: FragmentBufferIndex.FogColor.rawValue)
    }
}
