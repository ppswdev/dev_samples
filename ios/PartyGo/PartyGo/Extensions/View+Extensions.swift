//
//  View+Extensions.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import SwiftUI

/**
 * 视图扩展
 * 
 * 功能说明:
 * - 提供常用的视图修饰符
 * - 使用AppTheme中的配置
 * - 自动响应颜色变化
 */
extension View {
    
    // MARK: - Layout Modifiers
    func standardPadding() -> some View {
        self.padding(AppConstants.UI.padding)
    }
    
    func standardCornerRadius() -> some View {
        self.cornerRadius(AppConstants.UI.cornerRadius)
    }
    
    func standardSpacing() -> some View {
        self.padding(.horizontal, AppConstants.UI.spacing)
    }
    
    // MARK: - Animation Modifiers
    func standardAnimation() -> some View {
        self.animation(.easeInOut(duration: AppConstants.UI.animationDuration), value: true)
    }
    
    // MARK: - Color Modifiers
    func primaryTextColor() -> some View {
        self.foregroundColor(.myTextPrimary)
    }
    
    func secondaryTextColor() -> some View {
        self.foregroundColor(.myTextSecondary)
    }
    
    func placeholderTextColor() -> some View {
        self.foregroundColor(.myPlaceholder)
    }
    
    // MARK: - Background Modifiers
    func primaryBackground() -> some View {
        self.background(.myBackground)
    }
    
    func cardBackground() -> some View {
        self.background(.myCardBackground)
    }
    
    // MARK: - Conditional Modifiers
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
