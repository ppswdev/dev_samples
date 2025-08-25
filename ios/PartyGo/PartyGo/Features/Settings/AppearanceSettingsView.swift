//
//  AppearanceSettingsView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/25.
//

import SwiftUI

/**
 * 外观模式设置视图
 */
struct AppearanceSettingsView: View {
    @EnvironmentObject var globalState: GlobalStateManager
    @Environment(\.colorScheme) var colorScheme
    
    var body: some View {
        List {
            ForEach(GlobalStateManager.AppTheme.allCases, id: \.self) { theme in
                Button {
                    globalState.switchTheme(theme)
                } label: {
                    HStack {
                        // 主题图标
                        Image(systemName: themeIcon(for: theme))
                            .foregroundColor(themeColor(for: theme))
                            .frame(width: 24)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(theme.displayName)
                                .font(.body)
                            
                            Text(themeDescription(for: theme))
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        // 选中状态
                        if globalState.appTheme == theme {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                                .font(.headline)
                        }
                        
                        // 预览效果
                        Circle()
                            .fill(themePreviewColor(for: theme))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: 1)
                            )
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .navigationTitle("外观模式")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - 私有方法
    
    /**
     * 获取主题图标
     */
    private func themeIcon(for theme: GlobalStateManager.AppTheme) -> String {
        switch theme {
        case .light:
            return "sun.max.fill"
        case .dark:
            return "moon.fill"
        case .system:
            return "gear"
        }
    }
    
    /**
     * 获取主题颜色
     */
    private func themeColor(for theme: GlobalStateManager.AppTheme) -> Color {
        switch theme {
        case .light:
            return .orange
        case .dark:
            return .purple
        case .system:
            return .blue
        }
    }
    
    /**
     * 获取主题描述
     */
    private func themeDescription(for theme: GlobalStateManager.AppTheme) -> String {
        switch theme {
        case .light:
            return "使用浅色主题，适合明亮环境"
        case .dark:
            return "使用深色主题，适合夜间使用"
        case .system:
            return "跟随系统设置自动切换"
        }
    }
    
    /**
     * 获取主题预览颜色
     */
    private func themePreviewColor(for theme: GlobalStateManager.AppTheme) -> Color {
        switch theme {
        case .light:
            return .white
        case .dark:
            return .black
        case .system:
            return colorScheme == .dark ? .black : .white
        }
    }
}
#Preview {
    AppearanceSettingsView()
}
