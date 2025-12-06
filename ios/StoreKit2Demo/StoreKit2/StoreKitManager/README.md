# StoreKitManager

一个简洁、易用的 StoreKit2 封装库，提供统一的接口来管理应用内购买。

## 特性

- ✅ 配置驱动，易于集成
- ✅ 支持协议回调和闭包回调两种方式
- ✅ 自动监听交易状态变化
- ✅ 完整的错误处理
- ✅ 支持所有产品类型（消耗品、非消耗品、订阅等）
- ✅ 线程安全，所有回调在主线程
- ✅ 自动管理资源生命周期
- ✅ 支持从 plist/JSON 配置文件加载

## 快速开始

### 1. 基本配置

```swift
import StoreKitManager

// 方式1: 使用代码配置
let config = StoreKitConfig(
    productIds: [
        "premium.lifetime",
        "subscription.monthly",
        "subscription.yearly"
    ],
    nonRenewableExpirationDays: 365, // 非续订订阅过期天数
    autoSortProducts: true // 自动按价格排序
)

// 方式2: 从 plist 文件加载
let config = try StoreKitConfig.fromPlist(named: "StoreKitConfig")

// 方式3: 从 JSON 文件加载
let config = try StoreKitConfig.fromJSON(named: "StoreKitConfig")
```

### 2. 使用代理方式

```swift
class MyStoreManager: StoreKitDelegate {
    func setupStore() {
        let config = StoreKitConfig(
            productIds: ["premium.lifetime", "subscription.monthly"]
        )
        
        StoreKitManager.shared.configure(with: config, delegate: self)
    }
    
    // MARK: - StoreKitDelegate
    
    func storeKit(_ manager: StoreKitManager, didUpdateState state: StoreKitState) {
        switch state {
        case .productsLoaded(let products):
            print("产品加载成功: \(products.count) 个")
        case .purchaseSuccess(let productId):
            print("购买成功: \(productId)")
            // 解锁功能
        case .purchaseFailed(let productId, let error):
            print("购买失败: \(productId), 错误: \(error.localizedDescription)")
        case .subscriptionStatusChanged(let status):
            print("订阅状态变化: \(status)")
        default:
            break
        }
    }
    
    func storeKit(_ manager: StoreKitManager, didLoadProducts products: [Product]) {
        // 更新UI显示产品列表
    }
    
    func storeKit(_ manager: StoreKitManager, didUpdatePurchasedProducts products: [Product]) {
        // 更新已购买状态
    }
}
```

### 3. 使用闭包方式

```swift
func setupStore() {
    let config = StoreKitConfig(productIds: ["premium.lifetime"])
    
    StoreKitManager.shared.onStateChanged = { state in
        switch state {
        case .purchaseSuccess(let productId):
            print("购买成功: \(productId)")
        default:
            break
        }
    }
    
    StoreKitManager.shared.onProductsLoaded = { products in
        print("加载了 \(products.count) 个产品")
    }
    
    StoreKitManager.shared.configure(with: config)
}
```

### 4. 购买产品

```swift
// 通过产品ID购买
Task {
    do {
        try await StoreKitManager.shared.purchase(productId: "premium.lifetime")
    } catch {
        print("购买失败: \(error)")
    }
}

// 通过产品对象购买
if let product = StoreKitManager.shared.product(for: "premium.lifetime") {
    Task {
        await StoreKitManager.shared.purchase(product)
    }
}
```

### 5. 查询购买状态

```swift
// 检查是否已购买
if StoreKitManager.shared.isPurchased(productId: "premium.lifetime") {
    // 解锁功能
}

// 获取所有已购买的产品
let purchased = StoreKitManager.shared.purchasedProducts

// 获取特定类型的已购买产品
let subscriptions = StoreKitManager.shared.purchasedAutoRenewables
```

### 6. 手动刷新

```swift
// 刷新产品列表
Task {
    await StoreKitManager.shared.refreshProducts()
}

// 刷新已购买产品列表
Task {
    await StoreKitManager.shared.refreshPurchases()
}
```

## 配置文件格式

### Plist 格式 (StoreKitConfig.plist)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>productIds</key>
    <array>
        <string>premium.lifetime</string>
        <string>subscription.monthly</string>
        <string>subscription.yearly</string>
    </array>
    <key>nonRenewableExpirationDays</key>
    <integer>365</integer>
    <key>autoSortProducts</key>
    <true/>
</dict>
</plist>
```

### JSON 格式 (StoreKitConfig.json)

```json
{
    "productIds": [
        "premium.lifetime",
        "subscription.monthly",
        "subscription.yearly"
    ],
    "nonRenewableExpirationDays": 365,
    "autoSortProducts": true
}
```

## 状态枚举

```swift
public enum StoreKitState {
    case idle                           // 空闲
    case loadingProducts                // 正在加载产品
    case productsLoaded([Product])      // 产品加载成功
    case loadingPurchases               // 正在加载已购买产品
    case purchasesLoaded                // 已购买产品加载完成
    case purchasing(String)             // 正在购买
    case purchaseSuccess(String)        // 购买成功
    case purchasePending(String)        // 购买待处理
    case purchaseCancelled(String)      // 用户取消购买
    case purchaseFailed(String, Error)  // 购买失败
    case subscriptionStatusChanged(RenewalState) // 订阅状态变化
    case error(Error)                   // 发生错误
}
```

## 错误处理

```swift
public enum StoreKitError: Error {
    case productNotFound(String)        // 产品未找到
    case purchaseFailed(Error)          // 购买失败
    case verificationFailed             // 交易验证失败
    case configurationMissing           // 配置缺失
    case serviceNotStarted              // 服务未启动
    case unknownError                   // 未知错误
}
```

## 架构说明

```
StoreKitManager (对外接口)
    ↓
StoreKitService (内部服务)
    ↓
StoreKit API
```

- **StoreKitManager**: 提供统一的对外接口，管理配置和回调
- **StoreKitService**: 内部服务层，处理与 StoreKit API 的交互
- **Models**: 配置、状态、错误等数据模型
- **Protocols**: 代理协议定义

## 注意事项

1. 确保在 App Store Connect 中配置了所有产品ID
2. 在真机上测试购买功能（模拟器不支持）
3. 使用沙盒测试账号进行测试
4. 所有回调都在主线程执行，可以直接更新UI
5. 服务会自动监听交易状态变化，无需手动刷新

## 生命周期管理

```swift
// 启动服务（在 configure 时自动启动）
StoreKitManager.shared.configure(with: config, delegate: self)

// 停止服务（释放资源）
StoreKitManager.shared.stop()
```

## 许可证

MIT License
