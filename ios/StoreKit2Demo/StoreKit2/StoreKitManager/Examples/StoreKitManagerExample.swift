//
//  StoreKitManagerExample.swift
//  StoreKitManager
//
//  Created by xiaopin on 2025/12/6.
//  使用示例
//

import Foundation
import StoreKit

// MARK: - 示例1: 使用代理方式

class StoreManagerExample1: StoreKitDelegate {
    
    func setupStore() {
        // 创建配置
        let config = StoreKitConfig(
            productIds: [
                "premium.lifetime",
                "subscription.monthly",
                "subscription.yearly"
            ],
            nonRenewableExpirationDays: 365,
            autoSortProducts: true
        )
        
        // 配置管理器
        StoreKitManager.shared.configure(with: config, delegate: self)
    }
    
    // MARK: - StoreKitDelegate
    
    func storeKit(_ manager: StoreKitManager, didUpdateState state: StoreKitState) {
        switch state {
        case .loadingProducts:
            print("正在加载产品...")
            
        case .productsLoaded(let products):
            print("产品加载成功，共 \(products.count) 个产品")
            for product in products {
                print("  - \(product.id): \(product.displayName) - \(product.displayPrice)")
            }
            
        case .purchasesLoaded:
            print("已购买产品加载完成")
            
        case .purchasing(let productId):
            print("正在购买: \(productId)")
            
        case .purchaseSuccess(let productId):
            print("✅ 购买成功: \(productId)")
            unlockFeature(for: productId)
            
        case .purchasePending(let productId):
            print("⏳ 购买待处理: \(productId)")
            
        case .purchaseCancelled(let productId):
            print("❌ 用户取消购买: \(productId)")
            
        case .purchaseFailed(let productId, let error):
            print("❌ 购买失败: \(productId), 错误: \(error.localizedDescription)")
            
        case .subscriptionStatusChanged(let status):
            print("📱 订阅状态变化: \(status)")
            handleSubscriptionStatusChange(status)
            
        case .error(let error):
            print("❌ 发生错误: \(error.localizedDescription)")
            
        default:
            break
        }
    }
    
    func storeKit(_ manager: StoreKitManager, didLoadProducts products: [Product]) {
        // 更新UI显示产品列表
        updateProductList(products)
    }
    
    func storeKit(_ manager: StoreKitManager, didUpdatePurchasedProducts products: [Product]) {
        // 更新已购买状态
        updatePurchaseStatus(products)
    }
    
    func storeKit(_ manager: StoreKitManager, didUpdateSubscriptionStatus status: Product.SubscriptionInfo.RenewalState?) {
        // 处理订阅状态变化
        if let status = status {
            print("当前订阅状态: \(status)")
        }
    }
    
    // MARK: - 辅助方法
    
    func purchaseProduct(productId: String) {
        Task {
            do {
                try await StoreKitManager.shared.purchase(productId: productId)
            } catch {
                print("购买失败: \(error)")
            }
        }
    }
    
    func checkPurchaseStatus(productId: String) -> Bool {
        return StoreKitManager.shared.isPurchased(productId: productId)
    }
    
    private func unlockFeature(for productId: String) {
        // 根据产品ID解锁相应功能
        switch productId {
        case "premium.lifetime":
            enablePremiumFeatures()
        case "subscription.monthly", "subscription.yearly":
            enableSubscriptionFeatures()
        default:
            break
        }
    }
    
    private func enablePremiumFeatures() {
        // 启用高级功能
    }
    
    private func enableSubscriptionFeatures() {
        // 启用订阅功能
    }
    
    private func handleSubscriptionStatusChange(_ status: Product.SubscriptionInfo.RenewalState) {
        switch status {
        case .subscribed:
            enableSubscriptionFeatures()
        case .expired, .revoked:
            disableSubscriptionFeatures()
        default:
            break
        }
    }
    
    private func updateProductList(_ products: [Product]) {
        // 更新产品列表UI
    }
    
    private func updatePurchaseStatus(_ products: [Product]) {
        // 更新购买状态UI
    }
    
    private func disableSubscriptionFeatures() {
        // 禁用订阅功能
    }
}

// MARK: - 示例2: 使用闭包方式

class StoreManagerExample2 {
    
    func setupStore() {
        // 从 plist 文件加载配置
        guard let config = try? StoreKitConfig.fromPlist(named: "StoreKitConfig") else {
            print("配置文件加载失败")
            return
        }
        
        // 设置闭包回调
        StoreKitManager.shared.onStateChanged = { [weak self] state in
            self?.handleStateChange(state)
        }
        
        StoreKitManager.shared.onProductsLoaded = { products in
            print("产品加载成功: \(products.count) 个")
        }
        
        StoreKitManager.shared.onPurchasedProductsUpdated = { products in
            print("已购买产品更新: \(products.count) 个")
        }
        
        StoreKitManager.shared.onSubscriptionStatusChanged = { status in
            if let status = status {
                print("订阅状态: \(status)")
            }
        }
        
        // 配置管理器
        StoreKitManager.shared.configure(with: config)
    }
    
    private func handleStateChange(_ state: StoreKitState) {
        switch state {
        case .purchaseSuccess(let productId):
            print("购买成功: \(productId)")
        case .purchaseFailed(let productId, let error):
            print("购买失败: \(productId), \(error)")
        default:
            break
        }
    }
    
    func purchaseProduct() {
        Task {
            do {
                try await StoreKitManager.shared.purchase(productId: "premium.lifetime")
            } catch {
                print("购买错误: \(error)")
            }
        }
    }
}

// MARK: - 示例3: SwiftUI 中使用

import SwiftUI

class StoreViewModel: ObservableObject {
    @Published var products: [Product] = []
    @Published var purchasedProducts: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    init() {
        setupStore()
    }
    
    private func setupStore() {
        let config = StoreKitConfig(
            productIds: ["premium.lifetime", "subscription.monthly"]
        )
        
        StoreKitManager.shared.onStateChanged = { [weak self] state in
            DispatchQueue.main.async {
                self?.handleState(state)
            }
        }
        
        StoreKitManager.shared.onProductsLoaded = { [weak self] products in
            DispatchQueue.main.async {
                self?.products = products
            }
        }
        
        StoreKitManager.shared.onPurchasedProductsUpdated = { [weak self] products in
            DispatchQueue.main.async {
                self?.purchasedProducts = products
            }
        }
        
        StoreKitManager.shared.configure(with: config)
    }
    
    private func handleState(_ state: StoreKitState) {
        switch state {
        case .loadingProducts:
            isLoading = true
        case .productsLoaded:
            isLoading = false
        case .purchaseSuccess:
            isLoading = false
        case .error(let error):
            isLoading = false
            errorMessage = error.localizedDescription
        default:
            break
        }
    }
    
    func purchase(_ product: Product) {
        Task {
            await StoreKitManager.shared.purchase(product)
        }
    }
    
    func isPurchased(_ product: Product) -> Bool {
        return StoreKitManager.shared.isPurchased(productId: product.id)
    }
}

struct StoreView: View {
    @StateObject private var viewModel = StoreViewModel()
    
    var body: some View {
        List {
            ForEach(viewModel.products, id: \.id) { product in
                ProductRow(
                    product: product,
                    isPurchased: viewModel.isPurchased(product),
                    onPurchase: { viewModel.purchase(product) }
                )
            }
        }
    }
}

struct ProductRow: View {
    let product: Product
    let isPurchased: Bool
    let onPurchase: () -> Void
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(product.displayName)
                Text(product.displayPrice)
                    .font(.caption)
            }
            Spacer()
            if isPurchased {
                Text("已购买")
                    .foregroundColor(.green)
            } else {
                Button("购买", action: onPurchase)
            }
        }
    }
}

