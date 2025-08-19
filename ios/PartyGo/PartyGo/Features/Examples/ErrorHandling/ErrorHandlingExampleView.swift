//
//  ErrorHandlingExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct ErrorHandlingExampleView: View {
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var data: String = ""
    @State private var errorLogs: [String] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("错误处理示例")
                    .font(.title)
                    .padding()
                
                // 基础错误处理
                VStack {
                    Text("基础错误处理")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        Button("触发错误") {
                            triggerError()
                        }
                        .buttonStyle(.borderedProminent)
                        .foregroundColor(.red)
                        
                        Button("模拟网络请求") {
                            simulateNetworkRequest()
                        }
                        .buttonStyle(.bordered)
                        
                        if isLoading {
                            ProgressView("加载中...")
                                .padding()
                        }
                        
                        if !data.isEmpty {
                            Text("数据: \(data)")
                                .font(.body)
                                .foregroundColor(.green)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 错误类型示例
                VStack {
                    Text("错误类型示例")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        Button("网络错误") {
                            handleNetworkError()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.orange)
                        
                        Button("数据错误") {
                            handleDataError()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.purple)
                        
                        Button("权限错误") {
                            handlePermissionError()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                        
                        Button("未知错误") {
                            handleUnknownError()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.gray)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 错误恢复
                VStack {
                    Text("错误恢复")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        Button("重试操作") {
                            retryOperation()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("使用备用数据") {
                            useFallbackData()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("重置状态") {
                            resetState()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 错误日志
                VStack {
                    Text("错误日志")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(errorLogs.suffix(5), id: \.self) { log in
                            HStack {
                                Image(systemName: "exclamationmark.triangle")
                                    .font(.caption)
                                    .foregroundColor(.red)
                                
                                Text(log)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    Button("清空日志") {
                        errorLogs.removeAll()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 错误状态显示
                VStack {
                    Text("错误状态显示")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("当前状态:")
                            Spacer()
                            Text(isLoading ? "加载中" : (data.isEmpty ? "无数据" : "有数据"))
                                .fontWeight(.bold)
                                .foregroundColor(isLoading ? .orange : (data.isEmpty ? .red : .green))
                        }
                        
                        if !data.isEmpty {
                            Text("成功获取数据")
                                .font(.caption)
                                .foregroundColor(.green)
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
        .navigationTitle("错误处理")
        .alert("错误", isPresented: $showingError) {
            Button("确定") { }
            Button("重试") {
                retryOperation()
            }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - 错误处理方法
    
    private func triggerError() {
        errorMessage = "这是一个基础错误示例"
        showingError = true
        addErrorLog("触发基础错误")
    }
    
    private func simulateNetworkRequest() {
        isLoading = true
        data = ""
        
        // 模拟网络请求
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            isLoading = false
            
            // 随机成功或失败
            if Bool.random() {
                data = "网络请求成功"
                addErrorLog("网络请求成功")
            } else {
                errorMessage = "网络请求失败，请检查网络连接"
                showingError = true
                addErrorLog("网络请求失败")
            }
        }
    }
    
    private func handleNetworkError() {
        errorMessage = "网络连接错误，请检查网络设置"
        showingError = true
        addErrorLog("网络连接错误")
    }
    
    private func handleDataError() {
        errorMessage = "数据格式错误，无法解析响应"
        showingError = true
        addErrorLog("数据格式错误")
    }
    
    private func handlePermissionError() {
        errorMessage = "权限不足，无法访问此功能"
        showingError = true
        addErrorLog("权限不足")
    }
    
    private func handleUnknownError() {
        errorMessage = "发生未知错误，请稍后重试"
        showingError = true
        addErrorLog("未知错误")
    }
    
    private func retryOperation() {
        addErrorLog("重试操作")
        simulateNetworkRequest()
    }
    
    private func useFallbackData() {
        data = "使用备用数据"
        addErrorLog("使用备用数据")
    }
    
    private func resetState() {
        isLoading = false
        data = ""
        addErrorLog("重置状态")
    }
    
    private func addErrorLog(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        errorLogs.append("[\(timestamp)] \(message)")
    }
}

#Preview {
    NavigationView {
        ErrorHandlingExampleView()
    }
}
