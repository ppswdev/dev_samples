//
//  TransitionExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct TransitionExampleView: View {
    @State private var showingView = false
    @State private var selectedTransition = 0
    @State private var showingCustomTransition = false
    
    let transitions = [
        ("滑动", AnyTransition.slide),
        ("缩放", AnyTransition.scale),
        ("淡入淡出", AnyTransition.opacity),
        ("移动", AnyTransition.move(edge: .trailing)),
        ("不对称", AnyTransition.asymmetric(
            insertion: .scale.combined(with: .opacity),
            removal: .slide
        ))
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("转场动画示例")
                    .font(.title)
                    .padding()
                
                // 基础转场动画
                VStack {
                    Text("基础转场动画")
                        .font(.headline)
                    
                    Picker("选择转场效果", selection: $selectedTransition) {
                        ForEach(0..<transitions.count, id: \.self) { index in
                            Text(transitions[index].0).tag(index)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    ZStack {
                        if showingView {
                            RoundedRectangle(cornerRadius: 20)
                                .fill(LinearGradient(
                                    gradient: Gradient(colors: [.blue, .purple]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ))
                                .frame(width: 200, height: 150)
                                .overlay(
                                    VStack {
                                        Image(systemName: "star.fill")
                                            .font(.system(size: 40))
                                            .foregroundColor(.white)
                                        Text("转场视图")
                                            .font(.title2)
                                            .foregroundColor(.white)
                                    }
                                )
                                .transition(transitions[selectedTransition].1)
                        }
                    }
                    .frame(height: 150)
                    
                    Button(showingView ? "隐藏" : "显示") {
                        withAnimation(.easeInOut(duration: 0.8)) {
                            showingView.toggle()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 自定义转场动画
                VStack {
                    Text("自定义转场动画")
                        .font(.headline)
                    
                    ZStack {
                        if showingCustomTransition {
                            CustomTransitionView()
                                .transition(.customTransition)
                        }
                    }
                    .frame(height: 200)
                    
                    Button(showingCustomTransition ? "隐藏" : "显示") {
                        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                            showingCustomTransition.toggle()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 组合转场动画
                VStack {
                    Text("组合转场动画")
                        .font(.headline)
                    
                    CombinedTransitionExample()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("转场动画")
    }
}

struct CustomTransitionView: View {
    var body: some View {
        VStack(spacing: 15) {
            Image(systemName: "heart.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
            
            Text("自定义转场")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("这是一个自定义的转场效果")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(15)
        .shadow(radius: 10)
    }
}

struct CombinedTransitionExample: View {
    @State private var showingCard = false
    @State private var cardIndex = 0
    
    let cards = [
        ("卡片1", Color.blue),
        ("卡片2", Color.green),
        ("卡片3", Color.orange),
        ("卡片4", Color.purple)
    ]
    
    var body: some View {
        VStack(spacing: 20) {
            ZStack {
                if showingCard {
                    RoundedRectangle(cornerRadius: 15)
                        .fill(cards[cardIndex].1)
                        .frame(width: 250, height: 150)
                        .overlay(
                            VStack {
                                Text(cards[cardIndex].0)
                                    .font(.title)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                Text("组合转场效果")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .scale.combined(with: .opacity).combined(with: .slide),
                            removal: .scale.combined(with: .opacity)
                        ))
                }
            }
            .frame(height: 150)
            
            HStack(spacing: 20) {
                Button("上一张") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showingCard = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        cardIndex = (cardIndex - 1 + cards.count) % cards.count
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showingCard = true
                        }
                    }
                }
                .disabled(!showingCard)
                
                Button("下一张") {
                    withAnimation(.easeInOut(duration: 0.5)) {
                        showingCard = false
                    }
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                        cardIndex = (cardIndex + 1) % cards.count
                        withAnimation(.easeInOut(duration: 0.5)) {
                            showingCard = true
                        }
                    }
                }
                .disabled(!showingCard)
            }
            
            Button("开始") {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showingCard = true
                }
            }
            .buttonStyle(.borderedProminent)
        }
    }
}

// 自定义转场扩展
extension AnyTransition {
    static var customTransition: AnyTransition {
        AnyTransition.modifier(
            active: CustomTransitionModifier(scale: 0.1, opacity: 0, rotation: 180),
            identity: CustomTransitionModifier(scale: 1.0, opacity: 1, rotation: 0)
        )
    }
}

struct CustomTransitionModifier: ViewModifier {
    let scale: CGFloat
    let opacity: Double
    let rotation: Double
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(scale)
            .opacity(opacity)
            .rotationEffect(.degrees(rotation))
    }
}

#Preview {
    NavigationView {
        TransitionExampleView()
    }
}
