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
            // 确保在主线程调用 delegate
            let state = currentState
            Task { @MainActor [weak self] in
                guard let self = self else { return }
                await self.notifyStateChanged(state)
            }
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
            // delegate 会在 didSet 中通过 notifyStateChanged 调用
            // 这里直接调用 didLoadProducts
            await notifyProductsLoaded(products)
            
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
        // delegate 会在 didSet 中通过 notifyStateChanged 调用
        // 这里直接调用 didUpdatePurchasedProducts
        await notifyPurchasedProductsUpdated(purchased)
        
        // 更新订阅状态
        if let firstAutoRenewable = allProducts.first(where: { $0.type == .autoRenewable }) {
            subscriptionStatus = try? await firstAutoRenewable.subscription?.status.first?.state
            await notifySubscriptionStatusChanged(subscriptionStatus)
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
        await MainActor.run {
            currentState = .purchasing(product.id)
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                do {
                    let transaction = try verifyPurchase(verification)
                    
                    // 打印详细的交易信息
                    await printTransactionDetails(transaction: transaction, product: product)
                    
                    // 如果是消耗品，立即完成交易
                    if product.type == .consumable {
                        await transaction.finish()
                    }
                    
                    await retrievePurchasedProducts()
                    
                    // 非消耗品和订阅在 retrievePurchasedProducts 后完成
                    if product.type != .consumable {
                        await transaction.finish()
                    }
                    
                    await MainActor.run {
                        currentState = .purchaseSuccess(transaction.productID)
                    }
                    continuation.resume()
                } catch {
                    await MainActor.run {
                        currentState = .purchaseFailed(product.id, error)
                    }
                    continuation.resume(throwing: error)
                }
                
            case .pending:
                await MainActor.run {
                    currentState = .purchasePending(product.id)
                }
                continuation.resume()
                
            case .userCancelled:
                await MainActor.run {
                    currentState = .purchaseCancelled(product.id)
                }
                continuation.resume()
                
            @unknown default:
                let error = StoreKitError.unknownError
                await MainActor.run {
                    currentState = .purchaseFailed(product.id, error)
                }
                continuation.resume(throwing: error)
            }
        } catch {
            await MainActor.run {
                currentState = .purchaseFailed(product.id, error)
            }
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
        
        return product.subscription
    }
    
    /// 打开订阅管理页面（使用 URL）
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
    
    /// 显示应用内订阅管理界面（iOS 15.0+ / macOS 12.0+）
    /// - Returns: 是否成功显示（如果系统不支持则返回 false）
    @MainActor
    func showManageSubscriptionsSheet() async -> Bool {
        #if os(iOS)
        if #available(iOS 15.0, *) {
            do {
                // 获取当前的 windowScene
                let windowScene = await UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .first
                
                if let windowScene = windowScene {
                    try await AppStore.showManageSubscriptions(in: windowScene)
                    
                    // 订阅管理界面关闭后，刷新订阅状态
                    await refreshSubscriptionStatus()
                    
                    return true
                } else {
                    // 如果无法获取 windowScene，回退到打开 URL
                    openSubscriptionManagement()
                    return false
                }
            } catch {
                print("显示订阅管理界面失败: \(error)")
                // 如果失败，回退到打开 URL
                openSubscriptionManagement()
                return false
            }
        } else {
            // iOS 15.0 以下使用 URL
            openSubscriptionManagement()
            return false
        }
        #elseif os(macOS)
        if #available(macOS 12.0, *) {
            do {
                try await AppStore.showManageSubscriptions()
                
                // 订阅管理界面关闭后，刷新订阅状态
                await refreshSubscriptionStatus()
                
                return true
            } catch {
                print("显示订阅管理界面失败: \(error)")
                openSubscriptionManagement()
                return false
            }
        } else {
            openSubscriptionManagement()
            return false
        }
        #else
        openSubscriptionManagement()
        return false
        #endif
    }
    
    /// 取消订阅（显示应用内订阅管理界面）
    /// - Parameter productId: 产品ID（可选，如果提供则直接定位到该订阅）
    /// - Returns: 是否成功显示管理界面
    @MainActor
    func cancelSubscription(for productId: String? = nil) async -> Bool {
        // 优先使用应用内订阅管理界面
        let success = await showManageSubscriptionsSheet()
        
        if !success {
            // 如果应用内界面不可用，则打开 URL
            openSubscriptionManagement()
        }
        
        return success
    }
    
    /// 刷新订阅状态（同步最新的订阅信息）
    @MainActor
    func refreshSubscriptionStatus() async {
        // 同步 App Store 的购买状态
        do {
            try await AppStore.sync()
        } catch {
            print("同步 App Store 状态失败: \(error)")
        }
        
        // 重新获取已购买产品（会更新订阅状态）
        await retrievePurchasedProducts()
    }
    
    // MARK: - 私有方法
    
    /// 通知状态变化（在主线程执行）
    @MainActor
    private func notifyStateChanged(_ state: StoreKitState) {
        delegate?.service(self, didUpdateState: state)
    }
    
    /// 通知产品加载（在主线程执行）
    @MainActor
    private func notifyProductsLoaded(_ products: [Product]) {
        delegate?.service(self, didLoadProducts: products)
    }
    
    /// 通知已购买产品更新（在主线程执行）
    @MainActor
    private func notifyPurchasedProductsUpdated(_ products: [Product]) {
        delegate?.service(self, didUpdatePurchasedProducts: products)
    }
    
    /// 通知订阅状态变化（在主线程执行）
    @MainActor
    private func notifySubscriptionStatusChanged(_ status: Product.SubscriptionInfo.RenewalState?) {
        delegate?.service(self, didUpdateSubscriptionStatus: status)
    }
    
    /// 设置订阅者
    private func setupSubscribers() {
        // 监听产品变化
        $allProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                guard let self = self else { return }
                Task { @MainActor in
                    self.notifyProductsLoaded(products)
                }
            }
            .store(in: &cancellables)
        
        // 监听已购买产品变化
        $purchasedProducts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] products in
                guard let self = self else { return }
                Task { @MainActor in
                    self.notifyPurchasedProductsUpdated(products)
                }
            }
            .store(in: &cancellables)
        
        // 监听订阅状态变化
        $subscriptionStatus
            .receive(on: DispatchQueue.main)
            .sink { [weak self] status in
                guard let self = self else { return }
                Task { @MainActor in
                    self.notifySubscriptionStatusChanged(status)
                }
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
    
    /// 打印详细的交易信息
    private func printTransactionDetails(transaction: Transaction, product: Product) async {
        // 时间格式化为东八区（北京时间）
        let beijingTimeZone = TimeZone(secondsFromGMT: 8 * 3600) ?? .current
        let formatter = DateFormatter()
        formatter.timeZone = beijingTimeZone
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"

        print("════════════════════════════════════════")
        print("✅ 购买成功 - 交易详细信息")
        print("════════════════════════════════════════")
        print("📦 产品信息:")
        print("   - 产品ID: \(transaction.productID)")
        print("   - 产品名称: \(product.displayName)")
        print("   - 产品描述: \(product.description)")
        print("   - 产品类型: \(product.type)")
        print("   - 产品价格: \(product.displayPrice)")
        print("   - 价格数值: \(product.price)")
       
        print("")
        print("💳 交易信息:")
        print("   - 交易ID: \(transaction.id)") // 当前交易的唯一标识符
        print("   - 产品ID: \(transaction.productID)") // 购买的产品ID
        print("   - 产品类型: \(transaction.productType)") // 产品类型（消耗品/非消耗品/非续订订阅/自动续订订阅）
        print("   - 购买日期: \(formatter.string(from: transaction.purchaseDate))") // 购买时间（UTC时间）
        print("   - 所有权类型: \(transaction.ownershipType)") // 所有权类型（purchased/familyShared）
        print("   - 原始交易ID: \(transaction.originalID)") // 首次购买的交易ID（用于订阅续订）
        print("   - 原始购买日期: \(formatter.string(from: transaction.originalPurchaseDate))") // 首次购买时间
        
        // 过期日期（仅订阅产品有）
        if let expirationDate = transaction.expirationDate {
            let dateStr = formatter.string(from: expirationDate)
            print("   - 过期日期: \(dateStr)") // 订阅过期时间
        } else {
            print("   - 过期日期: 无")
        }
        
        // 撤销日期（如果已退款/撤销）
        if let revocationDate = transaction.revocationDate {
            let dateStr = formatter.string(from: revocationDate)
            print("   - 撤销日期: \(dateStr)") // 退款或撤销的时间
        } else {
            print("   - 撤销日期: 无")
        }
        
        // 撤销原因
        if let revocationReason = transaction.revocationReason {
            print("   - 撤销原因: \(revocationReason)") // 退款/撤销的原因代码
        }
        print("   - 购买原因: \(transaction.reason.rawValue)") // 购买原因（purchased/upgraded/renewed等）
        print("   - 是否升级: \(transaction.isUpgraded)") // 是否为升级购买
        
        // 购买数量
        print("   - 购买数量: \(transaction.purchasedQuantity)") // 购买的数量
        
        // 价格
        if let price = transaction.price {
            print("   - 交易价格: \(price)") // 实际支付的价格
        }
        
        // 货币代码
        if let currency = transaction.currency {
            print("   - 货币代码: \(currency)") // 货币代码（如CNY、USD）
        }
        print("   - 环境: \(transaction.environment.rawValue)") // 交易环境（sandbox/production）
        print("   - 应用交易ID: \(transaction.appTransactionID)") // 应用级别的交易ID
        print("   - 应用Bundle ID: \(transaction.appBundleID )") // 应用的Bundle标识符
        // 应用账户Token（用于关联用户账户）
        if let appAccountToken = transaction.appAccountToken {
            print("   - 应用账户Token: \(appAccountToken)") // 用于关联用户账户的Token
        }
        // 订阅组ID（仅订阅产品）
        if let subscriptionGroupID = transaction.subscriptionGroupID {
            print("   - 订阅组ID: \(subscriptionGroupID)") // 订阅所属的组ID
        }
        
        // 订阅状态（仅订阅产品）
        //if let subscriptionStatus = await transaction.subscriptionStatus {
        //    print("   - 订阅状态: \(subscriptionStatus)") // 订阅的当前状态
        //}
        
        print("   - 签名日期: \(formatter.string(from: transaction.signedDate))") // 交易签名的日期
        print("   - 商店区域: \(transaction.storefront)") // 商店区域代码
        
        // Web订单行项目ID
        if let webOrderLineItemID = transaction.webOrderLineItemID {
            print("   - Web订单行项目ID: \(webOrderLineItemID)") // Web订单的行项目ID
        }
        print("   - 设备验证: \(transaction.deviceVerification)") // 设备验证数据
        print("   - 设备验证Nonce: \(transaction.deviceVerificationNonce)") // 设备验证的Nonce值
        
        // 优惠信息
        if #available(iOS 17.2, *) {
            if let offer = transaction.offer {
                print("   - 优惠信息: \(offer)") // 使用的优惠信息
            }
        } else {
            // Fallback on earlier versions
        }
        
        // 高级商务信息
        if #available(iOS 18.4, *) {
            if let advancedCommerceInfo = transaction.advancedCommerceInfo {
                print("   - 高级商务信息: \(advancedCommerceInfo)") // 高级商务相关信息
            }
        } else {
            // Fallback on earlier versions
        }
        
        // JSON表示（用于服务器验证）
        //if let jsonRepresentation = transaction.jsonRepresentation {
        //    print("   - JSON表示 (前200字符): \(String(jsonRepresentation.prefix(200)))...") // JSON格式的交易数据，可用于服务器验证
        //}
        
        // Debug描述
        print("   - Debug描述: \(transaction.debugDescription)") // 调试用的描述信息
        print("")
        
        // 如果是订阅，打印订阅相关信息
        if let subscription = product.subscription {
            print("📱 订阅信息:")
            print("   - 订阅组ID: \(subscription.subscriptionGroupID)")
            
            // 打印订阅周期
            let period = subscription.subscriptionPeriod
            let periodName: String
            switch period.unit {
            case .day:
                periodName = "\(period.value) 天"
            case .week:
                periodName = "\(period.value) 周"
            case .month:
                periodName = "\(period.value) 月"
            case .year:
                periodName = "\(period.value) 年"
            @unknown default:
                periodName = "未知"
            }
            print("   - 订阅周期: \(periodName)")
            
            // 介绍性优惠
            if let introductoryOffer = subscription.introductoryOffer {
                print("   - 介绍性优惠: 有")
                print("     * 支付模式: \(introductoryOffer.paymentMode)")
                print("     * 价格: \(introductoryOffer.displayPrice)")
            } else {
                print("   - 介绍性优惠: 无")
            }
        }
        
        print("════════════════════════════════════════")
        print("")
    }
}

