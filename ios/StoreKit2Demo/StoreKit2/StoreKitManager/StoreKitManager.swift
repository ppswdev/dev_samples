//
//  StoreKitManager.swift
//  StoreKitManager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

public typealias SubscriptionInfo = Product.SubscriptionInfo
public typealias SubscriptionStatus = Product.SubscriptionInfo.Status

/// 交易类型别名
public typealias Transaction = StoreKit.Transaction

/// 续订信息类型别名
public typealias RenewalInfo = StoreKit.Product.SubscriptionInfo.RenewalInfo

/// 续订状态类型别名
public typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

/// StoreKit 管理器
/// 提供统一的接口来管理应用内购买
public class StoreKitManager {
    /// 单例实例
    public static let shared = StoreKitManager()
    
    // MARK: - 配置和代理
    
    private var config: StoreKitConfig?
    private weak var delegate: StoreKitDelegate?
    private var service: StoreKitService?
    
    // MARK: - 闭包回调（可选，与代理二选一）
    
    /// 状态变化回调
    public var onStateChanged: ((StoreKitState) -> Void)?
    
    /// 产品加载成功回调
    public var onProductsLoaded: (([Product]) -> Void)?
    
    /// 已购买产品更新回调
    public var onPurchasedTransactionsUpdated: (([Product]) -> Void)?
    
    /// 订阅状态变化回调
    public var onSubscriptionStatusChanged: ((RenewalState?) -> Void)?
    
    // MARK: - 当前状态和数据
    
    /// 当前状态
    public private(set) var currentState: StoreKitState = .idle
    
    /// 所有产品
    public private(set) var allProducts: [Product] = []
    
    /// 已购买的产品
    public private(set) var purchasedProducts: [Product] = []
    
    /// 订阅状态
    public private(set) var subscriptionStatus: RenewalState?
    
    // MARK: - 按类型分类的产品（计算属性）
    
    /// 非消耗品
    public var nonConsumables: [Product] {
        allProducts.filter { $0.type == .nonConsumable }
    }
    
    /// 消耗品
    public var consumables: [Product] {
        allProducts.filter { $0.type == .consumable }
    }
    
    /// 非续订订阅
    public var nonRenewables: [Product] {
        allProducts.filter { $0.type == .nonRenewable }
    }
    
    /// 自动续订订阅
    public var autoRenewables: [Product] {
        allProducts.filter { $0.type == .autoRenewable }
    }
    
    // MARK: - 按类型分类的已购买产品（计算属性）
    
    /// 已购买的非消耗品
    public var purchasedNonConsumables: [Product] {
        purchasedProducts.filter { $0.type == .nonConsumable }
    }
    
    /// 已购买的非续订订阅
    public var purchasedNonRenewables: [Product] {
        purchasedProducts.filter { $0.type == .nonRenewable }
    }
    
    /// 已购买的自动续订订阅
    public var purchasedAutoRenewables: [Product] {
        purchasedProducts.filter { $0.type == .autoRenewable }
    }
    
    // MARK: - 初始化
    
    private init() {}
    
    // MARK: - 配置和启动
    
    /// 使用代理配置管理器
    /// - Parameters:
    ///   - config: 配置对象
    ///   - delegate: 代理对象
    public func configure(with config: StoreKitConfig, delegate: StoreKitDelegate) {
        self.config = config
        self.delegate = delegate
        self.service = StoreKitService(config: config, delegate: self)
        service?.start()
    }
    
    /// 使用闭包配置管理器
    /// - Parameter config: 配置对象
    public func configure(with config: StoreKitConfig) {
        self.config = config
        self.service = StoreKitService(config: config, delegate: self)
        service?.start()
    }
    
    // MARK: - 购买相关
    
    /// 通过产品ID购买产品
    /// - Parameter productId: 产品ID
    /// - Throws: StoreKitError.productNotFound 如果产品未找到
    public func purchase(productId: String) async throws {
        guard let product = allProducts.first(where: { $0.id == productId }) else {
            throw StoreKitError.productNotFound(productId)
        }
        try await service?.purchase(product)
    }
    
    /// 通过产品对象购买
    /// - Parameter product: 产品对象
    /// - Throws: StoreKitError.purchaseInProgress 如果已有购买正在进行
    public func purchase(_ product: Product) async throws {
        guard let service = service else {
            throw StoreKitError.serviceNotStarted
        }
        try await service.purchase(product)
    }
    
    // MARK: - 查询方法
    
    /// 检查产品是否已购买
    /// - Parameter productId: 产品ID
    /// - Returns: 如果已购买返回 true
    public func isPurchased(productId: String) -> Bool {
        return purchasedProducts.contains(where: { $0.id == productId })
    }
    
    /// 获取产品对象
    /// - Parameter productId: 产品ID
    /// - Returns: 产品对象，如果未找到返回 nil
    public func product(for productId: String) -> Product? {
        return allProducts.first(where: { $0.id == productId })
    }
    
    // MARK: - 刷新方法
    
    /// 手动刷新产品列表
    public func refreshProducts() async {
        await service?.loadProducts()
    }
    
    /// 手动刷新已购买产品列表
    public func refreshPurchases() async {
        await service?.retrievePurchasedProducts()
    }
    
    // MARK: - 恢复购买
    
    /// 恢复购买
    /// - Throws: StoreKitError.restorePurchasesFailed 如果恢复失败
    public func restorePurchases() async throws {
        try await service?.restorePurchases()
    }
    
    // MARK: - 交易历史
    
    /// 获取交易历史
    /// - Parameter productId: 可选的产品ID，如果提供则只返回该产品的交易历史
    /// - Returns: 交易历史记录数组，按购买日期倒序排列
    public func getTransactionHistory(for productId: String? = nil) async -> [TransactionHistory] {
        await service?.getTransactionHistory(for: productId) ?? []
    }
    
    /// 获取消耗品的购买历史
    /// - Parameter productId: 产品ID
    /// - Returns: 该消耗品的所有购买历史
    public func getConsumablePurchaseHistory(for productId: String) async -> [TransactionHistory] {
        await service?.getConsumablePurchaseHistory(for: productId) ?? []
    }
    
    // MARK: - 订阅相关
    
    /// 获取订阅详细信息
    /// - Parameter productId: 产品ID
    /// - Returns: 订阅信息，如果不是订阅产品则返回 nil
    public func getSubscriptionInfo(for productId: String) async -> SubscriptionInfo? {
        await service?.getSubscriptionInfo(for: productId)
    }
    
    /// 打开订阅管理页面（使用 URL）
    @MainActor
    public func openSubscriptionManagement() {
        service?.openSubscriptionManagement()
    }
    
    /// 显示应用内订阅管理界面（iOS 15.0+ / macOS 12.0+）
    /// - Returns: 是否成功显示管理界面
    @MainActor
    public func showManageSubscriptionsSheet() async -> Bool {
        await service?.showManageSubscriptionsSheet() ?? false
    }
    
    /// 取消订阅（显示应用内订阅管理界面）
    /// - Parameter productId: 产品ID（可选，如果提供则直接定位到该订阅）
    /// - Returns: 是否成功显示管理界面
    @MainActor
    public func cancelSubscription(for productId: String? = nil) async -> Bool {
        await service?.cancelSubscription(for: productId) ?? false
    }
    
    /// 刷新订阅状态（同步最新的订阅信息）
    /// 在用户取消订阅后调用此方法可以获取最新的订阅状态
    @MainActor
    public func refreshSubscriptionStatus() async {
        await service?.refreshSubscriptionStatus()
    }
    
    // MARK: - 控制方法
    
    /// 停止服务（释放资源）
    public func stop() {
        service?.stop()
        service = nil
        config = nil
        delegate = nil
        currentState = .idle
        allProducts = []
        purchasedProducts = []
        subscriptionStatus = nil
    }
}

// MARK: - StoreKitServiceDelegate

extension StoreKitManager: StoreKitServiceDelegate {
    @MainActor
    func service(_ service: StoreKitService, didUpdateState state: StoreKitState) {
        currentState = state
        
        // 通知代理
        delegate?.storeKit(self, didUpdateState: state)
        
        // 通知闭包回调
        onStateChanged?(state)
    }
    
    @MainActor
    func service(_ service: StoreKitService, didLoadProducts products: [Product]) {
        allProducts = products
        
        // 通知代理
        delegate?.storeKit(self, didLoadProducts: products)
        
        // 通知闭包回调
        onProductsLoaded?(products)
    }
    
    @MainActor
    func service(_ service: StoreKitService, didUpdatePurchasedTransactions efficient: [Transaction], latests: [Transaction]) {
        purchasedProducts = efficient
        
        // 通知代理
        delegate?.storeKit(self, didUpdatePurchasedTransactions: efficient, latests: latests)
        
        // 通知闭包回调
        onPurchasedTransactionsUpdated?(products)
    }
    
    @MainActor
    func service(_ service: StoreKitService, didUpdateSubscriptionStatus status: RenewalState?) {
        subscriptionStatus = status

        // 打印订阅状态
        switch status {
        case .subscribed:
            print("当前订阅状态：已订阅")
        case .expired:
            print("当前订阅状态：已过期")
        case .revoked:
            print("当前订阅状态：已撤销")
        case .inBillingRetryPeriod:
            print("当前订阅状态：在计费重试期")
        case .inGracePeriod:
            print("当前订阅状态：在宽限期")
        default:
            print("当前订阅状态：未知")
        }
        
        // 通知代理
        delegate?.storeKit(self, didUpdateSubscriptionStatus: status)
        
        // 通知闭包回调
        onSubscriptionStatusChanged?(status)
    }
}

