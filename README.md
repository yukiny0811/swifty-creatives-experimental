# SwiftyCreatives

[![Release](https://img.shields.io/github/v/release/yukiny0811/swifty-creatives-experimental)](https://github.com/yukiny0811/swifty-creatives-experimental/releases/latest)
[![Swift Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fyukiny0811%2Fswifty-creatives-experimental%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/yukiny0811/swifty-creatives-experimental)
[![Platform Compatibility](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fyukiny0811%2Fswifty-creatives-experimental%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/yukiny0811/swifty-creatives-experimental)
[![License](https://img.shields.io/github/license/yukiny0811/swifty-creatives-experimental)](https://github.com/yukiny0811/swifty-creatives-experimental/blob/main/LICENSE)

__Creative coding framework for Swift.__   
Using Metal directly for rendering.

![ExampleMacOSApp 2022年-12月-16日 18 08 41](https://user-images.githubusercontent.com/28947703/208063423-3ad00c20-1d1c-48b8-8996-2d43e1365fe4.gif)

## Features
|Geometry|Other Features|
|-|-|
|Rectangle (with hit test)|Perspective Camera|
|Circle|Orthographic Camera|
|Triangle|BlendMode(normal, add, alphaBlend)|
|Line|Lighting|
|Box (with hit test)|push/pop matrix|
|3D Model|can be used as UIView / NSView|
|Image (with hit test)|can be used as SwiftUI View|
|Text|Post Processing|
|UIViewObject (3d view with interactive button)|User-defined shaders|


![ExampleMacOSApp 2023年-02月-24日 17 11 06](https://user-images.githubusercontent.com/28947703/221126530-c362018e-325c-4747-8e57-c5e18ab7085d.gif)

![CheckMacOS 2023年-03月-01日 6 46 57](https://user-images.githubusercontent.com/28947703/221993495-7840a9e0-4de7-4c6c-8fef-ef3b9f53677f.gif)

![QuickTime Player - 画面収録 2023-02-10 1 53 14 mov 2023年-02月-10日 2 55 14](https://user-images.githubusercontent.com/28947703/217897685-7a83bedf-5624-45e2-b566-9a05aab7c103.gif)


## Sample Code

### Main sketch process
```SampleSketch.swift
import SwiftyCreatives

final class SampleSketch: Sketch {
    override func draw(encoder: SCEncoder) {
        let count = 20
        for i in 0...count {
            color(1, Float(i) / 20, 0, 1)
            pushMatrix()
            rotateY(Float.pi * 2 / Float(count) * Float(i))
            translate(10, 0, 0)
            box(1, 1, 1)
            popMatrix()
        }
    }
}
```

### You can use SketchView as SwiftUI View
```View.swift
ZStack {
    SketchView(SampleSketch())
}
.background(.black)
```

<img width="863" alt="スクリーンショット 2023-02-03 7 51 34" src="https://user-images.githubusercontent.com/28947703/216469226-3f32ccee-c045-48c3-8fc0-0044ef7da891.png">

## Other Examples
- https://github.com/yukiny0811/sc-treeart
- https://github.com/yukiny0811/sc-stable-fluids
