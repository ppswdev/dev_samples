//
//  CustomModifierExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct CustomModifierExampleView: View {
    @State private var isHighlighted = false
    @State private var selectedStyle = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("自定义修饰符示例")
                    .font(.title)
                    .padding()
                
                // 基础自定义修饰符
                VStack {
                    Text("基础自定义修饰符")
                        .font(.headline)
                    
                    Text("普通文本")
                        .customCardStyle()
                    
                    Text("带阴影的文本")
                        .customShadowStyle()
                    
                    Text("渐变背景文本")
                        .customGradientStyle()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 交互式修饰符
                VStack {
                    Text("交互式修饰符")
                        .font(.headline)
                    
                    Text("点击我")
                        .customInteractiveStyle(isActive: isHighlighted)
                        .onTapGesture {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                isHighlighted.toggle()
                            }
                        }
                    
                    Button("切换状态") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            isHighlighted.toggle()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 组合修饰符
                VStack {
                    Text("组合修饰符")
                        .font(.headline)
                    
                    Text("组合样式文本")
                        .customCombinedStyle()
                    
                    Text("另一种组合")
                        .customCombinedStyle2()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 动态修饰符
                VStack {
                    Text("动态修饰符")
                        .font(.headline)
                    
                    Picker("选择样式", selection: $selectedStyle) {
                        Text("样式1").tag(0)
                        Text("样式2").tag(1)
                        Text("样式3").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    Text("动态样式文本")
                        .customDynamicStyle(style: selectedStyle)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 扩展修饰符
                VStack {
                    Text("扩展修饰符")
                        .font(.headline)
                    
                    Text("使用扩展的修饰符")
                        .roundedCard()
                    
                    Text("带边框的文本")
                        .borderedText()
                    
                    Text("发光效果")
                        .glowEffect()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("自定义修饰符")
    }
}

// MARK: - 自定义修饰符定义

// 基础卡片样式
struct CustomCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.white)
            .cornerRadius(12)
            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

// 阴影样式
struct CustomShadowModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
            .shadow(color: .blue.opacity(0.5), radius: 8, x: 0, y: 4)
    }
}

// 渐变样式
struct CustomGradientModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [.purple, .blue]),
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .foregroundColor(.white)
            .cornerRadius(10)
    }
}

// 交互式样式
struct CustomInteractiveModifier: ViewModifier {
    let isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(isActive ? Color.green : Color.gray.opacity(0.2))
            .foregroundColor(isActive ? .white : .primary)
            .cornerRadius(8)
            .scaleEffect(isActive ? 1.1 : 1.0)
    }
}

// 组合样式1
struct CustomCombinedModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(Color.orange.opacity(0.2))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.orange, lineWidth: 2)
            )
            .shadow(color: .orange.opacity(0.3), radius: 6, x: 0, y: 3)
    }
}

// 组合样式2
struct CustomCombinedModifier2: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.pink, .purple]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
            )
            .foregroundColor(.white)
            .shadow(color: .purple.opacity(0.4), radius: 10, x: 0, y: 5)
    }
}

// 动态样式
struct CustomDynamicModifier: ViewModifier {
    let style: Int
    
    func body(content: Content) -> some View {
        content
            .padding()
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(cornerRadius)
            .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
    }
    
    private var backgroundColor: Color {
        switch style {
        case 0: return .blue.opacity(0.2)
        case 1: return .green.opacity(0.2)
        case 2: return .red.opacity(0.2)
        default: return .gray.opacity(0.2)
        }
    }
    
    private var foregroundColor: Color {
        switch style {
        case 0: return .blue
        case 1: return .green
        case 2: return .red
        default: return .primary
        }
    }
    
    private var cornerRadius: CGFloat {
        switch style {
        case 0: return 8
        case 1: return 12
        case 2: return 20
        default: return 8
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case 0: return .blue.opacity(0.3)
        case 1: return .green.opacity(0.3)
        case 2: return .red.opacity(0.3)
        default: return .gray.opacity(0.3)
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case 0: return 4
        case 1: return 6
        case 2: return 8
        default: return 4
        }
    }
    
    private var shadowOffset: CGFloat {
        switch style {
        case 0: return 2
        case 1: return 3
        case 2: return 4
        default: return 2
        }
    }
}

// MARK: - 扩展修饰符
extension View {
    func customCardStyle() -> some View {
        self.modifier(CustomCardModifier())
    }
    
    func customShadowStyle() -> some View {
        self.modifier(CustomShadowModifier())
    }
    
    func customGradientStyle() -> some View {
        self.modifier(CustomGradientModifier())
    }
    
    func customInteractiveStyle(isActive: Bool) -> some View {
        self.modifier(CustomInteractiveModifier(isActive: isActive))
    }
    
    func customCombinedStyle() -> some View {
        self.modifier(CustomCombinedModifier())
    }
    
    func customCombinedStyle2() -> some View {
        self.modifier(CustomCombinedModifier2())
    }
    
    func customDynamicStyle(style: Int) -> some View {
        self.modifier(CustomDynamicModifier(style: style))
    }
    
    func roundedCard() -> some View {
        self
            .padding()
            .background(Color.cyan.opacity(0.1))
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.cyan, lineWidth: 1)
            )
    }
    
    func borderedText() -> some View {
        self
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color.yellow.opacity(0.2))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color.yellow, lineWidth: 2)
            )
    }
    
    func glowEffect() -> some View {
        self
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(8)
            .shadow(color: .purple.opacity(0.6), radius: 8, x: 0, y: 0)
    }
}

#Preview {
    NavigationView {
        CustomModifierExampleView()
    }
}
