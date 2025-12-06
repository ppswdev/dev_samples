//
//  StoreKitState.swift
//  StoreKitManager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// StoreKit 状态枚举
public enum StoreKitState: Equatable {
    /// 空闲状态
    case idle
    
    /// 正在加载产品
    case loadingProducts
    
    /// 产品加载成功
    case productsLoaded([Product])
    
    /// 正在加载已购买产品
    case loadingPurchases
    
    /// 已购买产品加载完成
    case purchasesLoaded
    
    /// 正在购买指定产品
    case purchasing(String) // 产品ID
    
    /// 购买成功
    case purchaseSuccess(String) // 产品ID
    
    /// 购买待处理（需要用户操作）
    case purchasePending(String) // 产品ID
    
    /// 用户取消购买
    case purchaseCancelled(String) // 产品ID
    
    /// 购买失败
    case purchaseFailed(String, Error) // 产品ID, 错误
    
    /// 订阅状态变化
    case subscriptionStatusChanged(Product.SubscriptionInfo.RenewalState)
    
    /// 发生错误
    case error(Error)
    
    public static func == (lhs: StoreKitState, rhs: StoreKitState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle),
             (.loadingProducts, .loadingProducts),
             (.loadingPurchases, .loadingPurchases),
             (.purchasesLoaded, .purchasesLoaded):
            return true
        case (.productsLoaded(let lhsProducts), .productsLoaded(let rhsProducts)):
            return lhsProducts.map { $0.id } == rhsProducts.map { $0.id }
        case (.purchasing(let lhsId), .purchasing(let rhsId)),
             (.purchaseSuccess(let lhsId), .purchaseSuccess(let rhsId)),
             (.purchasePending(let lhsId), .purchasePending(let rhsId)),
             (.purchaseCancelled(let lhsId), .purchaseCancelled(let rhsId)):
            return lhsId == rhsId
        case (.purchaseFailed(let lhsId, _), .purchaseFailed(let rhsId, _)):
            return lhsId == rhsId
        case (.subscriptionStatusChanged(let lhsState), .subscriptionStatusChanged(let rhsState)):
            return lhsState == rhsState
        case (.error(let lhsError), .error(let rhsError)):
            return lhsError.localizedDescription == rhsError.localizedDescription
        default:
            return false
        }
    }
}

