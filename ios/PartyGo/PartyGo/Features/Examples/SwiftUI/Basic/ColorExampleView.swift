//
//  ColorExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct ColorExampleView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("颜色组件示例")
                .font(.title)
            
            // 基础颜色
            Color.red
                .frame(width: 100, height: 50)
                .cornerRadius(10)
            
            // 系统颜色
            Color(.systemBackground)
                .frame(width: 100, height: 50)
                .cornerRadius(10)
                .overlay(
                    Text("系统背景")
                        .foregroundColor(.primary)
                )
            
            // 渐变颜色
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .frame(width: 100, height: 50)
            .cornerRadius(10)
            
            // 径向渐变
            RadialGradient(
                gradient: Gradient(colors: [.yellow, .orange]),
                center: .center,
                startRadius: 0,
                endRadius: 50
            )
            .frame(width: 100, height: 50)
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    ColorExampleView()
}
