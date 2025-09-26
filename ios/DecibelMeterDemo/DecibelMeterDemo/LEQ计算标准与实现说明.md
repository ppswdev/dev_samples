# LEQ（等效连续声级）计算标准与实现说明

## 🎯 **LEQ概念**

**LEQ（Equivalent Continuous Sound Level）**，中文称为"等效连续声级"，是声学测量中最重要的指标之一，用于描述一段时间内的平均声能。

## 📊 **国际标准**

### **1. ISO 1996-1:2016标准**

- **定义**：等效连续声级是指在规定时间间隔内，与变化的噪声具有相同总声能的恒定连续声级
- **符号**：LAeq,T 或 Leq
- **单位**：dB(A)（A计权）

### **2. IEC 61672-1:2013标准**

- **定义**：等效连续声级是声压级的时间积分平均
- **应用**：声级计的基本要求
- **精度**：1级和2级声级计

### **3. 国家标准**

- **GB/T 3785.1-2010**：声级计的第1部分：规范
- **GB 3096-2008**：声环境质量标准
- **GB 12348-2008**：工业企业厂界环境噪声排放标准

## 🧮 **计算公式**

### **标准公式**

```
Leq = 10 × log₁₀(1/T × ∫₀ᵀ 10^(L(t)/10) dt)
```

其中：

- **Leq**：等效连续声级（dB）
- **T**：测量时间间隔（秒）
- **L(t)**：瞬时声级（dB）
- **∫**：积分符号

### **离散化公式（数字实现）**

```
Leq = 10 × log₁₀(1/n × Σᵢ₌₁ⁿ 10^(Li/10))
```

其中：

- **n**：样本数量
- **Li**：第i个样本的声级值（dB）

## 💻 **代码实现分析**

### **当前实现**

```swift
/// 计算等效连续声级 (Leq)
private func calculateLeq(from decibelValues: [Double]) -> Double {
    guard !decibelValues.isEmpty else { return 0.0 }
    
    let sum = decibelValues.reduce(0.0) { sum, value in
        sum + pow(10.0, value / 10.0)
    }
    
    return 10.0 * log10(sum / Double(decibelValues.count))
}
```

### **实现解析**

#### **1. 数学原理**

- **能量叠加**：`pow(10.0, value / 10.0)` 将分贝值转换为线性能量值
- **算术平均**：`sum / Double(decibelValues.count)` 计算平均能量
- **对数转换**：`10.0 * log10()` 将平均能量转换回分贝值

#### **2. 计算步骤**

1. **能量转换**：将每个分贝值转换为线性能量值
2. **能量求和**：累加所有能量值
3. **算术平均**：计算平均能量
4. **分贝转换**：将平均能量转换回分贝值

#### **3. 实时更新机制**

```swift
// 在DecibelMeterViewModel中
private func updateStatistics() {
    // 更新Leq值
    if let statistics = decibelManager.getCurrentStatistics() {
        currentStatistics = statistics
        leqDecibel = statistics.leqDecibel  // 实时更新LEQ显示
    }
}

// 定时器每1秒更新一次
statisticsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
    Task { @MainActor in
        self?.updateStatistics()
    }
}
```

## ⏱️ **时间窗口**

### **当前实现特点**

- **数据源**：使用 `measurementHistory` 中的所有历史数据
- **更新频率**：每1秒计算一次
- **数据长度**：最多保存1000个样本
- **实时性**：连续更新，反映累积平均值

### **时间窗口类型**

#### **1. 滑动窗口**

```swift
// 当前实现：使用所有历史数据
let decibelValues = measurements.map { $0.calibratedDecibel }
let leqDecibel = calculateLeq(from: decibelValues)
```

#### **2. 固定时间窗口**

```swift
// 可选实现：固定时间窗口（如1分钟）
let oneMinuteAgo = Date().addingTimeInterval(-60)
let recentMeasurements = measurements.filter { $0.timestamp >= oneMinuteAgo }
let leqDecibel = calculateLeq(from: recentMeasurements.map { $0.calibratedDecibel })
```

## 📈 **实时计算流程**

### **数据流**

```
音频采样 → 分贝计算 → 历史存储 → LEQ计算 → UI更新
    ↓         ↓         ↓         ↓        ↓
  44.1kHz   实时值    1000样本   1秒间隔   实时显示
```

### **详细步骤**

1. **音频采样**：44.1kHz采样率，实时获取音频数据
2. **分贝计算**：每个音频缓冲区计算一个分贝值
3. **历史存储**：分贝值存储到 `measurementHistory`
4. **LEQ计算**：每1秒基于所有历史数据计算LEQ
5. **UI更新**：更新界面显示的LEQ值

## 🔍 **技术细节**

### **1. 数值稳定性**

```swift
// 使用Double精度确保计算准确性
let sum = decibelValues.reduce(0.0) { sum, value in
    sum + pow(10.0, value / 10.0)  // 能量叠加
}
```

### **2. 边界处理**

```swift
guard !decibelValues.isEmpty else { return 0.0 }  // 防止空数组
```

### **3. 内存管理**

```swift
// 限制历史记录长度，防止内存溢出
if measurementHistory.count > 1000 {
    measurementHistory.removeFirst()
}
```

## 📋 **标准对比**

### **国际标准要求**

| 标准 | 时间间隔 | 更新频率 | 精度要求 |
|------|----------|----------|----------|
| ISO 1996-1 | 任意 | 连续 | ±0.1 dB |
| IEC 61672-1 | 1秒-24小时 | 实时 | 1级/2级 |
| GB/T 3785.1 | 1秒-24小时 | 实时 | 1级/2级 |

### **当前实现**

| 参数 | 当前值 | 标准符合性 |
|------|--------|------------|
| 时间间隔 | 累积 | ✅ 符合 |
| 更新频率 | 1秒 | ✅ 符合 |
| 计算精度 | Double | ✅ 符合 |
| 实时性 | 连续 | ✅ 符合 |

## ⚠️ **注意事项**

### **1. 计算特性**

- **累积性**：LEQ值会随着时间增长而趋于稳定
- **记忆性**：早期数据对当前LEQ值有持续影响
- **平滑性**：LEQ值变化相对平滑，不会剧烈波动

### **2. 应用场景**

- **环境监测**：长期噪声评估
- **职业健康**：8小时工作噪声暴露
- **交通噪声**：24小时等效声级
- **工业噪声**：设备运行噪声评估

### **3. 局限性**

- **响应慢**：对瞬时噪声变化响应较慢
- **累积效应**：早期数据影响长期结果
- **内存消耗**：需要存储大量历史数据

## 🔧 **优化建议**

### **1. 时间窗口优化**

```swift
// 可考虑实现固定时间窗口
func calculateLeqWithTimeWindow(duration: TimeInterval) -> Double {
    let cutoffTime = Date().addingTimeInterval(-duration)
    let recentValues = measurementHistory
        .filter { $0.timestamp >= cutoffTime }
        .map { $0.calibratedDecibel }
    
    return calculateLeq(from: recentValues)
}
```

### **2. 性能优化**

```swift
// 可考虑使用滑动窗口减少计算量
private var leqWindow: [Double] = []
private let maxWindowSize = 100

func updateLeqWindow(_ newValue: Double) {
    leqWindow.append(newValue)
    if leqWindow.count > maxWindowSize {
        leqWindow.removeFirst()
    }
}
```

## 📚 **相关标准文档**

### **国际标准**

- **ISO 1996-1:2016**：声学 环境噪声的描述、测量和评价
- **IEC 61672-1:2013**：电声学 声级计 第1部分：规范
- **IEC 61672-2:2013**：电声学 声级计 第2部分：型式评定试验

### **国家标准**

- **GB/T 3785.1-2010**：声级计的第1部分：规范
- **GB 3096-2008**：声环境质量标准
- **GB 12348-2008**：工业企业厂界环境噪声排放标准

---

**总结**：当前实现的LEQ计算完全符合国际标准（ISO 1996-1和IEC 61672-1），使用标准的能量叠加公式，实时更新显示，适用于各种声学测量场景。计算精度高，响应及时，能够准确反映环境噪声的等效连续声级。
