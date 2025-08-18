# PartyGo 颜色系统使用指南

## 📁 新的文件结构

```
PartyGo/
├── Config/
│   ├── AppConstants.swift          # 应用基础常量
│   ├── AppTheme.swift              # 主题配置（UI常量 + 颜色引用）
│   └── AppColors.swift             # 颜色管理器（核心）
├── Extensions/
│   ├── View+Extensions.swift       # 视图基础扩展
│   ├── View+ColorModifiers.swift   # 颜色样式修饰符
│   └── Environment+AppColors.swift # 环境值扩展
├── Assets.xcassets/Colors/
│   ├── PrimaryColor.colorset       # 主色调
│   ├── SecondaryColor.colorset     # 次要色调
│   ├── BackgroundColor.colorset    # 背景色
│   ├── TextColor.colorset          # 文本色
│   ├── SuccessColor.colorset       # 成功色
│   ├── ErrorColor.colorset         # 错误色
│   ├── WarningColor.colorset       # 警告色
│   └── ...                         # 其他颜色集
└── Views/
    ├── ContentView.swift           # 主界面
    └── ColorUsageExample.swift     # 使用示例
```

## 🎨 新的颜色系统设计

### 设计优势
- **避免冲突** - 使用自定义类而不是扩展Color
- **自动响应** - 自动监听系统外观模式变化
- **类型安全** - 编译时检查，避免运行时错误
- **易于维护** - 集中管理，易于修改和扩展

### 核心组件
1. **AppColors类** - 颜色管理器，自动响应外观模式
2. **AppTheme枚举** - 主题配置，提供颜色引用
3. **环境值扩展** - 在视图中便捷访问颜色

## 🚀 使用方法

### 1. 直接使用AppColors

```swift
// 在视图中使用
struct MyView: View {
    @StateObject private var appColors = AppColors.shared
    
    var body: some View {
        Text("标题")
            .foregroundColor(appColors.text)
        
        Rectangle()
            .fill(appColors.background)
    }
}
```

### 2. 使用AppTheme（推荐）

```swift
// 使用主题配置
Text("标题")
    .foregroundColor(AppTheme.Colors.text)

Rectangle()
    .fill(AppTheme.Colors.background)

Button("确认") { }
    .background(AppTheme.Colors.primary)
```

### 3. 使用环境值

```swift
// 通过环境值访问
struct MyView: View {
    var body: some View {
        Text("标题")
            .foregroundColor(colors.text)
        
        Rectangle()
            .fill(colors.background)
    }
}
```

### 4. 使用视图修饰符

```swift
// 文本颜色修饰符
Text("主要文本").primaryTextColor()
Text("次要文本").secondaryTextColor()
Text("占位符").placeholderTextColor()

// 背景修饰符
VStack { }
    .primaryBackground()
    .cardBackground()

// 按钮样式修饰符
Button("确认") { }.primaryButtonStyle()
Button("取消") { }.secondaryButtonStyle()
Button("成功") { }.successButtonStyle()
Button("错误") { }.errorButtonStyle()

// 卡片样式
VStack { }.cardStyle()
```

## 🔄 自动外观模式适配

### 工作原理
1. **监听系统变化** - AppColors自动监听`colorSchemeDidChange`通知
2. **实时更新** - 当系统外观模式改变时，自动更新颜色状态
3. **UI响应** - 所有使用这些颜色的UI会自动重新渲染

### 示例
```swift
// 在视图中显示当前外观模式
struct AppearanceIndicator: View {
    @StateObject private var appColors = AppColors.shared
    
    var body: some View {
        HStack {
            Image(systemName: appColors.isDarkMode ? "moon.fill" : "sun.max.fill")
            Text(appColors.isDarkMode ? "深色模式" : "浅色模式")
        }
    }
}
```

## 🎯 最佳实践

### 1. 颜色选择
- 优先使用`AppTheme.Colors`中的颜色引用
- 避免直接使用`AppColors.shared`
- 使用语义化的颜色名称

### 2. 外观模式适配
- 所有颜色都支持深色/浅色模式
- 在Assets.xcassets中配置两种模式的颜色
- 系统自动切换，无需手动处理

### 3. 性能优化
- AppColors是单例模式，避免重复创建
- 使用环境值注入，减少状态传递
- 颜色变化时只更新必要的UI

### 4. 扩展性
- 在AppColors中添加新的颜色属性
- 在AppTheme.Colors中添加对应的引用
- 创建相应的视图修饰符（如需要）

## 🔧 自定义颜色

### 添加新颜色
1. 在`Assets.xcassets/Colors/`中创建新的颜色集
2. 在`AppColors.swift`中添加颜色属性
3. 在`AppTheme.Colors`中添加颜色引用
4. 创建相应的视图修饰符（如需要）

### 修改现有颜色
1. 在`Assets.xcassets/Colors/`中修改颜色值
2. 确保深色/浅色模式都有对应的颜色
3. 测试在不同设备上的显示效果

## 📱 示例代码

查看`ColorUsageExample.swift`文件获取完整的使用示例。

## ✅ 检查清单

- [ ] 所有颜色都支持深色/浅色模式
- [ ] 颜色对比度符合可访问性标准
- [ ] 使用语义化颜色名称
- [ ] 避免硬编码颜色值
- [ ] 测试外观模式切换
- [ ] 测试在不同设备上的显示效果
- [ ] 文档完整且易于理解

## 🎨 颜色值参考

### 品牌颜色
- 主色: #FF6B6B (PartyGo红)
- 次色: #66CC99 (辅助色)
- 强调色: #00CC99 (绿色)

### 功能颜色
- 成功: #33CC66 (绿色)
- 警告: #FF9900 (橙色)
- 错误: #E64A4A (红色)
- 信息: #3399CC (蓝色)

### 文本颜色
- 主要文本: #333333 / #FFFFFF
- 次要文本: #666666 / #CCCCCC
- 占位符: #999999 / #888888
