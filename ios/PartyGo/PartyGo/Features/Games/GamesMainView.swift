//
//  GamesMainView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/27.
//

import SwiftUI

struct GamesMainView: View {
    var body: some View {
        NavigationView {
            List {
                Section("小游戏") {
                    NavigationLink(destination: DiceDemoView()) {
                        HStack {
                            Image(systemName: "dice.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("3D骰子")
                                    .font(.headline)
                                
                                Text("体验真实的3D骰子效果")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    NavigationLink(destination: SceneKitDemoView()) {
                        HStack {
                            Image(systemName: "dice.fill")
                                .foregroundColor(.blue)
                                .frame(width: 30)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SceneKit Demo")
                                    .font(.headline)
                                
                                Text("体验真实的3D骰子效果")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        .padding(.vertical, 4)
                    }
                    
                    // 可以在这里添加更多游戏
                    HStack {
                        Image(systemName: "gamecontroller.fill")
                            .foregroundColor(.green)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("更多游戏")
                                .font(.headline)
                            
                            Text("敬请期待更多精彩游戏")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                    .opacity(0.6)
                }
                
                Section("游戏统计") {
                    HStack {
                        Image(systemName: "chart.bar.fill")
                            .foregroundColor(.orange)
                            .frame(width: 30)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("游戏记录")
                                .font(.headline)
                            
                            Text("查看你的游戏历史记录")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                    .opacity(0.6)
                }
            }
            .navigationTitle("游戏中心")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

#Preview {
    GamesMainView()
}
