//
//  DragGestureExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct DragGestureExampleView: View {
    @State private var dragOffset = CGSize.zero
    @State private var cardOffset = CGSize.zero
    @State private var sliderValue: Double = 50
    @State private var isDragging = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("DragGesture 示例")
                    .font(.title)
                    .padding()
                
                // 基础拖拽
                VStack {
                    Text("基础拖拽")
                        .font(.headline)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(isDragging ? Color.green : Color.blue)
                        .frame(width: 100, height: 100)
                        .overlay(
                            VStack {
                                Image(systemName: "hand.draw")
                                    .font(.title)
                                    .foregroundColor(.white)
                                Text("拖拽我")
                                    .font(.caption)
                                    .foregroundColor(.white)
                            }
                        )
                        .offset(dragOffset)
                        .gesture(
                            DragGesture()
                                .onChanged { value in
                                    dragOffset = value.translation
                                    isDragging = true
                                }
                                .onEnded { _ in
                                    withAnimation(.spring()) {
                                        dragOffset = .zero
                                        isDragging = false
                                    }
                                }
                        )
                    
                    Text("偏移: X: \(Int(dragOffset.width)), Y: \(Int(dragOffset.height))")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 卡片拖拽
                VStack {
                    Text("卡片拖拽")
                        .font(.headline)
                    
                    ZStack {
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.gray.opacity(0.3))
                            .frame(width: 300, height: 200)
                        
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.orange)
                            .frame(width: 120, height: 80)
                            .overlay(
                                VStack {
                                    Image(systemName: "rectangle.stack")
                                        .font(.title)
                                        .foregroundColor(.white)
                                    Text("卡片")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            )
                            .offset(cardOffset)
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        cardOffset = value.translation
                                    }
                                    .onEnded { _ in
                                        withAnimation(.spring()) {
                                            cardOffset = .zero
                                        }
                                    }
                            )
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 自定义滑块
                VStack {
                    Text("自定义滑块")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        Text("当前值: \(Int(sliderValue))")
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.3))
                                .frame(height: 20)
                            
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.blue)
                                .frame(width: CGFloat(sliderValue) * 2, height: 20)
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: 30, height: 30)
                                .shadow(radius: 2)
                                .offset(x: CGFloat(sliderValue) * 2 - 15)
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let newValue = max(0, min(100, Double(value.location.x / 2)))
                                            sliderValue = newValue
                                        }
                                )
                        }
                        .frame(width: 200)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 拖拽列表
                VStack {
                    Text("拖拽列表")
                        .font(.headline)
                    
                    VStack(spacing: 10) {
                        ForEach(0..<3, id: \.self) { index in
                            HStack {
                                Image(systemName: "line.3.horizontal")
                                    .foregroundColor(.gray)
                                
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
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        // 拖拽效果
                                    }
                                    .onEnded { _ in
                                        // 拖拽结束
                                    }
                            )
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 重置按钮
                Button("重置所有状态") {
                    dragOffset = .zero
                    cardOffset = .zero
                    sliderValue = 50
                    isDragging = false
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
        }
        .navigationTitle("DragGesture")
    }
}

#Preview {
    NavigationView {
        DragGestureExampleView()
    }
}
