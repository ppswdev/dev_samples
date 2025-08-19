//
//  LaunchScreenView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import SwiftUI

/**
 * 启动页面视图
 * 
 * 功能说明:
 * - 显示App启动时的动态启动页面
 * - 提供品牌展示和加载状态
 * - 与静态启动屏幕保持视觉一致性
 * 
 * 设计原则:
 * 1. 简洁性: 只显示核心品牌元素
 * 2. 连续性: 从静态启动屏幕平滑过渡
 * 3. 信息性: 显示加载进度和状态
 * 4. 品牌性: 强化品牌形象和视觉识别
 */
struct LaunchScreenView: View {
    // MARK: - 状态管理
    @State private var isAnimating = false
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    @State private var textOpacity: Double = 0.0
    @State private var progressOpacity: Double = 0.0
    @State private var rotationAngle: Double = 0.0
    
    // MARK: - 动画配置
    private let animationDuration: Double = 1.0
    private let textDelay: Double = 0.3
    private let progressDelay: Double = 0.6
    
    var body: some View {
        ZStack {
            // MARK: - 背景设计
            // 使用与静态启动屏幕一致的背景
            Color(.backgroundMain)
                .ignoresSafeArea()
            
            // MARK: - 主要内容区域
            VStack(spacing: 40) {
                // MARK: - Logo和品牌区域
                VStack(spacing: 25) {
                    // App图标 - 带动画效果
                    ZStack {
                        // 背景光环效果
                        Circle()
                            .fill(Color.white.opacity(0.1))
                            .frame(width: 120, height: 120)
                            .scaleEffect(isAnimating ? 1.2 : 0.8)
                            .opacity(isAnimating ? 0.5 : 0.0)
                            .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: isAnimating)
                        
                        // 主图标
                        Image(systemName: "party.popper.fill")
                            .font(.system(size: 60, weight: .medium))
                            .foregroundColor(.white)
                            .scaleEffect(logoScale)
                            .opacity(logoOpacity)
                            .rotationEffect(.degrees(rotationAngle))
                            .animation(.easeInOut(duration: animationDuration), value: logoScale)
                            .animation(.easeInOut(duration: animationDuration), value: logoOpacity)
                            .animation(.easeInOut(duration: 3.0).repeatForever(autoreverses: false), value: rotationAngle)
                    }
                    
                    // App名称
                    Text("SwiftUI App")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .opacity(textOpacity)
                        .animation(.easeInOut(duration: animationDuration).delay(textDelay), value: textOpacity)
                    
                    // 副标题/标语
                    Text("让派对更精彩")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .opacity(textOpacity)
                        .animation(.easeInOut(duration: animationDuration).delay(textDelay + 0.2), value: textOpacity)
                }
                
                // MARK: - 加载指示器区域
                VStack(spacing: 15) {
                    // 进度指示器
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.3)
                        .opacity(progressOpacity)
                        .animation(.easeInOut(duration: animationDuration).delay(progressDelay), value: progressOpacity)
                    
                    // 加载文本
                    Text("正在启动...")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(progressOpacity)
                        .animation(.easeInOut(duration: animationDuration).delay(progressDelay + 0.1), value: progressOpacity)
                }
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            startLaunchAnimation()
        }
    }
    
    // MARK: - 动画控制方法
    
    /**
     * 启动动画序列
     * 
     * 动画流程:
     * 1. Logo缩放和透明度动画
     * 2. 文字渐显动画
     * 3. 进度指示器显示
     * 4. 持续的品牌展示动画
     */
    private func startLaunchAnimation() {
        // 启动所有动画
        withAnimation(.easeInOut(duration: animationDuration)) {
            logoScale = 1.0
            logoOpacity = 1.0
            textOpacity = 1.0
            progressOpacity = 1.0
            isAnimating = true
            rotationAngle = 360.0
        }
    }
}

// MARK: - 预览
#Preview {
    LaunchScreenView()
        .preferredColorScheme(.dark)
}
