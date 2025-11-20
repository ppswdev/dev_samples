# 苹果应用内购实现逻辑API文档

## 概述

`PurchaseHelper` 是一个基于 StoreKit 2 的应用内购买封装类，封装了所有的操作和回调事件。这是一个通用的、可随意迁移的工具类，可以直接复制粘贴到任意项目，只需修改配置文件中的产品ID即可使用。

## 设计目标

- ✅ 通用性强：可直接复制到任意项目使用
- ✅ 易于迁移：只需修改产品ID配置
- ✅ 完整封装：包含所有操作和回调事件
- ✅ 支持 SwiftUI 和 UIKit
- ✅ 单例模式：全局唯一实例
- ✅ 事件驱动：所有操作都有事件回调

---

## 必须属性

### 1. `lastPurchaseTime: Int64`
- **类型**: `@Published private(set) var`
- **单位**: 毫秒
- **说明**: 最后一次订阅的时间戳

### 2. `expirationTime: Int64`
- **类型**: `@Published private(set) var`
- **单位**: 毫秒
- **说明**: 订阅的过期时间戳。如果是终身购买，此值为 0

### 3. `isPurchaseAvailable: Bool`
- **类型**: `@Published private(set) var`
- **说明**: 购买是否可用（是否已购买且在有效期内）

### 4. `isLoggingEnabled: Bool`
- **类型**: `var`（可读写）
- **默认值**: `true`
- **说明**: 是否显示打印日志。设置为 `false` 可关闭日志输出

---

## 公开方法

### 1. 初始化配置方法

```swift
func configure(productIDs: Set<String>)
```

**功能**: 在应用启动时，将内购产品ID和产品信息进行初始化配置，获取其他初始化数据。

**参数**:
- `productIDs`: 产品ID集合

**使用示例**:
```swift
PurchaseHelper.shared.configure(productIDs: ["premium_monthly", "premium_yearly"])
```

**注意**: 
- 必须在应用启动时调用
- 可以多次调用以更新产品ID列表
- 配置后会自动加载产品信息

---

### 2. 获取加载产品列表信息

```swift
func loadProducts() async throws
```

**功能**: 获取初始化的产品IDs的具体产品对象信息。

**返回**: 无（异步方法）

**使用示例**:
```swift
Task {
    do {
        try await PurchaseHelper.shared.loadProducts()
        print("产品加载成功")
    } catch {
        print("产品加载失败: \(error)")
    }
}
```

**说明**:
- 加载产品信息后会自动更新购买状态
- 会自动加载历史购买记录

---

### 3. 获取加载所有历史购买产品列表信息

```swift
func loadPurchaseHistory() async
```

**功能**: 加载所有历史购买记录（已验证的交易）。

**返回**: 无（异步方法）

**使用示例**:
```swift
Task {
    await PurchaseHelper.shared.loadPurchaseHistory()
    // 通过 purchaseHistory 属性访问历史记录
    let history = PurchaseHelper.shared.purchaseHistory
}
```

**说明**:
- 历史记录按时间倒序排列
- 只包含已验证的交易

---

### 4. 判断是否有购买过指定产品

```swift
func isPurchased(productID: String) -> Bool
```

**功能**: 判断指定产品是否已购买且在有效期内。

**参数**:
- `productID`: 产品ID

**返回**: `Bool` - 是否已购买

**使用示例**:
```swift
if PurchaseHelper.shared.isPurchased(productID: "premium_monthly") {
    print("已购买月度会员")
}
```

---

### 5. 判断是否有购买了任意产品

```swift
func hasAnyPurchase() -> Bool
```

**功能**: 判断是否购买了任意产品。

**返回**: `Bool` - 是否购买了任意产品

**使用示例**:
```swift
if PurchaseHelper.shared.hasAnyPurchase() {
    print("用户已购买产品")
}
```

---

### 6. 获取指定产品ID的产品信息

```swift
func getProduct(productID: String) -> Product?
```

**功能**: 获取指定产品ID的 Product 对象。

**参数**:
- `productID`: 产品ID

**返回**: `Product?` - Product对象，如果不存在返回 `nil`

**使用示例**:
```swift
if let product = PurchaseHelper.shared.getProduct(productID: "premium_monthly") {
    print("产品标题: \(product.displayName)")
    print("产品价格: \(product.displayPrice)")
}
```

---

### 7. 获取产品标题

```swift
func getProductTitle(productID: String) -> String?
```

**功能**: 获取产品的显示标题。

**参数**:
- `productID`: 产品ID

**返回**: `String?` - 产品标题，如果不存在返回 `nil`

**使用示例**:
```swift
if let title = PurchaseHelper.shared.getProductTitle(productID: "premium_monthly") {
    print("产品标题: \(title)")
}
```

---

### 8. 获取产品的副标题

```swift
func getProductSubtitle(productID: String) -> String?
```

**功能**: 获取产品的副标题（描述信息）。

**参数**:
- `productID`: 产品ID

**返回**: `String?` - 产品副标题，如果不存在返回 `nil`

**使用示例**:
```swift
if let subtitle = PurchaseHelper.shared.getProductSubtitle(productID: "premium_monthly") {
    print("产品描述: \(subtitle)")
}
```

---

### 9. 购买或订阅产品

```swift
func purchase(productID: String) async throws
```

**功能**: 购买或订阅指定的产品。

**参数**:
- `productID`: 产品ID

**返回**: 无（异步方法，可能抛出错误）

**使用示例**:
```swift
Task {
    do {
        try await PurchaseHelper.shared.purchase(productID: "premium_monthly")
        print("购买成功")
    } catch {
        if let purchaseError = error as? PurchaseError {
            switch purchaseError {
            case .userCancelled:
                print("用户取消购买")
            case .pending:
                print("购买待处理")
            default:
                print("购买失败: \(purchaseError.localizedDescription)")
            }
        }
    }
}
```

**说明**:
- 购买成功后会自动更新购买状态和历史记录
- 会自动更新订阅时间信息

---

### 10. 恢复购买

```swift
func restorePurchases() async throws
```

**功能**: 恢复用户之前的购买记录。

**返回**: 无（异步方法，可能抛出错误）

**使用示例**:
```swift
Task {
    do {
        try await PurchaseHelper.shared.restorePurchases()
        print("恢复购买成功")
    } catch {
        print("恢复购买失败: \(error.localizedDescription)")
    }
}
```

**说明**:
- 恢复成功后会同步更新购买状态和历史记录

---

## 私有方法

### 1. 日志打印（可打印代码行）

```swift
private func log(_ message: String, file: String = #file, line: Int = #line)
```

**功能**: 内部日志打印方法，支持打印文件名和行号。

**参数**:
- `message`: 日志消息
- `file`: 文件路径（默认使用 `#file`）
- `line`: 行号（默认使用 `#line`）

**说明**:
- 只有当 `isLoggingEnabled` 为 `true` 时才会打印
- 日志格式: `[时间戳] [文件名:行号] 消息`

---

### 2. 验证凭据

```swift
private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T
```

**功能**: 验证交易凭据，确保交易的真实性。

**参数**:
- `result`: StoreKit 的交易验证结果

**返回**: 已验证的交易对象

**抛出**: 验证失败时抛出 `PurchaseError.verificationFailed`

---

## 订阅购买的所有相关事件

所有购买相关的事件都封装在 `PurchaseEvent` 枚举中，通过 `onEvent` 回调统一通知 UI 层。

### PurchaseEvent 事件类型

#### 配置事件
- `configured(productIDs: Set<String>)` - 产品ID配置完成

#### 产品加载事件
- `productsLoadStarted` - 开始加载产品信息
- `productsLoadSuccess(productCount: Int)` - 产品加载成功
- `productsLoadFailed(error: Error)` - 产品加载失败

#### 购买事件
- `purchaseStarted(productID: String)` - 开始购买
- `purchaseSuccess(productID: String, transactionID: UInt64?)` - 购买成功
- `purchaseFailed(productID: String, error: Error)` - 购买失败
- `purchaseCancelled(productID: String)` - 用户取消购买
- `purchasePending(productID: String)` - 购买待处理

#### 恢复购买事件
- `restoreStarted` - 开始恢复购买
- `restoreSuccess` - 恢复购买成功
- `restoreFailed(error: Error)` - 恢复购买失败

#### 状态更新事件
- `purchaseStatusUpdated(productID: String, isPurchased: Bool)` - 购买状态更新
- `purchaseStatusRefreshed([String: Bool])` - 购买状态刷新

#### 交易监听事件
- `transactionReceived(productID: String, transactionID: UInt64)` - 收到交易
- `transactionVerified(productID: String, transactionID: UInt64)` - 交易验证成功
- `transactionVerificationFailed(productID: String, error: Error)` - 交易验证失败

#### 产品信息事件
- `productInfoRequested(productID: String)` - 请求产品信息
- `productInfoRetrieved(productID: String, product: Product)` - 获取产品信息

### onEvent 回调

```swift
var onEvent: ((PurchaseEvent) -> Void)?
```

**功能**: 统一事件回调，所有购买操作相关的事件都会通过此回调通知 UI 层。

**说明**:
- 回调会在主线程执行
- 可以通过 `event.description` 获取事件描述
- 可以通过 `switch` 语句处理不同的事件类型

**使用示例**:

```swift
// SwiftUI
PurchaseHelper.shared.onEvent = { event in
    print("收到事件: \(event.description)")
    
    switch event {
    case .purchaseSuccess(let productID, _):
        print("购买成功: \(productID)")
    case .purchaseFailed(let productID, let error):
        print("购买失败: \(productID), 错误: \(error)")
    default:
        break
    }
}

// UIKit
PurchaseHelper.shared.onEvent = { [weak self] event in
    DispatchQueue.main.async {
        // 处理事件
        self?.handlePurchaseEvent(event)
    }
}
```

---

## 所有购买的错误

所有购买过程中的各种错误都汇总在 `PurchaseError` 枚举中，在 `onEvent` 中会通过相应的事件回调回去。

### PurchaseError 错误类型

- `notConfigured` - PurchaseHelper 未配置
- `productNotFound` - 产品未找到
- `userCancelled` - 用户取消购买
- `pending` - 购买待处理
- `verificationFailed` - 交易验证失败
- `unknown` - 未知错误

### 错误处理示例

```swift
do {
    try await PurchaseHelper.shared.purchase(productID: "premium_monthly")
} catch let error as PurchaseError {
    switch error {
    case .notConfigured:
        print("未配置，请先调用 configure 方法")
    case .productNotFound:
        print("产品未找到")
    case .userCancelled:
        print("用户取消购买")
    case .pending:
        print("购买待处理")
    case .verificationFailed:
        print("交易验证失败")
    case .unknown:
        print("未知错误")
    }
}
```

---

## 使用流程

### 1. 应用启动时配置

```swift
// 在 AppDelegate 或 SceneDelegate 中
func application(_ application: UIApplication, 
                 didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    
    // 配置产品ID
    PurchaseHelper.shared.configure(productIDs: ["premium_monthly", "premium_yearly"])
    
    return true
}
```

### 2. 加载产品信息

```swift
Task {
    try? await PurchaseHelper.shared.loadProducts()
}
```

### 3. 监听事件（可选）

```swift
PurchaseHelper.shared.onEvent = { event in
    print("事件: \(event.description)")
}
```

### 4. 购买产品

```swift
Task {
    do {
        try await PurchaseHelper.shared.purchase(productID: "premium_monthly")
    } catch {
        print("购买失败: \(error)")
    }
}
```

### 5. 检查购买状态

```swift
if PurchaseHelper.shared.isPurchased(productID: "premium_monthly") {
    // 已购买，解锁功能
}
```

---

## SwiftUI 使用示例

```swift
struct ContentView: View {
    @ObservedObject private var purchaseHelper = PurchaseHelper.shared
    
    var body: some View {
        VStack {
            if purchaseHelper.isPurchased(productID: "premium_monthly") {
                Text("已购买 Premium")
            }
            
            Button("购买") {
                Task {
                    try? await purchaseHelper.purchase(productID: "premium_monthly")
                }
            }
        }
        .onAppear {
            Task {
                try? await purchaseHelper.loadProducts()
            }
        }
    }
}
```

---

## UIKit 使用示例

```swift
class ViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // 设置回调
        PurchaseHelper.shared.onEvent = { [weak self] event in
            DispatchQueue.main.async {
                self?.handlePurchaseEvent(event)
            }
        }
    }
    
    @IBAction func purchaseButtonTapped(_ sender: UIButton) {
        Task {
            do {
                try await PurchaseHelper.shared.purchase(productID: "premium_monthly")
            } catch {
                print("购买失败: \(error)")
            }
        }
    }
}
```

---

## 注意事项

1. **产品ID配置**: 产品ID必须与 App Store Connect 中配置的产品ID完全一致
2. **配置时机**: `configure` 方法必须在应用启动时调用
3. **线程安全**: 所有操作都在主线程执行（使用 `@MainActor`）
4. **日志控制**: 可以通过 `isLoggingEnabled` 控制日志输出
5. **事件回调**: 所有事件都会通过 `onEvent` 回调，建议在应用启动时设置
6. **订阅过期**: 订阅过期后 `isPurchaseAvailable` 会自动变为 `false`
7. **历史记录**: 历史购买记录按时间倒序排列

---

## 迁移指南

1. 复制 `PurchaseHelper.swift` 到新项目
2. 修改 `PurchaseConfig.swift` 中的产品ID配置
3. 在应用启动时调用 `configure` 方法
4. 在需要的地方使用 `PurchaseHelper.shared` 访问功能

---

## 版本要求

- iOS 15.0+
- macOS 12.0+
- StoreKit 2.0+

---

## 技术支持

如有问题，请查看：
- StoreKit 2 官方文档
- App Store Connect 配置指南
- 示例代码：`UIKitSampleViewController.swift` 和 `SwiftUISampleView.swift`
