//
//  AppearanceManager.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import SwiftUI
import Foundation

/// 外观模式枚举
enum AppearanceMode: String, CaseIterable, Codable {
    case system = "system"      // 跟随系统
    case light = "light"        // 浅色模式
    case dark = "dark"          // 深色模式
    
    var displayName: String {
        switch self {
        case .system:
            return "跟随系统"
        case .light:
            return "浅色模式"
        case .dark:
            return "深色模式"
        }
    }
    
    var iconName: String {
        switch self {
        case .system:
            return "gear"
        case .light:
            return "sun.max"
        case .dark:
            return "moon"
        }
    }
}

/// 外观模式管理服务
@MainActor
class AppearanceManager: ObservableObject {
    // MARK: - 单例模式
    static let shared = AppearanceManager()
    
    // MARK: - 发布属性
    @Published var currentAppearanceMode: AppearanceMode = .system
    @Published var effectiveColorScheme: ColorScheme? = nil
    
    // MARK: - 私有属性
    private let userDefaults = UserDefaults.standard
    private let appearanceModeKey = "AppearanceMode"
    private var systemColorSchemeObserver: NSObjectProtocol?
    
    // MARK: - 初始化
    private init() {
        loadSavedAppearanceMode()
        setupSystemColorSchemeObserver()
        updateEffectiveColorScheme()
    }
    
    deinit {
        if let observer = systemColorSchemeObserver {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - 公共方法
    
    /// 设置外观模式
    /// - Parameter mode: 目标外观模式
    func setAppearanceMode(_ mode: AppearanceMode) {
        currentAppearanceMode = mode
        saveAppearanceMode()
        updateEffectiveColorScheme()
    }
    
    /// 获取当前有效的外观模式
    var currentEffectiveMode: AppearanceMode {
        if currentAppearanceMode == .system {
            return getSystemAppearanceMode()
        }
        return currentAppearanceMode
    }
    
    /// 切换外观模式（循环切换）
    func toggleAppearanceMode() {
        let allModes = AppearanceMode.allCases
        guard let currentIndex = allModes.firstIndex(of: currentAppearanceMode) else { return }
        
        let nextIndex = (currentIndex + 1) % allModes.count
        setAppearanceMode(allModes[nextIndex])
    }
    
    // MARK: - 私有方法
    
    /// 加载保存的外观模式
    private func loadSavedAppearanceMode() {
        if let savedModeString = userDefaults.string(forKey: appearanceModeKey),
           let savedMode = AppearanceMode(rawValue: savedModeString) {
            currentAppearanceMode = savedMode
        } else {
            // 默认使用系统模式
            currentAppearanceMode = .system
        }
    }
    
    /// 保存外观模式到本地存储
    private func saveAppearanceMode() {
        userDefaults.set(currentAppearanceMode.rawValue, forKey: appearanceModeKey)
    }
    
    /// 设置系统外观模式监听器
    private func setupSystemColorSchemeObserver() {
        systemColorSchemeObserver = NotificationCenter.default.addObserver(
            forName: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handleSystemAppearanceChange()
        }
    }
    
    /// 处理系统外观模式变化
    private func handleSystemAppearanceChange() {
        if currentAppearanceMode == .system {
            updateEffectiveColorScheme()
        }
    }
    
    /// 获取系统当前的外观模式
    private func getSystemAppearanceMode() -> AppearanceMode {
        // 使用UITraitCollection来获取系统外观模式
        let traitCollection = UITraitCollection.current
        return traitCollection.userInterfaceStyle == .dark ? .dark : .light
    }
    
    /// 更新有效的颜色方案
    private func updateEffectiveColorScheme() {
        let effectiveMode = currentEffectiveMode
        effectiveColorScheme = effectiveMode == .dark ? .dark : .light
    }
}

// MARK: - 扩展：便捷访问方法
extension AppearanceManager {
    /// 是否为深色模式
    var isDarkMode: Bool {
        return effectiveColorScheme == .dark
    }
    
    /// 是否为浅色模式
    var isLightMode: Bool {
        return effectiveColorScheme == .light
    }
    
    /// 是否为跟随系统模式
    var isSystemMode: Bool {
        return currentAppearanceMode == .system
    }
}

// MARK: - 扩展：SwiftUI环境值
struct AppearanceModeKey: EnvironmentKey {
    static let defaultValue: AppearanceManager = AppearanceManager.shared
}

extension EnvironmentValues {
    var appearanceManager: AppearanceManager {
        get { self[AppearanceModeKey.self] }
        set { self[AppearanceModeKey.self] = newValue }
    }
}
