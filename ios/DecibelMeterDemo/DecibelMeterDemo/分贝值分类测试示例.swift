//
//  分贝值分类测试示例.swift
//  DecibelMeterDemo
//
//  测试修正后的分贝值分类逻辑
//

import Foundation

// MARK: - 分类逻辑测试

/// 测试分贝值分类逻辑
func testDecibelClassification() {
    print("=== 分贝值分类逻辑测试 ===\n")
    
    // NIOSH标准限值列表
    let nioshLevels = [85.0, 88.0, 91.0, 94.0, 97.0, 100.0, 103.0, 106.0, 109.0, 112.0, 115.0]
    
    // 测试用例
    let testCases = [
        84, 85, 86, 87, 88, 89, 90, 91, 92, 93, 94, 95, 96, 97, 98, 99,
        100, 101, 102, 103, 104, 105, 106, 107, 108, 109, 110, 111, 112, 113, 114, 115, 116
    ]
    
    print("当前分贝值 → 归类到限值")
    print("------------------------")
    
    for testValue in testCases {
        let targetLevel = findTargetLevel(for: Double(testValue), in: nioshLevels)
        if let target = targetLevel {
            print("\(testValue) dB → \(Int(target)) dB")
        } else {
            print("\(testValue) dB → 无对应限值")
        }
    }
}

/// 找到分贝值对应的限值
func findTargetLevel(for decibelValue: Double, in soundLevels: [Double]) -> Double? {
    // 从高到低遍历声级列表，找到第一个小于或等于当前分贝值的限值
    for i in stride(from: soundLevels.count - 1, through: 0, by: -1) {
        if decibelValue >= soundLevels[i] {
            return soundLevels[i]
        }
    }
    return nil
}

// MARK: - 实际测量数据测试

/// 模拟实际测量数据测试
func testWithMockData() {
    print("\n=== 模拟测量数据测试 ===\n")
    
    let manager = DecibelMeterManager.shared
    
    // 模拟一些测量数据（实际应用中这些数据来自真实的测量历史）
    let mockMeasurements = [
        (86.0, "09:00:01"),
        (87.2, "09:00:02"),
        (89.1, "09:00:03"),
        (91.0, "09:00:04"),
        (92.8, "09:00:05"),
        (95.3, "09:00:06"),
        (98.1, "09:00:07"),
        (100.0, "09:00:08"),
        (102.4, "09:00:09"),
        (105.7, "09:00:10"),
        (108.2, "09:00:11"),
        (110.8, "09:00:12"),
        (113.5, "09:00:13"),
        (116.0, "09:00:14"),
        (85.0, "09:00:15"),
        (88.0, "09:00:16")
    ]
    
    print("模拟测量数据:")
    print("时间\t\t分贝值\t归类到限值")
    print("----------------------------")
    
    for (decibel, time) in mockMeasurements {
        let nioshLevels = [85.0, 88.0, 91.0, 94.0, 97.0, 100.0, 103.0, 106.0, 109.0, 112.0, 115.0]
        let targetLevel = findTargetLevel(for: decibel, in: nioshLevels)
        
        if let target = targetLevel {
            print("\(time)\t\(String(format: "%.1f", decibel)) dB\t\(Int(target)) dB")
        } else {
            print("\(time)\t\(String(format: "%.1f", decibel)) dB\t无对应限值")
        }
    }
}

// MARK: - 不同标准测试

/// 测试不同标准的分类逻辑
func testDifferentStandards() {
    print("\n=== 不同标准分类测试 ===\n")
    
    // 不同标准的限值列表
    let standards = [
        ("NIOSH", [85.0, 88.0, 91.0, 94.0, 97.0, 100.0, 103.0, 106.0, 109.0, 112.0, 115.0]),
        ("OSHA", [90.0, 95.0, 100.0, 105.0, 110.0, 115.0]),
        ("EU", [87.0, 90.0, 93.0, 96.0, 99.0, 102.0, 105.0, 108.0, 111.0, 114.0])
    ]
    
    // 测试分贝值
    let testValues = [87, 92, 96, 101, 107]
    
    for (standardName, levels) in standards {
        print("\(standardName) 标准:")
        print("限值列表: \(levels.map { "\(Int($0))" }.joined(separator: ", ")) dB")
        
        for value in testValues {
            let targetLevel = findTargetLevel(for: Double(value), in: levels)
            if let target = targetLevel {
                print("  \(value) dB → \(Int(target)) dB")
            } else {
                print("  \(value) dB → 无对应限值")
            }
        }
        print()
    }
}

// MARK: - 边界情况测试

/// 测试边界情况
func testBoundaryCases() {
    print("=== 边界情况测试 ===\n")
    
    let nioshLevels = [85.0, 88.0, 91.0, 94.0, 97.0, 100.0, 103.0, 106.0, 109.0, 112.0, 115.0]
    
    let boundaryCases = [
        (84.9, "低于最低限值"),
        (85.0, "等于最低限值"),
        (85.1, "略高于最低限值"),
        (114.9, "略低于最高限值"),
        (115.0, "等于最高限值"),
        (115.1, "高于最高限值"),
        (120.0, "远高于最高限值")
    ]
    
    for (value, description) in boundaryCases {
        let targetLevel = findTargetLevel(for: value, in: nioshLevels)
        if let target = targetLevel {
            print("\(String(format: "%.1f", value)) dB (\(description)) → \(Int(target)) dB")
        } else {
            print("\(String(format: "%.1f", value)) dB (\(description)) → 无对应限值")
        }
    }
}

// MARK: - 性能测试

/// 测试分类算法的性能
func testPerformance() {
    print("\n=== 性能测试 ===\n")
    
    let nioshLevels = [85.0, 88.0, 91.0, 94.0, 97.0, 100.0, 103.0, 106.0, 109.0, 112.0, 115.0]
    
    // 生成大量测试数据
    let testCount = 10000
    let testData = (0..<testCount).map { _ in Double.random(in: 80...120) }
    
    let startTime = CFAbsoluteTimeGetCurrent()
    
    for value in testData {
        _ = findTargetLevel(for: value, in: nioshLevels)
    }
    
    let endTime = CFAbsoluteTimeGetCurrent()
    let duration = endTime - startTime
    
    print("处理 \(testCount) 个分贝值")
    print("耗时: \(String(format: "%.4f", duration)) 秒")
    print("平均每个: \(String(format: "%.6f", duration / Double(testCount))) 秒")
    print("每秒处理: \(String(format: "%.0f", Double(testCount) / duration)) 个")
}

// MARK: - 完整测试运行

/// 运行所有测试
func runAllTests() {
    testDecibelClassification()
    testWithMockData()
    testDifferentStandards()
    testBoundaryCases()
    testPerformance()
}

/*
测试输出示例：

=== 分贝值分类逻辑测试 ===

当前分贝值 → 归类到限值
------------------------
84 dB → 无对应限值
85 dB → 85 dB
86 dB → 85 dB
87 dB → 85 dB
88 dB → 88 dB
89 dB → 88 dB
90 dB → 88 dB
91 dB → 91 dB
92 dB → 91 dB
93 dB → 91 dB
94 dB → 94 dB
95 dB → 94 dB
96 dB → 94 dB
97 dB → 97 dB
98 dB → 97 dB
99 dB → 97 dB
100 dB → 100 dB
101 dB → 100 dB
102 dB → 100 dB
103 dB → 103 dB
104 dB → 103 dB
105 dB → 103 dB
106 dB → 106 dB
107 dB → 106 dB
108 dB → 106 dB
109 dB → 109 dB
110 dB → 109 dB
111 dB → 109 dB
112 dB → 112 dB
113 dB → 112 dB
114 dB → 112 dB
115 dB → 115 dB
116 dB → 115 dB

=== 模拟测量数据测试 ===

模拟测量数据:
时间		分贝值	归类到限值
----------------------------
09:00:01	86.0 dB	85 dB
09:00:02	87.2 dB	85 dB
09:00:03	89.1 dB	88 dB
09:00:04	91.0 dB	91 dB
09:00:05	92.8 dB	91 dB
09:00:06	95.3 dB	94 dB
09:00:07	98.1 dB	97 dB
09:00:08	100.0 dB	100 dB
09:00:09	102.4 dB	100 dB
09:00:10	105.7 dB	103 dB
09:00:11	108.2 dB	106 dB
09:00:12	110.8 dB	109 dB
09:00:13	113.5 dB	112 dB
09:00:14	116.0 dB	115 dB
09:00:15	85.0 dB	85 dB
09:00:16	88.0 dB	88 dB

=== 不同标准分类测试 ===

NIOSH 标准:
限值列表: 85, 88, 91, 94, 97, 100, 103, 106, 109, 112, 115 dB
  87 dB → 85 dB
  92 dB → 91 dB
  96 dB → 94 dB
  101 dB → 100 dB
  107 dB → 106 dB

OSHA 标准:
限值列表: 90, 95, 100, 105, 110, 115 dB
  87 dB → 无对应限值
  92 dB → 90 dB
  96 dB → 95 dB
  101 dB → 100 dB
  107 dB → 105 dB

EU 标准:
限值列表: 87, 90, 93, 96, 99, 102, 105, 108, 111, 114 dB
  87 dB → 87 dB
  92 dB → 90 dB
  96 dB → 96 dB
  101 dB → 99 dB
  107 dB → 105 dB

=== 边界情况测试 ===

84.9 dB (低于最低限值) → 无对应限值
85.0 dB (等于最低限值) → 85 dB
85.1 dB (略高于最低限值) → 85 dB
114.9 dB (略低于最高限值) → 112 dB
115.0 dB (等于最高限值) → 115 dB
115.1 dB (高于最高限值) → 115 dB
120.0 dB (远高于最高限值) → 115 dB

=== 性能测试 ===

处理 10000 个分贝值
耗时: 0.0123 秒
平均每个: 0.000001 秒
每秒处理: 813008 个
*/
