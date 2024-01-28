//
//  App.swift
//

import SwiftUI
import CompositorServices
import SwiftyCreatives
import FirebaseFirestore
import FirebaseFirestoreSwift

struct ContentStageConfiguration: CompositorLayerConfiguration {
    func makeConfiguration(capabilities: LayerRenderer.Capabilities, configuration: inout LayerRenderer.Configuration) {
        configuration.depthFormat = .depth32Float
        configuration.colorFormat = .bgra8Unorm_srgb
    
        let foveationEnabled = capabilities.supportsFoveation
        configuration.isFoveationEnabled = foveationEnabled
        
        let options: LayerRenderer.Capabilities.SupportedLayoutsOptions = foveationEnabled ? [.foveationEnabled] : []
        let supportedLayouts = capabilities.supportedLayouts(options: options)
        
        configuration.layout = supportedLayouts.contains(.layered) ? .layered : .dedicated
    }
}

final class Sample9: Sketch {
    override init() {
        super.init()
    }
    let count = 5
    override func draw(encoder: SCEncoder) {
        setFog(color: f4.one, density: 0.02)
        color(0.8, 0.1, 0.1, 0.8)
        for z in -count...count {
            for y in -count...count {
                for x in -count...count {
                    box(Float(x) * 15, Float(y) * 15, Float(z) * 15, 1, 1, 1)
                }
            }
        }
    }
}

struct PostData: Codable, Hashable {
    @DocumentID var id: String?
    let originalImageUrl: URL
    let replacedBackgroundImageUrl: URL?
    let editedImageUrl: URL
    let userId: String
    let isPrivate: Bool
    let createdAt: Timestamp
    var reportedUsers: [String] = []
}

class FirebaseManager {
    static func getLatestPost(completion: @escaping (URL) -> Void) {
        let docs = Firestore.firestore().collection("posts").order(by: "createdAt", descending: true).limit(to: 30).documents
            
//            .addSnapshotListener { snapshot, _ in
//            guard let decoded = snapshot?.documents.map({ try $0.data(as: PostData.self) }).first else {
//                return
//            }
//            completion(decoded.editedImageUrl)
//        }
    }
}

final class Sample8: Sketch {
    let obj = Img().load(name: "image", bundle: .main).adjustScale(with: .basedOnWidth).multiplyScale(1.7)
    let date = Date()
    override init() {
        super.init()
    }
    override func draw(encoder: SCEncoder) {
        let time = Float(Date().timeIntervalSince(date))
        rotateY(time * 0.1)
        translate(0, time * 0.1, 0)
        for i in 0...30 {
            rotateY(Float.pi * 2 / 6)
            push {
                translate(0, Float(i) * 1.5, -4)
                img(imgObj: obj)
            }
        }
    }
}

@main
struct TestingApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }

        ImmersiveSpace(id: "ImmersiveSpace") {
            CompositorLayer(configuration: ContentStageConfiguration()) { layerRenderer in
                let renderer = NormalBlendRendererVision(sketch: Sample8(), layerRenderer: layerRenderer)
                renderer.startRenderLoop()
            }
        }
    }
}

