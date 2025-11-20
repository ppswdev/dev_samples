//
//  PurchaseHelper.swift
//  DecibelMeterDemo
//
//  基于 StoreKit 2 的应用内购买工具类
//  仅使用 StoreKit 2 API，不包含 StoreKit 1 的任何实现
//
//  StoreKit 2 特性：
//  - 使用 async/await 异步 API
//  - 使用 Product 和 Transaction 类型
//  - 使用 VerificationResult 进行交易验证
//  - 支持 Transaction.currentEntitlements 检查授权（兼容 iOS 15.0+）
//  - 支持 Transaction.updates 监听交易更新
//  - 使用 AppStore.sync() 恢复购买
//
//  要求：iOS 15.0+ / macOS 12.0+

import StoreKit
import Combine

// MARK: - Product Type

/// 产品类型枚举
enum ProductType: String, Codable {
    /// 消耗型产品（Consumable）
    /// 可以重复购买，如游戏币、道具等
    case consumable = "consumable"
    
    /// 非消耗型产品（Non-Consumable）
    /// 一次性购买，永久有效，如解锁功能、去广告等
    case nonConsumable = "nonConsumable"
    
    /// 非自动续订订阅（Non-Renewing Subscription）
    /// 有时间限制的订阅，到期后需要手动续订
    case nonRenewingSubscription = "nonRenewingSubscription"
    
    /// 自动续订订阅（Auto-Renewing Subscription）
    /// 自动续订的订阅，如月度会员、年度会员等
    case autoRenewingSubscription = "autoRenewingSubscription"
}

// MARK: - Purchase Event Types

/// 购买相关事件类型
enum PurchaseEvent {
    // 配置事件
    case configured(productIDs: Set<String>)
    
    // 产品加载事件
    case productsLoadStarted
    case productsLoadSuccess(productCount: Int)
    case productsLoadFailed(error: Error)
    
    // 购买事件
    case purchaseStarted(productID: String)
    case purchaseSuccess(productID: String, transactionID: UInt64?)
    case purchaseFailed(productID: String, error: Error)
    case purchaseCancelled(productID: String)
    case purchasePending(productID: String)
    
    // 恢复购买事件
    case restoreStarted
    case restoreSuccess
    case restoreFailed(error: Error)
    
    // 状态更新事件
    case purchaseStatusUpdated(productID: String, isPurchased: Bool)
    case purchaseStatusRefreshed([String: Bool])
    
    // 交易监听事件
    case transactionReceived(productID: String, transactionID: UInt64)
    case transactionVerified(productID: String, transactionID: UInt64)
    case transactionVerificationFailed(productID: String, error: Error)
    
    // 产品信息事件
    case productInfoRequested(productID: String)
    case productInfoRetrieved(productID: String, product: Product)
    
    /// 事件描述（用于日志和回调）
    var description: String {
        switch self {
        case .configured(let productIDs):
            return "配置产品ID: \(productIDs.joined(separator: ", "))"
        case .productsLoadStarted:
            return "开始加载产品信息"
        case .productsLoadSuccess(let count):
            return "产品加载成功，共 \(count) 个产品"
        case .productsLoadFailed(let error):
            return "产品加载失败: \(error.localizedDescription)"
        case .purchaseStarted(let productID):
            return "开始购买: \(productID)"
        case .purchaseSuccess(let productID, let transactionID):
            return "购买成功: \(productID), 交易ID: \(transactionID?.description ?? "N/A")"
        case .purchaseFailed(let productID, let error):
            return "购买失败: \(productID), 错误: \(error.localizedDescription)"
        case .purchaseCancelled(let productID):
            return "用户取消购买: \(productID)"
        case .purchasePending(let productID):
            return "购买待处理: \(productID)"
        case .restoreStarted:
            return "开始恢复购买"
        case .restoreSuccess:
            return "恢复购买成功"
        case .restoreFailed(let error):
            return "恢复购买失败: \(error.localizedDescription)"
        case .purchaseStatusUpdated(let productID, let isPurchased):
            return "购买状态更新: \(productID) = \(isPurchased)"
        case .purchaseStatusRefreshed(let status):
            return "购买状态刷新: \(status)"
        case .transactionReceived(let productID, let transactionID):
            return "收到交易: \(productID), ID: \(transactionID)"
        case .transactionVerified(let productID, let transactionID):
            return "交易验证成功: \(productID), ID: \(transactionID)"
        case .transactionVerificationFailed(let productID, let error):
            return "交易验证失败: \(productID), 错误: \(error.localizedDescription)"
        case .productInfoRequested(let productID):
            return "请求产品信息: \(productID)"
        case .productInfoRetrieved(let productID, let product):
            return "获取产品信息: \(productID), 价格: \(product.displayPrice ?? "N/A")"
        }
    }
}

// MARK: - Purchase Helper

@MainActor
class PurchaseHelper: ObservableObject {
    
    // MARK: - Singleton
    
    /// 全局单例实例
    static let shared = PurchaseHelper()
    
    // MARK: - Properties (必须属性)
    
    /// 最后一次订阅的时间（单位：毫秒）
    @Published private(set) var lastPurchaseTime: Int64 = 0
    
    /// 订阅的过期时间戳（单位：毫秒）
    @Published private(set) var expirationTime: Int64 = 0
    
    /// 购买是否可用
    @Published private(set) var isPurchaseAvailable: Bool = false
    
    /// 是否显示打印日志（默认：true）
    var isLoggingEnabled: Bool = true {
        didSet {
            log("日志打印已\(isLoggingEnabled ? "开启" : "关闭")", file: #file, line: #line)
        }
    }
    
    // MARK: - Internal Properties
    
    /// 产品ID集合
    private var productIDs: Set<String> = []
    
    /// 产品类型映射 [ProductID: ProductType]
    private var productTypeMap: [String: ProductType] = [:]
    
    /// 已加载的产品字典 [ProductID: Product]
    @Published private(set) var products: [String: Product] = [:]
    
    /// 购买状态字典 [ProductID: Bool]
    @Published private(set) var purchaseStatus: [String: Bool] = [:] {
        didSet {
            updatePurchaseAvailability()
        }
    }
    
    /// 历史购买记录（所有已验证的交易）
    @Published private(set) var purchaseHistory: [Transaction] = []
    
    /// 加载产品状态
    @Published private(set) var isLoadingProducts: Bool = false
    
    /// 购买中状态
    @Published private(set) var isPurchasing: Bool = false
    
    /// 交易监听任务
    private var transactionListenerTask: Task<Void, Never>?
    
    /// 是否已配置产品ID
    private(set) var isConfigured: Bool = false
    
    // MARK: - Event Callback (统一事件回调)
    
    /// 统一事件回调 - 所有操作事件都会通过此回调通知UI层
    /// - Parameter event: 购买事件
    /// - Note: 此回调会在主线程执行
    /// 所有购买相关的操作都会通过此回调通知，包括：
    /// - 产品加载：productsLoadStarted, productsLoadSuccess, productsLoadFailed, productInfoRetrieved
    /// - 购买操作：purchaseStarted, purchaseSuccess, purchaseFailed, purchaseCancelled, purchasePending
    /// - 恢复购买：restoreStarted, restoreSuccess, restoreFailed
    /// - 状态更新：purchaseStatusUpdated, purchaseStatusRefreshed
    /// - 交易监听：transactionReceived, transactionVerified, transactionVerificationFailed
    var onEvent: ((PurchaseEvent) -> Void)?
    
    // MARK: - Initialization
    
    /// 私有初始化方法，确保单例模式
    private init() {
        self.startTransactionListener()
    }
    
    deinit {
        transactionListenerTask?.cancel()
    }
    
    // MARK: - Configuration (初始化配置方法)
    
    /// 初始化配置方法
    /// 在应用启动的时候，将内购产品ID和产品类型信息初始化配置
    /// - Parameters:
    ///   - productIDs: 产品ID集合
    ///   - productTypeMap: 产品类型映射（可选），如果提供则用于区分不同类型的产品
    /// - Note: 可以多次调用以更新产品ID列表和类型映射
    func configure(productIDs: Set<String>, productTypeMap: [String: ProductType]? = nil) {
        self.productIDs = productIDs
        if let typeMap = productTypeMap {
            self.productTypeMap = typeMap
        }
        self.isConfigured = true
        
        log("配置产品ID: \(productIDs.joined(separator: ", "))", file: #file, line: #line)
        logEvent(.configured(productIDs: productIDs))
        
        // 如果已经启动监听，重新加载产品
        Task {
            try? await loadProducts()
        }
    }
    
    // MARK: - Public Methods
    
    /// 获取加载产品列表信息
    /// 获取初始化的产品IDs的具体产品对象信息
    func loadProducts() async throws {
        guard isConfigured else {
            let error = PurchaseError.notConfigured
            logEvent(.productsLoadFailed(error: error))
            throw error
        }
        
        log("开始加载产品信息", file: #file, line: #line)
        isLoadingProducts = true
        logEvent(.productsLoadStarted)
        defer {
            isLoadingProducts = false
            // 注意：这里不发送事件，因为 productsLoadSuccess 或 productsLoadFailed 已经包含了状态变化
        }
        
        do {
            let storeProducts = try await Product.products(for: productIDs)
            
            // 更新产品字典
            for product in storeProducts {
                products[product.id] = product
                logEvent(.productInfoRetrieved(productID: product.id, product: product))
            }
            
            // 检查已购买状态并加载历史记录
            await refreshPurchaseData()
            
            log("产品加载成功，共 \(storeProducts.count) 个产品", file: #file, line: #line)
            logEvent(.productsLoadSuccess(productCount: storeProducts.count))
        } catch {
            log("产品加载失败: \(error.localizedDescription)", file: #file, line: #line)
            logEvent(.productsLoadFailed(error: error))
            throw error
        }
    }
    
    /// 获取加载所有历史购买产品列表信息
    func loadPurchaseHistory() async {
        var history: [Transaction] = []
        
        for productID in productIDs {
            for await result in Transaction.all {
                do {
                    let transaction = try checkVerified(result)
                    if transaction.productID == productID {
                        history.append(transaction)
                    }
                } catch {
                    continue
                }
            }
        }
        
        // 按时间倒序排列
        purchaseHistory = history.sorted { $0.purchaseDate > $1.purchaseDate }
        
        log("加载历史购买记录，共 \(purchaseHistory.count) 条", file: #file, line: #line)
    }
    
    /// 获取产品类型
    /// - Parameter productID: 产品ID
    /// - Returns: 产品类型，如果未配置返回 nil
    func getProductType(productID: String) -> ProductType? {
        return productTypeMap[productID]
    }
    
    /// 设置产品类型映射
    /// - Parameter productTypeMap: 产品类型映射 [ProductID: ProductType]
    /// - Note: 可以多次调用以更新产品类型映射
    func setProductTypeMap(_ productTypeMap: [String: ProductType]) {
        self.productTypeMap = productTypeMap
    }
    
    /// 判断是否有购买过指定产品
    /// - Parameter productID: 产品ID
    /// - Returns: 是否已购买
    /// - Note: 根据产品类型采用不同的判断逻辑：
    ///   - 消耗型：检查历史记录，只要有购买记录就返回 true
    ///   - 非消耗型：检查当前授权
    ///   - 非自动续订订阅：检查历史记录和过期时间
    ///   - 自动续订订阅：检查当前授权和过期时间
    func isPurchased(productID: String) -> Bool {
        guard let productType = getProductType(productID: productID) else {
            // 如果未配置类型，使用默认逻辑（检查当前授权）
            return purchaseStatus[productID] ?? false
        }
        
        switch productType {
        case .consumable:
            // 消耗型产品：检查历史记录，只要有购买记录就认为已购买
            // 注意：消耗型产品通常需要服务端记录使用次数，这里只检查是否有购买记录
            return purchaseHistory.contains { $0.productID == productID }
            
        case .nonConsumable:
            // 非消耗型产品：检查当前授权
            return purchaseStatus[productID] ?? false
            
        case .nonRenewingSubscription:
            // 非自动续订订阅：检查历史记录和过期时间
            return checkNonRenewingSubscriptionStatus(productID: productID)
            
        case .autoRenewingSubscription:
            // 自动续订订阅：检查当前授权和过期时间
            return purchaseStatus[productID] ?? false
        }
    }
    
    /// 检查非自动续订订阅状态
    private func checkNonRenewingSubscriptionStatus(productID: String) -> Bool {
        // 查找该产品的最新交易
        let relevantTransactions = purchaseHistory
            .filter { $0.productID == productID }
            .sorted { $0.purchaseDate > $1.purchaseDate }
        
        guard let latestTransaction = relevantTransactions.first else {
            return false
        }
        
        // 检查是否过期
        if let expirationDate = latestTransaction.expirationDate {
            let currentTime = Date()
            return currentTime < expirationDate
        }
        
        // 如果没有过期时间，认为已购买
        return true
    }
    
    /// 判断是否有购买了任意产品
    /// - Returns: 是否已购买
    func hasAnyPurchase() -> Bool {
        return purchaseStatus.values.contains(true)
    }
    
    /// 获取指定产品ID的产品信息
    /// - Parameter productID: 产品ID
    /// - Returns: Product对象，如果不存在返回nil
    func getProduct(productID: String) -> Product? {
        return products[productID]
    }
    
    /// 获取产品标题
    /// - Parameter productID: 产品ID
    /// - Returns: 产品标题
    /// - Note: 建议直接使用 getProduct(productID:)?.displayName
    func getProductTitle(productID: String) -> String? {
        return getProduct(productID: productID)?.displayName
    }
    
    /// 获取产品的副标题
    /// - Parameter productID: 产品ID
    /// - Returns: 产品副标题（描述）
    /// - Note: 建议直接使用 getProduct(productID:)?.description
    func getProductSubtitle(productID: String) -> String? {
        return getProduct(productID: productID)?.description
    }
    
    /// 购买或订阅产品
    /// - Parameter productID: 产品ID
    func purchase(productID: String) async throws {
        guard isConfigured else {
            let error = PurchaseError.notConfigured
            logEvent(.purchaseFailed(productID: productID, error: error))
            throw error
        }
        
        logEvent(.productInfoRequested(productID: productID))
        
        guard let product = products[productID] else {
            let error = PurchaseError.productNotFound
            logEvent(.purchaseFailed(productID: productID, error: error))
            throw error
        }
        
        log("开始购买: \(productID)", file: #file, line: #line)
        isPurchasing = true
        logEvent(.purchaseStarted(productID: productID))
        defer {
            isPurchasing = false
            // 注意：这里不发送事件，因为购买结果事件（success/failed/cancelled）已经包含了状态变化
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                
                logEvent(.transactionVerified(
                    productID: transaction.productID,
                    transactionID: transaction.id
                ))
                
                // 更新订阅时间信息（这会自动更新可用性）
                updateSubscriptionTime(transaction: transaction)
                
                // 更新购买状态和历史记录
                await refreshPurchaseData()
                
                // 完成交易
                await transaction.finish()
                
                log("购买成功: \(productID), 交易ID: \(transaction.id)", file: #file, line: #line)
                logEvent(.purchaseSuccess(
                    productID: productID,
                    transactionID: transaction.id
                ))
                
            case .userCancelled:
                log("用户取消购买: \(productID)", file: #file, line: #line)
                logEvent(.purchaseCancelled(productID: productID))
                throw PurchaseError.userCancelled
                
            case .pending:
                log("购买待处理: \(productID)", file: #file, line: #line)
                logEvent(.purchasePending(productID: productID))
                throw PurchaseError.pending
                
            @unknown default:
                let error = PurchaseError.unknown
                logEvent(.purchaseFailed(productID: productID, error: error))
                throw error
            }
        } catch {
            if !(error is PurchaseError) {
                log("购买失败: \(productID), 错误: \(error.localizedDescription)", file: #file, line: #line)
                logEvent(.purchaseFailed(productID: productID, error: error))
            }
            throw error
        }
    }
    
    /// 恢复购买
    func restorePurchases() async throws {
        guard isConfigured else {
            let error = PurchaseError.notConfigured
            logEvent(.restoreFailed(error: error))
            throw error
        }
        
        log("开始恢复购买", file: #file, line: #line)
        logEvent(.restoreStarted)
        
        do {
            try await AppStore.sync()
            await refreshPurchaseData()
            
            log("恢复购买成功", file: #file, line: #line)
            logEvent(.restoreSuccess)
        } catch {
            log("恢复购买失败: \(error.localizedDescription)", file: #file, line: #line)
            logEvent(.restoreFailed(error: error))
            throw error
        }
    }
    
    // MARK: - Private Methods
    
    /// 日志打印（可打印代码行）
    /// - Parameters:
    ///   - message: 日志消息
    ///   - file: 文件路径（默认使用 #file）
    ///   - line: 行号（默认使用 #line）
    private func log(_ message: String, file: String = #file, line: Int = #line) {
        guard isLoggingEnabled else { return }
        
        let fileName = (file as NSString).lastPathComponent
        let timestamp = DateFormatter.logFormatter.string(from: Date())
        let logMessage = "[\(timestamp)] [\(fileName):\(line)] \(message)"
        print(logMessage)
    }
    
    /// 记录事件（内部方法）
    private func logEvent(_ event: PurchaseEvent) {
        // 回调给UI层
        DispatchQueue.main.async { [weak self] in
            self?.onEvent?(event)
        }
    }
    
    /// 更新购买状态
    /// 根据产品类型采用不同的判断逻辑：
    /// - 消耗型：不更新状态（消耗型产品不依赖当前授权）
    /// - 非消耗型：检查当前授权
    /// - 非自动续订订阅：检查历史记录和过期时间
    /// - 自动续订订阅：检查当前授权和过期时间
    private func updatePurchaseStatus() async {
        guard isConfigured else { return }
        
        var status: [String: Bool] = [:]
        var latestPurchaseTime: Int64 = 0
        var latestExpirationTime: Int64 = 0
        
        for productID in productIDs {
            guard let productType = getProductType(productID: productID) else {
                // 如果未配置类型，使用默认逻辑（检查当前授权）
                status[productID] = await checkCurrentEntitlement(productID: productID)
                continue
            }
            
            var isPurchased = false
            var productLatestTime: Int64 = 0
            var productExpirationTime: Int64 = 0
            
            switch productType {
            case .consumable:
                // 消耗型产品：不依赖当前授权，状态由历史记录决定
                // 这里不设置状态，因为消耗型产品每次购买都会记录到历史
                // 如果需要检查是否购买过，使用 isPurchased() 方法
                isPurchased = purchaseHistory.contains { $0.productID == productID }
                
            case .nonConsumable:
                // 非消耗型产品：检查当前授权
                isPurchased = await checkCurrentEntitlement(productID: productID)
                
            case .nonRenewingSubscription:
                // 非自动续订订阅：检查历史记录和过期时间
                isPurchased = checkNonRenewingSubscriptionStatus(productID: productID)
                
            case .autoRenewingSubscription:
                // 自动续订订阅：检查当前授权和过期时间
                let entitlementInfo = await getCurrentEntitlementInfo(productID: productID)
                isPurchased = entitlementInfo.isEntitled
                if isPurchased {
                    productLatestTime = entitlementInfo.purchaseTime
                    productExpirationTime = entitlementInfo.expirationTime
                }
            }
            
            let oldStatus = purchaseStatus[productID] ?? false
            status[productID] = isPurchased
            
            // 更新全局时间（只更新订阅类型的）
            if productType == .autoRenewingSubscription || productType == .nonRenewingSubscription {
                latestPurchaseTime = max(latestPurchaseTime, productLatestTime)
                latestExpirationTime = max(latestExpirationTime, productExpirationTime)
            }
            
            // 如果状态发生变化，记录事件
            if oldStatus != isPurchased {
                logEvent(.purchaseStatusUpdated(productID: productID, isPurchased: isPurchased))
            }
        }
        
        purchaseStatus = status
        lastPurchaseTime = latestPurchaseTime
        expirationTime = latestExpirationTime
        
        logEvent(.purchaseStatusRefreshed(status))
    }
    
    /// 授权信息结构
    private struct EntitlementInfo {
        let isEntitled: Bool
        let purchaseTime: Int64
        let expirationTime: Int64
    }
    
    /// 获取当前授权信息（包含授权状态、购买时间和过期时间）
    /// 兼容 iOS 15.0+ 版本
    private func getCurrentEntitlementInfo(productID: String) async -> EntitlementInfo {
        var latestPurchaseTime: Int64 = 0
        var latestExpirationTime: Int64 = 0
        var isEntitled = false
        
        // 使用 Transaction.currentEntitlements（iOS 15.0+ 支持）
        // 注意：Transaction.currentEntitlements(for:) 需要 iOS 18.4+
        // 这里使用兼容写法，遍历所有授权并过滤出对应产品ID
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                // 过滤出对应产品ID的交易
                if transaction.productID == productID {
                    isEntitled = true
                    let purchaseTime = Int64(transaction.purchaseDate.timeIntervalSince1970 * 1000)
                    latestPurchaseTime = max(latestPurchaseTime, purchaseTime)
                    
                    if let expirationDate = transaction.expirationDate {
                        let expiration = Int64(expirationDate.timeIntervalSince1970 * 1000)
                        latestExpirationTime = max(latestExpirationTime, expiration)
                    }
                }
            } catch {
                continue
            }
        }
        
        return EntitlementInfo(
            isEntitled: isEntitled,
            purchaseTime: latestPurchaseTime,
            expirationTime: latestExpirationTime
        )
    }
    
    /// 检查当前授权状态（简化方法）
    private func checkCurrentEntitlement(productID: String) async -> Bool {
        return await getCurrentEntitlementInfo(productID: productID).isEntitled
    }
    
    /// 刷新购买数据（更新状态和历史记录）
    private func refreshPurchaseData() async {
        await updatePurchaseStatus()
        await loadPurchaseHistory()
    }
    
    /// 更新购买可用性
    private func updatePurchaseAvailability() {
        let hasActivePurchase = purchaseStatus.values.contains(true)
        
        // 如果有过期时间，需要检查是否过期
        if expirationTime > 0 {
            let currentTime = Int64(Date().timeIntervalSince1970 * 1000)
            isPurchaseAvailable = hasActivePurchase && (currentTime < expirationTime)
        } else {
            // 没有过期时间（可能是终身购买），只要有购买记录就可用
            isPurchaseAvailable = hasActivePurchase
        }
    }
    
    /// 更新订阅时间信息
    private func updateSubscriptionTime(transaction: Transaction) {
        let purchaseTime = Int64(transaction.purchaseDate.timeIntervalSince1970 * 1000)
        lastPurchaseTime = max(lastPurchaseTime, purchaseTime)
        
        if let expirationDate = transaction.expirationDate {
            let expiration = Int64(expirationDate.timeIntervalSince1970 * 1000)
            expirationTime = max(expirationTime, expiration)
        }
        
        updatePurchaseAvailability()
    }
    
    /// 启动交易监听器
    private func startTransactionListener() {
        transactionListenerTask = Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    
                    logEvent(.transactionReceived(
                        productID: transaction.productID,
                        transactionID: transaction.id
                    ))
                    
                    logEvent(.transactionVerified(
                        productID: transaction.productID,
                        transactionID: transaction.id
                    ))
                    
                    // 更新订阅时间（这会自动更新可用性）
                    updateSubscriptionTime(transaction: transaction)
                    
                    // 更新购买状态和历史记录
                    await refreshPurchaseData()
                    
                    // 完成交易
                    await transaction.finish()
                } catch {
                    // 尝试获取 productID（即使验证失败）
                    if case .unverified(let transaction, _) = result {
                        logEvent(.transactionVerificationFailed(
                            productID: transaction.productID,
                            error: error
                        ))
                    }
                    log("交易验证失败: \(error.localizedDescription)", file: #file, line: #line)
                }
            }
        }
    }
    
    /// 验证凭据（验证交易）
    /// - Parameter result: 交易验证结果
    /// - Returns: 已验证的交易
    /// - Throws: 验证失败时抛出错误
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.verificationFailed
        case .verified(let safe):
            return safe
        }
    }
}

// MARK: - DateFormatter Extension

extension DateFormatter {
    static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        return formatter
    }()
}

// MARK: - Error Types

/// 所有购买过程中的各种错误，汇总在PurchaseError中，在onEvent中会回调回去
enum PurchaseError: LocalizedError {
    case notConfigured
    case productNotFound
    case userCancelled
    case pending
    case verificationFailed
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "PurchaseHelper 未配置，请先调用 configure(productIDs:) 方法"
        case .productNotFound:
            return "产品未找到"
        case .userCancelled:
            return "用户取消购买"
        case .pending:
            return "购买待处理"
        case .verificationFailed:
            return "交易验证失败"
        case .unknown:
            return "未知错误"
        }
    }
}
