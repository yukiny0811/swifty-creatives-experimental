//
//  File.swift
//
//
//  Created by Yuki Kuwashima on 2024/01/18.
//

#if os(visionOS)

import MetalKit
import CommonEntity
import Spatial
import CompositorServices

public class TransparentRendererVision: RendererBase {
    
    let arSession: ARKitSession
    let worldTracking: WorldTrackingProvider
    let layerRenderer: LayerRenderer
    
    var pipelineState: MTLRenderPipelineState
    var depthState: MTLDepthStencilState
    var clearTileState: MTLRenderPipelineState
    var resolveState: MTLRenderPipelineState
    var vertexDescriptor: MTLVertexDescriptor
    
    let optimalTileSize = MTLSize(width: 32, height: 16, depth: 1)
    
    public init(sketch: SketchBase, layerRenderer: LayerRenderer) {
        self.layerRenderer = layerRenderer
        worldTracking = WorldTrackingProvider()
        arSession = ARKitSession()
        
        let constantValue = MTLFunctionConstantValues()
        let transparencyMethodFragmentFunction = try! ShaderCore.library.makeFunction(name: "OITFragmentFunction_4Layer", constantValues: constantValue)
        let vertexFunction = ShaderCore.library.makeFunction(name: "vertexTransform")
        let resolveFunction = try! ShaderCore.library.makeFunction(name: "OITResolve_4Layer", constantValues: constantValue)
        let clearFunction = try! ShaderCore.library.makeFunction(name: "OITClear_4Layer", constantValues: constantValue)
        
        // MARK: - vertexDescriptor
        vertexDescriptor = Self.createVertexDescriptor()
        
        // MARK: - render pipeline descriptor
        let pipelineStateDescriptor = MTLRenderPipelineDescriptor()
        pipelineStateDescriptor.vertexDescriptor = vertexDescriptor
        pipelineStateDescriptor.vertexFunction = vertexFunction
        pipelineStateDescriptor.rasterSampleCount = 1
        pipelineStateDescriptor.depthAttachmentPixelFormat = .depth32Float
        pipelineStateDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm_srgb
        pipelineStateDescriptor.colorAttachments[0].isBlendingEnabled = false
        pipelineStateDescriptor.fragmentFunction = transparencyMethodFragmentFunction
        pipelineState = try! ShaderCore.device.makeRenderPipelineState(descriptor: pipelineStateDescriptor)
        
        // MARK: - Tile descriptor
        let tileDesc = MTLTileRenderPipelineDescriptor()
        tileDesc.tileFunction = resolveFunction
        tileDesc.colorAttachments[0].pixelFormat = .bgra8Unorm
        tileDesc.threadgroupSizeMatchesTileSize = true
        resolveState = try! ShaderCore.device.makeRenderPipelineState(tileDescriptor: tileDesc, options: .argumentInfo, reflection: nil) // FIXME: argumentinfo?
        
        tileDesc.tileFunction = clearFunction
        clearTileState = try! ShaderCore.device.makeRenderPipelineState(tileDescriptor: tileDesc, options: .argumentInfo, reflection: nil) // FIXME: argumentinfo?
        
        // MARK: - Depth Descriptor
        let depthStateDesc = Self.createDepthStencilDescriptor(compareFunc: .less, writeDepth: false)
        depthState = ShaderCore.device.makeDepthStencilState(descriptor: depthStateDesc)!
        
        super.init(drawProcess: sketch)
    }
    
    public func startRenderLoop() {
        Task {
            do {
                try await arSession.run([worldTracking])
            } catch {
                fatalError("Failed to initialize ARSession")
            }
            
            let renderThread = Thread {
                self.renderLoop()
            }
            renderThread.name = "Render Thread"
            renderThread.start()
        }
    }
    
    func renderLoop() {
        while true {
            if layerRenderer.state == .invalidated {
                print("Layer is invalidated")
                return
            } else if layerRenderer.state == .paused {
                layerRenderer.waitUntilRunning()
                continue
            } else {
                autoreleasepool {
                    self.renderFrame()
                }
            }
        }
    }
    
    func renderFrame() {
        /// Per frame updates hare

        guard let frame = layerRenderer.queryNextFrame() else { return }
        
        frame.startUpdate()
        
        // Perform frame independent work
        
        frame.endUpdate()
        
        guard let timing = frame.predictTiming() else { return }
        LayerRenderer.Clock().wait(until: timing.optimalInputTime)
        guard let drawable = frame.queryDrawable() else { return }
        frame.startSubmission()
        let time = LayerRenderer.Clock.Instant.epoch.duration(to: drawable.frameTiming.presentationTime).timeInterval
        let deviceAnchor = worldTracking.queryDeviceAnchor(atTimestamp: time)
        drawable.deviceAnchor = deviceAnchor
        
        
        //cb
        
        let commandBuffer = ShaderCore.commandQueue.makeCommandBuffer()!
        
        // MARK: - render pass descriptor
        let renderPassDescriptor = MTLRenderPassDescriptor()
        renderPassDescriptor.colorAttachments[0].texture = drawable.colorTextures[0]
        renderPassDescriptor.depthAttachment.texture = drawable.depthTextures[0]
        renderPassDescriptor.colorAttachments[0].loadAction = .clear
        renderPassDescriptor.colorAttachments[0].storeAction = .store
        renderPassDescriptor.colorAttachments[0].clearColor = .init(red: 0, green: 0, blue: 0, alpha: 0)
        renderPassDescriptor.tileWidth = optimalTileSize.width
        renderPassDescriptor.tileHeight = optimalTileSize.height
        renderPassDescriptor.imageblockSampleLength = resolveState.imageblockSampleLength
        
        drawProcess.preProcess(commandBuffer: commandBuffer)
        
        // MARK: - render encoder
        let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor)!
        
        Self.setDefaultBuffers(encoder: renderEncoder)
        
        renderEncoder.setRenderPipelineState(clearTileState)
        renderEncoder.dispatchThreadsPerTile(optimalTileSize)
        renderEncoder.setCullMode(.none)
        renderEncoder.setDepthStencilState(depthState)
        renderEncoder.setRenderPipelineState(pipelineState)
        
        // MARK: - set buffer
        
        let simdDeviceAnchor = deviceAnchor?.originFromAnchorTransform ?? matrix_identity_float4x4
        
        let view = drawable.views[0]
        let viewMatrix = (simdDeviceAnchor * view.transform).inverse
        let projectionTemp = ProjectiveTransform3D(leftTangent: Double(view.tangents[0]),
                                               rightTangent: Double(view.tangents[1]),
                                               topTangent: Double(view.tangents[2]),
                                               bottomTangent: Double(view.tangents[3]),
                                               nearZ: Double(drawable.depthRange.y),
                                               farZ: Double(drawable.depthRange.x),
                                               reverseZ: true)
        let projection = matrix_float4x4.init(projectionTemp)
        
        renderEncoder.setVertexBytes([projection], length: f4x4.memorySize, index: VertexBufferIndex.ProjectionMatrix.rawValue)
        renderEncoder.setVertexBytes([viewMatrix], length: f4x4.memorySize, index: VertexBufferIndex.ViewMatrix.rawValue)
        
        let cameraPosBuffer = ShaderCore.device.makeBuffer(bytes: [f3(0, 0, 0)], length: f3.memorySize)
        renderEncoder.setVertexBuffer(cameraPosBuffer, offset: 0, index: VertexBufferIndex.CameraPos.rawValue)
        renderEncoder.setFragmentTexture(AssetUtil.defaultMTLTexture, index: FragmentTextureIndex.MainTexture.rawValue)
        
        // MARK: - draw primitive
        drawProcess.beforeDraw(encoder: renderEncoder)
        drawProcess.updateAndDrawLight(encoder: renderEncoder)
        drawProcess.update()
        drawProcess.draw(encoder: renderEncoder)
        
        let viewports = drawable.views.map { $0.textureMap.viewport }
        renderEncoder.setViewport(viewports[0])
        
        // MARK: - end encoding
        renderEncoder.setRenderPipelineState(resolveState)
        renderEncoder.dispatchThreadsPerTile(optimalTileSize)
        
        renderEncoder.endEncoding()
        
        self.drawProcess.postProcess(texture: renderPassDescriptor.colorAttachments[0].texture!, commandBuffer: commandBuffer)
        
        drawable.encodePresent(commandBuffer: commandBuffer)
        commandBuffer.commit()
        
        commandBuffer.waitUntilCompleted()
        frame.endSubmission()
    }
}

#endif
