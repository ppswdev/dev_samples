//
//  StoreExampleViewModel.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit
import SwiftUI

/// StoreKit2Manager 使用示例的 ViewModel
@MainActor
class StoreExampleViewModel: ObservableObject, StoreKitDelegate {
    @Published var products: [Product] = []
    @Published var purchasedTransactions: [Transaction] = []
    @Published var latestTransactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var alertMessage: String?
    @Published var showAlert = false
    @Published var subscriptionInfo: SubscriptionInfo?
    
    // 从 StoreProducts.storekit 获取的产品ID
    private let productIds = [
        //消耗品
        "com.ppswdev.store.goldcoin.10",
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
    
    private let lifetimeIds = [
        "com.ppswdev.store.lifetimevip",
        "com.ppswdev.store.lifetimevip2",
    ]
    
    init() {
        setupStoreKit()
    }
    
    /// 配置 StoreKit2Manager
    private func setupStoreKit() {
        let config = StoreKitConfig(
            productIds: productIds,
            lifetimeIds: lifetimeIds,
            nonRenewableExpirationDays: 30, // 非续订订阅30天过期
            autoSortProducts: true
        )
        
        StoreKit2Manager.shared.configure(with: config, delegate: self)
    }
    
    // MARK: - StoreKitDelegate
    
    func storeKit(_ manager: StoreKit2Manager, didUpdateState state: StoreKitState) {
        switch state {
        case .loadingProducts:
            isLoading = true
            errorMessage = nil
            print("正在加载产品...")
            
        case .productsLoaded(let products):
            isLoading = false
            self.products = products
            print("✅ 产品加载成功: \(products.count) 个")
            
        case .loadingPurchases:
            isLoading = true
            print("正在加载已购买交易...")
        case .purchasesLoaded:
            isLoading = false
            print("✅ 已购买产品加载完成, 共 \(purchasedTransactions.count) 个有效交易")
            
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
            
        case .error(let error):
            isLoading = false
            errorMessage = error.localizedDescription
            print("❌ 发生错误: \(error)")
            
        default:
            break
        }
    }
    
    func storeKit(_ manager: StoreKit2Manager, didLoadProducts products: [Product]) {
        self.products = products
    }
    
    func storeKit(_ manager: StoreKit2Manager, didUpdatePurchasedTransactions efficient: [Transaction], latests: [Transaction]) {
        self.purchasedTransactions = efficient
        self.latestTransactions = latests
    }
    
    // MARK: - 公共方法
    
    /// 购买产品
    func purchase(_ product: Product) {
        Task {
            do {
                try await StoreKit2Manager.shared.purchase(product)
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
                try await StoreKit2Manager.shared.restorePurchases()
            } catch {
                print("❌ 恢复购买失败2: \(error.localizedDescription)")
            }
        }
    }
    
    /// 刷新已购买产品
    func refreshPurchases() async {
        await StoreKit2Manager.shared.refreshPurchases()
        self.purchasedTransactions = StoreKit2Manager.shared.purchasedTransactions
        self.latestTransactions = StoreKit2Manager.shared.latestTransactions
    }
    
    /// 检查是否已购买
    func isPurchased(_ product: Product) -> Bool {
        return StoreKit2Manager.shared.isPurchased(productId: product.id)
    }
    
    /// 加载订阅信息
    /// 从已购买的订阅交易中获取订阅信息
    func loadSubscriptionInfo() async {
        // 从已购买的有效交易中查找订阅产品
        let subscriptionTransactions = purchasedTransactions.filter { transaction in
            transaction.productType == .autoRenewable
        }
        
        // 如果有订阅交易，从对应的产品中获取订阅信息
        for transaction in subscriptionTransactions {
            if let product = StoreKit2Manager.shared.product(for: transaction.productID),
               let subscription = product.subscription {
                // 检查订阅状态
                do {
                    let statuses = try await subscription.status
                    for status in statuses {
                        if status.state == .subscribed {
                            self.subscriptionInfo = subscription
                            return
                        }
                    }
                } catch {
                    print("获取订阅状态失败: \(error)")
                }
                
                // 如果状态不是 subscribed，仍然使用这个订阅信息（可能已过期但仍在有效期内）
                self.subscriptionInfo = subscription
                return
            }
        }
        
        // 如果没有已购买的订阅，尝试从所有自动续订订阅中获取（用于显示订阅详情）
        for autoRenewable in StoreKit2Manager.shared.autoRenewables {
            if let subscription = autoRenewable.subscription {
                do {
                    let statuses = try await subscription.status
                    for status in statuses {
                        if status.state == .subscribed {
                            self.subscriptionInfo = subscription
                            return
                        }
                    }
                } catch {
                    continue
                }
            }
        }
        
        // 如果没有任何订阅产品，清空订阅信息
        self.subscriptionInfo = nil
    }
    
    /// 应用评价
    func requestReview() {
        StoreKit2Manager.shared.requestReview()
    }
    
    
    /// 打开订阅管理（使用 URL）
    func openSubscriptionManagement() {
        StoreKit2Manager.shared.openSubscriptionManagement()
    }
    
    /// 显示应用内订阅管理界面
    func showManageSubscriptionsSheet() async -> Bool {
        let success = await StoreKit2Manager.shared.showManageSubscriptionsSheet()
        
        // 订阅管理界面关闭后，刷新状态
        if success {
            await refreshPurchases()
            await loadSubscriptionInfo()
        }
        
        return success
    }
    
    /// 显示订阅管理界面（用于取消订阅）
    func showSubscriptionManagement() async {
        let success = await StoreKit2Manager.shared.showManageSubscriptionsSheet()
        
        // 订阅管理界面关闭后，刷新状态
        if success {
            await refreshPurchases()
            await loadSubscriptionInfo()
        }
    }
    
    /// 获取交易历史
    func getTransactionHistory() async -> [TransactionHistory] {
        return await StoreKit2Manager.shared.getTransactionHistory()
    }
    
    /// 显示优惠代码兑换界面（iOS 16.0+）
    func presentOfferCodeRedeemSheet() async {
        let result =  await StoreKit2Manager.shared.presentOfferCodeRedeemSheet()
        if(result){
            await refreshPurchases()
        }
    }
    
    // MARK: - 辅助方法
    
    
    /// 按类型获取产品
    var consumables: [Product] {
        StoreKit2Manager.shared.consumables
    }
    
    var nonConsumables: [Product] {
        StoreKit2Manager.shared.nonConsumables
    }
    
    var nonRenewables: [Product] {
        StoreKit2Manager.shared.nonRenewables
    }
    
    var autoRenewables: [Product] {
        StoreKit2Manager.shared.autoRenewables
    }
    
    /// 获取消耗品的购买历史
    /// - Parameter productId: 产品ID
    /// - Returns: 该消耗品的所有购买历史
    func getConsumablePurchaseHistory(for productId: String) async -> [TransactionHistory] {
        return await StoreKit2Manager.shared.getConsumablePurchaseHistory(for: productId)
    }
    
    /// 获取消耗品的购买次数
    /// - Parameter productId: 产品ID
    /// - Returns: 购买次数
    func getConsumablePurchaseCount(for productId: String) async -> Int {
        let history = await getConsumablePurchaseHistory(for: productId)
        return history.count
    }
}

