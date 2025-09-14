//
//  View+ColorModifiers.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import SwiftUI

/**
 * 颜色相关的视图修饰符
 * 
 * 功能说明:
 * - 提供常用的颜色样式修饰符
 * - 使用AppTheme中的配置
 * - 自动响应外观模式变化
 */
extension View {
    
    /// 应用卡片样式
    func cardStyle() -> some View {
        self
            .padding(AppConstants.UI.padding)
            .background(.myCardBackground)
            .cornerRadius(AppConstants.UI.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.UI.cornerRadius)
                    .stroke(.myBorder, lineWidth: AppConstants.UI.borderWidth)
            )
            .shadow(
                color: .myShadow,
                radius: AppConstants.UI.shadowRadius,
                x: 0,
                y: 2
            )
    }
    
    /// 应用主要按钮样式
    func primaryButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .padding(AppConstants.UI.padding)
            .background(.primary)
            .cornerRadius(AppConstants.UI.cornerRadius)
    }
    
    /// 应用次要按钮样式
    func secondaryButtonStyle() -> some View {
        self
            .foregroundColor(.primary)
            .padding(AppConstants.UI.padding)
            .background(.primary.opacity(0.1))
            .cornerRadius(AppConstants.UI.cornerRadius)
    }
    
    /// 应用成功按钮样式
    func successButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .padding(AppConstants.UI.padding)
            .background(.mySuccess)
            .cornerRadius(AppConstants.UI.cornerRadius)
    }
    
    /// 应用错误按钮样式
    func errorButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .padding(AppConstants.UI.padding)
            .background(.myError)
            .cornerRadius(AppConstants.UI.cornerRadius)
    }
    
    /// 应用警告按钮样式
    func warningButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .padding(AppConstants.UI.padding)
            .background(.myWarning)
            .cornerRadius(AppConstants.UI.cornerRadius)
    }
    
    /// 应用信息按钮样式
    func infoButtonStyle() -> some View {
        self
            .foregroundColor(.white)
            .padding(AppConstants.UI.padding)
            .background(.myInfo)
            .cornerRadius(AppConstants.UI.cornerRadius)
    }
}

extension View {
    func textStroke(strokeColor: Color = .black, strokeWidth: CGFloat = 2, offset: CGSize = CGSize(width: 1, height: 1)) -> some View {
        modifier(TextStrokeModifier(strokeColor: strokeColor, strokeWidth: strokeWidth, offset: offset))
    }
}