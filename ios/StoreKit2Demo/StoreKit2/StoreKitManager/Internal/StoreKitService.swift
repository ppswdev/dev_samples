//
//  StoreKitService.swift
//  StoreKitManager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit
import Combine

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
    
    /// 购买产品
    func purchase(_ product: Product) async {
        currentState = .purchasing(product.id)
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                do {
                    let transaction = try verifyPurchase(verification)
                    
                    await retrievePurchasedProducts()
                    await transaction.finish()
                    
                    currentState = .purchaseSuccess(transaction.productID)
                } catch {
                    currentState = .purchaseFailed(product.id, error)
                }
                
            case .pending:
                currentState = .purchasePending(product.id)
                
            case .userCancelled:
                currentState = .purchaseCancelled(product.id)
                
            @unknown default:
                currentState = .purchaseFailed(product.id, StoreKitError.unknownError)
            }
        } catch {
            currentState = .purchaseFailed(product.id, error)
        }
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

