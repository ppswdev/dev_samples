//
//  AppInitializationService.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import Foundation
import SwiftData

/**
 * 应用初始化服务
 * 
 * 功能说明:
 * - 管理应用启动时的初始化流程
 * - 处理数据预加载和配置设置
 * - 提供启动状态通知
 * - 网络连接检测和管理
 * 
 * 初始化流程:
 * 1. 基础配置初始化
 * 2. 数据模型准备
 * 3. 用户数据加载
 * 4. 网络服务检查
 * 5. UI资源准备
 */
@MainActor
class AppInitService: ObservableObject {
    // MARK: - 单例模式
    static let shared = AppInitService()
    
    // MARK: - 发布状态
    @Published var initializationProgress: Double = 0.0
    @Published var currentStep: String = "准备中..."
    @Published var isInitialized = false
    @Published var errorMessage: String?
    
    // MARK: - 私有属性
    private var initializationSteps: [InitializationStep] = []
    private let totalSteps: Int = 5
    
    // MARK: - 初始化步骤枚举
    private enum InitializationStep: CaseIterable {
        case basicConfig
        case dataModel
        case userData
        case networkCheck
        case uiResources
        
        var description: String {
            switch self {
            case .basicConfig:
                return "初始化基础配置"
            case .dataModel:
                return "准备数据模型"
            case .userData:
                return "加载用户数据"
            case .networkCheck:
                return "检查网络连接"
            case .uiResources:
                return "准备UI资源"
            }
        }
        
        var progress: Double {
            switch self {
            case .basicConfig: return 0.2
            case .dataModel: return 0.4
            case .userData: return 0.6
            case .networkCheck: return 0.8
            case .uiResources: return 1.0
            }
        }
    }
    
    private init() {
        setupInitializationSteps()
    }
    
    // MARK: - 公共方法
    
    /**
     * 开始应用初始化流程
     * 
     * 使用Swift6的并发特性进行异步初始化
     * 每个步骤都有独立的错误处理和进度更新
     */
    func initializeApp() async {
        guard !isInitialized else { return }
        
        do {
            // 执行所有初始化步骤
            for step in InitializationStep.allCases {
                try await performInitializationStep(step)
            }
            
            // 初始化完成
            await completeInitialization()
            
        } catch {
            await handleInitializationError(error)
        }
    }
    
    // MARK: - 私有方法
    
    /**
     * 设置初始化步骤
     */
    private func setupInitializationSteps() {
        initializationSteps = InitializationStep.allCases
    }
    
    /**
     * 执行单个初始化步骤
     * 
     * @param step 要执行的初始化步骤
     * @throws 初始化过程中的错误
     */
    private func performInitializationStep(_ step: InitializationStep) async throws {
        // 更新当前步骤
        await updateCurrentStep(step.description)
        
        // 模拟步骤执行时间（实际项目中替换为真实逻辑）
        try await Task.sleep(nanoseconds: UInt64(0.5 * 1_000_000_000))
        
        // 执行具体步骤
        switch step {
        case .basicConfig:
            try await initializeBasicConfig()
        case .dataModel:
            try await prepareDataModel()
        case .userData:
            try await loadUserData()
        case .networkCheck:
            try await checkNetworkConnection()
        case .uiResources:
            try await prepareUIResources()
        }
        
        // 更新进度
        await updateProgress(step.progress)
    }
    
    /**
     * 初始化基础配置
     */
    private func initializeBasicConfig() async throws {
        // 设置应用配置
        UserDefaults.standard.set(true, forKey: "app_initialized")
        
        // 配置日志系统
        print("📱 PartyGo App - 基础配置初始化完成")
        
        // 模拟可能的错误
        if Bool.random() && false { // 设置为false避免随机错误
            throw InitializationError.configurationFailed
        }
    }
    
    /**
     * 准备数据模型
     */
    private func prepareDataModel() async throws {
        // 检查SwiftData模型
        // 在实际项目中，这里会进行数据模型验证
        print("📊 PartyGo App - 数据模型准备完成")
    }
    
    /**
     * 加载用户数据
     */
    private func loadUserData() async throws {
        // 加载用户偏好设置
        // 检查是否有保存的用户数据
        let hasUserData = UserDefaults.standard.bool(forKey: "has_user_data")
        
        if !hasUserData {
            // 创建默认用户数据
            UserDefaults.standard.set(true, forKey: "has_user_data")
            print("👤 PartyGo App - 创建默认用户数据")
        } else {
            print("👤 PartyGo App - 用户数据加载完成")
        }
    }
    
    /**
     * 检查网络连接
     */
    private func checkNetworkConnection() async throws {
        // 使用NetworkService检查网络连接
        let isConnected = await NetworkService.shared.checkNetworkConnection()
        
        if isConnected {
            print("🌐 PartyGo App - 网络连接检查完成")
        } else {
            print("❌ PartyGo App - 网络连接不可用")
            // 注意：这里不抛出错误，允许应用在没有网络的情况下继续运行
            // 但会设置网络状态为不可用
        }
    }
    
    /**
     * 准备UI资源
     */
    private func prepareUIResources() async throws {
        // 预加载图片资源
        // 准备动画资源
        print("🎨 PartyGo App - UI资源准备完成")
    }
    
    /**
     * 完成初始化
     */
    private func completeInitialization() async {
        isInitialized = true
        currentStep = "启动完成"
        initializationProgress = 1.0
        
        print("✅ PartyGo App - 初始化完成")
        
        // 发送初始化完成通知
        NotificationCenter.default.post(name: .appInitialized, object: nil)
    }
    
    /**
     * 处理初始化错误
     */
    private func handleInitializationError(_ error: Error) async {
        errorMessage = error.localizedDescription
        print("❌ PartyGo App - 初始化失败: \(error)")
    }
    
    /**
     * 更新当前步骤
     */
    private func updateCurrentStep(_ step: String) async {
        await MainActor.run {
            currentStep = step
        }
    }
    
    /**
     * 更新进度
     */
    private func updateProgress(_ progress: Double) async {
        await MainActor.run {
            initializationProgress = progress
        }
    }
}

// MARK: - 错误定义

/**
 * 初始化错误类型
 */
enum InitializationError: LocalizedError {
    case configurationFailed
    case dataModelError
    case userDataError
    case networkError
    case resourceError
    
    var errorDescription: String? {
        switch self {
        case .configurationFailed:
            return "基础配置初始化失败"
        case .dataModelError:
            return "数据模型准备失败"
        case .userDataError:
            return "用户数据加载失败"
        case .networkError:
            return "网络连接检查失败"
        case .resourceError:
            return "UI资源准备失败"
        }
    }
}

// MARK: - 通知扩展

extension Notification.Name {
    static let appInitialized = Notification.Name("appInitialized")
}
