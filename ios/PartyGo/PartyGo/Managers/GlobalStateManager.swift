//
//  GlobalStateManager.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/20.
//

import SwiftUI
import Foundation
import Combine

/**
 * 全局状态管理器
 * 
 * 管理整个应用生命周期的公共状态，包括：
 * - 用户状态（登录、VIP、订阅等）
 * - 应用配置（主题、语言、设置等）
 * - 网络状态
 * - 缓存状态
 * - 业务状态
 */
@MainActor
class GlobalStateManager: ObservableObject {
    // MARK: - 单例
    static let shared = GlobalStateManager()
    
    // MARK: - 发布者
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - 用户状态
    @AppStorage("appuuid") var userId: String = ""
    @AppStorage("isVip") var isVip: Bool = false
    @AppStorage("vipExpireDate") var vipExpireDate: TimeInterval = 0
    @AppStorage("isFirstLaunch") var isFirstLaunch: Bool = true
    
    // MARK: - 应用配置
    @AppStorage("appTheme") var appTheme: AppTheme = .system
    @AppStorage("appLanguage") var appLanguage: AppLanguage = .chineseSimplified
    @AppStorage("appVersion") var appVersion: String = ""
    @AppStorage("buildNumber") var buildNumber: String = ""
    @AppStorage("lastUpdateCheck") var lastUpdateCheck: TimeInterval = 0
    @AppStorage("soundEnabled") var soundEnabled: Bool = true
    @AppStorage("hapticFeedbackEnabled") var hapticFeedbackEnabled: Bool = true
    
    // MARK: - 网络状态
    @Published var networkStatus: NetworkStatus = .unknown
    @Published var networkType: NetworkType = .unknown
    @Published var isNetworkAvailable: Bool = false
    
    // MARK: - 应用状态
    @Published var appState: AppState = .launching
    @Published var isLoading: Bool = false
    @Published var loadingMessage: String = ""
    @Published var errorMessage: String = ""
    @Published var showError: Bool = false
    
    // MARK: - 缓存状态
    @Published var cacheSize: Int64 = 0
    @Published var lastCacheCleanup: Date = Date()
    
    // MARK: - 业务状态
    @Published var currentTab: AppTab = .home
    @Published var unreadMessageCount: Int = 0
    @Published var pendingNotifications: Int = 0
    @Published var lastSyncTime: Date = Date()
    
    // MARK: - 枚举定义
    
    enum AppTheme: String, CaseIterable {
        case light = "light"
        case dark = "dark"
        case system = "system"
        
        var displayName: String {
            switch self {
            case .light: return "浅色"
            case .dark: return "深色"
            case .system: return "跟随系统"
            }
        }
    }
    
    enum AppLanguage: String, CaseIterable {
        case arabic = "ar"
        case german = "de"
        case english = "en"
        case spanish = "es"
        case filipino = "fil"
        case french = "fr"
        case indonesian = "id"
        case italian = "it"
        case japanese = "ja"
        case korean = "ko"
        case polish = "pl"
        case portuguese = "pt"
        case russian = "ru"
        case thai = "th"
        case turkish = "tr"
        case vietnamese = "vi"
        case chineseSimplified = "zh-Hans"
        case chineseTraditional = "zh-Hant"
        
        var displayName: String {
            switch self {
            case .arabic: return "العربية"
            case .german: return "Deutsch"
            case .english: return "English"
            case .spanish: return "Español"
            case .filipino: return "Filipino"
            case .french: return "Français"
            case .indonesian: return "Bahasa Indonesia"
            case .italian: return "Italiano"
            case .japanese: return "日本語"
            case .korean: return "한국어"
            case .polish: return "Polski"
            case .portuguese: return "Português"
            case .russian: return "Русский"
            case .thai: return "ไทย"
            case .turkish: return "Türkçe"
            case .vietnamese: return "Tiếng Việt"
            case .chineseSimplified: return "简体中文"
            case .chineseTraditional: return "繁體中文"
            }
        }
        
        var nativeName: String {
            switch self {
            case .arabic: return "العربية"
            case .german: return "Deutsch"
            case .english: return "English"
            case .spanish: return "Español"
            case .filipino: return "Filipino"
            case .french: return "Français"
            case .indonesian: return "Bahasa Indonesia"
            case .italian: return "Italiano"
            case .japanese: return "日本語"
            case .korean: return "한국어"
            case .polish: return "Polski"
            case .portuguese: return "Português"
            case .russian: return "Русский"
            case .thai: return "ไทย"
            case .turkish: return "Türkçe"
            case .vietnamese: return "Tiếng Việt"
            case .chineseSimplified: return "简体中文"
            case .chineseTraditional: return "繁體中文"
            }
        }
        
        var flag: String {
            switch self {
            case .arabic: return "🇸🇦"
            case .german: return "🇩🇪"
            case .english: return "🇺🇸"
            case .spanish: return "🇪🇸"
            case .filipino: return "🇵🇭"
            case .french: return "🇫🇷"
            case .indonesian: return "🇮🇩"
            case .italian: return "🇮🇹"
            case .japanese: return "🇯🇵"
            case .korean: return "🇰🇷"
            case .polish: return "🇵🇱"
            case .portuguese: return "🇵🇹"
            case .russian: return "🇷🇺"
            case .thai: return "🇹🇭"
            case .turkish: return "🇹🇷"
            case .vietnamese: return "🇻🇳"
            case .chineseSimplified: return "🇨🇳"
            case .chineseTraditional: return "🇨🇳"
            }
        }
        
        var locale: Locale {
            return Locale(identifier: self.rawValue)
        }
        
        var isRTL: Bool {
            return self == .arabic
        }
    }
    
    enum NetworkStatus: String {
        case unknown = "unknown"
        case connected = "connected"
        case disconnected = "disconnected"
        case connecting = "connecting"
        
        var description: String {
            switch self {
            case .unknown: return "未知"
            case .connected: return "已连接"
            case .disconnected: return "已断开"
            case .connecting: return "连接中"
            }
        }
    }
    
    enum AppState: String {
        case launching = "launching"
        case loading = "loading"
        case ready = "ready"
        case error = "error"
        case background = "background"
        
        var description: String {
            switch self {
            case .launching: return "启动中"
            case .loading: return "加载中"
            case .ready: return "就绪"
            case .error: return "错误"
            case .background: return "后台"
            }
        }
    }
    
    enum AppTab: String, CaseIterable {
        case home = "home"
        case explore = "explore"
        case profile = "profile"
        case settings = "settings"
        
        var displayName: String {
            switch self {
            case .home: return "首页"
            case .explore: return "探索"
            case .profile: return "个人"
            case .settings: return "设置"
            }
        }
        
        var iconName: String {
            switch self {
            case .home: return "house.fill"
            case .explore: return "magnifyingglass"
            case .profile: return "person.fill"
            case .settings: return "gear"
            }
        }
    }
    
    // MARK: - 初始化
    private init() {
        setupInitialState()
        setupNetworkMonitoring()
        setupNotificationObservers()
        print("✅ GlobalStateManager - 初始化完成")
    }
    
    // MARK: - 设置方法
    
    /**
     * 设置初始状态
     */
    private func setupInitialState() {
        // 获取应用版本信息
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        }
        if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            buildNumber = build
        }
        
        // 设置应用状态
        appState = .launching
    }
    
    /**
     * 设置网络监控
     */
    private func setupNetworkMonitoring() {
        // 监听网络状态变化
        NotificationCenter.default.publisher(for: .networkStatusChanged)
            .sink { [weak self] notification in
                self?.handleNetworkStatusChange(notification)
            }
            .store(in: &cancellables)
    }
    
    /**
     * 设置通知观察者
     */
    private func setupNotificationObservers() {
        // 监听应用生命周期
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppDidBecomeActive()
            }
            .store(in: &cancellables)
        
        NotificationCenter.default.publisher(for: UIApplication.didEnterBackgroundNotification)
            .sink { [weak self] _ in
                self?.handleAppDidEnterBackground()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - 用户状态管理
    
    /**
     * 用户登录
     */
    func login(userId: String, userName: String, email: String) {
        print("✅ GlobalStateManager - 用户登录成功: \(userName)")
        
        // 发送登录成功通知
        NotificationCenter.default.post(name: .userDidLogin, object: nil)
    }
    
    /**
     * 用户登出
     */
    func logout() {
        // 清除用户数据
        
        print("✅ GlobalStateManager - 用户登出")
        
        // 发送登出通知
        NotificationCenter.default.post(name: .userDidLogout, object: nil)
    }
    
    /**
     * 升级为 VIP
     */
    func upgradeToVip(expireDate: TimeInterval) {
        isVip = true
        vipExpireDate = expireDate
        
        print("✅ GlobalStateManager - 用户升级为 VIP，到期时间: \(expireDate)")
        
        // 发送 VIP 升级通知
        NotificationCenter.default.post(name: .userDidUpgradeToVip, object: nil)
    }
    
    /**
     * 检查 VIP 是否过期
     */
    func checkVipExpiration() -> Bool {
        if !isVip { return false }
        
        let isExpired = Date().timeIntervalSince1970 > vipExpireDate
        if isExpired {
            isVip = false
            print("❌ GlobalStateManager - VIP 已过期")
            
            // 发送 VIP 过期通知
            NotificationCenter.default.post(name: .userVipDidExpire, object: nil)
        }
        
        return !isExpired
    }
    
    // MARK: - 应用配置管理
    
    /**
     * 切换主题
     */
    func switchTheme(_ theme: AppTheme) {
        appTheme = theme
        print("✅ GlobalStateManager - 切换主题: \(theme.displayName)")
        
        // 发送主题切换通知
        NotificationCenter.default.post(name: .appThemeDidChange, object: theme)
    }
    
    /**
     * 切换语言
     */
    func switchLanguage(_ language: AppLanguage) {
        appLanguage = language
        print("✅ GlobalStateManager - 切换语言: \(language.displayName)")
        
        // 发送语言切换通知
        NotificationCenter.default.post(name: .appLanguageDidChange, object: language)
    }
    
    /**
     * 切换标签页
     */
    func switchTab(_ tab: AppTab) {
        currentTab = tab
        print("✅ GlobalStateManager - 切换标签页: \(tab.displayName)")
    }
    
    // MARK: - 加载状态管理
    
    /**
     * 开始加载
     */
    func startLoading(_ message: String = "加载中...") {
        isLoading = true
        loadingMessage = message
        appState = .loading
        
        print("�� GlobalStateManager - 开始加载: \(message)")
    }
    
    /**
     * 结束加载
     */
    func stopLoading() {
        isLoading = false
        loadingMessage = ""
        appState = .ready
        
        print("✅ GlobalStateManager - 加载完成")
    }
    
    /**
     * 显示错误
     */
    func showError(_ message: String) {
        errorMessage = message
        showError = true
        appState = .error
        
        print("❌ GlobalStateManager - 显示错误: \(message)")
        
        // 3秒后自动隐藏错误
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.hideError()
        }
    }
    
    /**
     * 隐藏错误
     */
    func hideError() {
        showError = false
        if appState == .error {
            appState = .ready
        }
    }
    
    // MARK: - 网络状态处理
    
    /**
     * 处理网络状态变化
     */
    private func handleNetworkStatusChange(_ notification: Notification) {
        if let userInfo = notification.userInfo,
           let status = userInfo["status"] as? NetworkStatus {
            networkStatus = status
            isNetworkAvailable = (status == .connected)
            
            print("�� GlobalStateManager - 网络状态变化: \(status.description)")
        }
    }
    
    // MARK: - 应用生命周期处理
    
    /**
     * 应用变为活跃状态
     */
    private func handleAppDidBecomeActive() {
        appState = .ready
        lastSyncTime = Date()
        
        // 检查 VIP 过期
        checkVipExpiration()
        
        print("�� GlobalStateManager - 应用变为活跃状态")
    }
    
    /**
     * 应用进入后台
     */
    private func handleAppDidEnterBackground() {
        appState = .background
        
        print("�� GlobalStateManager - 应用进入后台")
    }
    
    // MARK: - 缓存管理
    
    /**
     * 清理缓存
     */
    func clearCache() {
        // 这里实现具体的缓存清理逻辑
        cacheSize = 0
        lastCacheCleanup = Date()
        
        print("🗑️ GlobalStateManager - 缓存清理完成")
    }
    
    /**
     * 获取缓存大小
     */
    func calculateCacheSize() {
        // 这里实现具体的缓存大小计算逻辑
        // 示例：cacheSize = 计算出的缓存大小
    }
    
    // MARK: - 工具方法
    
    /**
     * 重置所有状态
     */
    func resetAllState() {
        // 重置所有状态到初始值
        logout()
        
        print("�� GlobalStateManager - 重置所有状态")
    }
}

// MARK: - 通知扩展
extension Notification.Name {
    static let userDidLogin = Notification.Name("userDidLogin")
    static let userDidLogout = Notification.Name("userDidLogout")
    static let userDidUpgradeToVip = Notification.Name("userDidUpgradeToVip")
    static let userVipDidExpire = Notification.Name("userVipDidExpire")
    static let appThemeDidChange = Notification.Name("appThemeDidChange")
    static let appLanguageDidChange = Notification.Name("appLanguageDidChange")
}
