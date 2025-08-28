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
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                Text("3D多面骰子")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                
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
                        
                        Button("清空历史") {
                            engine.clearHistory()
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
        }
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