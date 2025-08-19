//
//  LifecycleExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct LifecycleExampleView: View {
    @State private var count = 0
    @State private var isVisible = false
    @State private var timer: Timer?
    
    var body: some View {
        VStack(spacing: 20) {
            Text("生命周期示例")
                .font(.title)
            
            Text("计数: \(count)")
                .font(.headline)
            
            Button("增加计数") {
                count += 1
            }
            .buttonStyle(.bordered)
            
            Button("切换显示") {
                isVisible.toggle()
            }
            .buttonStyle(.bordered)
            
            if isVisible {
                LifecycleChildView(count: count)
                    .transition(.opacity.combined(with: .scale))
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            print("主视图出现")
            startTimer()
        }
        .onDisappear {
            print("主视图消失")
            stopTimer()
        }
        .onChange(of: count) { oldValue, newValue in
            print("计数变化: \(oldValue) -> \(newValue)")
        }
    }
    
    func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            print("定时器触发")
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
}

struct LifecycleChildView: View {
    let count: Int
    @State private var internalCount = 0
    
    var body: some View {
        VStack(spacing: 15) {
            Text("子视图")
                .font(.headline)
            
            Text("父视图计数: \(count)")
                .font(.caption)
            
            Text("内部计数: \(internalCount)")
                .font(.caption)
            
            Button("增加内部计数") {
                internalCount += 1
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
        .onAppear {
            print("子视图出现")
        }
        .onDisappear {
            print("子视图消失")
        }
        .onChange(of: count) { oldValue, newValue in
            print("子视图接收到父视图计数变化: \(oldValue) -> \(newValue)")
        }
        .onChange(of: internalCount) { oldValue, newValue in
            print("子视图内部计数变化: \(oldValue) -> \(newValue)")
        }
    }
}

#Preview {
    NavigationView {
        LifecycleExampleView()
    }
}