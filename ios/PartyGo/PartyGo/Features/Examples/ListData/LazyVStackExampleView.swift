//
//  LazyVStackExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct LazyVStackExampleView: View {
    @State private var items = Array(1...50).map { "项目 \($0)" }
    @State private var showingPerformance = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("LazyVStack 示例")
                    .font(.title)
                    .padding()
                
                // 性能对比说明
                VStack {
                    Text("性能对比")
                        .font(.headline)
                    
                    HStack {
                        VStack {
                            Text("VStack")
                                .font(.caption)
                                .foregroundColor(.red)
                            Text("立即加载所有视图")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        VStack {
                            Text("LazyVStack")
                                .font(.caption)
                                .foregroundColor(.green)
                            Text("按需加载视图")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // LazyVStack示例
                VStack {
                    Text("LazyVStack 列表")
                        .font(.headline)
                    
                    LazyVStack(spacing: 8) {
                        ForEach(items, id: \.self) { item in
                            HStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Text("\(items.firstIndex(of: item)! + 1)")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                    )
                                
                                Text(item)
                                    .font(.body)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 控制按钮
                HStack(spacing: 20) {
                    Button("添加项目") {
                        let newCount = items.count + 1
                        items.append("新项目 \(newCount)")
                    }
                    .buttonStyle(.bordered)
                    
                    Button("清空列表") {
                        items.removeAll()
                    }
                    .buttonStyle(.bordered)
                    .foregroundColor(.red)
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("LazyVStack")
    }
}

#Preview {
    NavigationView {
        LazyVStackExampleView()
    }
}
