//
//  ExampleMacOSApp.swift
//  ExampleMacOSApp
//
//  Created by Yuki Kuwashima on 2022/12/15.
//

import SwiftUI
import SwiftyCreatives

@main
struct ExampleMacOSApp: App {
    let innerSketch = InnerSketch()
    var body: some Scene {
        WindowGroup {
            ZStack {
//                FFTVisualizerSketch.VIEW()
                FFTVisualizerSketch2D.VIEW()
//                TouchSampleSketch.VIEW()
//                TouchSampleSketch2D.VIEW()
            }
            .background(.black)
        }
    }
}
