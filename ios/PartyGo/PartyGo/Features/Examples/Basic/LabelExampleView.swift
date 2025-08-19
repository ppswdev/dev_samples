//
//  LabelExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct LabelExampleView: View {
    var body: some View {
        VStack(spacing: 20) {
            // 基础标签
            Label("基础标签", systemImage: "star.fill")
            
            // 自定义图标
            Label("自定义图标", systemImage: "heart.fill")
                .foregroundColor(.red)
            
            // 自定义样式
            Label("自定义样式", systemImage: "gear")
                .labelStyle(CustomLabelStyle())
            
            // 垂直标签
            Label("垂直标签", systemImage: "person.circle")
                .labelStyle(VerticalLabelStyle())
            
            // 图标和文本分离
            HStack {
                Image(systemName: "envelope.fill")
                    .foregroundColor(.blue)
                Text("邮箱")
            }
        }
        .padding()
    }
}

// 自定义标签样式
struct CustomLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        HStack {
            configuration.icon
                .foregroundColor(.blue)
                .font(.title2)
            
            configuration.title
                .font(.headline)
                .foregroundColor(.primary)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(10)
    }
}

// 垂直标签样式
struct VerticalLabelStyle: LabelStyle {
    func makeBody(configuration: Configuration) -> some View {
        VStack {
            configuration.icon
                .font(.title)
                .foregroundColor(.blue)
            
            configuration.title
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

#Preview {
    LabelExampleView()
}
