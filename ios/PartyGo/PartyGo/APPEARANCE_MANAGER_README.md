# 外观模式管理器使用指南

## 概述

`AppearanceManager` 是一个专门管理应用外观模式的服务类，支持动态切换主题、监听系统变化、本地存储用户偏好等功能。

## 核心功能

### 1. 外观模式类型
- **跟随系统** (`system`): 自动跟随系统设置
- **浅色模式** (`light`): 强制使用浅色主题
- **深色模式** (`dark`): 强制使用深色主题

### 2. 主要特性
- ✅ 监听系统外观模式变化
- ✅ 本地存储用户偏好设置
- ✅ 动态更新应用主题
- ✅ 支持SwiftUI环境注入
- ✅ 单例模式，全局统一管理

## 使用方法

### 1. 在App中集成

```swift
@main
struct PartyGoApp: App {
    @StateObject private var appearanceManager = AppearanceManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .preferredColorScheme(appearanceManager.effectiveColorScheme)
                .environment(\.appearanceManager, appearanceManager)
        }
    }
}
```

### 2. 在视图中使用

```swift
struct MyView: View {
    @Environment(\.appearanceManager) private var appearanceManager
    
    var body: some View {
        VStack {
            // 显示当前模式
            Text("当前模式: \(appearanceManager.currentAppearanceMode.displayName)")
            
            // 根据主题显示不同内容
            if appearanceManager.isDarkMode {
                Text("深色模式")
            } else {
                Text("浅色模式")
            }
            
            // 快速切换按钮
            AppearanceToggleButton()
        }
    }
}
```

### 3. 编程方式切换

```swift
// 设置特定模式
appearanceManager.setAppearanceMode(.dark)

// 循环切换模式
appearanceManager.toggleAppearanceMode()

// 检查当前状态
if appearanceManager.isSystemMode {
    print("当前跟随系统设置")
}
```

## 组件说明

### AppearanceManager
核心管理类，负责：
- 监听系统外观变化
- 管理本地存储
- 提供当前有效的外观模式

### AppearanceSettingsView
设置界面，提供：
- 三种模式的选择界面
- 用户友好的交互体验
- 实时预览效果

### AppearanceToggleButton
快速切换按钮，支持：
- 一键循环切换模式
- 显示当前模式图标
- 紧凑的UI设计

## 最佳实践

### 1. 颜色使用
```swift
// 推荐：使用系统颜色，自动适配主题
Text("Hello")
    .foregroundColor(.primary)  // 自动适配
    .background(Color(.systemBackground))  // 自动适配

// 避免：硬编码颜色
Text("Hello")
    .foregroundColor(.black)  // 不推荐
```

### 2. 条件渲染
```swift
// 根据主题显示不同内容
if appearanceManager.isDarkMode {
    // 深色模式特定内容
} else {
    // 浅色模式特定内容
}
```

### 3. 动态样式
```swift
// 根据主题应用不同样式
.background(appearanceManager.isDarkMode ? Color.black : Color.white)
```

## 技术实现

### 系统监听
使用 `AppleInterfaceThemeChangedNotification` 监听系统外观变化：

```swift
NotificationCenter.default.addObserver(
    forName: NSNotification.Name("AppleInterfaceThemeChangedNotification"),
    object: nil,
    queue: .main
) { [weak self] _ in
    self?.handleSystemAppearanceChange()
}
```

### 本地存储
使用 `UserDefaults` 持久化用户偏好：

```swift
// 保存
userDefaults.set(mode.rawValue, forKey: appearanceModeKey)

// 读取
if let savedModeString = userDefaults.string(forKey: appearanceModeKey),
   let savedMode = AppearanceMode(rawValue: savedModeString) {
    currentAppearanceMode = savedMode
}
```

### SwiftUI集成
通过环境值注入，实现全局访问：

```swift
struct AppearanceModeKey: EnvironmentKey {
    static let defaultValue: AppearanceManager = AppearanceManager.shared
}

extension EnvironmentValues {
    var appearanceManager: AppearanceManager {
        get { self[AppearanceModeKey.self] }
        set { self[AppearanceModeKey.self] = newValue }
    }
}
```

## 扩展功能

### 自定义主题
可以扩展 `AppearanceMode` 枚举添加更多主题：

```swift
enum AppearanceMode: String, CaseIterable, Codable {
    case system = "system"
    case light = "light"
    case dark = "dark"
    case custom = "custom"  // 新增自定义主题
}
```

### 主题配置
可以为不同主题定义配置：

```swift
struct ThemeConfig {
    let primaryColor: Color
    let backgroundColor: Color
    let textColor: Color
}

extension AppearanceMode {
    var config: ThemeConfig {
        switch self {
        case .light:
            return ThemeConfig(primaryColor: .blue, backgroundColor: .white, textColor: .black)
        case .dark:
            return ThemeConfig(primaryColor: .cyan, backgroundColor: .black, textColor: .white)
        case .system:
            return getSystemAppearanceMode().config
        }
    }
}
```

## 注意事项

1. **性能考虑**: 外观变化会触发整个视图树的重绘，避免在频繁变化的视图中过度使用
2. **动画效果**: 主题切换时考虑添加适当的动画效果
3. **测试**: 确保在不同主题下UI元素都有良好的可读性和对比度
4. **无障碍**: 考虑色盲用户的体验，不要仅依赖颜色传达信息

## 故障排除

### 常见问题

1. **主题不生效**
   - 检查是否正确注入了环境值
   - 确认 `preferredColorScheme` 设置正确

2. **系统变化不响应**
   - 检查通知监听器是否正确设置
   - 确认在主线程处理UI更新

3. **本地存储不工作**
   - 检查 `UserDefaults` 的键名是否正确
   - 确认枚举的 `rawValue` 设置正确
