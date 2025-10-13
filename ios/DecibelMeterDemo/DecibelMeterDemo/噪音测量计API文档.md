# 噪音测量计 API 文档

## 📋 **目录**

1. [功能概述](#功能概述)
2. [核心计算方法](#核心计算方法)
3. [数据获取方法](#数据获取方法)
4. [图表数据方法](#图表数据方法)
5. [设置和查询方法](#设置和查询方法)
6. [数据模型](#数据模型)
7. [使用示例](#使用示例)

---

## 🎯 **功能概述**

### **新增的噪音测量计功能**

| 功能类别 | 功能数量 | 说明 |
|---------|---------|------|
| **核心计算** | 5个方法 | TWA、Dose、剂量率、预测时间 |
| **数据获取** | 4个方法 | 剂量数据、限值比较、报告生成 |
| **图表数据** | 2个方法 | 剂量累积图、TWA趋势图 |
| **设置查询** | 3个方法 | 设置标准、获取标准 |
| **数据模型** | 9个模型 | 支持JSON转换 |

### **符合的标准**

- ✅ OSHA 29 CFR 1910.95
- ✅ NIOSH REL
- ✅ GBZ 2.2-2007
- ✅ EU Directive 2003/10/EC

---

## 🧮 **核心计算方法**

### **1. 计算TWA（时间加权平均值）**

```swift
func calculateTWA(leq: Double, duration: TimeInterval, standardWorkDay: Double = 8.0) -> Double
```

**参数**：

- `leq`: 等效连续声级（dB）
- `duration`: 实际测量时长（秒）
- `standardWorkDay`: 标准工作日时长（小时），默认8小时

**返回值**：TWA值（dB）

**计算公式**：

```
TWA = 10 × log₁₀((T/8) × 10^(LEQ/10))
```

**使用示例**：

```swift
let twa = manager.calculateTWA(leq: 90.0, duration: 14400) // 4小时
print("TWA: \(twa) dB") // 约87 dB
```

---

### **2. 计算噪声剂量（Dose）**

```swift
func calculateNoiseDose(twa: Double, standard: NoiseStandard) -> Double
```

**参数**：

- `twa`: 时间加权平均值（dB）
- `standard`: 噪声限值标准（OSHA、NIOSH、GBZ、EU）

**返回值**：噪声剂量百分比（%）

**计算公式**：

```
Dose = 100 × 2^((TWA - CriterionLevel) / ExchangeRate)
```

**不同标准的参数**：

| 标准 | 参考声级 | 交换率 | TWA限值 |
|------|---------|--------|---------|
| OSHA | 85 dB | 5 dB | 90 dB |
| NIOSH | 85 dB | 3 dB | 85 dB |
| GBZ | 85 dB | 3 dB | 85 dB |
| EU | 85 dB | 3 dB | 87 dB |

**使用示例**：

```swift
let dose = manager.calculateNoiseDose(twa: 90.0, standard: .osha)
print("剂量: \(dose)%") // 200%（OSHA标准）

let dose2 = manager.calculateNoiseDose(twa: 90.0, standard: .niosh)
print("剂量: \(dose2)%") // 约1000%（NIOSH标准，更严格）
```

---

### **3. 计算剂量率**

```swift
func calculateDoseRate(currentDose: Double, duration: TimeInterval) -> Double
```

**参数**：

- `currentDose`: 当前累积剂量（%）
- `duration`: 已暴露时长（秒）

**返回值**：剂量率（%/小时）

**使用示例**：

```swift
let rate = manager.calculateDoseRate(currentDose: 50.0, duration: 7200) // 2小时
print("剂量率: \(rate)%/小时") // 25%/小时
```

---

### **4. 预测达到100%剂量的时间**

```swift
func predictTimeToFullDose(currentDose: Double, doseRate: Double) -> Double?
```

**参数**：

- `currentDose`: 当前累积剂量（%）
- `doseRate`: 剂量率（%/小时）

**返回值**：预测时间（小时），如果已超过100%或剂量率为0则返回nil

**使用示例**：

```swift
if let time = manager.predictTimeToFullDose(currentDose: 50.0, doseRate: 25.0) {
    print("预计\(time)小时后达到100%剂量") // 2小时
}
```

---

### **5. 计算剩余允许暴露时间**

```swift
func calculateRemainingAllowedTime(currentDose: Double, doseRate: Double) -> Double?
```

**参数**：

- `currentDose`: 当前累积剂量（%）
- `doseRate`: 剂量率（%/小时）

**返回值**：剩余时间（小时），如果已超标则返回nil

**使用示例**：

```swift
if let time = manager.calculateRemainingAllowedTime(currentDose: 75.0, doseRate: 25.0) {
    print("剩余允许暴露时间: \(time)小时") // 1小时
}
```

---

## 📊 **数据获取方法**

### **1. 获取完整的噪声剂量数据**

```swift
func getNoiseDoseData(standard: NoiseStandard? = nil) -> NoiseDoseData
```

**参数**：

- `standard`: 噪声限值标准，默认使用当前设置的标准

**返回值**：`NoiseDoseData`对象，包含：

- `dosePercentage`: 剂量百分比（%）
- `doseRate`: 剂量率（%/小时）
- `twa`: TWA值（dB）
- `duration`: 测量时长（小时）
- `standard`: 使用的标准
- `isExceeding`: 是否超标
- `limitMargin`: 限值余量（dB）
- `predictedTimeToFullDose`: 预测达标时间（小时）
- `remainingAllowedTime`: 剩余允许时间（小时）
- `riskLevel`: 风险等级

**使用示例**：

```swift
let doseData = manager.getNoiseDoseData(standard: .osha)
print("剂量: \(doseData.dosePercentage)%")
print("TWA: \(doseData.twa) dB")
print("风险等级: \(doseData.riskLevel)")
print("是否超标: \(doseData.isExceeding)")

if let predictedTime = doseData.predictedTimeToFullDose {
    print("预计\(predictedTime)小时后达到100%剂量")
}

// JSON转换
if let json = doseData.toJSON() {
    print(json)
}
```

---

### **2. 检查是否超过限值**

```swift
func isExceedingLimit(standard: NoiseStandard) -> Bool
```

**参数**：

- `standard`: 噪声限值标准

**返回值**：是否超过限值

**使用示例**：

```swift
if manager.isExceedingLimit(standard: .osha) {
    print("警告：已超过OSHA限值！")
}

if manager.isExceedingLimit(standard: .niosh) {
    print("警告：已超过NIOSH限值！")
}
```

---

### **3. 获取限值比较结果**

```swift
func getLimitComparisonResult(standard: NoiseStandard) -> LimitComparisonResult
```

**参数**：

- `standard`: 噪声限值标准

**返回值**：`LimitComparisonResult`对象，包含：

- `standard`: 使用的标准
- `currentTWA`: 当前TWA值（dB）
- `twaLimit`: TWA限值（dB）
- `currentDose`: 当前剂量（%）
- `isExceeding`: 是否超标
- `isActionLevelReached`: 是否达到行动值
- `limitMargin`: 限值余量（dB）
- `doseMargin`: 剂量余量（%）
- `riskLevel`: 风险等级
- `recommendations`: 建议措施数组

**使用示例**：

```swift
let result = manager.getLimitComparisonResult(standard: .niosh)
print("TWA: \(result.currentTWA) dB, 限值: \(result.twaLimit) dB")
print("余量: \(result.limitMargin) dB")
print("风险等级: \(result.riskLevel)")

for recommendation in result.recommendations {
    print("建议: \(recommendation)")
}

// JSON转换
if let json = result.toJSON() {
    print(json)
}
```

---

### **4. 生成噪音测量计综合报告**

```swift
func generateNoiseDosimeterReport(standard: NoiseStandard? = nil) -> NoiseDosimeterReport?
```

**参数**：

- `standard`: 噪声限值标准，默认使用当前设置的标准

**返回值**：`NoiseDosimeterReport`对象，包含完整的评估报告

**使用示例**：

```swift
if let report = manager.generateNoiseDosimeterReport(standard: .osha) {
    print("报告生成时间: \(report.reportTime)")
    print("测量时长: \(report.measurementDuration)小时")
    print("TWA: \(report.doseData.twa) dB")
    print("剂量: \(report.doseData.dosePercentage)%")
    print("风险等级: \(report.doseData.riskLevel)")
    
    // 导出为JSON
    if let json = report.toJSON() {
        // 保存或分享报告
        print(json)
    }
}
```

---

## 📈 **图表数据方法**

### **1. 获取剂量累积图数据**

```swift
func getDoseAccumulationChartData(interval: TimeInterval = 60.0, standard: NoiseStandard? = nil) -> DoseAccumulationChartData
```

**参数**：

- `interval`: 采样间隔（秒），默认60秒
- `standard`: 噪声限值标准

**返回值**：`DoseAccumulationChartData`对象

**图表要求**：

- 横轴：时间（小时）
- 纵轴：剂量（%）
- 显示：累积曲线 + 100%限值线

**使用示例**：

```swift
let data = manager.getDoseAccumulationChartData(interval: 60.0, standard: .osha)
print("当前剂量: \(data.currentDose)%")
print("限值线: \(data.limitLine)%")
print("数据点数量: \(data.dataPoints.count)")

// 绘制图表
for point in data.dataPoints {
    print("时间: \(point.exposureTime)h, 剂量: \(point.cumulativeDose)%")
}

// JSON转换
if let json = data.toJSON() {
    print(json)
}
```

---

### **2. 获取TWA趋势图数据**

```swift
func getTWATrendChartData(interval: TimeInterval = 60.0, standard: NoiseStandard? = nil) -> TWATrendChartData
```

**参数**：

- `interval`: 采样间隔（秒），默认60秒
- `standard`: 噪声限值标准

**返回值**：`TWATrendChartData`对象

**图表要求**：

- 横轴：时间（小时）
- 纵轴：TWA（dB）
- 显示：TWA曲线 + 限值线

**使用示例**：

```swift
let data = manager.getTWATrendChartData(interval: 60.0, standard: .niosh)
print("当前TWA: \(data.currentTWA) dB")
print("限值线: \(data.limitLine) dB")
print("数据点数量: \(data.dataPoints.count)")

// 绘制图表
for point in data.dataPoints {
    print("时间: \(point.exposureTime)h, TWA: \(point.twa) dB, 剂量: \(point.dosePercentage)%")
}

// JSON转换
if let json = data.toJSON() {
    print(json)
}
```

---

## ⚙️ **设置和查询方法**

### **1. 设置噪声限值标准**

```swift
func setNoiseStandard(_ standard: NoiseStandard)
```

**参数**：

- `standard`: 要设置的标准（.osha、.niosh、.gbz、.eu）

**使用示例**：

```swift
manager.setNoiseStandard(.osha)  // 使用OSHA标准
manager.setNoiseStandard(.niosh) // 使用NIOSH标准
```

---

### **2. 获取当前噪声限值标准**

```swift
func getCurrentNoiseStandard() -> NoiseStandard
```

**返回值**：当前使用的标准

**使用示例**：

```swift
let standard = manager.getCurrentNoiseStandard()
print("当前标准: \(standard.rawValue)")
print("TWA限值: \(standard.twaLimit) dB")
print("交换率: \(standard.exchangeRate) dB")
```

---

### **3. 获取所有可用的标准列表**

```swift
func getAvailableNoiseStandards() -> [NoiseStandard]
```

**返回值**：所有标准的数组

**使用示例**：

```swift
let standards = manager.getAvailableNoiseStandards()
for standard in standards {
    print("\(standard.rawValue): TWA限值=\(standard.twaLimit)dB, 交换率=\(standard.exchangeRate)dB")
}
```

---

## 📦 **数据模型**

### **1. NoiseStandard（噪声限值标准）**

```swift
enum NoiseStandard: String, CaseIterable, Codable {
    case osha   // OSHA标准
    case niosh  // NIOSH标准
    case gbz    // GBZ标准
    case eu     // EU标准
}
```

**属性**：

- `twaLimit`: TWA限值（dB）
- `exchangeRate`: 交换率（dB）
- `criterionLevel`: 参考声级（dB）
- `peakLimit`: 峰值限值（dB）
- `actionLevel`: 行动值（dB）
- `fullName`: 完整名称
- `description`: 描述

---

### **2. NoiseDoseData（噪声剂量数据）**

```swift
struct NoiseDoseData: Codable {
    let dosePercentage: Double        // 剂量百分比（%）
    let doseRate: Double              // 剂量率（%/小时）
    let twa: Double                   // TWA值（dB）
    let duration: Double              // 测量时长（小时）
    let standard: NoiseStandard       // 使用的标准
    let isExceeding: Bool             // 是否超标
    let limitMargin: Double           // 限值余量（dB）
    let predictedTimeToFullDose: Double? // 预测达标时间（小时）
    let remainingAllowedTime: Double?    // 剩余允许时间（小时）
    let riskLevel: RiskLevel          // 风险等级
}
```

**支持JSON转换**：

```swift
let data = manager.getNoiseDoseData()
let json = data.toJSON()
let restored = NoiseDoseData.fromJSON(json!)
```

---

### **3. RiskLevel（风险等级）**

```swift
enum RiskLevel: String, Codable {
    case safe = "安全"           // 0-50%剂量
    case acceptable = "可接受"   // 50-100%剂量
    case exceeding = "超标"      // 100-200%剂量
    case dangerous = "严重超标"  // >200%剂量
}
```

**自动判断**：

```swift
let level = RiskLevel.from(dosePercentage: 75.0) // .acceptable
```

---

### **4. LimitComparisonResult（限值比较结果）**

```swift
struct LimitComparisonResult: Codable {
    let standard: NoiseStandard
    let currentTWA: Double
    let twaLimit: Double
    let currentDose: Double
    let isExceeding: Bool
    let isActionLevelReached: Bool
    let limitMargin: Double
    let doseMargin: Double
    let riskLevel: RiskLevel
    let recommendations: [String]     // 建议措施
}
```

---

### **5. DoseAccumulationChartData（剂量累积图数据）**

```swift
struct DoseAccumulationChartData: Codable {
    let dataPoints: [DoseAccumulationPoint]
    let currentDose: Double
    let limitLine: Double             // 100%
    let standard: NoiseStandard
    let timeRange: Double
    let title: String
}
```

---

### **6. TWATrendChartData（TWA趋势图数据）**

```swift
struct TWATrendChartData: Codable {
    let dataPoints: [TWATrendDataPoint]
    let currentTWA: Double
    let limitLine: Double
    let standard: NoiseStandard
    let timeRange: Double
    let title: String
}
```

---

## 💡 **使用示例**

### **完整工作流示例**

```swift
import Foundation

let manager = DecibelMeterManager.shared

// 1. 设置使用OSHA标准
manager.setNoiseStandard(.osha)

// 2. 开始测量
await manager.startMeasurement()

// 3. 测量一段时间...
try? await Task.sleep(nanoseconds: 3600_000_000_000) // 1小时

// 4. 获取噪声剂量数据
let doseData = manager.getNoiseDoseData()
print("=== 噪声剂量数据 ===")
print("剂量: \(String(format: "%.1f", doseData.dosePercentage))%")
print("TWA: \(String(format: "%.1f", doseData.twa)) dB")
print("剂量率: \(String(format: "%.1f", doseData.doseRate))%/小时")
print("风险等级: \(doseData.riskLevel.rawValue)")

if let predictedTime = doseData.predictedTimeToFullDose {
    print("预计\(String(format: "%.1f", predictedTime))小时后达到100%剂量")
}

// 5. 获取限值比较结果
let comparison = manager.getLimitComparisonResult(standard: .osha)
print("\n=== 限值比较 ===")
print("当前TWA: \(String(format: "%.1f", comparison.currentTWA)) dB")
print("限值: \(String(format: "%.1f", comparison.twaLimit)) dB")
print("余量: \(String(format: "%.1f", comparison.limitMargin)) dB")
print("是否超标: \(comparison.isExceeding)")
print("是否达到行动值: \(comparison.isActionLevelReached)")

print("\n建议措施:")
for recommendation in comparison.recommendations {
    print("- \(recommendation)")
}

// 6. 获取图表数据
let doseChart = manager.getDoseAccumulationChartData(interval: 60.0, standard: .osha)
print("\n=== 剂量累积图 ===")
print("当前剂量: \(String(format: "%.1f", doseChart.currentDose))%")
print("数据点数量: \(doseChart.dataPoints.count)")

let twaChart = manager.getTWATrendChartData(interval: 60.0, standard: .osha)
print("\n=== TWA趋势图 ===")
print("当前TWA: \(String(format: "%.1f", twaChart.currentTWA)) dB")
print("数据点数量: \(twaChart.dataPoints.count)")

// 7. 生成综合报告
if let report = manager.generateNoiseDosimeterReport(standard: .osha) {
    print("\n=== 综合报告 ===")
    print("测量时长: \(String(format: "%.2f", report.measurementDuration))小时")
    print("LEQ: \(String(format: "%.1f", report.leq)) dB")
    print("TWA: \(String(format: "%.1f", report.doseData.twa)) dB")
    print("剂量: \(String(format: "%.1f", report.doseData.dosePercentage))%")
    
    // 导出为JSON
    if let json = report.toJSON() {
        // 保存到文件或分享
        print("\n报告JSON已生成")
    }
}

// 8. 停止测量
manager.stopMeasurement()
```

---

### **多标准对比示例**

```swift
// 对比不同标准的结果
let standards: [NoiseStandard] = [.osha, .niosh, .gbz, .eu]

print("=== 多标准对比 ===")
for standard in standards {
    let doseData = manager.getNoiseDoseData(standard: standard)
    print("\n[\(standard.rawValue)]")
    print("TWA限值: \(standard.twaLimit) dB")
    print("交换率: \(standard.exchangeRate) dB")
    print("当前TWA: \(String(format: "%.1f", doseData.twa)) dB")
    print("剂量: \(String(format: "%.1f", doseData.dosePercentage))%")
    print("是否超标: \(doseData.isExceeding ? "是" : "否")")
    print("风险等级: \(doseData.riskLevel.rawValue)")
}
```

---

### **实时监控示例**

```swift
// 每秒更新一次剂量数据
Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    let doseData = manager.getNoiseDoseData(standard: .niosh)
    
    // 更新UI显示
    print("剂量: \(String(format: "%.1f", doseData.dosePercentage))%")
    print("TWA: \(String(format: "%.1f", doseData.twa)) dB")
    
    // 检查是否需要警告
    if doseData.dosePercentage >= 100.0 {
        print("⚠️ 警告：剂量已达到100%！")
    } else if doseData.dosePercentage >= 80.0 {
        print("⚠️ 注意：剂量已达到80%，接近限值")
    }
    
    // 显示剩余时间
    if let remainingTime = doseData.remainingAllowedTime {
        print("剩余允许暴露时间: \(String(format: "%.1f", remainingTime))小时")
    }
}
```

---

## 📊 **计算公式详解**

### **1. TWA计算**

```
TWA = 10 × log₁₀((T/8) × 10^(LEQ/10))
```

**示例**：

- LEQ = 90 dB，暴露4小时
- TWA = 10 × log₁₀((4/8) × 10^(90/10))
- TWA = 10 × log₁₀(0.5 × 10^9)
- TWA ≈ 87 dB

---

### **2. Dose计算**

```
Dose = 100 × 2^((TWA - 85) / ExchangeRate)
```

**OSHA示例（5dB交换率）**：

- TWA = 90 dB
- Dose = 100 × 2^((90-85)/5) = 100 × 2^1 = 200%

**NIOSH示例（3dB交换率）**：

- TWA = 90 dB
- Dose = 100 × 2^((90-85)/3) = 100 × 2^1.67 ≈ 318%

---

### **3. 剂量率计算**

```
Dose Rate = Current Dose / Elapsed Time (hours)
```

**示例**：

- 当前剂量 = 50%
- 已暴露时间 = 2小时
- 剂量率 = 50% / 2h = 25%/小时

---

### **4. 预测时间计算**

```
Predicted Time = (100% - Current Dose) / Dose Rate
```

**示例**：

- 当前剂量 = 75%
- 剂量率 = 25%/小时
- 预测时间 = (100% - 75%) / 25% = 1小时

---

## 🎯 **风险等级判断**

| 剂量范围 | 风险等级 | 颜色 | 建议措施 |
|---------|---------|------|---------|
| 0-50% | 安全 | 绿色 | 正常工作 |
| 50-100% | 可接受 | 黄色 | 建议佩戴听力保护设备 |
| 100-200% | 超标 | 橙色 | 必须佩戴听力保护设备，减少暴露时间 |
| >200% | 严重超标 | 红色 | 立即停止暴露，采取紧急措施 |

---

## ✅ **功能完成情况**

### **噪音测量计核心功能**

| 功能 | 状态 | 方法 |
|------|------|------|
| TWA计算 | ✅ 已实现 | `calculateTWA()` |
| Dose计算 | ✅ 已实现 | `calculateNoiseDose()` |
| 剂量率计算 | ✅ 已实现 | `calculateDoseRate()` |
| 预测时间 | ✅ 已实现 | `predictTimeToFullDose()` |
| 剩余时间 | ✅ 已实现 | `calculateRemainingAllowedTime()` |
| 限值比较 | ✅ 已实现 | `getLimitComparisonResult()` |
| 风险评估 | ✅ 已实现 | `RiskLevel.from()` |
| 剂量累积图 | ✅ 已实现 | `getDoseAccumulationChartData()` |
| TWA趋势图 | ✅ 已实现 | `getTWATrendChartData()` |
| 综合报告 | ✅ 已实现 | `generateNoiseDosimeterReport()` |

### **支持的标准**

| 标准 | TWA限值 | 交换率 | 参考声级 | 行动值 |
|------|---------|--------|---------|--------|
| OSHA | 90 dB | 5 dB | 85 dB | 85 dB |
| NIOSH | 85 dB | 3 dB | 85 dB | 85 dB |
| GBZ | 85 dB | 3 dB | 85 dB | 85 dB |
| EU | 87 dB | 3 dB | 85 dB | 80 dB |

---

## 📚 **参考标准**

1. **OSHA 29 CFR 1910.95** - Occupational Noise Exposure
2. **NIOSH REL** - Criteria for a Recommended Standard: Occupational Noise Exposure
3. **GBZ 2.2-2007** - 工作场所有害因素职业接触限值
4. **EU Directive 2003/10/EC** - Minimum health and safety requirements regarding the exposure of workers to noise
5. **ISO 1999:2013** - Acoustics — Estimation of noise-induced hearing loss
6. **IEC 61252:2017** - Electroacoustics — Specifications for personal sound exposure meters

---

**文档版本**：v1.0  
**最后更新**：2025年1月23日  
**功能状态**：✅ 完整实现
