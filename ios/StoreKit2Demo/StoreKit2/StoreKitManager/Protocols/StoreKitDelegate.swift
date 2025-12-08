//
//  StoreKitDelegate.swift
//  StoreKitManager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// StoreKit 代理协议
/// 所有方法都在主线程调用
public protocol StoreKitDelegate: AnyObject {
    /// 状态更新回调
    /// - Parameters:
    ///   - manager: StoreKitManager 实例
    ///   - state: 新的状态
    func storeKit(_ manager: StoreKitManager, didUpdateState state: StoreKitState)
    
    /// 产品加载成功回调
    /// - Parameters:
    ///   - manager: StoreKitManager 实例
    ///   - products: 加载的产品列表
    func storeKit(_ manager: StoreKitManager, didLoadProducts products: [Product])
    
    /// 已购买产品更新回调
    /// - Parameters:
    ///   - manager: StoreKitManager 实例
    ///   - products: 已购买的产品列表
    func storeKit(_ manager: StoreKitManager, didUpdatePurchasedTransactions efficient: [Transaction], latests: [Transaction])
    
    /// 订阅状态变化回调
    /// - Parameters:
    ///   - manager: StoreKitManager 实例
    ///   - status: 订阅状态，nil 表示没有订阅
    func storeKit(_ manager: StoreKitManager, didUpdateSubscriptionStatus status: Product.SubscriptionInfo.RenewalState?)
}

// MARK: - 可选方法默认实现
extension StoreKitDelegate {
    public func storeKit(_ manager: StoreKitManager, didUpdateState state: StoreKitState) {
        // 默认实现为空，子类可以选择性实现
    }
    
    public func storeKit(_ manager: StoreKitManager, didLoadProducts products: [Product]) {
        // 默认实现为空，子类可以选择性实现
    }
    
    public func storeKit(_ manager: StoreKitManager, didUpdatePurchasedTransactions efficient: [Transaction], latests: [Transaction]) {
        // 默认实现为空，子类可以选择性实现
    }
    
    public func storeKit(_ manager: StoreKitManager, didUpdateSubscriptionStatus status: Product.SubscriptionInfo.RenewalState?) {
        // 默认实现为空，子类可以选择性实现
    }
}

