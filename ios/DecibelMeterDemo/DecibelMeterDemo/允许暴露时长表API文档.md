# 允许暴露时长表 API 文档

## 📋 概述

允许暴露时长表（Permissible Exposure Duration Table）是噪音测量计的核心功能之一，用于展示不同声级下的允许暴露时间、实际累计暴露时间和剂量贡献。

该功能符合 **NIOSH**、**OSHA**、**GBZ**、**EU** 等国际标准的噪声暴露评估要求。

---

## 🎯 核心概念

### 1. 声级分段

根据标准的**基准限值**和**交换率**，将噪声声级分为多个区间：

- **NIOSH/GBZ**: 85, 88, 91, 94, 97, 100, 103, 106, 109, 112, 115 dB（共11级，3dB交换率）
- **OSHA**: 90, 95, 100, 105, 110, 115 dB（共6级，5dB交换率）
- **EU**: 87, 90, 93, 96, 99, ... 115 dB（10级，3dB交换率）

### 2. 允许暴露时长计算

每个声级的允许暴露时长根据以下公式计算：

```
T = 8小时 × 2^((基准限值 - 声级) / 交换率)
```

**示例（NIOSH标准）**：
- 85 dB: 8小时 × 2^((85-85)/3) = 8小时
- 88 dB: 8小时 × 2^((85-88)/3) = 4小时
- 91 dB: 8小时 × 2^((85-91)/3) = 2小时
- 94 dB: 8小时 × 2^((85-94)/3) = 1小时

### 3. 累计暴露时长统计

系统会统计实际测量中在每个声级范围内的累计暴露时间：

- 遍历所有测量历史数据
- 根据声级值分配到对应的声级区间
- 累加每个区间的暴露时间（秒）

### 4. 声级剂量计算

每个声级的剂量贡献按以下公式计算：

```
声级剂量 = (累计暴露时长 / 允许暴露时长) × 100%
```

**总剂量** = Σ 所有声级的剂量贡献

---

## 📦 数据模型

### PermissibleExposureDuration

表示单个声级的暴露时长信息。

```swift
struct PermissibleExposureDuration: Codable, Identifiable {
    let id: UUID                        // 唯一标识符
    let soundLevel: Double              // 声级（dB）
    let allowedDuration: TimeInterval   // 允许暴露时长（秒）
    let accumulatedDuration: TimeInterval // 累计暴露时长（秒）
    let isCeilingLimit: Bool            // 是否为天花板限值
    
    // 计算属性
    var currentLevelDose: Double        // 当前声级剂量（%）
    var isExceeding: Bool               // 是否超标
    var remainingDuration: TimeInterval // 剩余允许时长（秒）
    
    // 格式化显示
    var formattedAllowedDuration: String      // 格式化的允许时长
    var formattedAccumulatedDuration: String  // 格式化的累计时长
    var formattedRemainingDuration: String    // 格式化的剩余时长
}
```

### PermissibleExposureDurationTable

包含所有声级的暴露时长信息列表。

```swift
struct PermissibleExposureDurationTable: Codable {
    let standard: NoiseStandard         // 使用的标准
    let criterionLevel: Double          // 基准限值（dB）
    let exchangeRate: Double            // 交换率（dB）
    let ceilingLimit: Double            // 天花板限值（dB）
    let durations: [PermissibleExposureDuration] // 所有声级列表
    
    // 计算属性
    var totalDose: Double               // 总剂量（%）
    var exceedingLevelsCount: Int       // 超标声级数量
    var exposedLevelsCount: Int         // 有暴露记录的声级数量
    
    // 方法
    func toJSON() -> String?            // 转换为JSON
    static func fromJSON(_ jsonString: String) -> PermissibleExposureDurationTable?
}
```

---

## 🔧 API 方法

### getPermissibleExposureDurationTable()

获取允许暴露时长表。

```swift
func getPermissibleExposureDurationTable(
    standard: NoiseStandard? = nil
) -> PermissibleExposureDurationTable
```

#### 参数

- `standard`: 噪声限值标准（可选）
  - 默认使用当前设置的标准
  - 可选值：`.niosh`, `.osha`, `.gbz`, `.eu`

#### 返回值

返回 `PermissibleExposureDurationTable` 对象，包含：
- 所有声级的允许暴露时长
- 实际累计暴露时间
- 每个声级的剂量贡献
- 总剂量百分比

#### 使用示例

```swift
let manager = DecibelMeterManager.shared

// 获取NIOSH标准的暴露时长表
let table = manager.getPermissibleExposureDurationTable(standard: .niosh)

// 打印总体信息
print("总剂量: \(table.totalDose)%")
print("超标声级数: \(table.exceedingLevelsCount)")

// 遍历所有声级
for duration in table.durations {
    print("\(duration.soundLevel) dB:")
    print("  允许时长: \(duration.formattedAllowedDuration)")
    print("  累计时长: \(duration.formattedAccumulatedDuration)")
    print("  剂量贡献: \(String(format: "%.1f", duration.currentLevelDose))%")
    print("  是否超标: \(duration.isExceeding ? "是" : "否")")
}
```

---

## 📊 使用场景

### 1. 实时监控

定期检查暴露情况，及时发现超标声级：

```swift
Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
    let table = manager.getPermissibleExposureDurationTable(standard: .niosh)
    
    if table.totalDose >= 100.0 {
        print("⚠️ 警告：总剂量已超标！")
    }
    
    let exceedingLevels = table.durations.filter { $0.isExceeding }
    if !exceedingLevels.isEmpty {
        print("超标声级: \(exceedingLevels.map { "\($0.soundLevel) dB" }.joined(separator: ", "))")
    }
}
```

### 2. 标准对比

比较不同标准下的暴露情况：

```swift
for standard in NoiseStandard.allCases {
    let table = manager.getPermissibleExposureDurationTable(standard: standard)
    print("\(standard.rawValue): 总剂量 \(table.totalDose)%")
}
```

### 3. 报告生成

生成详细的暴露评估报告：

```swift
let table = manager.getPermissibleExposureDurationTable(standard: .niosh)

print("=== 噪声暴露报告 ===")
print("标准: \(table.standard.fullName)")
print("总剂量: \(String(format: "%.1f", table.totalDose))%")
print()

let exposedLevels = table.durations.filter { $0.accumulatedDuration > 0 }
for level in exposedLevels {
    print("\(level.soundLevel) dB: \(level.formattedAccumulatedDuration) / \(level.formattedAllowedDuration)")
}
```

### 4. JSON 导出

导出数据用于存储或分享：

```swift
let table = manager.getPermissibleExposureDurationTable(standard: .niosh)

if let json = table.toJSON() {
    // 保存到文件
    let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        .appendingPathComponent("exposure_table.json")
    try? json.write(to: fileURL, atomically: true, encoding: .utf8)
}
```

---

## 🎨 UI 集成示例

### SwiftUI 列表视图

```swift
struct ExposureTableView: View {
    let table: PermissibleExposureDurationTable
    
    var body: some View {
        List {
            Section(header: Text("总体情况")) {
                HStack {
                    Text("总剂量")
                    Spacer()
                    Text(String(format: "%.1f%%", table.totalDose))
                        .foregroundColor(doseColor(table.totalDose))
                        .bold()
                }
            }
            
            Section(header: Text("声级详情")) {
                ForEach(table.durations.filter { $0.accumulatedDuration > 0 }) { duration in
                    VStack(alignment: .leading) {
                        Text("\(String(format: "%.0f", duration.soundLevel)) dB")
                            .font(.headline)
                        
                        HStack {
                            Text("累计: \(duration.formattedAccumulatedDuration)")
                            Spacer()
                            Text("允许: \(duration.formattedAllowedDuration)")
                        }
                        .font(.caption)
                        
                        ProgressView(value: duration.currentLevelDose, total: 100.0)
                    }
                }
            }
        }
    }
    
    private func doseColor(_ dose: Double) -> Color {
        dose >= 100 ? .red : dose >= 80 ? .orange : dose >= 50 ? .yellow : .green
    }
}
```

---

## ⚠️ 注意事项

### 1. 数据准确性

- 累计时长基于测量历史数据统计
- 每个测量点假设代表1秒的暴露时间
- 确保测量采样率稳定（通常为1Hz）

### 2. 声级分段

- 声级分段基于标准的交换率
- 每个声级代表一个范围：[soundLevel, soundLevel + exchangeRate)
- 最后一个声级（天花板限值）包含所有更高的声级

### 3. 剂量计算

- 总剂量是所有声级剂量的**累加**，不是平均
- 总剂量可能超过100%（表示超标）
- 单个声级的剂量也可能超过100%

### 4. 性能考虑

- 遍历所有测量历史数据可能耗时
- 建议在后台线程调用
- 对于长时间测量，考虑缓存结果

---

## 📚 相关标准

- **NIOSH**: Criteria for a Recommended Standard: Occupational Noise Exposure
- **OSHA**: 29 CFR 1910.95 - Occupational Noise Exposure
- **GBZ**: GBZ 2.2-2007 - 工作场所有害因素职业接触限值
- **EU**: Directive 2003/10/EC - Physical Agents (Noise)

---

## 🔗 相关 API

- `getNoiseDoseData()` - 获取噪声剂量数据
- `getDoseAccumulationChartData()` - 获取剂量累积图数据
- `getTWATrendChartData()` - 获取TWA趋势图数据
- `generateNoiseDosimeterReport()` - 生成综合报告

---

## 📝 更新日志

### v1.0.0 (2025-01-23)
- ✅ 初始版本
- ✅ 支持 NIOSH、OSHA、GBZ、EU 四种标准
- ✅ 实现声级分段统计
- ✅ 实现剂量计算
- ✅ 支持 JSON 导出
- ✅ 提供详细的使用示例

