//
//  PurchaseConfig.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/11/4.
//
//  基于 StoreKit 2 的产品配置类
//  仅用于配置产品ID和类型，产品标题和描述通过 StoreKit 2 的 Product 对象动态获取（支持国际化）
//

import Foundation
import StoreKit

/// 购买配置类
/// 用于管理应用内购买的产品ID配置，支持消耗型、非消耗型、非自动续订和自动续订订阅
/// 注意：产品标题和描述通过 StoreKit 的 Product 对象动态获取，支持国际化
class PurchaseConfig {
    
    /// 消耗型产品ID集合
    static let consumableProductIDs: Set<String> = [
        // 示例：游戏币、道具等
        "coins_100",
        "coins_200",
        //"coins_1000",
    ]
    
    /// 非消耗型产品ID集合
    static let nonConsumableProductIDs: Set<String> = [
        // 示例：解锁功能、去广告等
        "remove_ads",
        "premium_lifetime",
    ]
    
    /// 非自动续订订阅产品ID集合
    static let nonRenewingSubscriptionProductIDs: Set<String> = [
        // 示例：有时间限制的订阅
        "premium_1month",
    ]
    
    /// 自动续订订阅产品ID集合
    static let autoRenewingSubscriptionProductIDs: Set<String> = [
        "premium_weekly",     // 周度订阅
        "premium_monthly",    // 月度订阅
        "premium_yearly",     // 年度订阅
    ]
    
    /// 所有产品ID集合（自动合并）
    static var allProductIDs: Set<String> {
        return consumableProductIDs
            .union(nonConsumableProductIDs)
            .union(nonRenewingSubscriptionProductIDs)
            .union(autoRenewingSubscriptionProductIDs)
    }
    
    /// 产品ID到产品类型的映射
    static let productTypeMap: [String: ProductType] = {
        var map: [String: ProductType] = [:]
        
        // 消耗型产品
        for productID in consumableProductIDs {
            map[productID] = .consumable
        }
        
        // 非消耗型产品
        for productID in nonConsumableProductIDs {
            map[productID] = .nonConsumable
        }
        
        // 非自动续订订阅
        for productID in nonRenewingSubscriptionProductIDs {
            map[productID] = .nonRenewingSubscription
        }
        
        // 自动续订订阅
        for productID in autoRenewingSubscriptionProductIDs {
            map[productID] = .autoRenewingSubscription
        }
        
        return map
    }()
    
    /// 获取产品类型
    /// - Parameter productID: 产品ID
    /// - Returns: 产品类型，如果未配置返回 nil
    static func getProductType(for productID: String) -> ProductType? {
        return productTypeMap[productID]
    }
    
    /// 获取指定类型的所有产品ID
    /// - Parameter type: 产品类型
    /// - Returns: 该类型的产品ID集合
    static func getProductIDs(for type: ProductType) -> Set<String> {
        switch type {
        case .consumable:
            return consumableProductIDs
        case .nonConsumable:
            return nonConsumableProductIDs
        case .nonRenewingSubscription:
            return nonRenewingSubscriptionProductIDs
        case .autoRenewingSubscription:
            return autoRenewingSubscriptionProductIDs
        }
    }
}
