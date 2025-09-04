//
//  SceneKitView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/27.
//

import SwiftUI
import SceneKit

struct SceneKitView: UIViewRepresentable {
    let sceneView: SCNView
    
    func makeUIView(context: Context) -> SCNView {
        return sceneView
    }
    
    func updateUIView(_ uiView: SCNView, context: Context) {
        // 更新视图
    }
}
