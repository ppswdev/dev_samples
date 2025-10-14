//
//  允许暴露时长表使用示例.swift
//  DecibelMeterDemo
//
//  本文件展示如何使用允许暴露时长表API
//

import Foundation

// MARK: - 使用示例

/// 示例1：获取并打印允许暴露时长表
func example1_PrintExposureTable() {
    let manager = DecibelMeterManager.shared
    
    // 获取NIOSH标准的允许暴露时长表
    let table = manager.getPermissibleExposureDurationTable(standard: .niosh)
    
    print("=== 允许暴露时长表 ===")
    print("标准: \(table.standard.rawValue)")
    print("基准限值: \(table.criterionLevel) dB")
    print("交换率: \(table.exchangeRate) dB")
    print("天花板限值: \(table.ceilingLimit) dB")
    print("总剂量: \(String(format: "%.1f", table.totalDose))%")
    print("超标声级数: \(table.exceedingLevelsCount)")
    print("有暴露记录的声级数: \(table.exposedLevelsCount)")
    print("\n声级 | 允许时长 | 累计时长 | 剂量 | 状态")
    print("-----|----------|----------|------|------")
    
    for duration in table.durations {
        let status = duration.isExceeding ? "⚠️超标" : 
                     duration.accumulatedDuration > 0 ? "✓已暴露" : "-"
        print("\(String(format: "%.0f", duration.soundLevel)) dB | \(duration.formattedAllowedDuration) | \(duration.formattedAccumulatedDuration) | \(String(format: "%.1f", duration.currentLevelDose))% | \(status)")
    }
}

/// 示例2：比较不同标准的暴露时长表
func example2_CompareStandards() {
    let manager = DecibelMeterManager.shared
    
    print("=== 不同标准对比 ===\n")
    
    for standard in NoiseStandard.allCases {
        let table = manager.getPermissibleExposureDurationTable(standard: standard)
        
        print("\(standard.rawValue) 标准:")
        print("  基准限值: \(table.criterionLevel) dB")
        print("  交换率: \(table.exchangeRate) dB")
        print("  总剂量: \(String(format: "%.1f", table.totalDose))%")
        print("  超标声级数: \(table.exceedingLevelsCount)")
        print("  风险等级: \(table.totalDose < 50 ? "🟢低" : table.totalDose < 100 ? "🟡中" : table.totalDose < 200 ? "🟠高" : "🔴极高")")
        print()
    }
}

/// 示例3：分析特定声级的暴露情况
func example3_AnalyzeSpecificLevel() {
    let manager = DecibelMeterManager.shared
    let table = manager.getPermissibleExposureDurationTable(standard: .niosh)
    
    // 找到90dB的暴露情况
    if let level90 = table.durations.first(where: { $0.soundLevel == 90.0 }) {
        print("=== 90 dB 暴露分析 ===")
        print("允许暴露时长: \(level90.formattedAllowedDuration)")
        print("累计暴露时长: \(level90.formattedAccumulatedDuration)")
        print("剩余允许时长: \(level90.formattedRemainingDuration)")
        print("当前剂量贡献: \(String(format: "%.1f", level90.currentLevelDose))%")
        print("是否超标: \(level90.isExceeding ? "是" : "否")")
        
        if level90.accumulatedDuration > 0 {
            let percentage = (level90.accumulatedDuration / level90.allowedDuration) * 100
            print("已使用允许时长的 \(String(format: "%.1f", percentage))%")
        }
    }
}

/// 示例4：导出为JSON
func example4_ExportToJSON() {
    let manager = DecibelMeterManager.shared
    let table = manager.getPermissibleExposureDurationTable(standard: .niosh)
    
    if let json = table.toJSON() {
        print("=== JSON导出 ===")
        print(json)
        
        // 可以保存到文件
        // let fileURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        //     .appendingPathComponent("exposure_table.json")
        // try? json.write(to: fileURL, atomically: true, encoding: .utf8)
    }
}

/// 示例5：实时监控暴露情况
func example5_MonitorExposure() {
    let manager = DecibelMeterManager.shared
    
    // 定期检查暴露情况（例如每分钟）
    Timer.scheduledTimer(withTimeInterval: 60.0, repeats: true) { _ in
        let table = manager.getPermissibleExposureDurationTable(standard: .niosh)
        
        // 检查是否有超标的声级
        let exceedingLevels = table.durations.filter { $0.isExceeding }
        
        if !exceedingLevels.isEmpty {
            print("⚠️ 警告：以下声级已超标")
            for level in exceedingLevels {
                print("  \(level.soundLevel) dB: 累计 \(level.formattedAccumulatedDuration) / 允许 \(level.formattedAllowedDuration)")
            }
        }
        
        // 检查总剂量
        if table.totalDose >= 100.0 {
            print("🔴 严重警告：总剂量已达 \(String(format: "%.1f", table.totalDose))%，已超过100%限值！")
        } else if table.totalDose >= 80.0 {
            print("🟠 警告：总剂量已达 \(String(format: "%.1f", table.totalDose))%，接近限值！")
        } else if table.totalDose >= 50.0 {
            print("🟡 提示：总剂量已达 \(String(format: "%.1f", table.totalDose))%")
        }
    }
}

/// 示例6：生成暴露报告
func example6_GenerateReport() {
    let manager = DecibelMeterManager.shared
    let table = manager.getPermissibleExposureDurationTable(standard: .niosh)
    
    print("=== 噪声暴露报告 ===")
    print("生成时间: \(Date())")
    print("标准: \(table.standard.fullName)")
    print()
    
    print("总体情况:")
    print("  总剂量: \(String(format: "%.1f", table.totalDose))%")
    print("  有暴露记录的声级: \(table.exposedLevelsCount) 个")
    print("  超标声级: \(table.exceedingLevelsCount) 个")
    print()
    
    print("详细暴露情况:")
    let exposedLevels = table.durations.filter { $0.accumulatedDuration > 0 }
    for level in exposedLevels {
        print("  \(String(format: "%.0f", level.soundLevel)) dB:")
        print("    累计暴露: \(level.formattedAccumulatedDuration)")
        print("    允许时长: \(level.formattedAllowedDuration)")
        print("    剂量贡献: \(String(format: "%.1f", level.currentLevelDose))%")
        print("    状态: \(level.isExceeding ? "⚠️超标" : "✓正常")")
    }
    
    print()
    print("建议措施:")
    if table.totalDose >= 100.0 {
        print("  - 立即停止暴露或采取有效防护措施")
        print("  - 必须佩戴听力保护设备")
        print("  - 建议进行听力检查")
    } else if table.totalDose >= 80.0 {
        print("  - 建议佩戴听力保护设备")
        print("  - 减少高噪声环境暴露时间")
    } else if table.totalDose >= 50.0 {
        print("  - 注意控制暴露时间")
        print("  - 考虑使用听力保护设备")
    } else {
        print("  - 当前暴露水平在安全范围内")
        print("  - 继续保持良好的听力保护习惯")
    }
}

// MARK: - SwiftUI视图示例

#if canImport(SwiftUI)
import SwiftUI

/// 示例7：SwiftUI列表视图
struct ExposureTableView: View {
    let table: PermissibleExposureDurationTable
    
    var body: some View {
        List {
            Section(header: Text("总体情况")) {
                HStack {
                    Text("标准")
                    Spacer()
                    Text(table.standard.rawValue)
                        .foregroundColor(.secondary)
                }
                
                HStack {
                    Text("总剂量")
                    Spacer()
                    Text(String(format: "%.1f%%", table.totalDose))
                        .foregroundColor(doseColor(table.totalDose))
                        .bold()
                }
                
                HStack {
                    Text("超标声级数")
                    Spacer()
                    Text("\(table.exceedingLevelsCount)")
                        .foregroundColor(table.exceedingLevelsCount > 0 ? .red : .green)
                }
            }
            
            Section(header: Text("声级暴露详情")) {
                ForEach(table.durations.filter { $0.accumulatedDuration > 0 }) { duration in
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("\(String(format: "%.0f", duration.soundLevel)) dB")
                                .font(.headline)
                            Spacer()
                            if duration.isExceeding {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        HStack {
                            Text("累计: \(duration.formattedAccumulatedDuration)")
                                .font(.caption)
                            Spacer()
                            Text("允许: \(duration.formattedAllowedDuration)")
                                .font(.caption)
                        }
                        
                        ProgressView(value: min(duration.currentLevelDose, 100.0), total: 100.0)
                            .tint(doseColor(duration.currentLevelDose))
                        
                        Text("剂量: \(String(format: "%.1f%%", duration.currentLevelDose))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 4)
                }
            }
        }
        .navigationTitle("暴露时长表")
    }
    
    private func doseColor(_ dose: Double) -> Color {
        if dose >= 100 {
            return .red
        } else if dose >= 80 {
            return .orange
        } else if dose >= 50 {
            return .yellow
        } else {
            return .green
        }
    }
}
#endif

