//
//  RootViewManager.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/20.
//

import SwiftUI
import Foundation

/**
 * 根视图管理器
 * 
 * 管理应用的页面流程：
 * 启动加载页面 -> 网络检查 -> 启动加载页面(带进度条) -> 引导页/订阅页 -> 首页
 */
@MainActor
class RootViewManager: ObservableObject {
    // MARK: - 单例
    static let shared = RootViewManager()
    
    // MARK: - 页面状态
    @Published var currentPage: AppPage = .launchLoading
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // MARK: - 应用状态
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @AppStorage("isVip") private var isVip = false
    
    // MARK: - 页面枚举
    enum AppPage: String, CaseIterable {
        case launchLoading = "launchLoading"           // 启动加载页面
        case noNetwork = "noNetwork"                   // 无网络页面
        case progressLoading = "progressLoading"       // 启动加载页面(带进度条)
        case onboarding = "onboarding"                 // 引导页面
        case trial = "trial"                           // 试订页面
        case detainment = "detainment"                   // 挽留页面
        case subscription = "subscription"             // 订阅页面
        case home = "home"                             // 首页
        
        var title: String {
            switch self {
            case .launchLoading: return "启动加载"
            case .noNetwork: return "无网络"
            case .progressLoading: return "进度加载"
            case .onboarding: return "引导页"
            case .trial: return "试订页"
            case .detainment: return "挽留页"
            case .subscription: return "订阅页"
            case .home: return "首页"
            }
        }
    }
    
    // MARK: - 初始化
    private init() {
        print("�� RootViewManager - 初始化完成")
    }
    
    // MARK: - 公共方法
    
    /**
     * 开始应用流程
     */
    func startAppFlow() {
        print("�� RootViewManager - 开始应用流程")
        currentPage = .launchLoading
        isLoading = true
        
        // 启动页面显示3秒
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.checkNetworkAndProceed()
        }
    }
    
    /**
     * 检查网络状态并决定下一步
     */
    func checkNetworkAndProceed() {
        let networkService = NetworkService.shared
        
        if !networkService.isNetworkAvailable {
            print("�� RootViewManager - 网络不可用，显示无网络页面")
            switchToPage(.noNetwork)
        } else {
            print("�� RootViewManager - 网络可用，进入进度加载页面")
            startProgressLoading()
        }
    }
    
    /**
     * 网络恢复处理
     */
    func handleNetworkRestored() {
        print("�� RootViewManager - 网络恢复，进入进度加载页面")
        startProgressLoading()
    }
    
    /**
     * 开始进度加载
     */
    func startProgressLoading() {
        switchToPage(.progressLoading)
        
        // 启动应用初始化服务
        Task {
            await AppInitService.shared.initializeApp()
        }
        
        // 监听初始化完成
        NotificationCenter.default.addObserver(
            forName: .appInitialized,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            Task { @MainActor in
               self?.handleInitializationComplete()
           }
        }
    }
    
    /**
     * 处理初始化完成
     */
    private func handleInitializationComplete() {
        print("✅ RootViewManager - 初始化完成，决定下一步页面")
        
        if isFirstLaunch {
            // 首次运行，进入引导页
            print("�� RootViewManager - 首次运行，进入引导页")
            switchToPage(.onboarding)
        } else {
            // 非首次运行，检查订阅状态
            if isVip {
                // 已有订阅，直接进入首页
                print("�� RootViewManager - 已有订阅，进入首页")
                switchToPage(.home)
            } else {
                // 无订阅，进入订阅页
                print("�� RootViewManager - 无订阅，进入订阅页")
                switchToPage(.subscription)
            }
        }
    }
    
    /**
     * 切换到指定页面
     */
    func switchToPage(_ page: AppPage, animated: Bool = true) {
        print("�� RootViewManager - 切换页面: \(currentPage.title) -> \(page.title)")
        
        if animated {
            withAnimation(.easeInOut(duration: 0.8)) {
                currentPage = page
            }
        } else {
            currentPage = page
        }
    }
    
    /**
     * 获取当前页面状态描述
     */
    func getCurrentPageDescription() -> String {
        return "当前页面: \(currentPage.title)"
    }
}

// MARK: - 页面视图组件

/**
 * 启动加载页面
 */
struct LaunchLoadingView: View {
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: Double = 0.0
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                    .scaleEffect(logoScale)
                    .opacity(logoOpacity)
                
                // 应用名称
                Text("PartyGo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .opacity(logoOpacity)
                
                // 加载指示器
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .scaleEffect(1.5)
            }
        }
        .onAppear {
            startAnimation()
        }
    }
    
    private func startAnimation() {
        withAnimation(.easeInOut(duration: 1.0)) {
            logoScale = 1.0
            logoOpacity = 1.0
        }
    }
}

/**
 * 进度加载页面
 */
struct ProgressLoadingView: View {
    @StateObject private var appInitService = AppInitService.shared
    
    var body: some View {
        ZStack {
            // 背景
            LinearGradient(
                colors: [Color.blue, Color.purple],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Logo
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                // 应用名称
                Text("PartyGo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                // 进度条
                VStack(spacing: 15) {
                    ProgressView(value: appInitService.initializationProgress)
                        .progressViewStyle(LinearProgressViewStyle(tint: .white))
                        .scaleEffect(x: 1, y: 2, anchor: .center)
                    
                    Text(appInitService.currentStep)
                        .font(.headline)
                        .foregroundColor(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                    
                    if let errorMessage = appInitService.errorMessage {
                        Text("错误: \(errorMessage)")
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }
                .frame(maxWidth: 300)
                
                // 进度百分比
                Text("\(Int(appInitService.initializationProgress * 100))%")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
            }
            .padding()
        }
    }
}

/**
 * 引导页面
 */
struct OnboardingView: View {
    @EnvironmentObject var rootManager: RootViewManager
    @State private var currentPage = 0
    
    private let onboardingPages = [
        OnboardingPage(
            image: "star.fill",
            title: "欢迎使用 PartyGo",
            description: "让您的派对更加精彩"
        ),
        OnboardingPage(
            image: "heart.fill",
            title: "简单易用",
            description: "一键创建和管理您的派对"
        ),
        OnboardingPage(
            image: "person.3.fill",
            title: "社交互动",
            description: "与朋友分享美好时光"
        )
    ]
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<onboardingPages.count, id: \.self) { index in
                OnboardingPageView(page: onboardingPages[index])
                    .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle())
        .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
        .overlay(
            VStack {
                Spacer()
                
                Button("继续") {
                    if currentPage == onboardingPages.count - 1 {
                        rootManager.switchToPage(.trial, animated: true)
                    }else{
                        currentPage += 1
                    }
                }
                .buttonStyle(.borderedProminent)
                .padding(.bottom, 50)
            }
        )
    }
}

struct OnboardingPage {
    let image: String
    let title: String
    let description: String
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: page.image)
                .font(.system(size: 100))
                .foregroundColor(.blue)
            
            Text(page.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(page.description)
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
        .padding()
    }
}

/**
 * 试订页面
 */
struct TrialView: View {
    @EnvironmentObject var rootManager: RootViewManager
    @AppStorage("isVip") private var isVip = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "gift.fill")
                .font(.system(size: 80))
                .foregroundColor(.blue)
            
            Text("免费试用")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("体验 PartyGo 的全部功能，7天免费试用")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(spacing: 15) {
                Button("开始试用") {
                    isVip = true
                    rootManager.switchToPage(.home, animated: true)
                }
                .buttonStyle(.borderedProminent)
                
                Button("跳过试用") {
                    rootManager.switchToPage(.detainment, animated: true)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

/**
 * 挽留页面
 */
struct DetainmentView: View {
    @EnvironmentObject var rootManager: RootViewManager
    @AppStorage("isVip") private var isVip = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 80))
                .foregroundColor(.red)
            
            Text("我们舍不得您离开")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("再给我们一次机会，体验更多精彩功能")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(spacing: 15) {
                Button("关闭挽留页") {
                    rootManager.switchToPage(.home, animated: true)
                }
                .buttonStyle(.borderedProminent)
                
                Button("订阅成功") {
                    isVip = true
                    rootManager.switchToPage(.home, animated: true)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}

/**
 * 订阅页面
 */
struct SubscriptionView: View {
    @EnvironmentObject var rootManager: RootViewManager
    @AppStorage("isVip") private var isVip = false
    
    var body: some View {
        VStack(spacing: 30) {
            Image(systemName: "crown.fill")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
            
            Text("升级到高级版")
                .font(.largeTitle)
                .fontWeight(.bold)
            
            Text("解锁所有功能，享受无限制的派对体验")
                .font(.title3)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
            
            VStack(spacing: 15) {
                Button("立即订阅") {
                    isVip = true
                    rootManager.switchToPage(.home, animated: true)
                }
                .buttonStyle(.borderedProminent)
                
                Button("稍后再说") {
                    rootManager.switchToPage(.home, animated: true)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
    }
}
