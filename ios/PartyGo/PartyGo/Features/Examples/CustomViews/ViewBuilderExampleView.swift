//
//  ViewBuilderExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct ViewBuilderExampleView: View {
    @State private var showContent = true
    @State private var selectedStyle = 0
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("ViewBuilder 示例")
                    .font(.title)
                    .padding()
                
                // 基础ViewBuilder
                VStack {
                    Text("基础ViewBuilder")
                        .font(.headline)
                    
                    CustomContainer {
                        VStack(spacing: 10) {
                            Text("这是ViewBuilder内容")
                                .font(.body)
                            
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                            
                            Text("可以包含任意视图")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 条件ViewBuilder
                VStack {
                    Text("条件ViewBuilder")
                        .font(.headline)
                    
                    ConditionalView(showContent: showContent) {
                        VStack(spacing: 10) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.green)
                            
                            Text("内容已显示")
                                .font(.body)
                        }
                    } else: {
                        VStack(spacing: 10) {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.red)
                            
                            Text("内容已隐藏")
                                .font(.body)
                        }
                    }
                    
                    Button(showContent ? "隐藏内容" : "显示内容") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showContent.toggle()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 样式化ViewBuilder
                VStack {
                    Text("样式化ViewBuilder")
                        .font(.headline)
                    
                    Picker("选择样式", selection: $selectedStyle) {
                        Text("样式1").tag(0)
                        Text("样式2").tag(1)
                        Text("样式3").tag(2)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    StyledContainer(style: selectedStyle) {
                        VStack(spacing: 15) {
                            Image(systemName: "paintbrush.fill")
                                .font(.title)
                                .foregroundColor(.white)
                            
                            Text("样式化容器")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("根据选择的样式显示不同的外观")
                                .font(.caption)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 列表ViewBuilder
                VStack {
                    Text("列表ViewBuilder")
                        .font(.headline)
                    
                    CustomList {
                        ForEach(1...5, id: \.self) { index in
                            HStack {
                                Circle()
                                    .fill(Color.blue)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Text("\(index)")
                                            .font(.caption)
                                            .foregroundColor(.white)
                                            .fontWeight(.bold)
                                    )
                                
                                VStack(alignment: .leading) {
                                    Text("项目 \(index)")
                                        .font(.body)
                                        .fontWeight(.medium)
                                    
                                    Text("这是第 \(index) 个项目的描述")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                
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
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 卡片ViewBuilder
                VStack {
                    Text("卡片ViewBuilder")
                        .font(.headline)
                    
                    HStack(spacing: 15) {
                        CustomCard {
                            VStack(spacing: 10) {
                                Image(systemName: "heart.fill")
                                    .font(.title)
                                    .foregroundColor(.red)
                                
                                Text("喜欢")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        CustomCard {
                            VStack(spacing: 10) {
                                Image(systemName: "star.fill")
                                    .font(.title)
                                    .foregroundColor(.yellow)
                                
                                Text("收藏")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                        
                        CustomCard {
                            VStack(spacing: 10) {
                                Image(systemName: "share")
                                    .font(.title)
                                    .foregroundColor(.blue)
                                
                                Text("分享")
                                    .font(.headline)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("ViewBuilder")
    }
}

// MARK: - ViewBuilder 函数和结构体

struct CustomContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.blue, lineWidth: 2)
        )
    }
}

struct ConditionalView<Content: View, ElseContent: View>: View {
    let showContent: Bool
    let content: Content
    let elseContent: ElseContent
    
    init(showContent: Bool, @ViewBuilder content: () -> Content, @ViewBuilder else: () -> ElseContent) {
        self.showContent = showContent
        self.content = content()
        self.elseContent = `else`()
    }
    
    var body: some View {
        if showContent {
            content
        } else {
            elseContent
        }
    }
}

struct StyledContainer<Content: View>: View {
    let style: Int
    let content: Content
    
    init(style: Int, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .padding()
        .background(backgroundColor)
        .cornerRadius(cornerRadius)
        .shadow(color: shadowColor, radius: shadowRadius, x: 0, y: shadowOffset)
    }
    
    private var backgroundColor: Color {
        switch style {
        case 0: return .blue
        case 1: return .green
        case 2: return .purple
        default: return .blue
        }
    }
    
    private var cornerRadius: CGFloat {
        switch style {
        case 0: return 10
        case 1: return 20
        case 2: return 30
        default: return 10
        }
    }
    
    private var shadowColor: Color {
        switch style {
        case 0: return .blue.opacity(0.3)
        case 1: return .green.opacity(0.3)
        case 2: return .purple.opacity(0.3)
        default: return .blue.opacity(0.3)
        }
    }
    
    private var shadowRadius: CGFloat {
        switch style {
        case 0: return 5
        case 1: return 8
        case 2: return 12
        default: return 5
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

struct CustomList<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack(spacing: 10) {
            content
        }
    }
}

struct CustomCard<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        VStack {
            content
        }
        .frame(width: 80, height: 80)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(15)
        .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 2)
    }
}

#Preview {
    NavigationView {
        ViewBuilderExampleView()
    }
}
