import UIKit

/// 钥匙串使用示例
class KeychainExample {
    
    // MARK: - Keys
    
    static let userTokenKey = "com.app.userToken"
    static let apiKeyKey = "com.app.apiKey"
    static let userIdKey = "com.app.userId"
    static let refreshTokenKey = "com.app.refreshToken"
    
    // MARK: - 保存方法
    
    /// 保存用户token
    static func saveUserToken(_ token: String) -> Bool {
        let success = KeychainManager.shared.save(key: userTokenKey, value: token)
        if success {
            print("✅ 已保存用户Token")
        } else {
            print("❌ 保存用户Token失败")
        }
        return success
    }
    
    /// 保存用户ID
    static func saveUserID(_ userId: String) -> Bool {
        let success = KeychainManager.shared.save(key: userIdKey, value: userId)
        if success {
            print("✅ 已保存用户ID")
        } else {
            print("❌ 保存用户ID失败")
        }
        return success
    }
    
    /// 保存刷新令牌
    static func saveRefreshToken(_ token: String) -> Bool {
        let success = KeychainManager.shared.save(key: refreshTokenKey, value: token)
        if success {
            print("✅ 已保存刷新令牌")
        } else {
            print("❌ 保存刷新令牌失败")
        }
        return success
    }
    
    /// 保存API密钥
    static func saveAPIKey(_ apiKey: String) -> Bool {
        let success = KeychainManager.shared.save(key: apiKeyKey, value: apiKey)
        if success {
            print("✅ 已保存API密钥")
        } else {
            print("❌ 保存API密钥失败")
        }
        return success
    }
    
    // MARK: - 读取方法
    
    /// 获取用户token
    static func getUserToken() -> String? {
        if let token = KeychainManager.shared.read(key: userTokenKey) {
            print("✅ 已获取用户Token")
            return token
        }
        print("❌ 未找到用户Token")
        return nil
    }
    
    /// 获取用户ID
    static func getUserID() -> String? {
        return KeychainManager.shared.read(key: userIdKey)
    }
    
    /// 获取刷新令牌
    static func getRefreshToken() -> String? {
        return KeychainManager.shared.read(key: refreshTokenKey)
    }
    
    /// 获取API密钥
    static func getAPIKey() -> String? {
        return KeychainManager.shared.read(key: apiKeyKey)
    }
    
    // MARK: - 删除方法
    
    /// 删除用户token
    static func deleteUserToken() {
        let success = KeychainManager.shared.delete(key: userTokenKey)
        if success {
            print("✅ 已删除用户Token")
        }
    }
    
    /// 删除用户ID
    static func deleteUserID() {
        let _ = KeychainManager.shared.delete(key: userIdKey)
    }
    
    /// 删除刷新令牌
    static func deleteRefreshToken() {
        let _ = KeychainManager.shared.delete(key: refreshTokenKey)
    }
    
    /// 删除API密钥
    static func deleteAPIKey() {
        let _ = KeychainManager.shared.delete(key: apiKeyKey)
    }
    
    // MARK: - 检查方法
    
    /// 检查Token是否存在
    static func isTokenExist() -> Bool {
        return KeychainManager.shared.read(key: userTokenKey) != nil
    }
    
    /// 检查用户ID是否存在
    static func isUserIDExist() -> Bool {
        return KeychainManager.shared.read(key: userIdKey) != nil
    }
    
    /// 检查API密钥是否存在
    static func isAPIKeyExist() -> Bool {
        return KeychainManager.shared.read(key: apiKeyKey) != nil
    }
    
    // MARK: - 清空方法
    
    /// 清空所有钥匙串数据
    static func clearAllKeychainData() {
        deleteUserToken()
        deleteUserID()
        deleteRefreshToken()
        deleteAPIKey()
        print("✅ 已清空所有钥匙串数据")
    }
    
    /// 登出（清空登录相关数据）
    static func logout() {
        deleteUserToken()
        deleteRefreshToken()
        deleteUserID()
        print("✅ 已清空登录信息")
    }
}

// MARK: - 在ViewController中的使用示例

/*
 在ViewController.swift中的使用方法:
 
 // 登录时保存token
 let token = "your_token_here"
 let userId = "user123"
 KeychainExample.saveUserToken(token)
 KeychainExample.saveUserID(userId)
 
 // 获取token
 if let token = KeychainExample.getUserToken() {
     // 使用token发送请求
 }
 
 // 检查是否已登录
 if KeychainExample.isTokenExist() {
     // 用户已登录
 }
 
 // 退出登录时删除token
 KeychainExample.logout()
 
 // 清空所有数据
 KeychainExample.clearAllKeychainData()
 */
