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
    @StateObject private var networkService = NetworkService.shared
    @StateObject private var rootManager = RootViewManager.shared
    @StateObject private var globalState = GlobalStateManager.shared
    
    // MARK: - SwiftData配置
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
            Group {
                switch rootManager.currentPage {
                case .launchLoading:
                    LaunchLoadingView()
                case .noNetwork:
                    NonetworkDetectedView()
                case .progressLoading:
                    ProgressLoadingView()
                case .onboarding:
                    OnboardingView()
                case .trial:
                    TrialView()
                case .detainment:
                    DetainmentView()
                case .subscription:
                    SubscriptionView()
                case .home:
                    ExampleRootView()
                }
            }
            .animation(.easeInOut(duration: 0.8), value: rootManager.currentPage)
            .environmentObject(networkService)
            .environmentObject(rootManager)
            .environmentObject(globalState)
            .preferredColorScheme(globalState.appTheme == .dark ? .dark : 
                                    globalState.appTheme == .light ? .light : nil)
            .environment(\.locale, Locale(identifier: globalState.appLanguage.rawValue))
            .id(globalState.appLanguage.rawValue)
            .onAppear {
                print("当前是会员状态: \(globalState.isVip)")
                rootManager.startAppFlow()
            }.onReceive(NotificationCenter.default.publisher(for: .networkStatusChanged)) { _ in
                print("🌐 PartyGo App 接收到网络变化：\(networkService.networkStatus)")
            }
        }
        .modelContainer(sharedModelContainer)
    }
}
