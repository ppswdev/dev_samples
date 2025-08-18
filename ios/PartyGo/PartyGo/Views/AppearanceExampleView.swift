//
//  AppearanceExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import SwiftUI

/// 外观模式使用示例视图
struct AppearanceExampleView: View {
    @Environment(\.appearanceManager) private var appearanceManager
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // 状态信息卡片
                StatusCard()
                
                // 主题相关UI示例
                ThemeExamplesCard()
                
                // 动态内容示例
                DynamicContentCard()
            }
            .padding()
        }
        .navigationTitle("外观模式示例")
        .navigationBarTitleDisplayMode(.large)
    }
}

/// 状态信息卡片
struct StatusCard: View {
    @Environment(\.appearanceManager) private var appearanceManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("当前状态")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(alignment: .leading, spacing: 8) {
                StatusRow(
                    title: "用户设置",
                    value: appearanceManager.currentAppearanceMode.displayName,
                    icon: appearanceManager.currentAppearanceMode.iconName
                )
                
                StatusRow(
                    title: "有效模式",
                    value: appearanceManager.currentEffectiveMode.displayName,
                    icon: appearanceManager.currentEffectiveMode.iconName
                )
                
                StatusRow(
                    title: "是否为深色",
                    value: appearanceManager.isDarkMode ? "是" : "否",
                    icon: appearanceManager.isDarkMode ? "moon.fill" : "sun.max.fill"
                )
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

/// 主题示例卡片
struct ThemeExamplesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("主题示例")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 16) {
                // 按钮示例
                HStack {
                    Button("主要按钮") { }
                        .buttonStyle(.borderedProminent)
                    
                    Button("次要按钮") { }
                        .buttonStyle(.bordered)
                }
                
                // 卡片示例
                HStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("示例卡片")
                            .font(.headline)
                        Text("这是一个示例卡片，展示不同主题下的视觉效果")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    Spacer()
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .cornerRadius(8)
                
                // 分割线
                Divider()
                
                // 图标示例
                HStack(spacing: 20) {
                    ForEach(["star.fill", "heart.fill", "bookmark.fill"], id: \.self) { icon in
                        Image(systemName: icon)
                            .font(.title2)
                            .foregroundColor(.accentColor)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

/// 动态内容卡片
struct DynamicContentCard: View {
    @Environment(\.appearanceManager) private var appearanceManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("动态内容")
                .font(.headline)
                .foregroundColor(.primary)
            
            VStack(spacing: 12) {
                // 根据主题显示不同内容
                if appearanceManager.isDarkMode {
                    HStack {
                        Image(systemName: "moon.stars.fill")
                            .foregroundColor(.yellow)
                        Text("深色模式已启用，适合夜间使用")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                } else {
                    HStack {
                        Image(systemName: "sun.max.fill")
                            .foregroundColor(.orange)
                        Text("浅色模式已启用，适合日间使用")
                            .font(.caption)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                
                // 主题相关的颜色示例
                HStack {
                    Circle()
                        .fill(Color.primary)
                        .frame(width: 20, height: 20)
                    Text("主色调")
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.secondary)
                        .frame(width: 20, height: 20)
                    Text("次要色调")
                    
                    Spacer()
                    
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 20, height: 20)
                    Text("强调色")
                }
                .font(.caption)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(12)
        .shadow(radius: 2)
    }
}

/// 状态行组件
struct StatusRow: View {
    let title: String
    let value: String
    let icon: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(.accentColor)
                .frame(width: 20)
            
            Text(title)
                .foregroundColor(.secondary)
            
            Spacer()
            
            Text(value)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    NavigationView {
        AppearanceExampleView()
            .environment(\.appearanceManager, AppearanceManager.shared)
    }
}
