//
//  StateObjectExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct StateObjectExampleView: View {
    @StateObject private var gameState = GameState()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("@StateObject 示例")
                    .font(.title)
                    .padding()
                
                // 游戏状态示例
                VStack {
                    Text("游戏状态管理")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("分数:")
                            Spacer()
                            Text("\(gameState.score)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("等级:")
                            Spacer()
                            Text("\(gameState.level)")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("生命值:")
                            Spacer()
                            HStack(spacing: 5) {
                                ForEach(0..<gameState.lives, id: \.self) { _ in
                                    Image(systemName: "heart.fill")
                                        .foregroundColor(.red)
                                }
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    HStack(spacing: 15) {
                        Button("得分") {
                            gameState.addScore(10)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("升级") {
                            gameState.levelUp()
                        }
                        .buttonStyle(.borderedProminent)
                        
                        Button("重置") {
                            gameState.resetGame()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 状态对比
                VStack {
                    Text("状态对比")
                        .font(.headline)
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("@StateObject:")
                            Spacer()
                            Text("视图拥有对象")
                                .font(.caption)
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("@ObservedObject:")
                            Spacer()
                            Text("外部传入对象")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                        
                        Text("StateObject 确保对象在视图生命周期内保持存在")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("@StateObject")
    }
}

// MARK: - ObservableObject 类

class GameState: ObservableObject {
    @Published var score = 0
    @Published var level = 1
    @Published var lives = 3
    
    func addScore(_ points: Int) {
        score += points
        if score >= level * 100 {
            levelUp()
        }
    }
    
    func levelUp() {
        level += 1
        lives += 1
    }
    
    func resetGame() {
        score = 0
        level = 1
        lives = 3
    }
}

#Preview {
    NavigationView {
        StateObjectExampleView()
    }
}
