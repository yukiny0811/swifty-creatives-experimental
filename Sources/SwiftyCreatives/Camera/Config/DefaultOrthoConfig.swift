//
//  DefaultOrthoConfig.swift
//  
//
//  Created by Yuki Kuwashima on 2023/01/30.
//

/// Default camera config for orthographic projection.
public class DefaultOrthoConfig: CameraConfigBase {
    public static let fov: Float = 85
    public static let near: Float = -1000
    public static let far: Float = 1000
    public static let easyCameraType: EasyCameraType = .manual
    public static let isPerspective: Bool = false
}
