//
//  ButtonExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct ButtonExampleView: View {
    @State private var count = 0
    @State private var isPressed = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 基础按钮
            Button("点击我") {
                count += 1
            }
            
            // 带图标的按钮
            Button(action: {
                count += 1
            }) {
                HStack {
                    Image(systemName: "plus.circle")
                    Text("增加")
                }
            }
            
            // 自定义样式按钮
            Button("自定义按钮") {
                isPressed.toggle()
            }
            .padding()
            .background(isPressed ? Color.red : Color.blue)
            .foregroundColor(.white)
            .cornerRadius(10)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
            
            // 系统样式按钮
            Button("系统样式") {
                // 动作
            }
            .buttonStyle(.borderedProminent)
            
            Button("边框样式") {
                // 动作
            }
            .buttonStyle(.bordered)
            
            // 禁用状态
            Button("禁用按钮") {
                // 动作
            }
            .disabled(true)
            
            Text("点击次数: \(count)")
        }
        .padding()
    }
}

#Preview {
    ButtonExampleView()
}
