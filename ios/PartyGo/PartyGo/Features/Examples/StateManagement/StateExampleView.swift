//
//  StateExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct StateExampleView: View {
    @State private var counter = 0
    @State private var text = ""
    @State private var isToggleOn = false
    @State private var selectedColor = Color.blue
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("@State 示例")
                    .font(.title)
                    .padding()
                
                // 计数器示例
                VStack {
                    Text("计数器示例")
                        .font(.headline)
                    
                    Text("\(counter)")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundColor(selectedColor)
                    
                    HStack(spacing: 20) {
                        Button("减少") {
                            counter -= 1
                        }
                        .buttonStyle(.bordered)
                        
                        Button("增加") {
                            counter += 1
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 文本输入示例
                VStack {
                    Text("文本输入示例")
                        .font(.headline)
                    
                    TextField("输入文本", text: $text)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .padding(.horizontal)
                    
                    Text("当前文本: \(text.isEmpty ? "无" : text)")
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 开关示例
                VStack {
                    Text("开关示例")
                        .font(.headline)
                    
                    Toggle("控制开关", isOn: $isToggleOn)
                        .padding(.horizontal)
                    
                    if isToggleOn {
                        Text("开关已开启")
                            .foregroundColor(.green)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("@State")
    }
}

#Preview {
    NavigationView {
        StateExampleView()
    }
}
