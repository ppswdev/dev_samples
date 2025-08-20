//
//  ShapeExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct ShapeExampleView: View {
    @State private var selectedShape = 0
    @State private var shapeSize: CGFloat = 100
    @State private var isAnimating = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Shape 示例")
                    .font(.title)
                    .padding()
                
                // 基础形状
                VStack {
                    Text("基础形状")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        Circle()
                            .fill(Color.blue)
                            .frame(width: shapeSize, height: shapeSize)
                        
                        Rectangle()
                            .fill(Color.green)
                            .frame(width: shapeSize, height: shapeSize)
                        
                        RoundedRectangle(cornerRadius: 20)
                            .fill(Color.orange)
                            .frame(width: shapeSize, height: shapeSize)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 自定义形状
                VStack {
                    Text("自定义形状")
                        .font(.headline)
                    
                    HStack(spacing: 20) {
                        CustomTriangle()
                            .fill(Color.purple)
                            .frame(width: shapeSize, height: shapeSize)
                        
                        CustomStar()
                            .fill(Color.red)
                            .frame(width: shapeSize, height: shapeSize)
                        
                        CustomHexagon()
                            .fill(Color.cyan)
                            .frame(width: shapeSize, height: shapeSize)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 形状选择器
                VStack {
                    Text("形状选择器")
                        .font(.headline)
                    
                    Picker("选择形状", selection: $selectedShape) {
                        Text("三角形").tag(0)
                        Text("星形").tag(1)
                        Text("六边形").tag(2)
                        Text("圆形").tag(3)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    ZStack {
                        switch selectedShape {
                        case 0:
                            CustomTriangle()
                                .fill(Color.blue)
                        case 1:
                            CustomStar()
                                .fill(Color.yellow)
                        case 2:
                            CustomHexagon()
                                .fill(Color.green)
                        case 3:
                            Circle()
                                .fill(Color.red)
                        default:
                            CustomTriangle()
                                .fill(Color.blue)
                        }
                    }
                    .frame(width: 150, height: 150)
                    .scaleEffect(isAnimating ? 1.2 : 1.0)
                    .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 形状动画
                VStack {
                    Text("形状动画")
                        .font(.headline)
                    
                    HStack(spacing: 30) {
                        // 旋转动画
                        CustomTriangle()
                            .fill(Color.purple)
                            .frame(width: 80, height: 80)
                            .rotationEffect(.degrees(isAnimating ? 360 : 0))
                            .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: isAnimating)
                        
                        // 缩放动画
                        CustomStar()
                            .fill(Color.orange)
                            .frame(width: 80, height: 80)
                            .scaleEffect(isAnimating ? 1.5 : 0.8)
                            .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
                        
                        // 位移动画
                        CustomHexagon()
                            .fill(Color.cyan)
                            .frame(width: 80, height: 80)
                            .offset(y: isAnimating ? -20 : 20)
                            .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 形状组合
                VStack {
                    Text("形状组合")
                        .font(.headline)
                    
                    ZStack {
                        // 背景圆形
                        Circle()
                            .fill(Color.blue.opacity(0.3))
                            .frame(width: 120, height: 120)
                        
                        // 中心星形
                        CustomStar()
                            .fill(Color.yellow)
                            .frame(width: 60, height: 60)
                            .rotationEffect(.degrees(isAnimating ? 180 : 0))
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                        
                        // 装饰三角形
                        ForEach(0..<3, id: \.self) { index in
                            CustomTriangle()
                                .fill(Color.red.opacity(0.7))
                                .frame(width: 30, height: 30)
                                .offset(
                                    x: 60 * cos(Double(index) * 2 * .pi / 3),
                                    y: 60 * sin(Double(index) * 2 * .pi / 3)
                                )
                                .rotationEffect(.degrees(Double(index) * 120))
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 控制按钮
                HStack(spacing: 20) {
                    Button("开始动画") {
                        isAnimating.toggle()
                    }
                    .buttonStyle(.borderedProminent)
                    
                    Button("重置") {
                        selectedShape = 0
                        shapeSize = 100
                        isAnimating = false
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("Shape")
    }
}

// MARK: - 自定义形状

struct CustomTriangle: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.closeSubpath()
        
        return path
    }
}

struct CustomStar: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        let innerRadius = radius * 0.4
        
        var path = Path()
        
        for i in 0..<10 {
            let angle = Double(i) * .pi / 5
            let isOuter = i % 2 == 0
            let currentRadius = isOuter ? radius : innerRadius
            
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * currentRadius,
                y: center.y + CGFloat(sin(angle)) * currentRadius
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.closeSubpath()
        return path
    }
}

struct CustomHexagon: Shape {
    func path(in rect: CGRect) -> Path {
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let radius = min(rect.width, rect.height) / 2
        
        var path = Path()
        
        for i in 0..<6 {
            let angle = Double(i) * .pi / 3
            let point = CGPoint(
                x: center.x + CGFloat(cos(angle)) * radius,
                y: center.y + CGFloat(sin(angle)) * radius
            )
            
            if i == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        path.closeSubpath()
        return path
    }
}

#Preview {
    NavigationView {
        ShapeExampleView()
    }
}
