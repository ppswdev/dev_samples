//
//  允许暴露时长表格式化示例.swift
//  DecibelMeterDemo
//
//  展示如何格式化输出允许暴露时长表
//

import Foundation

// MARK: - 格式化输出示例

/// 示例：标准表格格式输出
func printFormattedExposureTable() {
    let manager = DecibelMeterManager.shared
    
    // 获取NIOSH标准的暴露时长表
    let table = manager.getPermissibleExposureDurationTable(standard: .niosh)
    
    print("=== 允许暴露时长表 ===")
    print("标准: \(table.standard.rawValue)")
    print()
    print("声级\t\t允许时长\t\t累计达标时长(秒)\t当前声级剂量")
    print("------------------------------------------------------------")
    
    for duration in table.durations {
        let soundLevel = String(format: "%.0f dB", duration.soundLevel)
        let allowedTime = formatTimeToHours(duration.allowedDuration)
        let accumulated = String(format: "%.0f", duration.accumulatedDuration)
        let dose = String(format: "%.1f%%", duration.currentLevelDose)
        
        print("\(soundLevel)\t\t\(allowedTime)\t\t\(accumulated)\t\t\t\(dose)")
    }
    
    print("------------------------------------------------------------")
    print("总剂量: \(String(format: "%.1f%%", table.totalDose))")
}

/// 格式化时间为小时显示（如：8h, 4h, 2h, 1h, 30min等）
func formatTimeToHours(_ seconds: TimeInterval) -> String {
    let hours = seconds / 3600.0
    
    if hours >= 1.0 {
        return String(format: "%.0fh", hours)
    } else {
        let minutes = seconds / 60.0
        return String(format: "%.0fmin", minutes)
    }
}

// MARK: - 数据结构示例

/// 表格行数据结构
struct ExposureTableRow {
    let soundLevel: String      // 声级（如："85dB"）
    let allowedDuration: String // 允许时长（如："8h"）
    let accumulatedSeconds: Int // 累计达标时长（秒）
    let currentDose: String     // 当前声级剂量（如："10%"）
}

/// 获取格式化的表格数据
func getFormattedTableData(standard: NoiseStandard = .niosh) -> [ExposureTableRow] {
    let manager = DecibelMeterManager.shared
    let table = manager.getPermissibleExposureDurationTable(standard: standard)
    
    return table.durations.map { duration in
        ExposureTableRow(
            soundLevel: String(format: "%.0fdB", duration.soundLevel),
            allowedDuration: formatTimeToHours(duration.allowedDuration),
            accumulatedSeconds: Int(duration.accumulatedDuration),
            currentDose: String(format: "%.1f%%", duration.currentLevelDose)
        )
    }
}

/// 示例：打印格式化的表格数据
func printTableRows() {
    let rows = getFormattedTableData(standard: .niosh)
    
    print("声级\t\t允许时长\t\t累计达标时长(秒)\t当前声级剂量")
    print("------------------------------------------------------------")
    
    for row in rows {
        print("\(row.soundLevel)\t\t\(row.allowedDuration)\t\t\(row.accumulatedSeconds)\t\t\t\(row.currentDose)")
    }
}

// MARK: - 实际输出示例

/*
输出示例：

=== 允许暴露时长表 ===
标准: NIOSH

声级		允许时长		累计达标时长(秒)	当前声级剂量
------------------------------------------------------------
85dB		8h			300				6.3%
88dB		4h			450				18.8%
91dB		2h			200				16.7%
94dB		1h			120				20.0%
97dB		30min		60				20.0%
100dB		15min		30				20.0%
103dB		8min		0				0.0%
106dB		4min		0				0.0%
109dB		2min		0				0.0%
112dB		1min		0				0.0%
115dB		28s			0				0.0%
------------------------------------------------------------
总剂量: 101.8%
*/

// MARK: - JSON格式输出

/// 获取JSON格式的表格数据
func getTableDataAsJSON(standard: NoiseStandard = .niosh) -> String? {
    let manager = DecibelMeterManager.shared
    let table = manager.getPermissibleExposureDurationTable(standard: standard)
    
    // 构建简化的数据结构
    let simplifiedData = table.durations.map { duration -> [String: Any] in
        return [
            "soundLevel": String(format: "%.0fdB", duration.soundLevel),
            "allowedDuration": formatTimeToHours(duration.allowedDuration),
            "accumulatedSeconds": Int(duration.accumulatedDuration),
            "currentDose": String(format: "%.1f%%", duration.currentLevelDose)
        ]
    }
    
    let result: [String: Any] = [
        "standard": table.standard.rawValue,
        "totalDose": String(format: "%.1f%%", table.totalDose),
        "data": simplifiedData
    ]
    
    if let jsonData = try? JSONSerialization.data(withJSONObject: result, options: .prettyPrinted),
       let jsonString = String(data: jsonData, encoding: .utf8) {
        return jsonString
    }
    
    return nil
}

/// 示例：打印JSON格式
func printTableAsJSON() {
    if let json = getTableDataAsJSON(standard: .niosh) {
        print("=== JSON格式 ===")
        print(json)
    }
}

/*
JSON输出示例：

{
  "standard" : "NIOSH",
  "totalDose" : "101.8%",
  "data" : [
    {
      "soundLevel" : "85dB",
      "allowedDuration" : "8h",
      "accumulatedSeconds" : 300,
      "currentDose" : "6.3%"
    },
    {
      "soundLevel" : "88dB",
      "allowedDuration" : "4h",
      "accumulatedSeconds" : 450,
      "currentDose" : "18.8%"
    },
    ...
  ]
}
*/

// MARK: - CSV格式输出

/// 获取CSV格式的表格数据
func getTableDataAsCSV(standard: NoiseStandard = .niosh) -> String {
    let manager = DecibelMeterManager.shared
    let table = manager.getPermissibleExposureDurationTable(standard: standard)
    
    var csv = "声级,允许时长,累计达标时长(秒),当前声级剂量\n"
    
    for duration in table.durations {
        let soundLevel = String(format: "%.0fdB", duration.soundLevel)
        let allowedTime = formatTimeToHours(duration.allowedDuration)
        let accumulated = String(format: "%.0f", duration.accumulatedDuration)
        let dose = String(format: "%.1f%%", duration.currentLevelDose)
        
        csv += "\(soundLevel),\(allowedTime),\(accumulated),\(dose)\n"
    }
    
    csv += "\n总剂量,,,\(String(format: "%.1f%%", table.totalDose))\n"
    
    return csv
}

/// 示例：打印CSV格式
func printTableAsCSV() {
    let csv = getTableDataAsCSV(standard: .niosh)
    print("=== CSV格式 ===")
    print(csv)
}

/*
CSV输出示例：

声级,允许时长,累计达标时长(秒),当前声级剂量
85dB,8h,300,6.3%
88dB,4h,450,18.8%
91dB,2h,200,16.7%
94dB,1h,120,20.0%
97dB,30min,60,20.0%
100dB,15min,30,20.0%
103dB,8min,0,0.0%
106dB,4min,0,0.0%
109dB,2min,0,0.0%
112dB,1min,0,0.0%
115dB,28s,0,0.0%

总剂量,,,101.8%
*/

// MARK: - SwiftUI表格视图

#if canImport(SwiftUI)
import SwiftUI

/// 简洁的表格视图
struct SimpleExposureTableView: View {
    let table: PermissibleExposureDurationTable
    
    var body: some View {
        VStack(spacing: 0) {
            // 表头
            HStack {
                Text("声级")
                    .frame(width: 60, alignment: .leading)
                Text("允许时长")
                    .frame(width: 80, alignment: .leading)
                Text("累计时长(秒)")
                    .frame(width: 100, alignment: .trailing)
                Text("剂量")
                    .frame(width: 60, alignment: .trailing)
            }
            .font(.caption)
            .fontWeight(.bold)
            .padding(8)
            .background(Color.gray.opacity(0.2))
            
            Divider()
            
            // 数据行
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(table.durations) { duration in
                        HStack {
                            Text(String(format: "%.0fdB", duration.soundLevel))
                                .frame(width: 60, alignment: .leading)
                            
                            Text(formatTimeToHours(duration.allowedDuration))
                                .frame(width: 80, alignment: .leading)
                            
                            Text(String(format: "%.0f", duration.accumulatedDuration))
                                .frame(width: 100, alignment: .trailing)
                            
                            Text(String(format: "%.1f%%", duration.currentLevelDose))
                                .frame(width: 60, alignment: .trailing)
                                .foregroundColor(doseColor(duration.currentLevelDose))
                        }
                        .font(.system(.body, design: .monospaced))
                        .padding(.vertical, 6)
                        .padding(.horizontal, 8)
                        
                        if duration.id != table.durations.last?.id {
                            Divider()
                        }
                    }
                }
            }
            
            Divider()
            
            // 总剂量
            HStack {
                Text("总剂量")
                    .fontWeight(.bold)
                Spacer()
                Text(String(format: "%.1f%%", table.totalDose))
                    .fontWeight(.bold)
                    .foregroundColor(doseColor(table.totalDose))
            }
            .padding(8)
            .background(Color.gray.opacity(0.1))
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

/// 使用示例
struct ExposureTablePreview: View {
    var body: some View {
        let manager = DecibelMeterManager.shared
        let table = manager.getPermissibleExposureDurationTable(standard: .niosh)
        
        SimpleExposureTableView(table: table)
    }
}
#endif

