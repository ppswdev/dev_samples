//
//  SubscriptionInfo.swift
//  StoreKitManager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// 当前有效订阅详细信息
public struct ValidSubscriptionInfo {
    /// 产品ID
    public let productId: String
    
    /// 产品对象
    public let product: Product
    
    /// 订阅状态
    public let renewalState: Product.SubscriptionInfo.RenewalState
    
    /// 续订日期（如果已订阅）
    public let renewalDate: Date?
    
    /// 是否在试用期
    public let isInTrialPeriod: Bool
    
    /// 是否在优惠价格期（介绍性价格）
    public let isInIntroductoryPricePeriod: Bool
    
    /// 试用期结束日期
    public let trialPeriodEndDate: Date?
    
    /// 优惠价格期结束日期
    public let introductoryPriceEndDate: Date?
    
    /// 订阅组ID
    public let subscriptionGroupId: String?
    
    /// 是否已取消订阅（但仍在有效期内）
    public let isCancelled: Bool
    
    /// 取消日期
    public let cancellationDate: Date?
    
    /// 过期日期（如果已过期）
    public let expirationDate: Date?
    
    /// 是否已过期
    public var isExpired: Bool {
        guard let expirationDate = expirationDate else { return false }
        return Date() > expirationDate
    }
    
    /// 是否有效（已订阅且未过期）
    public var isValid: Bool {
        return renewalState == .subscribed && !isExpired
    }
    
    public init(
        productId: String,
        product: Product,
        renewalState: Product.SubscriptionInfo.RenewalState,
        renewalDate: Date? = nil,
        isInTrialPeriod: Bool = false,
        isInIntroductoryPricePeriod: Bool = false,
        trialPeriodEndDate: Date? = nil,
        introductoryPriceEndDate: Date? = nil,
        subscriptionGroupId: String? = nil,
        isCancelled: Bool = false,
        cancellationDate: Date? = nil,
        expirationDate: Date? = nil
    ) {
        self.productId = productId
        self.product = product
        self.renewalState = renewalState
        self.renewalDate = renewalDate
        self.isInTrialPeriod = isInTrialPeriod
        self.isInIntroductoryPricePeriod = isInIntroductoryPricePeriod
        self.trialPeriodEndDate = trialPeriodEndDate
        self.introductoryPriceEndDate = introductoryPriceEndDate
        self.subscriptionGroupId = subscriptionGroupId
        self.isCancelled = isCancelled
        self.cancellationDate = cancellationDate
        self.expirationDate = expirationDate
    }
}

// MARK: - 从 Product 创建
extension ValidSubscriptionInfo {
    /// 从 Product 创建订阅信息
    /// 使用 Product.SubscriptionInfo 来获取订阅状态和详细信息
    public static func from(_ product: Product) async -> ValidSubscriptionInfo? {
        // 1. 检查产品是否有订阅信息
        guard let subscription = product.subscription else { return nil }
        
        // 2. 从 Product.SubscriptionInfo.status 获取订阅状态
        // status 返回 [Product.SubscriptionInfo.Status] 数组（不是 AsyncSequence）
        // 每个 Status 包含：
        //   - state: RenewalState（订阅状态）
        //   - renewalInfo: VerificationResult<RenewalInfo>（续订信息）
        //   - transaction: VerificationResult<Transaction>（交易信息）
        
        var renewalState: Product.SubscriptionInfo.RenewalState = .expired
        var isCancelled = false
        var renewalDate: Date?
        var expirationDate: Date?
        var isInTrialPeriod = false
        var isInIntroductoryPricePeriod = false
        var trialPeriodEndDate: Date?
        var introductoryPriceEndDate: Date?
        var cancellationDate: Date?
        
        do {
            // 获取订阅状态列表
            // subscription.status 返回 [Product.SubscriptionInfo.Status]，不是 AsyncSequence
            // 需要 await 来获取状态数组
            let statuses = try await subscription.status
            
            // 获取第一个状态（通常是最新的）
            if let status = statuses.first {
                // 使用最新的订阅状态
                renewalState = status.state
                
                // 从 renewalInfo 获取续订信息
//                if let renewalInfoResult = status.renewalInfo {
//                    switch renewalInfoResult {
//                    case .verified(let renewalInfo):
//                        // renewalInfo 包含：
//                        //   - willAutoRenew: 是否自动续订
//                        //   - expirationDate: 过期日期
//                        //   - renewalDate: 续订日期
//                        //   - autoRenewPreference: 自动续订偏好
//                        //   - autoRenewProductId: 自动续订产品ID
//                        
//                        isCancelled = !renewalInfo.willAutoRenew
//                        expirationDate = renewalInfo.expirationDate
//                        renewalDate = renewalInfo.renewalDate
//                        
//                        // 如果已取消，获取取消日期
//                        if isCancelled {
//                            cancellationDate = renewalInfo.expirationDate
//                        }
//                    case .unverified:
//                        // 无法验证续订信息
//                        break
//                    }
//                }
//                
//                // 从 transaction 获取交易信息
//                if let transactionResult = status.transaction {
//                    switch transactionResult {
//                    case .verified(let transaction):
//                        // 从交易中获取过期日期（如果 renewalInfo 没有）
//                        if expirationDate == nil {
//                            expirationDate = transaction.expirationDate
//                        }
//                        
//                        // 检查是否在试用期（需要从 transaction 的购买日期和产品信息判断）
//                        // 这里简化处理，实际应该比较购买日期和试用期长度
//                    case .unverified:
//                        break
//                    }
//                }
            }
        } catch {
            print("获取订阅状态失败: \(error)")
            // 如果获取状态失败，尝试从 Transaction 获取
            if let transactionResult = try? await StoreKit.Transaction.latest(for: product.id) {
                switch transactionResult {
                case .verified(let transaction):
                    expirationDate = transaction.expirationDate
                    renewalDate = transaction.expirationDate
                case .unverified:
                    break
                }
            }
        }
        
        // 3. 从 Product.SubscriptionInfo 获取订阅产品信息
        // subscription 包含：
        //   - subscriptionPeriod: 订阅周期
        //   - subscriptionGroupID: 订阅组ID
        //   - introductoryOffer: 介绍性优惠
        //   - promotionalOffers: 促销优惠
        
        // 检查是否有介绍性优惠
        if let introductoryOffer = subscription.introductoryOffer {
            isInIntroductoryPricePeriod = true
            // 计算优惠期结束日期（需要从交易信息获取更准确的时间）
            // 这里简化处理
        }
        
        return ValidSubscriptionInfo(
            productId: product.id,
            product: product,
            renewalState: renewalState,
            renewalDate: renewalDate,
            isInTrialPeriod: isInTrialPeriod,
            isInIntroductoryPricePeriod: isInIntroductoryPricePeriod,
            trialPeriodEndDate: trialPeriodEndDate,
            introductoryPriceEndDate: introductoryPriceEndDate,
            subscriptionGroupId: subscription.subscriptionGroupID,
            isCancelled: isCancelled,
            cancellationDate: cancellationDate,
            expirationDate: expirationDate
        )
    }
}

