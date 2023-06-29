//
//  Sample5.swift
//  ExampleMacOSApp
//
//  Created by Yuki Kuwashima on 2023/02/02.
//

import AppKit
import SwiftyCreatives

final class Sample5: Sketch {
    let vectorWord3D = VectorWord3D(text: "Hello")
    override func update(camera: some MainCameraBase) {
        vectorWord3D.extrude(0.01)
    }
    override func draw(encoder: SCEncoder) {
        color(1)
        polytext(vectorWord3D)
    }
}
