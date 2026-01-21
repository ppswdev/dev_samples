# KeychainSwift 快速参考

## 🚀 快速开始

### 1. 在代码中导入

```swift
import KeychainSwift
```

### 2. 使用 KeychainManager 单例

```swift
let manager = KeychainManager.shared
```

## 📌 常用操作速查表

### 保存数据

```swift
// 保存字符串
KeychainManager.shared.save("myToken", for: "userToken")

// 保存数据
let data = "sensitiveData".data(using: .utf8)!
KeychainManager.shared.saveData(data, for: "myData")
```

### 读取数据

```swift
// 读取字符串
if let token = KeychainManager.shared.getString(for: "userToken") {
    print("Token: \(token)")
}

// 读取数据
if let data = KeychainManager.shared.getData(for: "myData") {
    let string = String(data: data, encoding: .utf8)
}
```

### 删除数据

```swift
// 删除单个键
KeychainManager.shared.delete(for: "userToken")

// 清空所有
KeychainManager.shared.deleteAll()
```

### 检查存在性

```swift
if KeychainManager.shared.exists(for: "userToken") {
    print("Token 已保存")
}
```

## 🔑 预设键名

| 常量名         | 用途         | 示例                                |
| -------------- | ------------ | ----------------------------------- |
| `userToken`    | 用户认证令牌 | `KeychainManager.Keys.userToken`    |
| `refreshToken` | 刷新令牌     | `KeychainManager.Keys.refreshToken` |
| `userPassword` | 用户密码     | `KeychainManager.Keys.userPassword` |
| `apiKey`       | API密钥      | `KeychainManager.Keys.apiKey`       |

## 💡 典型使用场景

### 场景 1: 登录流程

```swift
// 用户登录成功后保存token
func loginSuccess(token: String) {
    KeychainManager.shared.save(token, for: KeychainManager.Keys.userToken)
    // 导航到主屏幕
}
```

### 场景 2: 检查登录状态

```swift
// 在应用启动时检查是否已登录
func checkLoginStatus() -> Bool {
    return KeychainManager.shared.exists(for: KeychainManager.Keys.userToken)
}
```

### 场景 3: 使用保存的token

```swift
// 发送API请求时使用保存的token
func fetchUserData() {
    if let token = KeychainManager.shared.getString(for: KeychainManager.Keys.userToken) {
        let headers = ["Authorization": "Bearer \(token)"]
        // 使用headers发送请求
    }
}
```

### 场景 4: 退出登录

```swift
// 用户退出登录时清除敏感数据
func logout() {
    KeychainManager.shared.delete(for: KeychainManager.Keys.userToken)
    KeychainManager.shared.delete(for: KeychainManager.Keys.refreshToken)
    // 返回登录屏幕
}
```

## 🔒 安全要点

✅ **应该做的:**

- 使用钥匙串存储敏感信息（token、密钥等）
- 定期检查和更新token
- 登出时清除钥匙串数据
- 使用预定义的键常量

❌ **不应该做的:**

- 在代码中硬编码敏感信息
- 将token存储在 UserDefaults
- 忽视访问控制权限
- 在网络请求前不验证token

## 🐛 常见问题

**Q: 为什么两个应用不能共享数据?**
A: 检查 entitlements 文件中的 keychain-access-groups 是否相同

**Q: 如何在真机上测试?**
A: 确保 Xcode 中已启用 Keychain Sharing 能力，并检查证书

**Q: KeychainSwift 是线程安全的吗?**
A: 是的，KeychainSwift 使用串行队列确保线程安全

## 📱 Demo1 和 Demo2 协作

两个应用使用相同的钥匙串访问组 `com.mobiunity.dev.apps.group1`：

```
Demo1 保存 ← → Demo2 读取
Demo2 保存 ← → Demo1 读取
```

**示例：SSO (单点登录)**

```swift
// Demo1 中用户登录
KeychainManager.shared.save("shared_token", for: "userToken")

// Demo2 自动获得相同的token，无需重新登录
if let token = KeychainManager.shared.getString(for: "userToken") {
    // Demo2 已经获取到共享的token
}
```

## 📖 更多资源

- 详细文档: [KEYCHAIN_CONFIG.md](KEYCHAIN_CONFIG.md)
- KeychainSwift 仓库: https://github.com/evgenyneu/keychain-swift
- Apple 安全指南: https://developer.apple.com/security/

---

_最后更新: 2026年1月20日_
