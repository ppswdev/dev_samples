# KeychainSwift 钥匙串共享配置

## 📋 项目概述

已为 Demo1 和 Demo2 添加了 KeychainSwift 库的集成，并配置了钥匙串共享功能，使两个应用能够共享存储在钥匙串中的敏感数据。

## ✅ 已完成的配置

### 1. 依赖库添加

- ✅ 为 Demo1 和 Demo2 添加了 KeychainSwift 依赖（v24.0.0+）
- ✅ 通过 Swift Package Manager (SPM) 集成

### 2. 钥匙串访问组配置

已在两个应用的 entitlements 文件中配置了相同的钥匙串访问组：

```
$(AppIdentifierPrefix)com.mobiunity.dev.apps.group1
```

**重要说明**：

- 两个应用使用相同的访问组 ID，这使它们能够共享钥匙串数据
- `$(AppIdentifierPrefix)` 会自动替换为您的 Team ID
- 必须在苹果开发者账户中为两个应用都启用 **Keychain Sharing** 能力

### 3. 已创建的文件

#### KeychainManager.swift

这是一个单例类，提供了简化的钥匙串操作接口：

```swift
// 保存
KeychainManager.shared.save("token123", for: KeychainManager.Keys.userToken)

// 读取
if let token = KeychainManager.shared.getString(for: KeychainManager.Keys.userToken) {
    print("Token: \(token)")
}

// 删除
KeychainManager.shared.delete(for: KeychainManager.Keys.userToken)

// 检查是否存在
if KeychainManager.shared.exists(for: KeychainManager.Keys.userToken) {
    print("Token exists")
}
```

#### KeychainExample.swift

提供了常用的钥匙串操作示例方法。

## 🎯 支持的操作

### 保存数据

```swift
// 保存字符串
KeychainManager.shared.save("value", for: "key")

// 保存二进制数据
KeychainManager.shared.saveData(data, for: "key")
```

### 读取数据

```swift
// 读取字符串
if let value = KeychainManager.shared.getString(for: "key") { }

// 读取二进制数据
if let data = KeychainManager.shared.getData(for: "key") { }
```

### 删除数据

```swift
// 删除单个键
KeychainManager.shared.delete(for: "key")

// 清空所有钥匙串数据
KeychainManager.shared.deleteAll()
```

### 检查数据

```swift
if KeychainManager.shared.exists(for: "key") {
    // 键存在
}
```

## 📦 预定义的键常量

```swift
enum Keys {
    static let userToken = "userToken"           // 用户登录令牌
    static let refreshToken = "refreshToken"     // 刷新令牌
    static let userPassword = "userPassword"     // 用户密码
    static let apiKey = "apiKey"                 // API密钥
}
```

使用方式：

```swift
KeychainManager.shared.save("token123", for: KeychainManager.Keys.userToken)
```

## 🔐 数据访问权限设置

默认设置为 `.accessibleAfterFirstUnlock`，这意味着：

- 在设备首次解锁后，应用可以访问钥匙串数据
- 即使应用在后台运行，数据也可以访问
- 这是推荐用于大多数应用的配置

如需修改访问权限，可在 KeychainManager.swift 中修改 `.accessibleAfterFirstUnlock` 为其他选项。

## 🔄 跨应用数据共享

由于两个应用配置了相同的钥匙串访问组 `com.mobiunity.dev.apps.group1`，可以实现以下功能：

```swift
// Demo1 应用中保存数据
KeychainManager.shared.save("shared_token", for: "userToken")

// Demo2 应用中读取相同的数据
if let token = KeychainManager.shared.getString(for: "userToken") {
    print("获取到共享的token: \(token)")
}
```

## 🛠️ 故障排除

### 数据无法在应用间共享

1. 确认两个应用已正确配置了相同的钥匙串访问组
2. 检查 entitlements 文件中的访问组 ID 是否一致
3. 确保两个应用使用相同的 Development Team

### 权限错误

1. 检查应用是否已在 Xcode 中启用 Keychain Sharing 能力
2. 验证证书和预配置文件是否包含 Keychain Sharing 权限

### 找不到 KeychainSwift 导入

1. 在 Xcode 中选择 Product → Clean Build Folder
2. 然后重新构建项目
3. 如果问题仍然存在，尝试更新 Swift Package Manager 缓存

## 📚 相关资源

- [KeychainSwift GitHub](https://github.com/evgenyneu/keychain-swift)
- [Apple Keychain Services](https://developer.apple.com/documentation/security/keychain_services)
- [App Groups 文档](https://developer.apple.com/documentation/bundleresources/entitlements/com_apple_security_application-groups)

## ⚠️ 安全建议

1. **不要硬编码密钥**：始终使用预定义的键常量或配置
2. **使用 HTTPS**：网络数据传输时使用安全连接
3. **验证数据完整性**：存储前验证敏感数据的真实性
4. **定期审查**：定期检查钥匙串中存储的数据
5. **及时清理**：在不需要时及时删除过期的钥匙串数据

## 📝 更新日志

- **2026年1月20日**
  - 为 Demo1 和 Demo2 添加 KeychainSwift 库
  - 创建 KeychainManager 单例类
  - 配置钥匙串共享访问组
  - 添加 KeychainExample 示例类
