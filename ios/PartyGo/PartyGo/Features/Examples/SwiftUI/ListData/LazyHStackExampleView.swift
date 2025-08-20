//
//  LazyHStackExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct LazyHStackExampleView: View {
    @State private var items = Array(1...20).map { "卡片 \($0)" }
    @State private var selectedItem = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("LazyHStack 示例")
                    .font(.title)
                    .padding()
                
                // 说明
                VStack {
                    Text("水平懒加载列表")
                        .font(.headline)
                    
                    Text("LazyHStack 适合水平滚动的卡片列表，只加载可见区域的内容")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 基础LazyHStack
                VStack {
                    Text("基础卡片列表")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 15) {
                            ForEach(items, id: \.self) { item in
                                VStack {
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue)
                                        .frame(width: 80, height: 80)
                                        .overlay(
                                            Image(systemName: "star.fill")
                                                .foregroundColor(.white)
                                                .font(.title2)
                                        )
                                    
                                    Text(item)
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .onTapGesture {
                                    selectedItem = item
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 彩色卡片列表
                VStack {
                    Text("彩色卡片列表")
                        .font(.headline)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 12) {
                            ForEach(0..<items.count, id: \.self) { index in
                                let colors: [Color] = [.red, .green, .blue, .orange, .purple, .pink]
                                let color = colors[index % colors.count]
                                
                                VStack(spacing: 8) {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 60, height: 60)
                                        .overlay(
                                            Text("\(index + 1)")
                                                .font(.title2)
                                                .fontWeight(.bold)
                                                .foregroundColor(.white)
                                        )
                                    
                                    Text(items[index])
                                        .font(.caption)
                                        .fontWeight(.medium)
                                }
                                .frame(width: 80)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                                .shadow(color: .gray.opacity(0.3), radius: 4, x: 0, y: 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 选中状态显示
                if !selectedItem.isEmpty {
                    VStack {
                        Text("当前选中")
                            .font(.headline)
                        
                        Text(selectedItem)
                            .font(.title3)
                            .foregroundColor(.blue)
                            .fontWeight(.bold)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // 控制按钮
                HStack(spacing: 20) {
                    Button("添加卡片") {
                        let newCount = items.count + 1
                        items.append("新卡片 \(newCount)")
                    }
                    .buttonStyle(.bordered)
                    
                    Button("重置选择") {
                        selectedItem = ""
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.orange)
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("LazyHStack")
    }
}

#Preview {
    NavigationView {
        LazyHStackExampleView()
    }
}
