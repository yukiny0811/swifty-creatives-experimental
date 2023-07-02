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
//                VStack {
//                    HStack {
//                        SketchView(Sample1())
//                        SketchView(Sample2())
//                    }
//                    HStack {
//                        SketchView(Sample3())
//                SketchView(innerSketch).opacity(0)
//                SketchView(Sample4(inner: innerSketch))
//                    }
//                }
//                VStack {
//                    HStack {
                SketchView(Sample5())
//                        SketchView(Sample6())
//                    }
//                    HStack {
//                        SketchView(Sample7())
//                        SketchView(Sample8())
//                    }
//                }
//                VStack {
//                    HStack {
//                        ConfigurableSketchView<MainCameraConfig, Sample9DrawConfig>(Sample9())
//                        SketchView(Sample10())
//                    }
//                    HStack {
//                        SketchView(Sample11())
//                        SketchView(Sample12())
//                    }
//                }
            }
            .background {
                       ZStack {
                           RadialGradient(
                            colors: [.blue.opacity(0.2), .clear],
                               center: .bottomLeading,
                               startRadius: 1,
                               endRadius: 1000
                           )

                           RadialGradient(
                            colors: [.pink.opacity(0.2), .clear],
                               center: .bottomTrailing, startRadius: 1,
                               endRadius: 1000
                           )
                       }
                   }
            .background(.black)
        }
    }
}
