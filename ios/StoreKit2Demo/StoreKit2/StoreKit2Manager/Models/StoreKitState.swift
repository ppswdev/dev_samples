//
//  StoreKitState.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// StoreKit 状态枚举
public enum StoreKitState {
    /// 空闲状态
    case idle
    
    /// 正在加载产品
    case loadingProducts
    
    /// 正在加载已购买产品
    case loadingPurchases
    
    /// 已购买产品加载完成
    case purchasesLoaded
    
    /// 正在购买指定产品
    case purchasing(String) // 产品ID
    
    /// 购买待处理（需要用户操作）
    case purchasePending(String) // 产品ID
    
    /// 用户取消购买
    case purchaseCancelled(String) // 产品ID
    
    /// 购买成功
    case purchaseSuccess(String) // 产品ID
    
    /// 购买失败
    case purchaseFailed(String, Error) // 产品ID, 错误
    
    /// 购买已退款
    case purchaseRefunded(String) // 产品ID
    
    /// 购买已撤销
    case purchaseRevoked(String) // 产品ID
    
    /// 正在恢复购买
    case restoringPurchases
    
    /// 恢复购买成功
    case restorePurchasesSuccess
    
    /// 恢复购买失败
    case restorePurchasesFailed(Error)
    
    /// 订阅已取消
    /// - Parameters:
    ///   - productId: 产品ID
    ///   - isFreeTrialCancelled: 是否在免费试用期取消（true 表示在免费试用期内取消，false 表示在付费订阅期内取消）
    case subscriptionCancelled(String, isFreeTrialCancelled: Bool)
    
    /// 发生错误
    case error(Error)
}

