//
//  BasicAnimationExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct BasicAnimationExampleView: View {
    @State private var isAnimating = false
    @State private var scale: CGFloat = 1.0
    @State private var rotation: Double = 0
    @State private var opacity: Double = 1.0
    @State private var offset: CGFloat = 0
    @State private var color = Color.blue
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("基础动画示例")
                    .font(.title)
                    .padding()
                
                // 缩放动画
                VStack {
                    Text("缩放动画")
                        .font(.headline)
                    
                    Circle()
                        .fill(color)
                        .frame(width: 100, height: 100)
                        .scaleEffect(scale)
                        .animation(.easeInOut(duration: 1.0), value: scale)
                    
                    Button("缩放") {
                        scale = scale == 1.0 ? 2.0 : 1.0
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 旋转动画
                VStack {
                    Text("旋转动画")
                        .font(.headline)
                    
                    Image(systemName: "arrow.clockwise")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                        .rotationEffect(.degrees(rotation))
                        .animation(.linear(duration: 2.0), value: rotation)
                    
                    Button("旋转") {
                        rotation += 360
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 透明度动画
                VStack {
                    Text("透明度动画")
                        .font(.headline)
                    
                    Rectangle()
                        .fill(Color.green)
                        .frame(width: 100, height: 100)
                        .opacity(opacity)
                        .animation(.easeInOut(duration: 0.5), value: opacity)
                    
                    Button("淡入淡出") {
                        opacity = opacity == 1.0 ? 0.0 : 1.0
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 位移动画
                VStack {
                    Text("位移动画")
                        .font(.headline)
                    
                    Rectangle()
                        .fill(Color.purple)
                        .frame(width: 80, height: 80)
                        .offset(x: offset)
                        .animation(.spring(response: 0.5, dampingFraction: 0.6), value: offset)
                    
                    Button("移动") {
                        offset = offset == 0 ? 100 : 0
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 颜色动画
                VStack {
                    Text("颜色动画")
                        .font(.headline)
                    
                    RoundedRectangle(cornerRadius: 20)
                        .fill(color)
                        .frame(width: 120, height: 80)
                        .animation(.easeInOut(duration: 0.8), value: color)
                    
                    Button("改变颜色") {
                        let colors: [Color] = [.blue, .red, .green, .orange, .purple]
                        color = colors.randomElement() ?? .blue
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 组合动画
                VStack {
                    Text("组合动画")
                        .font(.headline)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.pink)
                        .frame(width: 100, height: 100)
                        .scaleEffect(isAnimating ? 1.5 : 1.0)
                        .rotationEffect(.degrees(isAnimating ? 180 : 0))
                        .opacity(isAnimating ? 0.7 : 1.0)
                        .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                    
                    Button("开始组合动画") {
                        isAnimating.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 重置按钮
                Button("重置所有动画") {
                    scale = 1.0
                    rotation = 0
                    opacity = 1.0
                    offset = 0
                    color = .blue
                    isAnimating = false
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
        }
        .navigationTitle("基础动画")
    }
}

#Preview {
    NavigationView {
        BasicAnimationExampleView()
    }
}
