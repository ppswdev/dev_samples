//
//  PartyGoApp.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import SwiftUI
import SwiftData

@main
struct PartyGoApp: App {
    // MARK: - 状态管理
    @StateObject private var appInitService = AppInitService.shared
    @StateObject private var networkService = NetworkService.shared
    @State private var isLaunching = true
    @State private var showNetworkError = false
    
    // MARK: - SwiftData配置
    // Swift6 改进的并发模型
    @MainActor
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema, 
            isStoredInMemoryOnly: false,
            allowsSave: true
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ZStack {
                // MARK: - 启动页面和主界面切换
                if isLaunching {
                    // 动态启动页面
                    LaunchScreenView()
                        .transition(.opacity)
                        .zIndex(1)
                } else if showNetworkError {
                    // 无网络检测页面
                    NonetworkDetectedView()
                        .transition(.opacity)
                        .zIndex(2)
                } else {
                    // 主界面
                    ExampleRootView()
                        .transition(.opacity)
                        .zIndex(0)
                }
            }
            .animation(.easeInOut(duration: 1.2), value: isLaunching)
            .animation(.easeInOut(duration: 0.8), value: showNetworkError)
            .preferredColorScheme(.dark) // 动态外观模式
            .environment(\.locale, .init(identifier: "zh_CN")) // 中文本地化
            .onAppear {
                startAppInitialization()
            }
            .onReceive(NotificationCenter.default.publisher(for: .appInitialized)) { _ in
                // 初始化完成，检查网络状态
                checkNetworkAndProceed()
            }
            .onReceive(NotificationCenter.default.publisher(for: .networkStatusChanged)) { _ in
                checkNetworkAndProceed()
            }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - 私有方法
    
    /**
     * 开始应用初始化
     * 
     * 启动初始化服务并设置最小显示时间
     */
    private func startAppInitialization() {
        // 启动初始化服务
        Task {
            await appInitService.initializeApp()
        }
        
        // 确保启动页面至少显示3秒，提供良好的用户体验
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            // 如果初始化还没完成，等待初始化完成
            if !appInitService.isInitialized {
                // 继续等待初始化完成通知
                return
            }
            // 如果初始化已完成，检查网络状态
            checkNetworkAndProceed()
        }
    }
    
    /**
     * 检查网络状态并决定下一步
     * 
     * 如果网络可用，切换到主界面；否则显示无网络页面
     */
    private func checkNetworkAndProceed() {
        // 如果还在启动状态，先切换到非启动状态
        if isLaunching {
            withAnimation(.easeInOut(duration: 1.2)) {
                isLaunching = false
            }
        }
        
        // 检查网络状态
        if !networkService.isNetworkAvailable {
            // 网络不可用，显示无网络页面
            withAnimation(.easeInOut(duration: 0.8)) {
                showNetworkError = true
            }
        } else {
            // 网络可用，确保不显示无网络页面
            showNetworkError = false
        }
    }
}
