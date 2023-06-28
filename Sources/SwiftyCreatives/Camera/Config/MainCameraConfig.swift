//
//  MainCameraConfig.swift
//  
//
//  Created by Yuki Kuwashima on 2022/12/09.
//

/// Default camera config for perspective projection.
public class MainCameraConfig: CameraConfigBase {
    public static let fov: Float = 85
    public static let near: Float = 0.01
    public static let far: Float = 1000.0
    public static let easyCameraType: EasyCameraType = .easy(polarSpacing: 0.03)
    public static let isPerspective: Bool = true
}
