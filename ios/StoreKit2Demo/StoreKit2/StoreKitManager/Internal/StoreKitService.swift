//
//  StoreKitService.swift
//  StoreKitManager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit
import Combine
#if os(iOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif

/// StoreKit 内部服务类
/// 负责与 StoreKit API 交互，处理产品加载、购买、交易监听等核心功能
internal class StoreKitService: ObservableObject {
    private let config: StoreKitConfig
    weak var delegate: StoreKitServiceDelegate?
    
    // 产品数据
    @Published private(set) var allProducts: [Product] = []
    @Published private(set) var purchasedProducts: [Product] = []
    @Published private(set) var subscriptionStatus: Product.SubscriptionInfo.RenewalState?
    
    // 后台任务
    private var transactionListener: Task<Void, Error>?
    private var subscriberTasks: [Task<Void, Never>] = []
    private var cancellables = Set<AnyCancellable>()
    
    // 并发购买保护
    private var isPurchasing = false
    private let purchasingQueue = DispatchQueue(label: "com.storekit.purchasing")
    
    // 当前状态
    private var currentState: StoreKitState = .idle {
        didSet {
            delegate?.service(self, didUpdateState: currentState)
        }
    }
    
    init(config: StoreKitConfig, delegate: StoreKitServiceDelegate) {
        self.config = config
        self.delegate = delegate
        setupSubscribers()
    }
    
    deinit {
        stop()
    }
    
    // MARK: - 公共方法
    
    /// 启动服务
    func start() {
        guard transactionListener == nil else { return }
        
        transactionListener = transactionStatusStream()
        
        Task {
            await retrieveProducts()
            await retrievePurchasedProducts()
        }
    }
    
    /// 停止服务
    func stop() {
        transactionListener?.cancel()
        transactionListener = nil
        
        subscriberTasks.forEach { $0.cancel() }
        subscriberTasks.removeAll()
        
        cancellables.removeAll()
    }
    
    /// 从商店获取产品
    @MainActor
    func retrieveProducts() async {
        currentState = .loadingProducts
        
        do {
            let storeProducts = try await Product.products(for: config.productIds)
            
            var products: [Product] = []
            for product in storeProducts {
                products.append(product)
            }
            
            // 如果需要，按价格排序
            if config.autoSortProducts {
                products = sortByPrice(products)
            }
            
            self.allProducts = products
            currentState = .productsLoaded(products)
            delegate?.service(self, didLoadProducts: products)
            
        } catch {
            currentState = .error(error)
            print("无法从 App Store 获取产品: \(error)")
        }
    }
    
    /// 获取已购买的产品
    @MainActor
    func retrievePurchasedProducts() async {
        currentState = .loadingPurchases
        
        var purchased: [Product] = []
        
        // 遍历用户已购买的产品
        for await verificationResult in Transaction.currentEntitlements {
            do {
                let transaction = try verifyPurchase(verificationResult)
                
                // 检查产品类型并分配到正确的数组
                switch transaction.productType {
                case .nonConsumable:
                    if let product = allProducts.first(where: { $0.id == transaction.productID }) {
                        purchased.append(product)
                    }
                    
                case .nonRenewable:
                    if let product = allProducts.first(where: { $0.id == transaction.productID }) {
                        // 检查过期时间
                        if let expirationDays = config.nonRenewableExpirationDays {
                            let currentDate = Date()
                            guard let expirationDate = Calendar(identifier: .gregorian).date(
                                byAdding: DateComponents(day: expirationDays),
                                to: transaction.purchaseDate) else {
                                continue
                            }
                            
                            if currentDate < expirationDate {
                                purchased.append(product)
                            }
                        } else {
                            // 永不过期
                            purchased.append(product)
                        }
                    }
                    
                case .autoRenewable:
                    if let product = allProducts.first(where: { $0.id == transaction.productID }) {
                        purchased.append(product)
                    }
                    
                default:
                    break
                }
            } catch {
                print("交易验证失败: \(error)")
            }
        }
        
        self.purchasedProducts = purchased
        currentState = .purchasesLoaded
        delegate?.service(self, didUpdatePurchasedProducts: purchased)
        
        // 更新订阅状态
        if let firstAutoRenewable = allProducts.first(where: { $0.type == .autoRenewable }) {
            subscriptionStatus = try? await firstAutoRenewable.subscription?.status.first?.state
            delegate?.service(self, didUpdateSubscriptionStatus: subscriptionStatus)
        }
    }
    
    /// 购买产品（带并发保护）
    func purchase(_ product: Product) async throws {
        // 并发购买保护
        return try await withCheckedThrowingContinuation { continuation in
            purchasingQueue.async { [weak self] in
                guard let self = self else {
                    continuation.resume(throwing: StoreKitError.unknownError)
                    return
                }
                
                guard !self.isPurchasing else {
                    continuation.resume(throwing: StoreKitError.purchaseInProgress)
                    return
                }
                
                self.isPurchasing = true
                
                Task {
                    defer {
                        self.purchasingQueue.async {
                            self.isPurchasing = false
                        }
                    }
                    
                    await self.performPurchase(product, continuation: continuation)
                }
            }
        }
    }
    
    /// 执行购买
    private func performPurchase(_ product: Product, continuation: CheckedContinuation<Void, Error>) async {
        currentState = .purchasing(product.id)
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                do {
                    let transaction = try verifyPurchase(verification)
                    
                    // 如果是消耗品，立即完成交易
                    if product.type == .consumable {
                        await transaction.finish()
                    }
                    
                    await retrievePurchasedProducts()
                    
                    // 非消耗品和订阅在 retrievePurchasedProducts 后完成
                    if product.type != .consumable {
                        await transaction.finish()
                    }
                    
                    currentState = .purchaseSuccess(transaction.productID)
                    continuation.resume()
                } catch {
                    currentState = .purchaseFailed(product.id, error)
                    continuation.resume(throwing: error)
                }
                
            case .pending:
                currentState = .purchasePending(product.id)
                continuation.resume()
                
            case .userCancelled:
                currentState = .purchaseCancelled(product.id)
                continuation.resume()
                
            @unknown default:
                let error = StoreKitError.unknownError
                currentState = .purchaseFailed(product.id, error)
                continuation.resume(throwing: error)
            }
        } catch {
            currentState = .purchaseFailed(product.id, error)
            continuation.resume(throwing: error)
        }
    }
    
    /// 恢复购买
    @MainActor
    func restorePurchases() async throws {
        currentState = .restoringPurchases
        
        do {
            try await AppStore.sync()
            await retrievePurchasedProducts()
            currentState = .restorePurchasesSuccess
        } catch {
            currentState = .restorePurchasesFailed(error)
            throw StoreKitError.restorePurchasesFailed(error)
        }
    }
    
    /// 获取交易历史
    func getTransactionHistory(for productId: String? = nil) async -> [TransactionHistory] {
        var histories: [TransactionHistory] = []
        
        // 查询所有历史交易
        for await verificationResult in Transaction.all {
            do {
                let transaction = try verifyPurchase(verificationResult)
                
                // 如果指定了产品ID，则过滤
                if let productId = productId, transaction.productID != productId {
                    continue
                }
                
                // 查找对应的产品对象
                let product = allProducts.first(where: { $0.id == transaction.productID })
                
                let history = TransactionHistory.from(transaction, product: product)
                histories.append(history)
                
                // 检查是否退款或撤销
                if transaction.revocationDate != nil {
                    await MainActor.run {
                        if transaction.productType == .autoRenewable {
                            currentState = .subscriptionCancelled(transaction.productID)
                        } else {
                            currentState = .purchaseRefunded(transaction.productID)
                        }
                    }
                }
            } catch {
                continue
            }
        }
        
        // 按购买日期倒序排列
        return histories.sorted(by: { $0.purchaseDate > $1.purchaseDate })
    }
    
    /// 获取消耗品的购买历史
    func getConsumablePurchaseHistory(for productId: String) async -> [TransactionHistory] {
        let allHistory = await getTransactionHistory(for: productId)
        return allHistory.filter { history in
            history.product?.type == .consumable
        }
    }
    
    /// 获取订阅详细信息
    func getSubscriptionInfo(for productId: String) async -> SubscriptionInfo? {
        guard let product = allProducts.first(where: { $0.id == productId }),
              product.type == .autoRenewable else {
            return nil
        }
        
        return await SubscriptionInfo.from(product)
    }
    
    /// 打开订阅管理页面
    @MainActor
    func openSubscriptionManagement() {
        guard let url = URL(string: "https://apps.apple.com/account/subscriptions") else { return }
        
        #if os(iOS)
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url)
        }
        #elseif os(macOS)
        NSWorkspace.shared.open(url)
        #endif
    }
    
    /// 取消订阅（打开系统设置）
    @MainActor
    func cancelSubscription(for productId: String) {
        // 在 iOS 上，取消订阅需要通过系统设置
        // 这里打开订阅管理页面
        openSubscriptionManagement()
    }
    
    // MARK: - 私有方法
    
    /// 设置订阅者
    private func setupSubscribers() {
        // 监听产品变化
        $allProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                guard let self = self else { return }
                self.delegate?.service(self, didLoadProducts: products)
            }
            .store(in: &cancellables)
        
        // 监听已购买产品变化
        $purchasedProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                guard let self = self else { return }
                self.delegate?.service(self, didUpdatePurchasedProducts: products)
            }
            .store(in: &cancellables)
        
        // 监听订阅状态变化
        $subscriptionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                self.delegate?.service(self, didUpdateSubscriptionStatus: status)
            }
            .store(in: &cancellables)
    }
    
    /// 验证购买
    private func verifyPurchase<T>(_ verificationResult: VerificationResult<T>) throws -> T {
        switch verificationResult {
        case .unverified(_, let error):
            throw StoreKitError.verificationFailed
        case .verified(let result):
            return result
        }
    }
    
    /// 监听交易状态流
    private func transactionStatusStream() -> Task<Void, Error> {
        return Task.detached { [weak self] in
            guard let self = self else { return }
            
            for await result in Transaction.updates {
                do {
                    let transaction = try self.verifyPurchase(result)
                    
                    // 检查是否退款或撤销
                    if transaction.revocationDate != nil {
                        await MainActor.run {
                            if transaction.productType == .autoRenewable {
                                self.currentState = .subscriptionCancelled(transaction.productID)
                            } else {
                                // 有撤销日期通常表示退款
                                self.currentState = .purchaseRefunded(transaction.productID)
                            }
                        }
                    }
                    
                    await MainActor.run {
                        Task {
                            await self.retrievePurchasedProducts()
                        }
                    }
                    
                    await transaction.finish()
                } catch {
                    print("交易处理失败: \(error)")
                }
            }
        }
    }
    
    /// 按价格排序产品
    private func sortByPrice(_ products: [Product]) -> [Product] {
        products.sorted(by: { $0.price < $1.price })
    }
}

