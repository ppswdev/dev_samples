//
//  StoreKitServiceDelegate.swift
//  StoreKitManager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// StoreKitService 内部代理协议
/// 所有回调都在主线程执行
@MainActor
internal protocol StoreKitServiceDelegate: AnyObject {
    /// 状态更新
    func service(_ service: StoreKitService, didUpdateState state: StoreKitState)
    
    /// 产品加载成功
    func service(_ service: StoreKitService, didLoadProducts products: [Product])
    
    /// 已购买产品更新
    func service(_ service: StoreKitService, didUpdatePurchasedProducts products: [Product])
    
    /// 订阅状态变化
    func service(_ service: StoreKitService, didUpdateSubscriptionStatus status: Product.SubscriptionInfo.RenewalState?)
}

