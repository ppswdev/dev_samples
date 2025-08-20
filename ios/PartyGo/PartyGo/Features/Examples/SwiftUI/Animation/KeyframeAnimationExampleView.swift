//
//  KeyframeAnimationExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct KeyframeAnimationExampleView: View {
    @State private var isAnimating = false
    @State private var bounceAnimation = false
    @State private var waveAnimation = false
    @State private var pulseAnimation = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("关键帧动画示例")
                    .font(.title)
                    .padding()
                
                // 基础关键帧动画
                VStack {
                    Text("基础关键帧动画")
                        .font(.headline)
                    
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 80, height: 80)
                        .keyframeAnimator(initialValue: KeyframeValues()) { view, value in
                            view
                                .scaleEffect(value.scale)
                                .offset(y: value.offset)
                                .rotationEffect(.degrees(value.rotation))
                        } keyframes: { _ in
                            KeyframeTrack(\.scale) {
                                LinearKeyframe(1.0, duration: 0.5)
                                LinearKeyframe(1.5, duration: 0.5)
                                LinearKeyframe(1.0, duration: 0.5)
                            }
                            
                            KeyframeTrack(\.offset) {
                                LinearKeyframe(0, duration: 0.5)
                                LinearKeyframe(-50, duration: 0.5)
                                LinearKeyframe(0, duration: 0.5)
                            }
                            
                            KeyframeTrack(\.rotation) {
                                LinearKeyframe(0, duration: 0.5)
                                LinearKeyframe(180, duration: 0.5)
                                LinearKeyframe(360, duration: 0.5)
                            }
                        }
                        .onTapGesture {
                            isAnimating.toggle()
                        }
                    
                    Button("开始动画") {
                        isAnimating.toggle()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 弹跳动画
                VStack {
                    Text("弹跳动画")
                        .font(.headline)
                    
                    RoundedRectangle(cornerRadius: 15)
                        .fill(Color.green)
                        .frame(width: 100, height: 100)
                        .keyframeAnimator(initialValue: BounceValues()) { view, value in
                            view
                                .scaleEffect(value.scale)
                                .offset(y: value.offset)
                        } keyframes: { _ in
                            KeyframeTrack(\.scale) {
                                LinearKeyframe(1.0, duration: 0.1)
                                LinearKeyframe(1.2, duration: 0.1)
                                LinearKeyframe(0.8, duration: 0.1)
                                LinearKeyframe(1.1, duration: 0.1)
                                LinearKeyframe(1.0, duration: 0.1)
                            }
                            
                            KeyframeTrack(\.offset) {
                                LinearKeyframe(0, duration: 0.1)
                                LinearKeyframe(-20, duration: 0.1)
                                LinearKeyframe(0, duration: 0.1)
                                LinearKeyframe(-10, duration: 0.1)
                                LinearKeyframe(0, duration: 0.1)
                            }
                        }
                        .onTapGesture {
                            bounceAnimation.toggle()
                        }
                    
                    Button("弹跳") {
                        bounceAnimation.toggle()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 波浪动画
                VStack {
                    Text("波浪动画")
                        .font(.headline)
                    
                    HStack(spacing: 8) {
                        ForEach(0..<5, id: \.self) { index in
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange)
                                .frame(width: 8, height: 40)
                                .keyframeAnimator(initialValue: WaveValues()) { view, value in
                                    view
                                        .scaleEffect(y: value.scale)
                                } keyframes: { _ in
                                    KeyframeTrack(\.scale) {
                                        LinearKeyframe(1.0, duration: 0.2)
                                        LinearKeyframe(2.0, duration: 0.2)
                                        LinearKeyframe(1.0, duration: 0.2)
                                    }
                                }
                                .animationDelay(Double(index) * 0.1)
                        }
                    }
                    .onTapGesture {
                        waveAnimation.toggle()
                    }
                    
                    Button("波浪") {
                        waveAnimation.toggle()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 脉冲动画
                VStack {
                    Text("脉冲动画")
                        .font(.headline)
                    
                    ZStack {
                        // 背景脉冲圈
                        ForEach(0..<3, id: \.self) { index in
                            Circle()
                                .stroke(Color.purple, lineWidth: 2)
                                .frame(width: 120, height: 120)
                                .keyframeAnimator(initialValue: PulseValues()) { view, value in
                                    view
                                        .scaleEffect(value.scale)
                                        .opacity(value.opacity)
                                } keyframes: { _ in
                                    KeyframeTrack(\.scale) {
                                        LinearKeyframe(0.5, duration: 1.0)
                                        LinearKeyframe(1.5, duration: 1.0)
                                    }
                                    
                                    KeyframeTrack(\.opacity) {
                                        LinearKeyframe(1.0, duration: 0.5)
                                        LinearKeyframe(0.0, duration: 0.5)
                                    }
                                }
                                .animationDelay(Double(index) * 0.3)
                        }
                        
                        // 中心图标
                        Image(systemName: "heart.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.purple)
                    }
                    .onTapGesture {
                        pulseAnimation.toggle()
                    }
                    
                    Button("脉冲") {
                        pulseAnimation.toggle()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 重置按钮
                Button("重置所有动画") {
                    isAnimating = false
                    bounceAnimation = false
                    waveAnimation = false
                    pulseAnimation = false
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
        }
        .navigationTitle("关键帧动画")
    }
}

// 关键帧动画数据结构
struct KeyframeValues {
    var scale: Double = 1.0
    var offset: Double = 0
    var rotation: Double = 0
}

struct BounceValues {
    var scale: Double = 1.0
    var offset: Double = 0
}

struct WaveValues {
    var scale: Double = 1.0
}

struct PulseValues {
    var scale: Double = 0.5
    var opacity: Double = 1.0
}

// 动画延迟扩展
extension View {
    func animationDelay(_ delay: Double) -> some View {
        self.animation(.easeInOut(duration: 0.6).delay(delay), value: UUID())
    }
}

#Preview {
    NavigationView {
        KeyframeAnimationExampleView()
    }
}
