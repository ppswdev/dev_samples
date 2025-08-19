//
//  DebugToolsExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct DebugToolsExampleView: View {
    @State private var debugInfo: [String] = []
    @State private var showingDebugPanel = false
    @State private var performanceData: [String: Double] = [:]
    @State private var isPerformanceMonitoring = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("调试工具示例")
                    .font(.title)
                    .padding()
                
                // 调试信息
                VStack {
                    Text("调试信息")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        Button("收集调试信息") {
                            collectDebugInfo()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("显示调试面板") {
                            showingDebugPanel.toggle()
                        }
                        .buttonStyle(.bordered)
                        
                        if showingDebugPanel {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(debugInfo, id: \.self) { info in
                                    HStack {
                                        Image(systemName: "info.circle")
                                            .font(.caption)
                                            .foregroundColor(.blue)
                                        
                                        Text(info)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 性能监控
                VStack {
                    Text("性能监控")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        Button(isPerformanceMonitoring ? "停止监控" : "开始监控") {
                            isPerformanceMonitoring.toggle()
                            if isPerformanceMonitoring {
                                startPerformanceMonitoring()
                            }
                        }
                        .buttonStyle(.borderedProminent)
                        
                        if !performanceData.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(Array(performanceData.keys.sorted()), id: \.self) { key in
                                    HStack {
                                        Text(key)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                        
                                        Spacer()
                                        
                                        Text(String(format: "%.2f", performanceData[key] ?? 0))
                                            .font(.caption)
                                            .fontWeight(.bold)
                                            .foregroundColor(.blue)
                                    }
                                }
                            }
                            .padding()
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 调试工具
                VStack {
                    Text("调试工具")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        Button("分析视图结构") {
                            analyzeViewHierarchy()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("检查约束") {
                            checkConstraints()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("内存使用情况") {
                            checkMemoryUsage()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("清除缓存") {
                            clearCache()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.orange)
                        
                        Button("重置所有数据") {
                            resetAllData()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 系统信息
                VStack {
                    Text("系统信息")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        HStack {
                            Text("设备:")
                            Spacer()
                            Text("iPhone Simulator")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("系统版本:")
                            Spacer()
                            Text("iOS 17.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        HStack {
                            Text("应用版本:")
                            Spacer()
                            Text("1.0.0")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("调试工具")
    }
    
    // MARK: - 调试方法
    
    private func collectDebugInfo() {
        debugInfo.removeAll()
        debugInfo.append("应用启动时间: \(Date().formatted())")
        debugInfo.append("内存使用: \(getMemoryUsage()) MB")
        debugInfo.append("CPU使用率: \(getCPUUsage())%")
        debugInfo.append("网络状态: \(getNetworkStatus())")
    }
    
    private func startPerformanceMonitoring() {
        Task { @MainActor in
            while isPerformanceMonitoring {
                // 更新性能数据
                performanceData["CPU使用率"] = Double.random(in: 10...80)
                performanceData["内存使用"] = Double.random(in: 50...200)
                performanceData["帧率"] = Double.random(in: 50...60)
                
                // 等待1秒
                try? await Task.sleep(nanoseconds: 1_000_000_000)
                
                // 检查是否应该停止监控
                if !isPerformanceMonitoring {
                    break
                }
            }
        }
    }
    
    private func analyzeViewHierarchy() {
        addDebugInfo("开始分析视图层次结构")
        addDebugInfo("发现 15 个视图")
    }
    
    private func checkConstraints() {
        addDebugInfo("检查约束完成")
        addDebugInfo("发现 2 个约束冲突")
    }
    
    private func checkMemoryUsage() {
        addDebugInfo("当前内存使用: \(getMemoryUsage()) MB")
    }
    
    private func clearCache() {
        addDebugInfo("缓存清理完成")
        addDebugInfo("释放空间: 15.2 MB")
    }
    
    private func resetAllData() {
        debugInfo.removeAll()
        performanceData.removeAll()
        addDebugInfo("所有数据已重置")
    }
    
    private func addDebugInfo(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        debugInfo.append("[\(timestamp)] \(message)")
    }
    
    // MARK: - 辅助方法
    
    private func getMemoryUsage() -> String {
        return String(format: "%.1f", Double.random(in: 50...200))
    }
    
    private func getCPUUsage() -> String {
        return String(format: "%.1f", Double.random(in: 10...80))
    }
    
    private func getNetworkStatus() -> String {
        return ["WiFi", "4G", "5G"].randomElement() ?? "未知"
    }
}

#Preview {
    NavigationView {
        DebugToolsExampleView()
    }
}
