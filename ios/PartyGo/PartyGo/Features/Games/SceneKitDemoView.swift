//
//  SceneKitDemoView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/28.
//

import SwiftUI
import SceneKit

// 主视图结构
struct SceneKitDemoView: View {
    // 状态管理：控制是否显示旋转到目标的动画
    @State private var isRotatingToTarget: Bool = false
    // 场景根节点（用于添加子节点）
    private let sceneRootNode = SCNNode()
    private var diceNodes: [SCNNode] = []
    
    var body: some View {
        GeometryReader { geo in
            VStack(spacing: 20) {
                // SceneKit 渲染视图
                SceneView(scene: createScene())
                    .frame(height: 300)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(12)
                
                // 控制按钮：触发精确旋转
                Button(action: rotateToTargetAngle) {
                    Text("旋转到 X 轴 180°")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                
                // 控制按钮：重置旋转
                Button(action: resetRotation) {
                    Text("重置旋转")
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            .padding()
        }
    }
    
    // MARK: - 创建红色空白场景
    private func createScene() -> SCNScene {
        // 创建场景
        let scene = SCNScene()
        
        // 设置红色背景
        scene.background.contents = UIColor.red
        
        scene.physicsWorld.speed = 3
        
        // 创建相机节点
        let cameraNode = SCNNode()
        cameraNode.camera = SCNCamera()
        cameraNode.position = SCNVector3(0, 0, 5) // 相机位置在z轴正方向
        scene.rootNode.addChildNode(cameraNode)
        
        // 创建光源节点
        let lightNode = SCNNode()
        lightNode.light = SCNLight()
        lightNode.light?.type = .directional // 方向光
        lightNode.light?.color = UIColor.white
        lightNode.light?.intensity = 1000.0
        lightNode.position = SCNVector3(0, 5, 5) // 光源位置
        scene.rootNode.addChildNode(lightNode)
        
        // 添加环境光，让场景更明亮
        let ambientLightNode = SCNNode()
        ambientLightNode.light = SCNLight()
        ambientLightNode.light?.type = .ambient
        ambientLightNode.light?.color = UIColor.white
        ambientLightNode.light?.intensity = 300.0
        scene.rootNode.addChildNode(ambientLightNode)
        
        let sides = [
            UIImage(named: "Image1")!,
            UIImage(named: "Image2")!,
            UIImage(named: "Image3")!,
            UIImage(named: "Image4")!,
            UIImage(named: "Image5")!,
            UIImage(named: "Image6")!,
        ]

//        diceNodes.append(createDie(position: SCNVector3(-4, 0, 0), sides: sides))
//        diceNodes.append(createDie(position: SCNVector3(4, 0, 0), sides: sides))
//        diceNodes.append(createDie(position: SCNVector3(0, 0, 0), sides: sides))

//        speeds.append(SCNVector3(0, 0, 0))
//        speeds.append(SCNVector3(0, 0, 0))
//        speeds.append(SCNVector3(0, 0, 0))

        let torque = SCNVector4(1, 2, -1, 1)
        for die in diceNodes {
            die.physicsBody?.applyTorque(torque, asImpulse: true)
            scene.rootNode.addChildNode(die)
        }
        
        return scene
    }
    
    func createDie(position: SCNVector3, sides: [UIImage]) -> SCNNode {
        let geometry = SCNBox(width: 3.0, height: 3.0, length: 3.0, chamferRadius: 0.1)

        let material1 = SCNMaterial()
        material1.diffuse.contents = sides[0]
        let material2 = SCNMaterial()
        material2.diffuse.contents = sides[1]
        let material3 = SCNMaterial()
        material3.diffuse.contents = sides[2]
        let material4 = SCNMaterial()
        material4.diffuse.contents = sides[3]
        let material5 = SCNMaterial()
        material5.diffuse.contents = sides[4]
        let material6 = SCNMaterial()
        material6.diffuse.contents = sides[5]

        geometry.materials = [material1, material2, material3, material4, material5, material6]

        let node = SCNNode(geometry: geometry)
        node.physicsBody = SCNPhysicsBody(type: .dynamic, shape: nil)
        node.position = position

        return node
    }
    
    // MARK: - 控制函数
    private func rotateToTargetAngle() {
        // 这里可以添加旋转逻辑
        print("旋转到 X 轴 180°")
    }
    
    private func resetRotation() {
        // 这里可以添加重置逻辑
        print("重置旋转")
    }
}

#Preview {
    SceneKitDemoView()
}
