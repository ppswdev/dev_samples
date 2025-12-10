//
//  TransactionConverter.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation
import StoreKit

/// Transaction 转换器
/// 将 Transaction 对象转换为可序列化的基础数据类型（Dictionary/JSON）
public struct TransactionConverter {
    
    /// 将 Transaction 转换为 Dictionary（可序列化为 JSON）
    /// - Parameter transaction: Transaction 对象
    /// - Returns: Dictionary 对象，包含所有交易信息
    public static func toDictionary(_ transaction: Transaction) -> [String: Any] {
        var dict: [String: Any] = [:]
        
        // 基本信息
        dict["id"] = String(transaction.id)
        dict["productID"] = transaction.productID
        dict["purchaseDate"] = dateToTimestamp(transaction.purchaseDate)
        
        // 过期日期（如果有）
        if let expirationDate = transaction.expirationDate {
            dict["expirationDate"] = dateToTimestamp(expirationDate)
        } else {
            dict["expirationDate"] = NSNull()
        }
        
        // 撤销日期（如果有）
        if let revocationDate = transaction.revocationDate {
            dict["revocationDate"] = dateToTimestamp(revocationDate)
            dict["isRefunded"] = true
            dict["isRevoked"] = true
        } else {
            dict["revocationDate"] = NSNull()
            dict["isRefunded"] = false
            dict["isRevoked"] = false
        }
        
        // 撤销原因
        if let revocationReason = transaction.revocationReason {
            dict["revocationReason"] = revocationReasonToString(revocationReason)
        } else {
            dict["revocationReason"] = NSNull()
        }
        
        // 产品类型
        dict["productType"] = productTypeToString(transaction.productType)
        
        // 所有权类型
        dict["ownershipType"] = ownershipTypeToString(transaction.ownershipType)
        
        // 原始交易ID
        dict["originalID"] = String(transaction.originalID)
        
        // 原始购买日期
        dict["originalPurchaseDate"] = dateToTimestamp(transaction.originalPurchaseDate)
        
        // 是否升级
        dict["isUpgraded"] = transaction.isUpgraded
        
        // 购买数量
        dict["purchasedQuantity"] = transaction.purchasedQuantity
        
        // 交易价格（如果有）
        if let price = transaction.price {
            dict["price"] = NSDecimalNumber(decimal: price).doubleValue
        } else {
            dict["price"] = NSNull()
        }
        
        // 货币代码（iOS 16.0+）
        if #available(iOS 16.0, *) {
            if let currency = transaction.currency {
                dict["currency"] = currency
            } else {
                dict["currency"] = NSNull()
            }
        } else {
            dict["currency"] = NSNull()
        }
    
        // 环境信息（iOS 16.0+）
        if #available(iOS 16.0, *) {
            dict["environment"] = environmentToString(transaction.environment)
        } else {
            dict["environment"] = "unknown"
        }
        
        // 应用交易ID
        dict["appTransactionID"] = transaction.appTransactionID
        
        // 应用Bundle ID
        dict["appBundleID"] = transaction.appBundleID
        
        // 应用账户令牌（如果有）
        if let appAccountToken = transaction.appAccountToken {
            dict["appAccountToken"] = appAccountToken.uuidString
        } else {
            dict["appAccountToken"] = ""
        }
        
        // 订阅组ID（如果有，仅订阅产品）
        if let subscriptionGroupID = transaction.subscriptionGroupID {
            dict["subscriptionGroupID"] = subscriptionGroupID
        } else {
            dict["subscriptionGroupID"] = NSNull()
        }
        
        // 签名日期
        dict["signedDate"] = dateToTimestamp(transaction.signedDate)
        
        // 商店区域（iOS 17.0+）
        if #available(iOS 17.0, *) {
            dict["storefront"] = transaction.storefront
        } else {
            dict["storefront"] = NSNull()
        }
        
        // Web订单行项目ID（如果有）
        if let webOrderLineItemID = transaction.webOrderLineItemID {
            dict["webOrderLineItemID"] = String(webOrderLineItemID)
        } else {
            dict["webOrderLineItemID"] = NSNull()
        }
        
        // 设备验证
        dict["deviceVerification"] = transaction.deviceVerification
        
        // 设备验证Nonce
        dict["deviceVerificationNonce"] = transaction.deviceVerificationNonce
        
        // 交易原因（iOS 17.0+）
        if #available(iOS 17.0, *) {
            dict["reason"] = transactionReasonToString(transaction.reason)
        } else {
            dict["reason"] = ""
        }
        
        // 优惠信息
        // iOS 17.2+ 使用新的 offer 属性
        if #available(iOS 17.2, macOS 14.2, tvOS 17.2, watchOS 10.2, *) {
            if let offer = transaction.offer {
                var offerDict: [String: Any] = [:]
                // offer.type 的类型需要根据实际 API 调整
                // 暂时使用 String(describing:) 作为后备方案
                let offerTypeString = String(describing: offer.type)
                // 移除命名空间前缀
                if let lastDot = offerTypeString.lastIndex(of: ".") {
                    offerDict["type"] = String(offerTypeString[offerTypeString.index(after: lastDot)...])
                } else {
                    offerDict["type"] = offerTypeString
                }
                
                if let offerID = offer.id {
                    offerDict["id"] = offerID
                } else {
                    offerDict["id"] = NSNull()
                }
                
                if let paymentMode = offer.paymentMode {
                    offerDict["paymentMode"] = transactionOfferPaymentModeToString(paymentMode)
                } else {
                    offerDict["paymentMode"] = NSNull()
                }
                
                // 优惠周期（iOS 18.4+）
                if #available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *) {
                    if let period = offer.period {
                        offerDict["period"] = subscriptionPeriodToDictionary(period)
                    } else {
                        offerDict["period"] = NSNull()
                    }
                } else {
                    offerDict["period"] = NSNull()
                }
                
                dict["offer"] = offerDict
            } else {
                dict["offer"] = NSNull()
            }
        } else if #available(iOS 15.0, macOS 12.0, tvOS 15.0, watchOS 8.0, *) {
            // iOS 15.0 - iOS 17.1 使用已废弃的属性
            var offerDict: [String: Any] = [:]
            
            if let offerType = transaction.offerType {
                offerDict["type"] = transactionOfferTypeDeprecatedToString(offerType)
                
                if let offerID = transaction.offerID {
                    offerDict["id"] = offerID
                } else {
                    offerDict["id"] = NSNull()
                }
                
                if let paymentMode = transaction.offerPaymentModeStringRepresentation {
                    offerDict["paymentMode"] = paymentMode
                } else {
                    offerDict["paymentMode"] = NSNull()
                }
                
                // 优惠周期字符串（iOS 15.0 - iOS 18.3）
                if #available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *) {
                    // iOS 18.4+ 已废弃，但为了兼容性仍可检查
                    offerDict["period"] = NSNull()
                } else {
                    if let period = transaction.offerPeriodStringRepresentation {
                        offerDict["period"] = period
                    } else {
                        offerDict["period"] = NSNull()
                    }
                }
                
                dict["offer"] = offerDict
            } else {
                dict["offer"] = NSNull()
            }
        } else {
            // iOS 15.0 以下版本不支持优惠信息
            dict["offer"] = NSNull()
        }
        
        // 高级商务信息（iOS 18.4+）
        // 注意：Transaction.AdvancedCommerceInfo 的具体结构需要根据实际 API 调整
        if #available(iOS 18.4, macOS 15.4, tvOS 18.4, watchOS 11.4, visionOS 2.4, *) {
            if let advancedCommerceInfo = transaction.advancedCommerceInfo {
                // 使用 String(describing:) 作为后备方案
                // 或者根据实际 API 结构进行转换
                dict["advancedCommerceInfo"] = String(describing: advancedCommerceInfo)
            } else {
                dict["advancedCommerceInfo"] = NSNull()
            }
        } else {
            dict["advancedCommerceInfo"] = NSNull()
        }
        
        // Debug描述
        dict["debugDescription"] = transaction.debugDescription
        
        return dict
    }
    
    /// 将 Transaction 数组转换为 Dictionary 数组
    /// - Parameter transactions: Transaction 数组
    /// - Returns: Dictionary 数组
    public static func toDictionaryArray(_ transactions: [Transaction]) -> [[String: Any]] {
        return transactions.map { toDictionary($0) }
    }
    
    /// 将 Transaction 转换为 JSON 字符串
    /// - Parameter transaction: Transaction 对象
    /// - Returns: JSON 字符串
    public static func toJSONString(_ transaction: Transaction) -> String? {
        let dict = toDictionary(transaction)
        return dictionaryToJSONString(dict)
    }
    
    /// 将 Transaction 数组转换为 JSON 字符串
    /// - Parameter transactions: Transaction 数组
    /// - Returns: JSON 字符串
    public static func toJSONString(_ transactions: [Transaction]) -> String? {
        let array = toDictionaryArray(transactions)
        return arrayToJSONString(array)
    }
    
    // MARK: - 私有方法
    
    /// 日期转时间戳（毫秒）
    private static func dateToTimestamp(_ date: Date) -> Int64 {
        return Int64(date.timeIntervalSince1970 * 1000)
    }
    
    /// 产品类型转字符串
    private static func productTypeToString(_ type: Product.ProductType) -> String {
        switch type {
        case .consumable:
            return "consumable"
        case .nonConsumable:
            return "nonConsumable"
        case .autoRenewable:
            return "autoRenewable"
        case .nonRenewable:
            return "nonRenewable"
        default:
            return "unknown"
        }
    }
    
    /// 所有权类型转字符串
    private static func ownershipTypeToString(_ type: Transaction.OwnershipType) -> String {
        switch type {
        case .purchased:
            return "purchased"
        case .familyShared:
            return "familyShared"
        default:
            return "unknown"
        }
    }
    
    /// 环境转字符串
    @available(iOS 16.0, *)
    private static func environmentToString(_ environment: AppStore.Environment) -> String {
        switch environment {
        case .production:
            return "production"
        case .sandbox:
            return "sandbox"
        case .xcode:
            return "xcode"
        default:
            return "unknown"
        }
    }
    
    /// 交易原因转字符串
    @available(iOS 17.0, *)
    private static func transactionReasonToString(_ reason: Transaction.Reason) -> String {
        switch reason {
        case .purchase:
            return "purchase"
        case .renewal:
            return "renewal"
        default:
            return "unknown"
        }
    }
    
    /// 撤销原因转字符串
    private static func revocationReasonToString(_ reason: Transaction.RevocationReason) -> String {
        // 使用 String(describing:) 作为后备方案，因为枚举值可能因 iOS 版本而异
        let reasonString = String(describing: reason)
        // 移除命名空间前缀
        if let lastDot = reasonString.lastIndex(of: ".") {
            return String(reasonString[reasonString.index(after: lastDot)...])
        }
        return reasonString
    }
    
    // 注意：Transaction.Offer.OfferType 类型可能不存在，已移除此方法
    // 如果需要，可以使用 String(describing:) 来获取类型字符串
    
    /// 交易优惠类型转字符串（已废弃，iOS 15.0-17.1）
    @available(iOS 15.0, *)
    private static func transactionOfferTypeDeprecatedToString(_ type: Transaction.OfferType) -> String {
        switch type {
        case .introductory:
            return "introductory"
        case .promotional:
            return "promotional"
        case .code:
            return "code"
        default:
            return "unknown"
        }
    }
    
    /// 支付模式转字符串（用于 Product.SubscriptionOffer.PaymentMode）
    private static func paymentModeToString(_ mode: Product.SubscriptionOffer.PaymentMode) -> String {
        switch mode {
        case .freeTrial:
            return "freeTrial"
        case .payAsYouGo:
            return "payAsYouGo"
        case .payUpFront:
            return "payUpFront"
        default:
            return "unknown"
        }
    }
    
    /// 交易优惠支付模式转字符串（用于 Transaction.Offer.PaymentMode）
    @available(iOS 17.2, *)
    private static func transactionOfferPaymentModeToString(_ mode: Transaction.Offer.PaymentMode) -> String {
        // 使用 String(describing:) 作为后备方案，因为类型可能因 iOS 版本而异
        let modeString = String(describing: mode)
        // 移除命名空间前缀
        if let lastDot = modeString.lastIndex(of: ".") {
            return String(modeString[modeString.index(after: lastDot)...])
        }
        return modeString
    }
    
    /// 订阅周期转 Dictionary
    private static func subscriptionPeriodToDictionary(_ period: Product.SubscriptionPeriod) -> [String: Any] {
        var dict: [String: Any] = [:]
        dict["value"] = period.value
        dict["unit"] = subscriptionPeriodUnitToString(period.unit)
        return dict
    }
    
    /// 订阅周期单位转字符串
    private static func subscriptionPeriodUnitToString(_ unit: Product.SubscriptionPeriod.Unit) -> String {
        switch unit {
        case .day:
            return "day"
        case .week:
            return "week"
        case .month:
            return "month"
        case .year:
            return "year"
        default:
            return "unknown"
        }
    }
    
    // 注意：Transaction.AdvancedCommerceProduct 类型可能不存在，已移除此方法
    // 如果需要，可以直接使用 jsonRepresentation
    
    /// Dictionary 转 JSON 字符串
    private static func dictionaryToJSONString(_ dict: [String: Any]) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: dict, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
    
    /// Array 转 JSON 字符串
    private static func arrayToJSONString(_ array: [[String: Any]]) -> String? {
        guard let jsonData = try? JSONSerialization.data(withJSONObject: array, options: .prettyPrinted),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            return nil
        }
        return jsonString
    }
}

