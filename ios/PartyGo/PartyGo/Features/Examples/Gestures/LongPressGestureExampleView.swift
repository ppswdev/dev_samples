//
//  LongPressGestureExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct LongPressGestureExampleView: View {
    @State private var isLongPressed = false
    @State private var longPressCount = 0
    @State private var showingContextMenu = false
    @State private var selectedItem = -1
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("LongPressGesture 示例")
                    .font(.title)
                    .padding()
                
                // 基础长按手势
                VStack {
                    Text("基础长按手势")
                        .font(.headline)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isLongPressed ? Color.red : Color.blue)
                        .frame(width: 150, height: 100)
                        .overlay(
                            VStack {
                                Image(systemName: isLongPressed ? "hand.raised.fill" : "hand.raised")
                                    .font(.title)
                                    .foregroundColor(.white)
                                Text(isLongPressed ? "长按中" : "长按我")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        )
                        .scaleEffect(isLongPressed ? 1.2 : 1.0)
                        .animation(.easeInOut(duration: 0.2), value: isLongPressed)
                        .onLongPressGesture(minimumDuration: 1.0, maximumDistance: 50) {
                            longPressCount += 1
                        } onPressingChanged: { pressing in
                            isLongPressed = pressing
                        }
                    
                    Text("长按次数: \(longPressCount)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 长按选择
                VStack {
                    Text("长按选择")
                        .font(.headline)
                    
                    VStack(spacing: 10) {
                        ForEach(0..<4, id: \.self) { index in
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
                            .onLongPressGesture(minimumDuration: 0.5) {
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
                
                // 长按删除
                VStack {
                    Text("长按删除")
                        .font(.headline)
                    
                    VStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { index in
                            HStack {
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .opacity(0)
                                
                                Text("项目 \(index + 1)")
                                    .font(.body)
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(8)
                            .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                            .onLongPressGesture(minimumDuration: 1.0) {
                                // 显示删除确认
                                showingContextMenu = true
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 长按预览
                VStack {
                    Text("长按预览")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        VStack {
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.blue)
                            
                            Text("图片")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                        .onLongPressGesture(minimumDuration: 0.8) {
                            // 预览图片
                        }
                        
                        VStack {
                            Image(systemName: "doc.text")
                                .font(.system(size: 40))
                                .foregroundColor(.green)
                            
                            Text("文档")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                        .onLongPressGesture(minimumDuration: 0.8) {
                            // 预览文档
                        }
                        
                        VStack {
                            Image(systemName: "link")
                                .font(.system(size: 40))
                                .foregroundColor(.orange)
                            
                            Text("链接")
                                .font(.caption)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(10)
                        .shadow(color: .gray.opacity(0.2), radius: 2, x: 0, y: 1)
                        .onLongPressGesture(minimumDuration: 0.8) {
                            // 预览链接
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 重置按钮
                Button("重置所有状态") {
                    isLongPressed = false
                    longPressCount = 0
                    selectedItem = -1
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
        }
        .navigationTitle("LongPressGesture")
        .alert("删除确认", isPresented: $showingContextMenu) {
            Button("取消", role: .cancel) { }
            Button("删除", role: .destructive) { }
        } message: {
            Text("确定要删除这个项目吗？")
        }
    }
}

#Preview {
    NavigationView {
        LongPressGestureExampleView()
    }
}
