//
//  TapGestureExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct TapGestureExampleView: View {
    @State private var tapCount = 0
    @State private var isHighlighted = false
    @State private var selectedItem = -1
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("TapGesture 示例")
                    .font(.title)
                    .padding()
                
                // 基础点击手势
                VStack {
                    Text("基础点击手势")
                        .font(.headline)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isHighlighted ? Color.green : Color.blue)
                        .frame(width: 150, height: 100)
                        .overlay(
                            VStack {
                                Text("点击次数: \(tapCount)")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Text("点击我")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        )
                        .onTapGesture {
                            tapCount += 1
                            withAnimation(.easeInOut(duration: 0.2)) {
                                isHighlighted.toggle()
                            }
                        }
                        .scaleEffect(isHighlighted ? 1.1 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isHighlighted)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 双击手势
                VStack {
                    Text("双击手势")
                        .font(.headline)
                    
                    Circle()
                        .fill(Color.purple)
                        .frame(width: 100, height: 100)
                        .overlay(
                            VStack {
                                Image(systemName: "hand.tap")
                                    .font(.title)
                                    .foregroundColor(.white)
                                Text("双击")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        )
                        .onTapGesture(count: 2) {
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
                                // 双击效果
                            }
                        }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 选择列表
                VStack {
                    Text("选择列表")
                        .font(.headline)
                    
                    VStack(spacing: 10) {
                        ForEach(0..<5, id: \.self) { index in
                            HStack {
                                Circle()
                                    .fill(selectedItem == index ? Color.green : Color.gray)
                                    .frame(width: 20, height: 20)
                                
                                Text("选项 \(index + 1)")
                                    .font(.body)
                                
                                Spacer()
                                
                                if selectedItem == index {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.green)
                                }
                            }
                            .padding()
                            .background(selectedItem == index ? Color.green.opacity(0.1) : Color.white)
                            .cornerRadius(8)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedItem = index
                                }
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 重置按钮
                Button("重置所有状态") {
                    tapCount = 0
                    isHighlighted = false
                    selectedItem = -1
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
        }
        .navigationTitle("TapGesture")
    }
}

#Preview {
    NavigationView {
        TapGestureExampleView()
    }
}
