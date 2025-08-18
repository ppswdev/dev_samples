//
//  AppConstants.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import Foundation

/**
 * 应用常量定义
 * 
 * 功能说明:
 * - 集中管理应用中的基础常量
 * - 不包含UI和颜色相关的配置
 * - 提供统一的配置入口
 */
enum AppConstants {
    // MARK: - App Info
    static let appName = "PartyGo"
    static let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    static let appBuildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    
    // MARK: - 网络配置
    enum Network {
        static let baseURL = "https://api.partygo.com"
        static let timeoutInterval: TimeInterval = 30
        static let maxRetryCount = 3
    }
    
    // MARK: - 存储配置
    enum Storage {
        static let maxCacheSize: Int64 = 100 * 1024 * 1024 // 100MB
        static let cacheExpirationDays = 7
    }
    
    // MARK: - 功能配置
    enum Features {
        static let enableAnalytics = true
        static let enableCrashReporting = true
        static let enablePushNotifications = true
    }
    
    // MARK: - 启动配置
    enum Launch {
        static let minimumDisplayTime: Double = 2.5
        static let animationDuration: Double = 0.8
        static let transitionDuration: Double = 0.5
    }
    
    // MARK: - UI Constants
    enum UI {
        static let cornerRadius: CGFloat = 12
        static let padding: CGFloat = 16
        static let spacing: CGFloat = 8
        static let animationDuration: Double = 0.3
        static let shadowRadius: CGFloat = 8
        static let shadowOpacity: Double = 0.1
        static let borderWidth: CGFloat = 1
        
        // 字体大小
        static let fontSize: CGFloat = 16
        static let fontSizeSmall: CGFloat = 14
        static let fontSizeLarge: CGFloat = 18
        static let fontSizeTitle: CGFloat = 24
        
        // 间距
        static let spacingSmall: CGFloat = 4
        static let spacingMedium: CGFloat = 8
        static let spacingLarge: CGFloat = 16
        static let spacingExtraLarge: CGFloat = 24
    }
}
