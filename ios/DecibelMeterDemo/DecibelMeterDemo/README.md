# 分贝测量仪 iOS 应用

## 项目简介

这是一个使用 Swift + SwiftUI 开发的分贝测量仪示例项目，实现了专业级的分贝测量功能。

## 功能特性

### 核心功能

- ✅ 实时分贝测量
- ✅ 多种权重计算（A权重、线性）
- ✅ 时间权重滤波（快、慢）
- ✅ 校准功能
- ✅ 历史数据记录
- ✅ 统计分析

### 技术特性

- ✅ 基于 AVAudioEngine 的音频采集
- ✅ 专业分贝计算算法
- ✅ 实时频谱分析
- ✅ 数据持久化
- ✅ 现代化 SwiftUI 界面

## 项目结构

```
DecibelMeterDemo/
├── DecibelMeterManager.swift      # 核心分贝测量管理器：采集，转换，图标数据等
├── DecibelDataModels.swift        # 数据模型定义
├── ContentView.swift              # 主界面
├── DecibelMeterViewModel.swift    # 核心分贝测量数据状态管理
├── DecibelMeterDemoApp.swift      # 应用入口
└── Info.plist                     # 权限配置
```

## 核心组件

### DecibelMeterManager

- 封装所有分贝测量逻辑
- 音频采集和处理
- 分贝计算和权重应用
- 实时数据更新

### 数据模型

- `DecibelMeasurement`: 单次测量结果
- `MeasurementSession`: 测量会话
- `StatisticalAnalysis`: 统计分析
- `CalibrationConfig`: 校准配置

## 使用方法

1. 启动应用
2. 点击"开始测量"按钮
3. 允许麦克风权限
4. 查看实时分贝值
5. 使用暂停/恢复功能
6. 查看历史记录和统计

## 技术实现

### 分贝计算

```swift
// 声压级计算
Lp = 20 × log₁₀(p/p₀) dB

// A权重计算
A(f) = 1.2588966 × 12200² × f⁴ / 
       [(f² + 20.6²) × √((f² + 107.7²)(f² + 737.9²)) × (f² + 12200²)]
```

### 时间权重

- Fast: 125ms 时间常数
- Slow: 1s 时间常数
- 指数平滑滤波

## 权限要求

- 麦克风访问权限（NSMicrophoneUsageDescription）

## 系统要求

- iOS 15.0+
- Xcode 14.0+
- Swift 5.7+

## 开发状态

- [x] 基础架构
- [x] 音频采集
- [x] 分贝计算
- [x] 用户界面
- [x] 权限管理
- [ ] 数据持久化
- [ ] 高级分析
- [ ] 导出功能
- [ ] 设置界面

## 注意事项

1. 首次使用需要授权麦克风权限
2. 测量精度受设备麦克风质量影响
3. 建议在安静环境中进行校准
4. 长期使用建议定期校准

## 技术文档

详细的技术理论请参考：

- `声学与分贝测量专业技术理论.md`

## 许可证

MIT License
