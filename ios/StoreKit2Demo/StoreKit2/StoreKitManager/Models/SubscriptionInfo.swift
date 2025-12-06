//
//  SubscriptionInfo.swift
//  StoreKitManager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// 订阅详细信息
public struct SubscriptionInfo {
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
extension SubscriptionInfo {
    /// 从 Product 创建订阅信息
    public static func from(_ product: Product) async -> SubscriptionInfo? {
        guard let subscription = product.subscription else { return nil }
        
        let statuses = try? await subscription.status
        let status = statuses?.first
        
        let renewalState = status?.state ?? .expired
        
        // 验证并获取续订信息
        var isCancelled = false
        if let renewalInfoResult = status?.renewalInfo {
            switch renewalInfoResult {
            case .verified(let renewalInfo):
                isCancelled = !renewalInfo.willAutoRenew
            case .unverified:
                // 无法验证，默认为未取消
                isCancelled = false
            }
        }
        
        // 计算续订日期
        var renewalDate: Date?
        if let transactionResult = try? await StoreKit.Transaction.latest(for: product.id) {
            switch transactionResult {
            case .verified(let transaction):
                renewalDate = transaction.expirationDate
            case .unverified:
                // 无法验证交易，跳过
                break
            }
        }
        
        // 检查是否在试用期（简化处理）
        let isInTrialPeriod = false // 需要从 transaction 获取更准确的信息
        
        // 检查是否在优惠价格期
        let isInIntroductoryPricePeriod = subscription.introductoryOffer != nil
        let introductoryPriceEndDate: Date? = nil // 需要从 transaction 获取更准确的信息
        
        return SubscriptionInfo(
            productId: product.id,
            product: product,
            renewalState: renewalState,
            renewalDate: renewalDate,
            isInTrialPeriod: isInTrialPeriod,
            isInIntroductoryPricePeriod: isInIntroductoryPricePeriod,
            trialPeriodEndDate: nil, // 需要从 transaction 获取
            introductoryPriceEndDate: introductoryPriceEndDate,
            subscriptionGroupId: subscription.subscriptionGroupID,
            isCancelled: isCancelled,
            cancellationDate: nil,
            expirationDate: renewalDate
        )
    }
}

