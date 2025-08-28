//
//  Dice3DEngine.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/27.
//

import Foundation
import SceneKit
import SwiftUI

// MARK: - 骰子类型枚举
enum DiceType: Int, CaseIterable {
    case two = 2      // 2面 - 正反面
    case four = 4     // 4面 - 三菱椎体
    case six = 6      // 6面 - 正方体
    
    var name: String {
        switch self {
        case .two: return "2面骰"
        case .four: return "4面骰"
        case .six: return "6面骰"
        }
    }
    
    var description: String {
        switch self {
        case .two: return "正反面骰子"
        case .four: return "三菱椎体骰子"
        case .six: return "正方体骰子"
        }
    }
}

// MARK: - 3D骰子引擎
@MainActor
class Dice3DEngine: NSObject, ObservableObject {
    @Published var currentDiceType: DiceType = .six
    @Published var currentNumber: Int = 1
    @Published var isRolling: Bool = false
    @Published var rollHistory: [Int] = []
    @Published var animationDuration: Double = 2.0
    
    private var sceneView: SCNView?
    private var diceNode: SCNNode?
    
    // MARK: - 初始化
    override init() {
        super.init()
        setupScene()
    }
    
    // MARK: - 场景设置
    private func setupScene() {
        sceneView = SCNView()
        sceneView?.backgroundColor = UIColor.clear
        sceneView?.allowsCameraControl = true
        sceneView?.autoenablesDefaultLighting = true
        
        // 修复焦点管理问题
        sceneView?.isUserInteractionEnabled = true
        sceneView?.isMultipleTouchEnabled = false
        sceneView?.isAccessibilityElement = false
        
        // 禁用焦点管理
        sceneView?.isAccessibilityElement = false
        
        // 设置代理来处理焦点
        sceneView?.delegate = self
        
        let scene = SCNScene()
        sceneView?.scene = scene
        
        // 添加环境光
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.intensity = 0.3
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        // 添加方向光
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        directionalLight.intensity = 0.8
        let directionalNode = SCNNode()
        directionalNode.light = directionalLight
        directionalNode.position = SCNVector3(5, 5, 5)
        scene.rootNode.addChildNode(directionalNode)
        
        createDice()
    }
    
    // MARK: - 创建骰子
    private func createDice() {
        // 安全地移除现有骰子
        if let existingNode = diceNode {
            existingNode.removeFromParentNode()
        }
        
        switch currentDiceType {
        case .two:
            createTwoSidedDice()
        case .four:
            createFourSidedDice()
        case .six:
            createSixSidedDice()
        }
    }
    
    // MARK: - 2面骰子（正反面）
    private func createTwoSidedDice() {
        let diceNode = SCNNode()
        
        // 创建圆柱体
        let cylinder = SCNCylinder(radius: 1.0, height: 0.2)
        cylinder.firstMaterial?.diffuse.contents = UIColor.white
        cylinder.firstMaterial?.specular.contents = UIColor.lightGray
        
        let cylinderNode = SCNNode(geometry: cylinder)
        diceNode.addChildNode(cylinderNode)
        
        // 添加数字
        addNumberToFace(node: diceNode, number: 1, position: SCNVector3(0, 0.11, 0), rotation: SCNVector4(0, 0, 0, 1))
        addNumberToFace(node: diceNode, number: 2, position: SCNVector3(0, -0.11, 0), rotation: SCNVector4(0, 0, 1, Float.pi))
        
        self.diceNode = diceNode
        sceneView?.scene?.rootNode.addChildNode(diceNode)
    }
    
    // MARK: - 4面骰子（三菱椎体）
    private func createFourSidedDice() {
        let diceNode = SCNNode()
        
        // 使用SCNPyramid替代自定义几何体，更稳定
        let pyramid = SCNPyramid(width: 1.5, height: 1.5, length: 1.5)
        pyramid.firstMaterial?.diffuse.contents = UIColor.white
        pyramid.firstMaterial?.specular.contents = UIColor.lightGray
        
        let pyramidNode = SCNNode(geometry: pyramid)
        diceNode.addChildNode(pyramidNode)
        
        // 添加数字到每个面
        addNumberToFace(node: diceNode, number: 1, position: SCNVector3(0, 0.3, 0), rotation: SCNVector4(0, 0, 0, 1))
        addNumberToFace(node: diceNode, number: 2, position: SCNVector3(-0.3, -0.2, 0), rotation: SCNVector4(0, 0, 1, Float.pi/3))
        addNumberToFace(node: diceNode, number: 3, position: SCNVector3(0.3, -0.2, 0), rotation: SCNVector4(0, 0, 1, -Float.pi/3))
        addNumberToFace(node: diceNode, number: 4, position: SCNVector3(0, -0.2, 0.3), rotation: SCNVector4(1, 0, 0, Float.pi/3))
        
        self.diceNode = diceNode
        sceneView?.scene?.rootNode.addChildNode(diceNode)
    }
    
    // MARK: - 6面骰子（正方体）
    private func createSixSidedDice() {
        let diceNode = SCNNode()
        
        // 创建立方体
        let box = SCNBox(width: 2.0, height: 2.0, length: 2.0, chamferRadius: 0.1)
        box.firstMaterial?.diffuse.contents = UIColor.white
        box.firstMaterial?.specular.contents = UIColor.lightGray
        
        let boxNode = SCNNode(geometry: box)
        diceNode.addChildNode(boxNode)
        
        // 添加数字到每个面
        addNumberToFace(node: diceNode, number: 1, position: SCNVector3(0, 1.1, 0), rotation: SCNVector4(0, 0, 0, 1))
        addNumberToFace(node: diceNode, number: 2, position: SCNVector3(0, -1.1, 0), rotation: SCNVector4(0, 0, 1, Float.pi))
        addNumberToFace(node: diceNode, number: 3, position: SCNVector3(1.1, 0, 0), rotation: SCNVector4(0, 0, 1, Float.pi/2))
        addNumberToFace(node: diceNode, number: 4, position: SCNVector3(-1.1, 0, 0), rotation: SCNVector4(0, 0, 1, -Float.pi/2))
        addNumberToFace(node: diceNode, number: 5, position: SCNVector3(0, 0, 1.1), rotation: SCNVector4(1, 0, 0, Float.pi/2))
        addNumberToFace(node: diceNode, number: 6, position: SCNVector3(0, 0, -1.1), rotation: SCNVector4(1, 0, 0, -Float.pi/2))
        
        self.diceNode = diceNode
        sceneView?.scene?.rootNode.addChildNode(diceNode)
    }
    
    // MARK: - 添加数字到面
    private func addNumberToFace(node: SCNNode, number: Int, position: SCNVector3, rotation: SCNVector4) {
        // 使用更安全的文本创建方式
        let textGeometry = SCNText(string: "\(number)", extrusionDepth: 0.05)
        textGeometry.font = UIFont.systemFont(ofSize: 0.3, weight: .bold)
        textGeometry.firstMaterial?.diffuse.contents = UIColor.black
        
        let textNode = SCNNode(geometry: textGeometry)
        textNode.position = position
        textNode.rotation = rotation
        
        // 安全地居中文本
        let boundingBox = textGeometry.boundingBox
        let dx = Float(boundingBox.max.x - boundingBox.min.x)
        let dy = Float(boundingBox.max.y - boundingBox.min.y)
        
        if dx > 0 && dy > 0 {
            textNode.position.x -= dx / 2
            textNode.position.y -= dy / 2
        }
        
        node.addChildNode(textNode)
    }
    
    // MARK: - 公共方法
    func rollDice() async {
        guard !isRolling else { return }
        
        isRolling = true
        
        // 生成随机旋转
        let randomRotationX = Float.random(in: 0...Float.pi * 2)
        let randomRotationY = Float.random(in: 0...Float.pi * 2)
        let randomRotationZ = Float.random(in: 0...Float.pi * 2)
        
        // 生成随机数字
        let maxNumber = currentDiceType.rawValue
        let newNumber = Int.random(in: 1...maxNumber)
        
        // 安全地执行动画
        guard let diceNode = diceNode else {
            isRolling = false
            return
        }
        
        // 使用更安全的动画方式
        let rotationAction = SCNAction.rotateBy(
            x: CGFloat(randomRotationX),
            y: CGFloat(randomRotationY),
            z: CGFloat(randomRotationZ),
            duration: animationDuration
        )
        
        rotationAction.timingMode = .easeInEaseOut
        
        // 使用弱引用避免循环引用
        diceNode.runAction(rotationAction) { [weak self] in
            Task { @MainActor in
                guard let self = self else { return }
                self.currentNumber = newNumber
                self.isRolling = false
                self.rollHistory.append(newNumber)
            }
        }
    }
    
    func resetDice() {
        diceNode?.removeAllActions()
        diceNode?.rotation = SCNVector4(0, 0, 0, 0)
        currentNumber = 1
        isRolling = false
    }
    
    func changeDiceType(_ type: DiceType) {
        currentDiceType = type
        currentNumber = 1
        createDice()
    }
    
    func getSceneView() -> SCNView? {
        return sceneView
    }
    
    func clearHistory() {
        rollHistory.removeAll()
    }
    
    func setAnimationDuration(_ duration: Double) {
        animationDuration = max(0.5, min(5.0, duration))
    }
    
    // MARK: - 计算属性
    var rollCount: Int {
        rollHistory.count
    }
    
    var averageRoll: Double {
        guard !rollHistory.isEmpty else { return 0 }
        return Double(rollHistory.reduce(0, +)) / Double(rollHistory.count)
    }
}

// MARK: - SCNView代理扩展
extension Dice3DEngine: SCNSceneRendererDelegate {
    nonisolated func renderer(_ renderer: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // 空实现，用于处理焦点管理
    }
}
