//
//  ShaderCore.swift
//  
//
//  Created by Yuki Kuwashima on 2022/12/08.
//

import MetalKit

public enum ShaderCore {
    public static let device: MTLDevice = MTLCreateSystemDefaultDevice()!
    public static let library: MTLLibrary = try! ShaderCore.device.makeDefaultLibrary(bundle: Bundle.module)
    public static let mainLibrary: MTLLibrary? = try? ShaderCore.device.makeDefaultLibrary(bundle: Bundle.main)
    public static let commandQueue: MTLCommandQueue = ShaderCore.device.makeCommandQueue()!
    public static let context: CIContext = CIContext(mtlCommandQueue: commandQueue)
    public static let textureLoader: MTKTextureLoader = MTKTextureLoader(device: ShaderCore.device)
    public static let defaultTextureLoaderOptions: [MTKTextureLoader.Option: Any] = [
        .textureUsage: NSNumber(
            value: MTLTextureUsage.shaderRead.rawValue |
            MTLTextureUsage.shaderWrite.rawValue |
            MTLTextureUsage.renderTarget.rawValue
        )
    ]
}
