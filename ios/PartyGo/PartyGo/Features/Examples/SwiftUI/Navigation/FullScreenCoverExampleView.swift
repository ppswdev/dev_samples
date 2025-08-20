//
//  FullScreenCoverExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct FullScreenCoverExampleView: View {
    @State private var showingFullScreen = false
    @State private var showingVideoPlayer = false
    @State private var showingGameView = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("FullScreenCover 示例")
                .font(.title)
            
            Text("点击按钮显示全屏模态视图")
                .foregroundColor(.secondary)
            
            // 基础全屏覆盖
            Button("显示基础全屏覆盖") {
                showingFullScreen = true
            }
            .buttonStyle(.borderedProminent)
            
            // 视频播放器
            Button("显示视频播放器") {
                showingVideoPlayer = true
            }
            .buttonStyle(.bordered)
            
            // 游戏视图
            Button("显示游戏视图") {
                showingGameView = true
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("FullScreenCover 示例")
        .fullScreenCover(isPresented: $showingFullScreen) {
            BasicFullScreenView()
        }
        .fullScreenCover(isPresented: $showingVideoPlayer) {
            VideoPlayerView()
        }
        .fullScreenCover(isPresented: $showingGameView) {
            GameView()
        }
    }
}

struct BasicFullScreenView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            // 背景渐变
            LinearGradient(
                gradient: Gradient(colors: [.blue, .purple]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                Image(systemName: "rectangle.expand.vertical")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("全屏覆盖视图")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("这是一个全屏模态视图，通常用于视频播放、游戏等需要全屏体验的场景")
                    .font(.body)
                    .foregroundColor(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                Button("关闭") {
                    dismiss()
                }
                .font(.title2)
                .foregroundColor(.blue)
                .padding()
                .background(Color.white)
                .cornerRadius(10)
            }
        }
    }
}

struct VideoPlayerView: View {
    @Environment(\.dismiss) var dismiss
    @State private var isPlaying = false
    @State private var progress = 0.0
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 20) {
                // 模拟视频播放器
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 200)
                    
                    VStack {
                        Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                            .font(.system(size: 50))
                            .foregroundColor(.white)
                        
                        Text(isPlaying ? "播放中..." : "暂停")
                            .foregroundColor(.white)
                    }
                }
                .onTapGesture {
                    isPlaying.toggle()
                }
                
                // 进度条
                VStack {
                    ProgressView(value: progress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    
                    HStack {
                        Text("00:00")
                            .foregroundColor(.white)
                        Spacer()
                        Text("02:30")
                            .foregroundColor(.white)
                    }
                    .font(.caption)
                }
                
                Spacer()
                
                // 控制按钮
                HStack(spacing: 40) {
                    Button("关闭") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.red)
                    .cornerRadius(8)
                }
            }
            .padding()
        }
    }
}

struct GameView: View {
    @Environment(\.dismiss) var dismiss
    @State private var score = 0
    @State private var timeRemaining = 60
    
    var body: some View {
        ZStack {
            // 游戏背景
            LinearGradient(
                gradient: Gradient(colors: [.green, .blue]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // 游戏信息
                HStack {
                    VStack {
                        Text("分数")
                            .font(.caption)
                            .foregroundColor(.white)
                        Text("\(score)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text("时间")
                            .font(.caption)
                            .foregroundColor(.white)
                        Text("\(timeRemaining)")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                    }
                }
                .padding()
                
                // 游戏区域
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.white.opacity(0.2))
                        .frame(height: 300)
                    
                    VStack {
                        Image(systemName: "gamecontroller.fill")
                            .font(.system(size: 60))
                            .foregroundColor(.white)
                        
                        Text("游戏区域")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        Button("点击得分") {
                            score += 10
                        }
                        .padding()
                        .background(Color.orange)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    }
                }
                
                Spacer()
                
                // 退出按钮
                Button("退出游戏") {
                    dismiss()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.red)
                .cornerRadius(10)
            }
            .padding()
        }
    }
}

#Preview {
    NavigationView {
        FullScreenCoverExampleView()
    }
}
