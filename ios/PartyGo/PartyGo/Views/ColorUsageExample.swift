//
//  ColorUsageExample.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import SwiftUI

/**
 * 颜色使用示例
 * 
 * 展示如何在界面中使用颜色系统
 */
struct ColorUsageExample: View {
    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.UI.spacingLarge) {
                // 主要颜色示例
                colorSection(title: "主要颜色", colors: [
                    ("主色", .primary),
                    ("次色", .secondary),
                    ("强调", .accent)
                ])
                
                // 背景颜色示例
                colorSection(title: "背景颜色", colors: [
                    ("背景", .backgroundMain),
                    ("次背景", .backgroundSecondary),
                    ("卡片", .card)
                ])
                
                // 文本颜色示例
                textColorSection()
                
                // 功能颜色示例
                colorSection(title: "功能颜色", colors: [
                    ("成功", .success),
                    ("警告", .warning),
                    ("错误", .error),
                    ("信息", .info)
                ])
                
        
                
                // 实际使用示例
                practicalUsageSection()
            }
            .padding(AppConstants.UI.padding)
        }.primaryBackground()
    }
    
    // MARK: - 外观模式指示器
   
    
    // MARK: - 颜色展示区域
    private func colorSection(title: String, colors: [(String, Color)]) -> some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.spacing) {
            Text(title)
                .font(.headline)
                .primaryTextColor()
            
            HStack(spacing: AppConstants.UI.spacing) {
                ForEach(colors, id: \.0) { name, color in
                    VStack {
                        RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                            .fill(color)
                            .frame(height: 40)
                            .overlay(
                                Text(name)
                                    .font(.caption)
                                    .foregroundColor(.white)
                            )
                    }
                }
            }
        }
    }
    
    // MARK: - 文本颜色示例
    private func textColorSection() -> some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.spacing) {
            Text("文本颜色")
                .font(.headline)
                .primaryTextColor()
            
            VStack(alignment: .leading, spacing: AppConstants.UI.spacingSmall) {
                Text("主要文本").primaryTextColor()
                Text("次要文本").secondaryTextColor()
                Text("占位符文本").placeholderTextColor()
            }
        }
    }
    

    
    // MARK: - 实际使用示例
    private func practicalUsageSection() -> some View {
        VStack(alignment: .leading, spacing: AppConstants.UI.spacingLarge) {
            Text("实际使用示例")
                .font(.headline)
                .primaryTextColor()
            
            // 卡片示例
            VStack(alignment: .leading, spacing: AppConstants.UI.spacing) {
                Text("卡片标题")
                    .font(.headline)
                    .primaryTextColor()
                
                Text("这是卡片的内容描述，展示如何使用颜色系统。")
                    .font(.body)
                    .secondaryTextColor()
                
                HStack(spacing: AppConstants.UI.spacing) {
                    Button("确认") { }
                        .successButtonStyle()
                    
                    Button("取消") { }
                        .secondaryButtonStyle()
                }
            }
            .cardStyle()
        }
    }
}

#Preview {
    ColorUsageExample()
}
