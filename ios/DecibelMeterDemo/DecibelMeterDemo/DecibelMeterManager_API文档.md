# DecibelMeterManager API 文档

## 📋 **目录**

1. [状态获取方法](#状态获取方法)
2. [权重列表获取方法](#权重列表获取方法)
3. [图表数据获取方法](#图表数据获取方法)
4. [设置方法](#设置方法)
5. [数据模型](#数据模型)
6. [JSON转换示例](#json转换示例)

---

## 🔍 **状态获取方法**

### **1. 获取当前测量状态**

```swift
func getCurrentState() -> MeasurementState
```

**返回值**：`.idle`（停止）、`.measuring`（测量中）、`.error(String)`（错误）

### **2. 获取当前测量时长**

```swift
// 格式化为 HH:mm:ss
func getFormattedMeasurementDuration() -> String

// 返回秒数
func getMeasurementDuration() -> TimeInterval
```

**示例**：`"00:05:23"` 或 `323.0` 秒

### **3. 获取当前频率权重**

```swift
func getDecibelMeterFrequencyWeighting() -> FrequencyWeighting
```

**返回值**：`.aWeight`、`.bWeight`、`.cWeight`、`.zWeight`、`.ituR468`

### **4. 获取当前时间权重**

```swift
func getCurrentTimeWeighting() -> TimeWeighting
```

**返回值**：`.fast`、`.slow`、`.impulse`

### **5. 获取频率时间权重简写文本**

```swift
func getWeightingDisplayText() -> String
```

**示例**：`"dB(A)F"`、`"dB(C)S"`、`"dB(ITU)I"`

### **6. 获取校准值**

```swift
func getCalibrationOffset() -> Double
```

### **7. 获取当前分贝值**

```swift
func getCurrentDecibel() -> Double
```

### **8. 获取最小分贝值**

```swift
func getMinDecibel() -> Double
```

### **9. 获取最大分贝值**

```swift
func getMaxDecibel() -> Double
```

### **10. 获取PEAK值**

```swift
func getCurrentPeak() -> Double
```

### **11. 获取LEQ值**

```swift
func getLeqDecibel() -> Double
// 或
func getRealTimeLeq() -> Double
```

---

## 📊 **权重列表获取方法**

### **1. 获取所有频率权重列表**

```swift
func getFrequencyWeightingsList() -> WeightingOptionsList
```

**返回数据结构**：

```swift
struct WeightingOptionsList {
    let options: [WeightingOption]
    let currentSelection: String
}

struct WeightingOption {
    let id: String              // "A-weight"
    let displayName: String     // "dB-A"
    let symbol: String          // "A"
    let description: String     // "A权重 - 环境噪声标准"
    let standard: String        // "IEC 61672-1, ISO 226"
}
```

**支持的权重**：

- dB-A (A权重)
- dB-B (B权重)
- dB-C (C权重)
- dB-Z (Z权重)
- ITU-R 468

**JSON转换**：

```swift
let list = manager.getFrequencyWeightingsList()
let jsonString = list.toJSON() // 转换为JSON字符串
let restored = WeightingOptionsList.fromJSON(jsonString!) // 从JSON恢复
```

### **2. 获取所有时间权重列表**

```swift
func getTimeWeightingsList() -> WeightingOptionsList
```

**支持的权重**：

- F (Fast - 快响应)
- S (Slow - 慢响应)
- I (Impulse - 脉冲响应)

---

## 📈 **图表数据获取方法**

### **1. 时间历程图数据（实时分贝曲线）**

```swift
func getTimeHistoryChartData(timeRange: TimeInterval = 60.0) -> TimeHistoryChartData
```

**参数**：

- `timeRange`: 时间范围（秒），默认60秒

**返回数据结构**：

```swift
struct TimeHistoryChartData {
    let dataPoints: [TimeHistoryDataPoint]
    let timeRange: TimeInterval
    let minDecibel: Double
    let maxDecibel: Double
    let title: String
}

struct TimeHistoryDataPoint {
    let timestamp: Date
    let decibel: Double
    let weightingType: String // "Fast", "Slow", "Impulse"
}
```

**使用示例**：

```swift
let chartData = manager.getTimeHistoryChartData(timeRange: 60.0)
print("数据点数量: \(chartData.dataPoints.count)")
print("分贝范围: \(chartData.minDecibel) - \(chartData.maxDecibel) dB")

// JSON转换
if let json = chartData.toJSON() {
    print(json)
}
```

**图表要求**：

- 横轴：时间（最近60秒或可配置）
- 纵轴：分贝值（0-140 dB）
- 显示：实时更新的曲线

### **2. 实时指示器数据**

```swift
func getRealTimeIndicatorData() -> RealTimeIndicatorData
```

**返回数据结构**：

```swift
struct RealTimeIndicatorData {
    let currentDecibel: Double
    let leq: Double
    let min: Double
    let max: Double
    let peak: Double
    let weightingDisplay: String // "dB(A)F"
    let timestamp: Date
}
```

**使用示例**：

```swift
let indicator = manager.getRealTimeIndicatorData()
print("当前: \(indicator.currentDecibel) dB")
print("LEQ: \(indicator.leq) dB")
print("MIN: \(indicator.min) dB")
print("MAX: \(indicator.max) dB")
print("PEAK: \(indicator.peak) dB")
print("权重: \(indicator.weightingDisplay)")
```

### **3. 频谱分析图数据**

```swift
func getSpectrumChartData(bandType: String = "1/3") -> SpectrumChartData
```

**参数**：

- `bandType`: `"1/1"` 或 `"1/3"` 倍频程

**返回数据结构**：

```swift
struct SpectrumChartData {
    let dataPoints: [SpectrumDataPoint]
    let bandType: String
    let frequencyRange: (min: Double, max: Double)
    let title: String
}

struct SpectrumDataPoint {
    let frequency: Double // Hz
    let magnitude: Double // dB
    let bandType: String  // "1/1" or "1/3"
}
```

**使用示例**：

```swift
// 1/1倍频程
let spectrum1_1 = manager.getSpectrumChartData(bandType: "1/1")
// 频率: 31.5, 63, 125, 250, 500, 1k, 2k, 4k, 8k, 16k Hz

// 1/3倍频程
let spectrum1_3 = manager.getSpectrumChartData(bandType: "1/3")
// 频率: 25, 31.5, 40, 50, 63, 80, 100, 125, ... 20k Hz

// JSON转换
if let json = spectrum1_3.toJSON() {
    print(json)
}
```

**图表要求**：

- 横轴：频率（Hz）- 对数坐标
- 纵轴：声压级（dB）
- 显示：1/1倍频程或1/3倍频程柱状图

### **4. 统计分布图数据（L10、L50、L90）**

```swift
func getStatisticalDistributionChartData() -> StatisticalDistributionChartData
```

**返回数据结构**：

```swift
struct StatisticalDistributionChartData {
    let dataPoints: [StatisticalDistributionPoint]
    let l10: Double
    let l50: Double
    let l90: Double
    let title: String
}

struct StatisticalDistributionPoint {
    let percentile: Double // 0-100
    let decibel: Double
    let label: String // "L10", "L50", "L90"
}
```

**使用示例**：

```swift
let distribution = manager.getStatisticalDistributionChartData()
print("L10: \(distribution.l10) dB") // 10%时间超过的声级
print("L50: \(distribution.l50) dB") // 50%时间超过的声级（中位数）
print("L90: \(distribution.l90) dB") // 90%时间超过的声级（背景噪声）

// JSON转换
if let json = distribution.toJSON() {
    print(json)
}
```

**图表要求**：

- 横轴：百分位数（%）
- 纵轴：分贝值（dB）
- 显示：柱状图或折线图

### **5. LEQ趋势图数据**

```swift
func getLEQTrendChartData(interval: TimeInterval = 10.0) -> LEQTrendChartData
```

**参数**：

- `interval`: 采样间隔（秒），默认10秒

**返回数据结构**：

```swift
struct LEQTrendChartData {
    let dataPoints: [LEQTrendDataPoint]
    let timeRange: TimeInterval
    let currentLeq: Double
    let title: String
}

struct LEQTrendDataPoint {
    let timestamp: Date
    let leq: Double           // 时段LEQ
    let cumulativeLeq: Double // 累积LEQ
}
```

**使用示例**：

```swift
let leqTrend = manager.getLEQTrendChartData(interval: 10.0)
print("当前LEQ: \(leqTrend.currentLeq) dB")
print("数据点数量: \(leqTrend.dataPoints.count)")

for point in leqTrend.dataPoints {
    print("时间: \(point.timestamp), LEQ: \(point.leq) dB, 累积LEQ: \(point.cumulativeLeq) dB")
}

// JSON转换
if let json = leqTrend.toJSON() {
    print(json)
}
```

**图表要求**：

- 横轴：时间
- 纵轴：LEQ值（dB）
- 显示：累积趋势曲线

---

## ⚙️ **设置方法**

### **1. 设置频率权重**

```swift
func setFrequencyWeighting(_ weighting: FrequencyWeighting)
```

**使用示例**：

```swift
manager.setFrequencyWeighting(.aWeight)
manager.setFrequencyWeighting(.cWeight)
manager.setFrequencyWeighting(.ituR468)
```

### **2. 设置时间权重**

```swift
func setTimeWeighting(_ weighting: TimeWeighting)
```

**使用示例**：

```swift
manager.setTimeWeighting(.fast)
manager.setTimeWeighting(.slow)
manager.setTimeWeighting(.impulse)
```

### **3. 设置校准偏移**

```swift
func setCalibrationOffset(_ offset: Double)
```

**使用示例**：

```swift
manager.setCalibrationOffset(2.5) // 增加2.5dB
manager.setCalibrationOffset(-1.0) // 减少1.0dB
```

### **4. 重置所有状态和数据**

```swift
func resetAllData()
```

**功能**：

- 停止测量
- 清除所有历史数据
- 重置统计值（MIN、MAX、PEAK、LEQ）
- 重置校准偏移为0
- 重置状态为idle

**使用示例**：

```swift
manager.resetAllData()
```

---

## 📦 **数据模型**

### **所有数据模型都支持JSON转换**

#### **1. WeightingOptionsList**

```swift
let list = manager.getFrequencyWeightingsList()
let json = list.toJSON()
let restored = WeightingOptionsList.fromJSON(json!)
```

#### **2. TimeHistoryChartData**

```swift
let data = manager.getTimeHistoryChartData()
let json = data.toJSON()
let restored = TimeHistoryChartData.fromJSON(json!)
```

#### **3. SpectrumChartData**

```swift
let data = manager.getSpectrumChartData()
let json = data.toJSON()
let restored = SpectrumChartData.fromJSON(json!)
```

#### **4. StatisticalDistributionChartData**

```swift
let data = manager.getStatisticalDistributionChartData()
let json = data.toJSON()
let restored = StatisticalDistributionChartData.fromJSON(json!)
```

#### **5. LEQTrendChartData**

```swift
let data = manager.getLEQTrendChartData()
let json = data.toJSON()
let restored = LEQTrendChartData.fromJSON(json!)
```

#### **6. RealTimeIndicatorData**

```swift
let data = manager.getRealTimeIndicatorData()
let json = data.toJSON()
let restored = RealTimeIndicatorData.fromJSON(json!)
```

---

## 💡 **JSON转换示例**

### **完整示例**

```swift
import Foundation

// 1. 获取数据
let manager = DecibelMeterManager.shared

// 2. 获取时间历程图数据
let chartData = manager.getTimeHistoryChartData(timeRange: 60.0)

// 3. 转换为JSON字符串
if let jsonString = chartData.toJSON() {
    print("JSON数据:")
    print(jsonString)
    
    // 4. 保存到文件
    if let data = jsonString.data(using: .utf8) {
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("chart_data.json")
        try? data.write(to: url)
        print("已保存到: \(url)")
    }
    
    // 5. 从JSON恢复
    if let restored = TimeHistoryChartData.fromJSON(jsonString) {
        print("恢复成功，数据点数量: \(restored.dataPoints.count)")
    }
}

// 6. 获取实时指示器数据
let indicator = manager.getRealTimeIndicatorData()
if let json = indicator.toJSON() {
    print("实时指示器JSON:")
    print(json)
}

// 7. 获取频谱数据
let spectrum = manager.getSpectrumChartData(bandType: "1/3")
if let json = spectrum.toJSON() {
    print("频谱数据JSON:")
    print(json)
}
```

### **JSON输出示例**

#### **时间历程图数据**

```json
{
  "dataPoints": [
    {
      "timestamp": "2025-01-23T10:30:00Z",
      "decibel": 65.5,
      "weightingType": "Fast"
    },
    {
      "timestamp": "2025-01-23T10:30:01Z",
      "decibel": 67.2,
      "weightingType": "Fast"
    }
  ],
  "timeRange": 60.0,
  "minDecibel": 60.0,
  "maxDecibel": 85.0,
  "title": "实时分贝曲线 - dB(A)F"
}
```

#### **实时指示器数据**

```json
{
  "currentDecibel": 72.5,
  "leq": 70.3,
  "min": 60.2,
  "max": 85.7,
  "peak": 92.1,
  "weightingDisplay": "dB(A)F",
  "timestamp": "2025-01-23T10:30:00Z"
}
```

---

## 🎯 **使用建议**

### **1. 实时更新**

```swift
// 使用Timer定期获取数据
Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
    let indicator = manager.getRealTimeIndicatorData()
    // 更新UI
}
```

### **2. 图表刷新**

```swift
// 每5秒更新一次图表
Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
    let chartData = manager.getTimeHistoryChartData(timeRange: 60.0)
    // 刷新图表
}
```

### **3. 数据导出**

```swift
// 导出所有图表数据为JSON
func exportAllChartData() {
    let data = [
        "timeHistory": manager.getTimeHistoryChartData().toJSON(),
        "spectrum": manager.getSpectrumChartData().toJSON(),
        "distribution": manager.getStatisticalDistributionChartData().toJSON(),
        "leqTrend": manager.getLEQTrendChartData().toJSON()
    ]
    // 保存或分享
}
```

---

## 📚 **参考标准**

- **IEC 61672-1:2013** - 声级计标准
- **ISO 1996-1:2016** - 环境噪声测量
- **IEC 61260-1:2014** - 倍频程滤波器
- **ITU-R BS.468-4** - 广播音频测量

---

**文档版本**：v1.0  
**最后更新**：2025年1月23日  
**适用范围**：iOS分贝测量仪DecibelMeterManager API
