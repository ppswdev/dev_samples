//
//  ShopViewModel.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/11/6.
//

import Foundation
import Combine
import StoreKit

@MainActor
class ShopViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// 购买助手实例
    @Published private(set) var purchaseHelper = PurchaseHelper.shared
    
    /// 产品列表（按类型分组）
    @Published private(set) var productsByType: [ProductType: [ProductInfo]] = [:]
    
    /// 加载状态
    @Published private(set) var isLoading: Bool = false
    
    /// 错误信息
    @Published private(set) var errorMessage: String?
    
    // MARK: - Product Info
    
    /// 产品信息结构
    struct ProductInfo: Identifiable {
        let id: String
        let productID: String
        let product: Product?
        let type: ProductType
        let isPurchased: Bool
        let displayName: String
        let price: String
        
        init(productID: String, product: Product?, type: ProductType, isPurchased: Bool) {
            self.id = productID
            self.productID = productID
            self.product = product
            self.type = type
            self.isPurchased = isPurchased
            self.displayName = product?.displayName ?? productID
            self.price = product?.displayPrice ?? "加载中..."
        }
    }
    
    // MARK: - Initialization
    
    init() {
        setupPurchaseHelper()
        loadProducts()
    }
    
    // MARK: - Setup
    
    /// 设置购买助手
    private func setupPurchaseHelper() {
        // 构建产品类型映射
        let productTypeMap = buildProductTypeMap()
        
        // 配置产品ID和类型映射
        purchaseHelper.configure(
            productIDs: PurchaseConfig.allProductIDs,
            productTypeMap: productTypeMap
        )
        
        // 设置统一事件回调 - 所有操作都会通过此回调
        purchaseHelper.onEvent = { [weak self] event in
            Task { @MainActor in
                self?.handlePurchaseEvent(event)
            }
        }
    }
    
    /// 构建产品类型映射
    private func buildProductTypeMap() -> [String: ProductType] {
        var typeMap: [String: ProductType] = [:]
        
        // 消耗型产品
        for productID in PurchaseConfig.consumableProductIDs {
            typeMap[productID] = .consumable
        }
        
        // 非消耗型产品
        for productID in PurchaseConfig.nonConsumableProductIDs {
            typeMap[productID] = .nonConsumable
        }
        
        // 非自动续订订阅
        for productID in PurchaseConfig.nonRenewingSubscriptionProductIDs {
            typeMap[productID] = .nonRenewingSubscription
        }
        
        // 自动续订订阅
        for productID in PurchaseConfig.autoRenewingSubscriptionProductIDs {
            typeMap[productID] = .autoRenewingSubscription
        }
        
        return typeMap
    }
    
    // MARK: - Public Methods
    
    /// 加载产品列表
    func loadProducts() {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                try await purchaseHelper.loadProducts()
                updateProductsList()
            } catch {
                errorMessage = "加载产品失败: \(error.localizedDescription)"
                printLog("❌ 加载产品失败: \(error.localizedDescription)")
            }
            
            isLoading = false
        }
    }
    
    /// 购买产品
    /// - Parameter productID: 产品ID
    func purchaseProduct(productID: String) {
        printLog("🛒 开始购买产品: \(productID)")
        
        Task {
            do {
                try await purchaseHelper.purchase(productID: productID)
                printLog("✅ 购买成功: \(productID)")
                // 更新产品列表
                updateProductsList()
            } catch {
                if let purchaseError = error as? PurchaseError {
                    switch purchaseError {
                    case .userCancelled:
                        printLog("⚠️ 用户取消购买: \(productID)")
                    case .pending:
                        printLog("⏳ 购买待处理: \(productID)")
                    default:
                        errorMessage = "购买失败: \(purchaseError.localizedDescription)"
                        printLog("❌ 购买失败: \(productID) - \(purchaseError.localizedDescription)")
                    }
                } else {
                    errorMessage = "购买失败: \(error.localizedDescription)"
                    printLog("❌ 购买失败: \(productID) - \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// 恢复购买
    func restorePurchases() {
        printLog("🔄 开始恢复购买")
        
        Task {
            do {
                try await purchaseHelper.restorePurchases()
                printLog("✅ 恢复购买成功")
                updateProductsList()
            } catch {
                errorMessage = "恢复购买失败: \(error.localizedDescription)"
                printLog("❌ 恢复购买失败: \(error.localizedDescription)")
            }
        }
    }
    
    /// 获取按钮文字
    /// - Parameter productID: 产品ID
    /// - Returns: 按钮文字
    func getButtonText(for productID: String) -> String {
        guard let type = purchaseHelper.getProductType(productID: productID) else {
            return "购买"
        }
        
        // 消耗品可以重复购买，不显示"已购买"
        if type == .consumable {
            return "购买"
        }
        
        // 其他类型如果已购买，显示"已购买"
        if purchaseHelper.isPurchased(productID: productID) {
            return "已购买"
        }
        
        switch type {
        case .consumable, .nonConsumable:
            return "购买"
        case .autoRenewingSubscription, .nonRenewingSubscription:
            return "订阅"
        }
    }
    
    /// 判断产品是否可以购买（消耗品可以重复购买）
    /// - Parameter productID: 产品ID
    /// - Returns: 是否可以购买
    func canPurchase(productID: String) -> Bool {
        guard let type = purchaseHelper.getProductType(productID: productID) else {
            return !purchaseHelper.isPurchased(productID: productID)
        }
        
        // 消耗品可以重复购买
        if type == .consumable {
            return true
        }
        
        // 其他类型如果已购买，则不能再次购买
        return !purchaseHelper.isPurchased(productID: productID)
    }
    
    // MARK: - Private Methods
    
    /// 更新产品列表
    private func updateProductsList() {
        var productsByTypeDict: [ProductType: [ProductInfo]] = [:]
        
        // 按类型分组产品
        for productID in PurchaseConfig.allProductIDs.sorted() {
            guard let type = purchaseHelper.getProductType(productID: productID) else {
                continue
            }
            
            let product = purchaseHelper.getProduct(productID: productID)
            let isPurchased = purchaseHelper.isPurchased(productID: productID)
            
            let productInfo = ProductInfo(
                productID: productID,
                product: product,
                type: type,
                isPurchased: isPurchased
            )
            
            if productsByTypeDict[type] == nil {
                productsByTypeDict[type] = []
            }
            productsByTypeDict[type]?.append(productInfo)
        }
        
        productsByType = productsByTypeDict
    }
    
    /// 处理购买事件
    private func handlePurchaseEvent(_ event: PurchaseEvent) {
        // 打印日志
        printLog("📢 事件: \(event.description)")
        
        // 根据事件类型更新UI
        switch event {
        case .productsLoadStarted:
            isLoading = true
            
        case .productsLoadSuccess:
            isLoading = false
            updateProductsList()
            
        case .productsLoadFailed:
            isLoading = false
            
        case .productInfoRetrieved:
            updateProductsList()
            
        case .purchaseStatusUpdated, .purchaseStatusRefreshed:
            updateProductsList()
            
        case .purchaseSuccess(let productID, _):
            printLog("🎉 购买成功回调: \(productID)")
            updateProductsList()
            
        case .purchaseFailed(let productID, let error):
            printLog("💥 购买失败回调: \(productID) - \(error.localizedDescription)")
            
        case .restoreSuccess:
            printLog("🎉 恢复购买成功回调")
            updateProductsList()
            
        default:
            break
        }
    }
    
    /// 打印日志
    private func printLog(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
        let timestamp = formatter.string(from: Date())
        print("[\(timestamp)] [ShopViewModel] \(message)")
    }
}
