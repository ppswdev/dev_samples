//
//  StoreExampleViewModel.swift
//  StoreKitManager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit
import SwiftUI

/// StoreKitManager 使用示例的 ViewModel
@MainActor
class StoreExampleViewModel: ObservableObject, StoreKitDelegate {
    @Published var products: [Product] = []
    @Published var purchasedProducts: [Product] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var alertMessage: String?
    @Published var showAlert = false
    @Published var subscriptionInfo: SubscriptionInfo?
    
    // 从 StoreProducts.storekit 获取的产品ID
    private let productIds = [
        // 非消耗品
        "com.ppswdev.store.lifetimevip",
        "com.ppswdev.store.lifetimevip2",
        // 非续订订阅
        "com.ppswdev.store.non.monthlyvip",
        // 自动续订订阅
        "com.ppswdev.store.onboarding.weeklyvip",
        "com.ppswdev.store.detainment.weeklyvip",
        "com.ppswdev.store.inapp.weeklyvip",
        "com.ppswdev.store.inapp.weeklyvip.wl",
        "com.ppswdev.store.inapp.monthlyvip",
        "com.ppswdev.store.inapp.yearlyvip"
    ]
    
    init() {
        setupStoreKit()
    }
    
    /// 配置 StoreKitManager
    private func setupStoreKit() {
        let config = StoreKitConfig(
            productIds: productIds,
            nonRenewableExpirationDays: 30, // 非续订订阅30天过期
            autoSortProducts: true
        )
        
        StoreKitManager.shared.configure(with: config, delegate: self)
    }
    
    // MARK: - StoreKitDelegate
    
    func storeKit(_ manager: StoreKitManager, didUpdateState state: StoreKitState) {
        switch state {
        case .loadingProducts:
            isLoading = true
            errorMessage = nil
            
        case .productsLoaded(let products):
            isLoading = false
            self.products = products
            print("✅ 产品加载成功: \(products.count) 个")
            
        case .loadingPurchases:
            isLoading = true
            
        case .purchasesLoaded:
            isLoading = false
            print("✅ 已购买产品加载完成")
            
        case .purchasing(let productId):
            isLoading = true
            showAlert(message: "正在购买: \(productId)")
            
        case .purchaseSuccess(let productId):
            isLoading = false
            showAlert(message: "✅ 购买成功: \(productId)")
            Task {
                await refreshPurchases()
            }
            
        case .purchasePending(let productId):
            isLoading = false
            showAlert(message: "⏳ 购买待处理: \(productId)")
            
        case .purchaseCancelled(let productId):
            isLoading = false
            showAlert(message: "❌ 用户取消购买: \(productId)")
            
        case .purchaseFailed(let productId, let error):
            isLoading = false
            errorMessage = "购买失败: \(productId)\n\(error.localizedDescription)"
            showAlert(message: "❌ 购买失败: \(error.localizedDescription)")
            
        case .restoringPurchases:
            isLoading = true
            showAlert(message: "正在恢复购买...")
            
        case .restorePurchasesSuccess:
            isLoading = false
            showAlert(message: "✅ 恢复购买成功")
            Task {
                await refreshPurchases()
            }
            
        case .restorePurchasesFailed(let error):
            isLoading = false
            errorMessage = "恢复购买失败: \(error.localizedDescription)"
            showAlert(message: "❌ 恢复购买失败: \(error.localizedDescription)")
            
        case .purchaseRefunded(let productId):
            showAlert(message: "⚠️ 购买已退款: \(productId)")
            Task {
                await refreshPurchases()
            }
            
        case .purchaseRevoked(let productId):
            showAlert(message: "⚠️ 购买已撤销: \(productId)")
            Task {
                await refreshPurchases()
            }
            
        case .subscriptionCancelled(let productId):
            showAlert(message: "⚠️ 订阅已取消: \(productId)")
            Task {
                await refreshPurchases()
            }
            
        case .subscriptionStatusChanged(let status):
            print("📱 订阅状态变化: \(status)")
            Task {
                await refreshPurchases()
                await loadSubscriptionInfo()
            }
            
        case .error(let error):
            isLoading = false
            errorMessage = error.localizedDescription
            showAlert(message: "❌ 发生错误: \(error.localizedDescription)")
            
        default:
            break
        }
    }
    
    func storeKit(_ manager: StoreKitManager, didLoadProducts products: [Product]) {
        self.products = products
    }
    
    func storeKit(_ manager: StoreKitManager, didUpdatePurchasedProducts products: [Product]) {
        self.purchasedProducts = products
    }
    
    func storeKit(_ manager: StoreKitManager, didUpdateSubscriptionStatus status: RenewalState?) {
        Task {
            await loadSubscriptionInfo()
        }
    }
    
    // MARK: - 公共方法
    
    /// 购买产品
    func purchase(_ product: Product) {
        Task {
            do {
                try await StoreKitManager.shared.purchase(product)
            } catch {
                errorMessage = error.localizedDescription
                showAlert(message: "购买失败: \(error.localizedDescription)")
            }
        }
    }
    
    /// 恢复购买
    func restorePurchases() {
        Task {
            do {
                try await StoreKitManager.shared.restorePurchases()
            } catch {
                errorMessage = error.localizedDescription
            }
        }
    }
    
    /// 刷新已购买产品
    func refreshPurchases() async {
        await StoreKitManager.shared.refreshPurchases()
        self.purchasedProducts = StoreKitManager.shared.purchasedProducts
    }
    
    /// 检查是否已购买
    func isPurchased(_ product: Product) -> Bool {
        return StoreKitManager.shared.isPurchased(productId: product.id)
    }
    
    /// 加载订阅信息
    func loadSubscriptionInfo() async {
        // 获取第一个订阅产品的信息
        if let subscription = StoreKitManager.shared.autoRenewables.first {
            subscriptionInfo = await StoreKitManager.shared.getSubscriptionInfo(for: subscription.id)
        }
    }
    
    /// 打开订阅管理
    func openSubscriptionManagement() {
        StoreKitManager.shared.openSubscriptionManagement()
    }
    
    /// 获取交易历史
    func getTransactionHistory() async -> [TransactionHistory] {
        return await StoreKitManager.shared.getTransactionHistory()
    }
    
    // MARK: - 辅助方法
    
    private func showAlert(message: String) {
        alertMessage = message
        showAlert = true
    }
    
    /// 按类型获取产品
    var nonConsumables: [Product] {
        StoreKitManager.shared.nonConsumables
    }
    
    var nonRenewables: [Product] {
        StoreKitManager.shared.nonRenewables
    }
    
    var autoRenewables: [Product] {
        StoreKitManager.shared.autoRenewables
    }
}

