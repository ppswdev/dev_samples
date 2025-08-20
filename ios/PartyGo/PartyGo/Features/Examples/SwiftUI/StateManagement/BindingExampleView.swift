//
//  BindingExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct BindingExampleView: View {
    @State private var parentText = "父视图文本"
    @State private var parentValue = 0
    @State private var parentColor = Color.blue
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("@Binding 示例")
                    .font(.title)
                    .padding()
                
                // 父视图状态
                VStack {
                    Text("父视图状态")
                        .font(.headline)
                    
                    Text("文本: \(parentText)")
                        .padding()
                    
                    Text("数值: \(parentValue)")
                        .padding()
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(parentColor)
                        .frame(height: 60)
                        .padding()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 子视图绑定
                ChildView(
                    text: $parentText,
                    value: $parentValue,
                    color: $parentColor
                )
            }
            .padding()
        }
        .navigationTitle("@Binding")
    }
}

struct ChildView: View {
    @Binding var text: String
    @Binding var value: Int
    @Binding var color: Color
    
    var body: some View {
        VStack {
            Text("子视图 (通过Binding修改父视图状态)")
                .font(.headline)
            
            VStack(spacing: 15) {
                TextField("修改父视图文本", text: $text)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                
                HStack {
                    Button("减少") {
                        value -= 1
                    }
                    .buttonStyle(.bordered)
                    
                    Text("\(value)")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Button("增加") {
                        value += 1
                    }
                    .buttonStyle(.bordered)
                }
                
                HStack {
                    ForEach([Color.red, Color.green, Color.blue, Color.orange], id: \.self) { newColor in
                        Circle()
                            .fill(newColor)
                            .frame(width: 40, height: 40)
                            .overlay(
                                Circle()
                                    .stroke(color == newColor ? Color.black : Color.clear, lineWidth: 3)
                            )
                            .onTapGesture {
                                color = newColor
                            }
                    }
                }
            }
            .padding()
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

#Preview {
    NavigationView {
        BindingExampleView()
    }
}
