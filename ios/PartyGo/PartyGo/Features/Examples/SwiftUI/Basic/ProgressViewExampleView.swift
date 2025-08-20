//
//  ProgressViewExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct ProgressViewExampleView: View {
    @State private var progress = 0.0
    @State private var isLoading = false
    @State private var isIndeterminate = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("进度组件示例")
                .font(.title)
                .padding()
            
            // 不确定进度
            VStack {
                Text("不确定进度")
                    .font(.headline)
                ProgressView()
                    .scaleEffect(1.5)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            
            // 确定进度
            VStack {
                Text("确定进度: \(Int(progress * 100))%")
                    .font(.headline)
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .scaleEffect(y: 2)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(10)
            
            // 圆形进度
            VStack {
                Text("圆形进度")
                    .font(.headline)
                ProgressView(value: progress)
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(1.5)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(10)
            
            // 自定义进度
            VStack {
                Text("自定义进度")
                    .font(.headline)
                ProgressView(value: progress)
                    .progressViewStyle(CustomProgressViewStyle())
            }
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(10)
            
            // 控制按钮
            HStack(spacing: 20) {
                Button("开始进度") {
                    startProgress()
                }
                .buttonStyle(.borderedProminent)
                
                Button("重置") {
                    resetProgress()
                }
                .buttonStyle(.bordered)
                
                Button("切换不确定") {
                    isIndeterminate.toggle()
                }
                .buttonStyle(.bordered)
            }
            
            // 不确定进度示例
            if isIndeterminate {
                VStack {
                    Text("不确定进度示例")
                        .font(.headline)
                    ProgressView()
                        .scaleEffect(1.2)
                }
                .padding()
                .background(Color.red.opacity(0.1))
                .cornerRadius(10)
            }
            
            Spacer()
        }
        .padding()
    }
    
    // Swift 6 现代并发方式 - 符合并发安全要求
    func startProgress() {
        progress = 0
        Task { @MainActor in
            for _ in 0..<100 {
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1秒
                progress += 0.01
                if progress >= 1.0 {
                    break
                }
            }
        }
    }
    
    func resetProgress() {
        progress = 0
    }
}

// 自定义进度样式
struct CustomProgressViewStyle: ProgressViewStyle {
    func makeBody(configuration: Configuration) -> some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 20)
                
                // 进度条
                RoundedRectangle(cornerRadius: 10)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * (configuration.fractionCompleted ?? 0), height: 20)
                    .animation(.easeInOut(duration: 0.3), value: configuration.fractionCompleted)
                
                // 进度文本
                if let fractionCompleted = configuration.fractionCompleted {
                    Text("\(Int(fractionCompleted * 100))%")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .frame(height: 20)
    }
}

// 预览
#Preview {
    ProgressViewExampleView()
}
