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
        //"com.ppswdev.store.onboarding.weeklyvip",
        //"com.ppswdev.store.detainment.weeklyvip",
        "com.ppswdev.store.inapp.weeklyvip",
        //"com.ppswdev.store.inapp.weeklyvip.wl",
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
            print("✅ 已购买产品加载完成, 共 \(purchasedProducts.count) 个")
            
        case .purchasing(let productId):
            isLoading = true
            print("正在购买: \(productId)")
            
        case .purchaseSuccess(let productId):
            isLoading = false
            print("✅ 购买成功: \(productId)")
            Task {
                await refreshPurchases()
            }
        case .purchasePending(let productId):
            isLoading = false
            print("⏳ 购买待处理: \(productId)")
            
        case .purchaseCancelled(let productId):
            isLoading = false
            print("❌ 用户取消购买: \(productId)")
            
        case .purchaseFailed(let productId, let error):
            isLoading = false
            errorMessage = "购买失败: \(productId)\n\(error.localizedDescription)"
            print("❌ 购买失败: \(error)")
            
        case .restoringPurchases:
            isLoading = true
            print("正在恢复购买...")
            
        case .restorePurchasesSuccess:
            isLoading = false
            print("✅ 恢复购买成功")
            Task {
                await refreshPurchases()
            }
            
        case .restorePurchasesFailed(let error):
            isLoading = false
            errorMessage = "恢复购买失败: \(error.localizedDescription)"
            print("❌ 恢复购买失败: \(error)")
            
        case .purchaseRefunded(let productId):
            print("⚠️ 购买已退款: \(productId)")
            Task {
                await refreshPurchases()
            }
            
        case .purchaseRevoked(let productId):
            print("⚠️ 购买已撤销: \(productId)")
            Task {
                await refreshPurchases()
            }
            
        case .subscriptionCancelled(let productId):
            print("⚠️ 订阅已取消: \(productId)")
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
            print("❌ 发生错误: \(error)")
            
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
                print("❌ 购买失败2: \(error.localizedDescription)")
            }
        }
    }
    
    /// 恢复购买
    func restorePurchases() {
        Task {
            do {
                try await StoreKitManager.shared.restorePurchases()
            } catch {
                print("❌ 恢复购买失败2: \(error.localizedDescription)")
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
    /// 优先加载已购买且有效的订阅信息
    /// 使用 Product.SubscriptionInfo 来获取订阅状态
    func loadSubscriptionInfo() async {
        // 1. 优先从已购买的订阅产品中获取
        let purchasedSubscriptions = StoreKitManager.shared.autoRenewables.filter { product in
            StoreKitManager.shared.isPurchased(productId: product.id)
        }
        
        // 2. 如果有已购买的订阅，通过 Product.SubscriptionInfo 获取状态
        for purchasedSubscription in purchasedSubscriptions {
            // 检查是否有订阅信息
            guard let subscriptionInfo = purchasedSubscription.subscription else { continue }
            
            // 从 Product.SubscriptionInfo.status 获取订阅状态
            // status 返回 [Product.SubscriptionInfo.Status] 数组，不是 AsyncSequence
            do {
                // 获取订阅状态数组（通常第一个是最新的）
                let statuses = try await subscriptionInfo.status
                
                // 遍历状态数组
                for status in statuses {
                    // status.state 是 RenewalState（subscribed, expired, inBillingRetryPeriod, inGracePeriod, revoked）
                    // status.renewalInfo 包含续订信息（willAutoRenew, expirationDate 等）
                    
                    // 如果订阅状态是已订阅，使用这个订阅信息
                    if status.state == .subscribed {
                        // 从 SubscriptionInfo.from 获取完整信息
                        if let info = await StoreKitManager.shared.getSubscriptionInfo(for: purchasedSubscription.id) {
                            self.subscriptionInfo = info
                            return
                        }
                    }
                }
            } catch {
                print("获取订阅状态失败: \(error)")
                continue
            }
            
            // 如果订阅状态不是 subscribed，尝试获取详细信息（可能已过期但仍在有效期内）
//            if let info = await StoreKitManager.shared.getSubscriptionInfo(for: purchasedSubscription.id) {
//                // 如果订阅有效（未过期），使用它
//                if info.isValid {
//                    self.subscriptionInfo = info
//                    return
//                }
//            }
        }
        
        // 3. 如果所有已购买的订阅都无效，使用第一个已购买订阅的信息（即使已过期）
        if let firstPurchased = purchasedSubscriptions.first {
            self.subscriptionInfo = await StoreKitManager.shared.getSubscriptionInfo(for: firstPurchased.id)
            return
        }
        
        // 4. 如果没有已购买的订阅，尝试从所有自动续订订阅中获取（用于显示订阅详情）
        // 通过 Product.SubscriptionInfo 检查是否有活跃的订阅状态
        for autoRenewable in StoreKitManager.shared.autoRenewables {
            guard let productSubscriptionInfo = autoRenewable.subscription else { continue }
            
            do {
                // 检查是否有已订阅的状态
                // status 返回 [Product.SubscriptionInfo.Status] 数组
                let statuses = try await productSubscriptionInfo.status
                
                for status in statuses {
                    if status.state == .subscribed {
                        // 找到已订阅的产品，获取详细信息
                        if let info = await StoreKitManager.shared.getSubscriptionInfo(for: autoRenewable.id) {
                            self.subscriptionInfo = info
                            return
                        }
                    }
                }
            } catch {
                continue
            }
        }
        
        // 5. 如果没有任何订阅产品，清空订阅信息
        self.subscriptionInfo = nil
    }
    
    /// 打开订阅管理（使用 URL）
    func openSubscriptionManagement() {
        StoreKitManager.shared.openSubscriptionManagement()
    }
    
    /// 显示应用内订阅管理界面
    func showManageSubscriptionsSheet() async -> Bool {
        let success = await StoreKitManager.shared.showManageSubscriptionsSheet()
        
        // 订阅管理界面关闭后，刷新订阅状态
        if success {
            await refreshSubscriptionStatus()
        }
        
        return success
    }
    
    /// 取消订阅（显示应用内订阅管理界面）
    func cancelSubscription(for productId: String? = nil) async -> Bool {
        let success = await StoreKitManager.shared.cancelSubscription(for: productId)
        
        // 订阅管理界面关闭后，刷新订阅状态
        if success {
            await refreshSubscriptionStatus()
        }
        
        return success
    }
    
    /// 刷新订阅状态（获取最新的订阅信息）
    func refreshSubscriptionStatus() async {
        await StoreKitManager.shared.refreshSubscriptionStatus()
        await refreshPurchases()
        await loadSubscriptionInfo()
    }
    
    /// 获取交易历史
    func getTransactionHistory() async -> [TransactionHistory] {
        return await StoreKitManager.shared.getTransactionHistory()
    }
    
    // MARK: - 辅助方法
    
    
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

