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
    
    /// 已购买产品更新回调: 有效的交易，每个产品最新的交易
    public var onPurchasedTransactionsUpdated: (([Transaction],[Transaction]) -> Void)?
    
    // MARK: - 当前状态和数据
    
    /// 当前执行的状态
    public private(set) var currentState: StoreKitState = .idle
    
    /// 所有产品
    public private(set) var allProducts: [Product] = []
    
    /// 已购买有效的交易信息
    public private(set) var purchasedTransactions: [Transaction] = []
    
    /// 每个产品的最新交易记录集合
    public private(set) var latestTransactions: [Transaction] = []
    
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
        return latestTransactions.contains(where: { $0.productID == productId })
    }
    
    /// 检查产品是否通过家庭共享获得
    /// - Parameter productId: 产品ID
    /// - Returns: 如果是通过家庭共享获得返回 true，否则返回 false
    /// - Note: 只有支持家庭共享的产品才能通过家庭共享获得
    public func isFamilyShared(productId: String) -> Bool {
        guard let transaction = latestTransactions.first(where: { $0.productID == productId }) else {
            return false
        }
        return transaction.ownershipType == .familyShared
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
        await service?.loadPurchasedTransactions()
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
    public func getSubscriptionInfo(for productId: String) async -> ValidSubscriptionInfo? {
        guard let product = allProducts.first(where: { $0.id == productId }) else {
            return nil
        }
        return await ValidSubscriptionInfo.from(product)
    }
    
    /// 获取订阅续订信息
    /// - Parameter productId: 产品ID
    /// - Returns: 续订信息，如果不是订阅产品或获取失败则返回 nil
    /// - Note: RenewalInfo 包含 willAutoRenew（是否自动续订）、expirationDate（过期日期）、renewalDate（续订日期）等信息
    public func getRenewalInfo(for productId: String) async -> RenewalInfo? {
        guard let product = allProducts.first(where: { $0.id == productId }),
              let subscription = product.subscription else {
            return nil
        }
        
        do {
            let statuses = try await subscription.status
            if let status = statuses.first,
               case .verified(let renewalInfo) = status.renewalInfo {
                return renewalInfo
            }
        } catch {
            print("获取续订信息失败: \(error)")
            return nil
        }
        return nil
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
    
    /// 显示优惠代码兑换界面（iOS 16.0+）
    /// - Throws: StoreKitError 如果显示失败
    /// - Note: 兑换后的交易会通过 Transaction.updates 发出
    @MainActor
    @available(iOS 16.0, visionOS 1.0, *)
    @available(macOS, unavailable)
    @available(watchOS, unavailable)
    @available(tvOS, unavailable)
    public func presentOfferCodeRedeemSheet() async throws {
        guard let service = service else {
            throw StoreKitError.serviceNotStarted
        }
        try await service.presentOfferCodeRedeemSheet()
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
        purchasedTransactions = efficient
        
        // 通知代理
        delegate?.storeKit(self, didUpdatePurchasedTransactions: efficient, latests: latests)
        
        // 通知闭包回调
        onPurchasedTransactionsUpdated?(efficient, latests)
    }
}

