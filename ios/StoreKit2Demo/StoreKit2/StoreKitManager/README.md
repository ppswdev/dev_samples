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
- ✅ 恢复购买功能
- ✅ 消耗品购买历史查询
- ✅ 订阅详细信息查询
- ✅ 交易历史查询
- ✅ 订阅管理链接
- ✅ 并发购买保护
- ✅ 自动处理退款和撤销

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

### 6. 恢复购买

```swift
// 恢复购买
Task {
    do {
        try await StoreKitManager.shared.restorePurchases()
        print("恢复购买成功")
    } catch {
        print("恢复购买失败: \(error)")
    }
}
```

### 7. 交易历史查询

```swift
// 获取所有交易历史
Task {
    let history = await StoreKitManager.shared.getTransactionHistory()
    for transaction in history {
        print("产品: \(transaction.productId), 日期: \(transaction.purchaseDate)")
    }
}

// 获取特定产品的交易历史
Task {
    let history = await StoreKitManager.shared.getTransactionHistory(for: "premium.lifetime")
}

// 获取消耗品的购买历史
Task {
    let consumableHistory = await StoreKitManager.shared.getConsumablePurchaseHistory(for: "consumable.coins")
}
```

### 8. 订阅详细信息

```swift
// 获取订阅详细信息
Task {
    if let subscriptionInfo = await StoreKitManager.shared.getSubscriptionInfo(for: "subscription.monthly") {
        print("续订日期: \(subscriptionInfo.renewalDate ?? Date())")
        print("是否在试用期: \(subscriptionInfo.isInTrialPeriod)")
        print("是否有效: \(subscriptionInfo.isValid)")
        print("是否已过期: \(subscriptionInfo.isExpired)")
    }
}
```

### 9. 订阅管理

```swift
// 打开订阅管理页面（系统设置）
StoreKitManager.shared.openSubscriptionManagement()

// 取消订阅（打开系统设置）
StoreKitManager.shared.cancelSubscription(for: "subscription.monthly")
```

### 10. 手动刷新

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
    case restoringPurchases             // 正在恢复购买
    case restorePurchasesSuccess        // 恢复购买成功
    case restorePurchasesFailed(Error)  // 恢复购买失败
    case purchaseRefunded(String)      // 购买已退款
    case purchaseRevoked(String)        // 购买已撤销
    case subscriptionCancelled(String)  // 订阅已取消
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
    case purchaseInProgress             // 购买正在进行中
    case cancelSubscriptionFailed(Error) // 取消订阅失败
    case restorePurchasesFailed(Error)   // 恢复购买失败
    case unknownError                   // 未知错误
}
```

## 数据模型

### SubscriptionInfo（订阅信息）

```swift
public struct SubscriptionInfo {
    let productId: String
    let product: Product
    let renewalState: RenewalState
    let renewalDate: Date?
    let isInTrialPeriod: Bool
    let isInIntroductoryPricePeriod: Bool
    let isCancelled: Bool
    let isExpired: Bool  // 计算属性
    let isValid: Bool    // 计算属性
    // ...
}
```

### TransactionHistory（交易历史）

```swift
public struct TransactionHistory {
    let productId: String
    let product: Product?
    let transaction: Transaction
    let purchaseDate: Date
    let expirationDate: Date?
    let isRefunded: Bool
    let isRevoked: Bool
    let ownershipType: Transaction.OwnershipType
    let transactionId: UInt64
}
```

## 架构说明

```text
StoreKitManager (对外接口)
    ↓
StoreKitService (内部服务)
    ↓
StoreKit API
```

- **StoreKitManager**: 提供统一的对外接口，管理配置和回调
- **StoreKitService**: 内部服务层，处理与 StoreKit API 的交互
- **Models**: 配置、状态、错误、订阅信息、交易历史等数据模型
- **Protocols**: 代理协议定义

## 高级功能

### 并发购买保护

库内置了并发购买保护机制，防止同时进行多个购买操作。如果尝试在购买进行中再次购买，会抛出 `StoreKitError.purchaseInProgress` 错误。

```swift
Task {
    do {
        try await StoreKitManager.shared.purchase(productId: "premium.lifetime")
    } catch StoreKitError.purchaseInProgress {
        print("已有购买正在进行，请等待完成")
    }
}
```

### 消耗品处理

消耗品购买后会立即完成交易，不会出现在 `currentEntitlements` 中。如果需要查询消耗品的购买历史，使用 `getConsumablePurchaseHistory` 方法。

```swift
// 购买消耗品
try await StoreKitManager.shared.purchase(productId: "consumable.coins")

// 查询消耗品购买历史
let history = await StoreKitManager.shared.getConsumablePurchaseHistory(for: "consumable.coins")
```

### 自动处理退款和撤销

库会自动监听交易状态变化，当发生退款或撤销时，会通过状态回调通知：

```swift
func storeKit(_ manager: StoreKitManager, didUpdateState state: StoreKitState) {
    switch state {
    case .purchaseRefunded(let productId):
        print("产品已退款: \(productId)")
        // 撤销用户权限
    case .purchaseRevoked(let productId):
        print("购买已撤销: \(productId)")
        // 撤销用户权限
    case .subscriptionCancelled(let productId):
        print("订阅已取消: \(productId)")
        // 处理订阅取消
    default:
        break
    }
}
```

## 注意事项

1. 确保在 App Store Connect 中配置了所有产品ID
2. 在真机上测试购买功能（模拟器不支持）
3. 使用沙盒测试账号进行测试
4. 所有回调都在主线程执行，可以直接更新UI
5. 服务会自动监听交易状态变化，无需手动刷新
6. 消耗品购买后会立即完成交易，不会保留在 entitlements 中
7. 恢复购买会同步所有已购买的产品，包括在其他设备上购买的
8. 订阅取消需要通过系统设置完成，应用内只能打开设置页面

## 生命周期管理

```swift
// 启动服务（在 configure 时自动启动）
StoreKitManager.shared.configure(with: config, delegate: self)

// 停止服务（释放资源）
StoreKitManager.shared.stop()
```

## 许可证

MIT License
