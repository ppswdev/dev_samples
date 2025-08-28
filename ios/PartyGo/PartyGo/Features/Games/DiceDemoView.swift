//
//  DiceDemoView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/27.
//

import SwiftUI
import SceneKit

struct DiceDemoView: View {
    @StateObject private var engine = Dice3DEngine()
    @State private var showSettings = false
    @State private var showManualControl = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 骰子类型选择器
                Picker("骰子类型", selection: $engine.currentDiceType) {
                    ForEach(DiceType.allCases, id: \.self) { type in
                        Text(type.name).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .onChange(of: engine.currentDiceType) { newType in
                    engine.changeDiceType(newType)
                }
                
                // 3D骰子视图
                if let sceneView = engine.getSceneView() {
                    SceneKitView(sceneView: sceneView)
                        .frame(height: 300)
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                // 当前数字显示
                VStack(spacing: 10) {
                    Text("当前数字")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text("\(engine.currentNumber)")
                        .font(.system(size: 48, weight: .bold, design: .rounded))
                        .foregroundColor(.primary)
                        .scaleEffect(engine.isRolling ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.3), value: engine.isRolling)
                }
                
                // 控制按钮
                VStack(spacing: 15) {
                    Button(action: {
                        Task {
                            await engine.rollDice()
                        }
                    }) {
                        HStack {
                            Image(systemName: "dice.fill")
                            Text(engine.isRolling ? "骰子中..." : "掷骰子")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            engine.isRolling ? 
                            LinearGradient(colors: [.gray, .gray.opacity(0.8)], startPoint: .leading, endPoint: .trailing) : 
                            LinearGradient(colors: [.blue, .purple], startPoint: .leading, endPoint: .trailing)
                        )
                        .cornerRadius(12)
                    }
                    .disabled(engine.isRolling)
                    
                    HStack(spacing: 15) {
                        Button("重置") {
                            engine.resetDice()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("手动控制") {
                            showManualControl = true
                        }
                        .buttonStyle(.bordered)
                        
                        Button("设置") {
                            showSettings = true
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // 统计信息
                if !engine.rollHistory.isEmpty {
                    StatisticsView(engine: engine)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("3D多面骰子")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showSettings) {
                SettingsView(engine: engine)
            }
            .sheet(isPresented: $showManualControl) {
                ManualControlView(engine: engine).presentationDetents([
                .height(300),  // 固定高度300点
                .fraction(0.5), // 屏幕高度的50%
            ])
            }
        }
    }
}

// MARK: - 手动控制视图
struct ManualControlView: View {
    @ObservedObject var engine: Dice3DEngine
    @Environment(\.dismiss) var dismiss
    
    @State private var positionX: Float = 0.0
    @State private var positionY: Float = 0.0
    @State private var positionZ: Float = 0.0
    @State private var rotationX: Float = 0.0
    @State private var rotationY: Float = 0.0
    @State private var rotationZ: Float = 0.0
    @State private var scale: Float = 1.0
    @State private var isAutoAnimation = false
    @State private var autoAnimationSpeed: Float = 1.0
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 自动动画开关
                    Section {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("自动动画")
                                    .font(.headline)
                                Spacer()
                                Toggle("", isOn: $isAutoAnimation)
                                    .onChange(of: isAutoAnimation) { newValue in
                                        if newValue {
                                            startAutoAnimation()
                                        } else {
                                            stopAutoAnimation()
                                        }
                                    }
                            }
                            
                            if isAutoAnimation {
                                VStack(alignment: .leading) {
                                    Text("动画速度: \(String(format: "%.1f", autoAnimationSpeed))")
                                        .font(.subheadline)
                                    
                                    Slider(value: $autoAnimationSpeed, in: 0.1...3.0, step: 0.1)
                                        .onChange(of: autoAnimationSpeed) { _ in
                                            updateAutoAnimation()
                                        }
                                }
                            }
                        }
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // 位置控制
                    Section {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("位置控制")
                                .font(.headline)
                            
                            VStack(spacing: 10) {
                                HStack {
                                    Text("X轴")
                                    Spacer()
                                    Text(String(format: "%.2f", positionX))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Slider(value: $positionX, in: -3.0...3.0, step: 0.1)
                                    .onChange(of: positionX) { _ in
                                        updateDiceTransform()
                                    }
                                
                                HStack {
                                    Text("Y轴")
                                    Spacer()
                                    Text(String(format: "%.2f", positionY))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Slider(value: $positionY, in: -3.0...3.0, step: 0.1)
                                    .onChange(of: positionY) { _ in
                                        updateDiceTransform()
                                    }
                                
                                HStack {
                                    Text("Z轴")
                                    Spacer()
                                    Text(String(format: "%.2f", positionZ))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Slider(value: $positionZ, in: -3.0...3.0, step: 0.1)
                                    .onChange(of: positionZ) { _ in
                                        updateDiceTransform()
                                    }
                            }
                        }
                        .padding()
                        .background(Color.green.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // 旋转控制
                    Section {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("旋转控制")
                                .font(.headline)
                            
                            VStack(spacing: 10) {
                                HStack {
                                    Text("X轴旋转")
                                    Spacer()
                                    Text(String(format: "%.1f°", rotationX * 180 / Float.pi))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Slider(value: $rotationX, in: 0...Float.pi * 2, step: 0.1)
                                    .onChange(of: rotationX) { _ in
                                        updateDiceTransform()
                                    }
                                
                                HStack {
                                    Text("Y轴旋转")
                                    Spacer()
                                    Text(String(format: "%.1f°", rotationY * 180 / Float.pi))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Slider(value: $rotationY, in: 0...Float.pi * 2, step: 0.1)
                                    .onChange(of: rotationY) { _ in
                                        updateDiceTransform()
                                    }
                                
                                HStack {
                                    Text("Z轴旋转")
                                    Spacer()
                                    Text(String(format: "%.1f°", rotationZ * 180 / Float.pi))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Slider(value: $rotationZ, in: 0...Float.pi * 2, step: 0.1)
                                    .onChange(of: rotationZ) { _ in
                                        updateDiceTransform()
                                    }
                            }
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // 缩放控制
                    Section {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("缩放控制")
                                .font(.headline)
                            
                            VStack(spacing: 10) {
                                HStack {
                                    Text("缩放比例")
                                    Spacer()
                                    Text(String(format: "%.2f", scale))
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Slider(value: $scale, in: 0.1...3.0, step: 0.1)
                                    .onChange(of: scale) { _ in
                                        updateDiceTransform()
                                    }
                            }
                        }
                        .padding()
                        .background(Color.purple.opacity(0.1))
                        .cornerRadius(12)
                    }
                    
                    // 快速预设按钮
                    Section {
                        VStack(alignment: .leading, spacing: 15) {
                            Text("快速预设")
                                .font(.headline)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 10) {
                                Button("重置位置") {
                                    resetPosition()
                                }
                                .buttonStyle(.bordered)
                                
                                Button("重置旋转") {
                                    resetRotation()
                                }
                                .buttonStyle(.bordered)
                                
                                Button("重置缩放") {
                                    resetScale()
                                }
                                .buttonStyle(.bordered)
                                
                                Button("全部重置") {
                                    resetAll()
                                }
                                .buttonStyle(.bordered)
                            }
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                .padding()
            }
            .navigationTitle("手动控制")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - 私有方法
    private func updateDiceTransform() {
        engine.updateDiceTransform(
            position: SCNVector3(positionX, positionY, positionZ),
            rotation: SCNVector4(rotationX, rotationY, rotationZ, 1.0),
            scale: scale
        )
    }
    
    private func startAutoAnimation() {
        engine.startAutoAnimation(speed: autoAnimationSpeed)
    }
    
    private func stopAutoAnimation() {
        engine.stopAutoAnimation()
    }
    
    private func updateAutoAnimation() {
        if isAutoAnimation {
            engine.updateAutoAnimationSpeed(speed: autoAnimationSpeed)
        }
    }
    
    private func resetPosition() {
        positionX = 0.0
        positionY = 0.0
        positionZ = 0.0
        updateDiceTransform()
    }
    
    private func resetRotation() {
        rotationX = 0.0
        rotationY = 0.0
        rotationZ = 0.0
        updateDiceTransform()
    }
    
    private func resetScale() {
        scale = 1.0
        updateDiceTransform()
    }
    
    private func resetAll() {
        resetPosition()
        resetRotation()
        resetScale()
    }
}

// MARK: - 统计信息视图
struct StatisticsView: View {
    @ObservedObject var engine: Dice3DEngine
    
    var body: some View {
        VStack(spacing: 15) {
            Text("统计信息")
                .font(.headline)
                .foregroundColor(.primary)
            
            HStack(spacing: 30) {
                StatItem(title: "掷骰次数", value: "\(engine.rollCount)")
                StatItem(title: "平均点数", value: String(format: "%.1f", engine.averageRoll))
            }
            
            // 历史记录
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(Array(engine.rollHistory.enumerated()), id: \.offset) { index, number in
                        Text("\(number)")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 30, height: 30)
                            .background(Color.blue)
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - 统计项视图
struct StatItem: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 5) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.primary)
        }
    }
}

// MARK: - 设置视图
struct SettingsView: View {
    @ObservedObject var engine: Dice3DEngine
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("动画设置") {
                    VStack(alignment: .leading) {
                        Text("动画时长: \(String(format: "%.1f", engine.animationDuration))秒")
                            .font(.headline)
                        
                        Slider(
                            value: Binding(
                                get: { engine.animationDuration },
                                set: { engine.setAnimationDuration($0) }
                            ),
                            in: 0.5...5.0,
                            step: 0.1
                        )
                    }
                }
                
                Section("关于") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    HStack {
                        Text("开发者")
                        Spacer()
                        Text("PartyGo Team")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    DiceDemoView()
}
