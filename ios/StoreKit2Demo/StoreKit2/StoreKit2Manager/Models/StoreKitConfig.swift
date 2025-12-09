//
//  StoreKitConfig.swift
//  StoreKit2Manager
//
//  Created by xiaopin on 2025/12/6.
//

import Foundation

/// StoreKit 配置模型
public struct StoreKitConfig {
    /// 产品ID数组
    public let productIds: [String]
    
    /// 非续订订阅的过期天数（从购买日期开始计算）
    /// 如果为 nil，则表示非续订订阅永不过期
    public let nonRenewableExpirationDays: Int?
    
    /// 是否自动排序产品（按价格从低到高）
    public let autoSortProducts: Bool
    
    /// 初始化配置
    /// - Parameters:
    ///   - productIds: 产品ID数组
    ///   - nonRenewableExpirationDays: 非续订订阅过期天数，默认为 365 天
    ///   - autoSortProducts: 是否自动排序产品，默认为 true
    public init(
        productIds: [String],
        nonRenewableExpirationDays: Int? = 365,
        autoSortProducts: Bool = true
    ) {
        self.productIds = productIds
        self.nonRenewableExpirationDays = nonRenewableExpirationDays
        self.autoSortProducts = autoSortProducts
    }
}

// MARK: - 配置文件支持
extension StoreKitConfig {
    /// 从 plist 文件加载配置
    /// - Parameter name: plist 文件名（不包含扩展名），默认为 "StoreKitConfig"
    /// - Returns: StoreKitConfig 实例
    /// - Throws: StoreKitError.configurationMissing 如果配置文件不存在或格式错误
    public static func fromPlist(named name: String = "StoreKitConfig") throws -> StoreKitConfig {
        guard let path = Bundle.main.path(forResource: name, ofType: "plist"),
              let plist = NSDictionary(contentsOfFile: path),
              let productIds = plist["productIds"] as? [String] else {
            throw StoreKitError.configurationMissing
        }
        
        let expirationDays = plist["nonRenewableExpirationDays"] as? Int
        let autoSort = plist["autoSortProducts"] as? Bool ?? true
        
        return StoreKitConfig(
            productIds: productIds,
            nonRenewableExpirationDays: expirationDays,
            autoSortProducts: autoSort
        )
    }
    
    /// 从 JSON 文件加载配置
    /// - Parameter name: JSON 文件名（不包含扩展名），默认为 "StoreKitConfig"
    /// - Returns: StoreKitConfig 实例
    /// - Throws: StoreKitError.configurationMissing 如果配置文件不存在或格式错误
    public static func fromJSON(named name: String = "StoreKitConfig") throws -> StoreKitConfig {
        guard let path = Bundle.main.path(forResource: name, ofType: "json"),
              let data = NSData(contentsOfFile: path),
              let json = try? JSONSerialization.jsonObject(with: data as Data) as? [String: Any],
              let productIds = json["productIds"] as? [String] else {
            throw StoreKitError.configurationMissing
        }
        
        let expirationDays = json["nonRenewableExpirationDays"] as? Int
        let autoSort = json["autoSortProducts"] as? Bool ?? true
        
        return StoreKitConfig(
            productIds: productIds,
            nonRenewableExpirationDays: expirationDays,
            autoSortProducts: autoSort
        )
    }
}

