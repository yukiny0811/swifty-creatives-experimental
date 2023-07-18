//
//  SketchBase.swift
//  
//
//  Created by Yuki Kuwashima on 2022/12/08.
//

#if os(macOS)
import AppKit
#elseif os(iOS)
import UIKit
#endif

@_exported import CommonEntity

public protocol SketchBase: AnyObject {
    var deltaTime: Float { get set }
    var metalDrawableSize: f2 { get set }
    
    // MARK: functions
    func setupCamera(camera: some MainCameraBase)
    func update(camera: some MainCameraBase)
    func draw(encoder: SCEncoder)
    func updateAndDrawLight(encoder: SCEncoder)
    func beforeDraw(encoder: SCEncoder)
    func preProcess(commandBuffer: MTLCommandBuffer)
    func postProcess(texture: MTLTexture, commandBuffer: MTLCommandBuffer)
    
    func afterCommit(texture: MTLTexture?)
    
    #if os(macOS)
    func mouseMoved(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect)
    func mouseDown(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect)
    func mouseDragged(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect)
    func mouseUp(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect)
    func mouseEntered(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect)
    func mouseExited(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect)
    func keyDown(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect)
    func keyUp(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect)
    func viewWillStartLiveResize(camera: some MainCameraBase, viewFrame: CGRect)
    func resize(withOldSuperviewSize oldSize: NSSize, camera: some MainCameraBase, viewFrame: CGRect)
    func viewDidEndLiveResize(camera: some MainCameraBase, viewFrame: CGRect)
    func scrollWheel(with event: NSEvent, camera: some MainCameraBase, viewFrame: CGRect)
    #endif

    #if os(iOS)
    func onScroll(delta: CGPoint, camera: some MainCameraBase, view: UIView, gestureRecognizer: UIPanGestureRecognizer)
    func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?, camera: some MainCameraBase, view: UIView)
    func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?, camera: some MainCameraBase, view: UIView)
    func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?, camera: some MainCameraBase, view: UIView)
    func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?, camera: some MainCameraBase, view: UIView)
    #endif
}
