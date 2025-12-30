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
class StoreExampleViewModel: ObservableObject, @preconcurrency StoreKitDelegate {
    @Published var products: [Product] = []
    @Published var purchasedTransactions: [Transaction] = []
    @Published var latestTransactions: [Transaction] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var alertMessage: String?
    @Published var showAlert = false
    @Published var subscriptionInfo: SubscriptionInfo?
    
    /// 产品显示信息
    struct ProductDisplayInfo {
        let productId: String
        let title: String
        let subtitle: String
        let buttonText: String
    }
    
    /// 产品显示信息字典，key 为 productId
    @Published var productDisplayInfo: [String: ProductDisplayInfo] = [:]
    
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
            
        case .loadingPurchases:
            isLoading = true
            print("正在加载已购买交易...")
        case .purchasesLoaded:
            isLoading = false
            print("✅ 已购买产品加载完成, 共 \(purchasedTransactions.count) 个有效交易")
            
        case .purchasing(let productId):
            isLoading = true
            print("正在购买: \(productId)")
            
        case .purchaseSuccess(let productId, let transaction):
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
            
        case .purchaseFailed(let productId, let errorMessage):
            isLoading = false
            print("❌ 购买失败: \(productId)， \(errorMessage)")
            
        case .restoringPurchases:
            isLoading = true
            print("正在恢复购买...")
            
        case .restorePurchasesSuccess:
            isLoading = false
            print("✅ 恢复购买成功")
            Task {
                await refreshPurchases()
            }
            
        case .restorePurchasesFailed(let errorMessage):
            isLoading = false
            print("❌ 恢复购买失败: \(errorMessage)")
            
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
            
        case .subscriptionCancelled(let productId, let isFreeTrialCancelled):
            print("⚠️ 订阅已取消: \(productId), 是否是免费试用期取消：\(isFreeTrialCancelled)")
            Task {
                await refreshPurchases()
            }
            
        case .error(let errorPosition,let errorMessage,let errorDetail):
            isLoading = false
            print("❌ 发生错误: \(errorPosition),\(errorMessage),\(errorDetail)")
            
        default:
            break
        }
    }
    
    func storeKit(_ manager: StoreKit2Manager, didLoadProducts products: [Product]) {
        self.products = products
        
        // 为每个产品生成显示信息
        Task {
            await loadProductDisplayInfo(products: products)
        }
    }
    
    /// 加载产品的显示信息（标题、副标题、按钮文本）
    /// - Parameter products: 产品数组
    private func loadProductDisplayInfo(products: [Product]) async {
        // 获取当前语言代码
        let languageCode = "zh_Hans"
        
        var displayInfoDict: [String: ProductDisplayInfo] = [:]
        
        for product in products {
            // 确定周期类型
            let periodType = determinePeriodType(for: product)
            
            // 获取标题
            let title = StoreKit2Manager.shared.productForVipTitle(
                for: product.id,
                periodType: periodType,
                languageCode: languageCode,
                isShort: false
            )
            
            // 获取副标题（异步）
            let subtitle = await StoreKit2Manager.shared.productForVipSubtitle(
                for: product.id,
                periodType: periodType,
                languageCode: languageCode
            )
            
            // 获取按钮文本（异步）
            let buttonText = await StoreKit2Manager.shared.productForVipButtonText(
                for: product.id,
                languageCode: languageCode
            )
            
            // 存储显示信息
            displayInfoDict[product.id] = ProductDisplayInfo(
                productId: product.id,
                title: title,
                subtitle: subtitle,
                buttonText: buttonText
            )
        }
        
        // 更新 UI
        self.productDisplayInfo = displayInfoDict
        
        // 打印显示信息（用于调试）
        print("=== 产品显示信息 ===")
        for (productId, info) in displayInfoDict {
            print("产品ID: \(productId)")
            print("  标题: \(info.title)")
            print("  副标题: \(info.subtitle)")
            print("  按钮文本: \(info.buttonText)")
            print("---")
        }
    }
    
    /// 确定产品的周期类型
    /// - Parameter product: 产品对象
    /// - Returns: 订阅周期类型
    private func determinePeriodType(for product: Product) -> SubscriptionPeriodType {
        // 检查是否是终身会员
        if lifetimeIds.contains(product.id) {
            return .lifetime
        }
        
        // 检查是否有订阅信息
        if let subscription = product.subscription {
            let unit = SubscriptionLocale.getUnit(from: subscription.subscriptionPeriod)
            switch unit {
            case "week":
                return .week
            case "month":
                return .month
            case "year":
                return .year
            default:
                return .month // 默认返回月
            }
        }
        
        // 默认返回月
        return .month
    }
    
    func storeKit(_ manager: StoreKit2Manager, didUpdatePurchasedTransactions efficient: [Transaction], latests: [Transaction]) {
        self.purchasedTransactions = efficient
        self.latestTransactions = latests
    }
    
    // MARK: - 公共方法
    
    /// 购买产品
    func purchase(_ product: Product) {
        Task {
            let isSubscribedButFreeTrailCancelled = await StoreKit2Manager.shared.isSubscribedButFreeTrailCancelled(productId: product.id)
            print("\(product.id) => isSubscribedButFreeTrailCancelled \(isSubscribedButFreeTrailCancelled)")
            await StoreKit2Manager.shared.purchase(product)
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
        self.purchasedTransactions = StoreKit2Manager.shared.validTransactions
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
        if #available(iOS 16.0, *) {
            let result =  await StoreKit2Manager.shared.presentOfferCodeRedeemSheet()
            if(result){
                await refreshPurchases()
            }
        } else {
            // Fallback on earlier versions
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

