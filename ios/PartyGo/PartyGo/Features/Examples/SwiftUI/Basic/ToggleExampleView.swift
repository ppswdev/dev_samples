//
//  ToggleExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI


struct ToggleExampleView: View {
    @State private var isOn = false
    @State private var isDarkMode = false
    @State private var notifications = true
    
    var body: some View {
        VStack(spacing: 20) {
            // 基础开关
            Toggle("基础开关", isOn: $isOn)
            
            // 自定义样式开关
            Toggle("深色模式", isOn: $isDarkMode)
                .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            // 按钮样式开关
            Toggle("通知", isOn: $notifications)
                .toggleStyle(ButtonToggleStyle())
            
            // 自定义开关
            HStack {
                Text("自定义开关")
                Spacer()
                Button(action: {
                    isOn.toggle()
                }) {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isOn ? Color.blue : Color.gray)
                        .frame(width: 50, height: 30)
                        .overlay(
                            Circle()
                                .fill(Color.white)
                                .frame(width: 26, height: 26)
                                .offset(x: isOn ? 10 : -10)
                                .shadow(radius: 2)
                        )
                }
            }
        }
        .padding()
    }
}

#Preview {
    ToggleExampleView()
}
