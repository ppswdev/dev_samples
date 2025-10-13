//
//  API使用示例.swift
//  DecibelMeterDemo
//
//  Created by AI Assistant on 2025/1/23.
//  这个文件展示了如何使用 DecibelMeterManager 的所有公共API
//

import Foundation
import SwiftUI

// MARK: - 使用示例

/// API使用示例类
class DecibelMeterAPIExample {
    
    let manager = DecibelMeterManager.shared
    
    // MARK: - 1. 获取状态值示例
    
    func exampleGetCurrentStatus() {
        print("=== 获取当前状态值 ===")
        
        // 1.1 获取测量状态
        let state = manager.getCurrentState()
        print("当前状态: \(state)")
        
        // 1.2 获取测量时长
        let formattedDuration = manager.getFormattedMeasurementDuration()
        let duration = manager.getMeasurementDuration()
        print("测量时长: \(formattedDuration) (\(duration)秒)")
        
        // 1.3 获取权重信息
        let freqWeighting = manager.getCurrentFrequencyWeighting()
        let timeWeighting = manager.getCurrentTimeWeighting()
        let weightingText = manager.getWeightingDisplayText()
        print("频率权重: \(freqWeighting)")
        print("时间权重: \(timeWeighting)")
        print("权重显示: \(weightingText)")
        
        // 1.4 获取校准值
        let calibration = manager.getCalibrationOffset()
        print("校准偏移: \(calibration) dB")
        
        // 1.5 获取分贝值
        let current = manager.getCurrentDecibel()
        let min = manager.getMinDecibel()
        let max = manager.getMaxDecibel()
        let peak = manager.getCurrentPeak()
        let leq = manager.getLeqDecibel()
        
        print("当前分贝: \(String(format: "%.1f", current)) dB")
        print("最小值: \(String(format: "%.1f", min)) dB")
        print("最大值: \(String(format: "%.1f", max)) dB")
        print("峰值: \(String(format: "%.1f", peak)) dB")
        print("LEQ: \(String(format: "%.1f", leq)) dB")
    }
    
    // MARK: - 2. 获取权重列表示例
    
    func exampleGetWeightingLists() {
        print("\n=== 获取权重列表 ===")
        
        // 2.1 获取频率权重列表
        let freqList = manager.getFrequencyWeightingsList()
        print("\n频率权重列表:")
        print("当前选择: \(freqList.currentSelection)")
        for option in freqList.options {
            print("- \(option.displayName): \(option.description)")
            print("  符号: \(option.symbol), 标准: \(option.standard)")
        }
        
        // 转换为JSON
        if let json = freqList.toJSON() {
            print("\n频率权重列表JSON:")
            print(json)
        }
        
        // 2.2 获取时间权重列表
        let timeList = manager.getTimeWeightingsList()
        print("\n时间权重列表:")
        print("当前选择: \(timeList.currentSelection)")
        for option in timeList.options {
            print("- \(option.displayName): \(option.description)")
            print("  符号: \(option.symbol), 标准: \(option.standard)")
        }
        
        // 转换为JSON
        if let json = timeList.toJSON() {
            print("\n时间权重列表JSON:")
            print(json)
        }
    }
    
    // MARK: - 3. 获取图表数据示例
    
    func exampleGetChartData() {
        print("\n=== 获取图表数据 ===")
        
        // 3.1 时间历程图数据
        let timeHistory = manager.getTimeHistoryChartData(timeRange: 60.0)
        print("\n时间历程图:")
        print("标题: \(timeHistory.title)")
        print("时间范围: \(timeHistory.timeRange)秒")
        print("分贝范围: \(timeHistory.minDecibel) - \(timeHistory.maxDecibel) dB")
        print("数据点数量: \(timeHistory.dataPoints.count)")
        
        if let json = timeHistory.toJSON() {
            print("JSON长度: \(json.count) 字符")
        }
        
        // 3.2 实时指示器数据
        let indicator = manager.getRealTimeIndicatorData()
        print("\n实时指示器:")
        print("当前: \(String(format: "%.1f", indicator.currentDecibel)) dB")
        print("LEQ: \(String(format: "%.1f", indicator.leq)) dB")
        print("MIN: \(String(format: "%.1f", indicator.min)) dB")
        print("MAX: \(String(format: "%.1f", indicator.max)) dB")
        print("PEAK: \(String(format: "%.1f", indicator.peak)) dB")
        print("权重: \(indicator.weightingDisplay)")
        
        if let json = indicator.toJSON() {
            print("JSON: \(json)")
        }
        
        // 3.3 频谱分析图数据
        let spectrum1_1 = manager.getSpectrumChartData(bandType: "1/1")
        print("\n频谱分析图 (1/1倍频程):")
        print("标题: \(spectrum1_1.title)")
        print("频率范围: \(spectrum1_1.frequencyRange.min) - \(spectrum1_1.frequencyRange.max) Hz")
        print("数据点数量: \(spectrum1_1.dataPoints.count)")
        
        let spectrum1_3 = manager.getSpectrumChartData(bandType: "1/3")
        print("\n频谱分析图 (1/3倍频程):")
        print("标题: \(spectrum1_3.title)")
        print("数据点数量: \(spectrum1_3.dataPoints.count)")
        
        // 3.4 统计分布图数据
        let distribution = manager.getStatisticalDistributionChartData()
        print("\n统计分布图:")
        print("标题: \(distribution.title)")
        print("L10: \(String(format: "%.1f", distribution.l10)) dB")
        print("L50: \(String(format: "%.1f", distribution.l50)) dB")
        print("L90: \(String(format: "%.1f", distribution.l90)) dB")
        print("数据点数量: \(distribution.dataPoints.count)")
        
        // 3.5 LEQ趋势图数据
        let leqTrend = manager.getLEQTrendChartData(interval: 10.0)
        print("\nLEQ趋势图:")
        print("标题: \(leqTrend.title)")
        print("时间范围: \(leqTrend.timeRange)秒")
        print("当前LEQ: \(String(format: "%.1f", leqTrend.currentLeq)) dB")
        print("数据点数量: \(leqTrend.dataPoints.count)")
    }
    
    // MARK: - 4. 设置方法示例
    
    func exampleSetMethods() {
        print("\n=== 设置方法示例 ===")
        
        // 4.1 设置频率权重
        print("\n设置频率权重为A权重:")
        manager.setFrequencyWeighting(.aWeight)
        print("当前权重: \(manager.getWeightingDisplayText())")
        
        // 4.2 设置时间权重
        print("\n设置时间权重为Slow:")
        manager.setTimeWeighting(.slow)
        print("当前权重: \(manager.getWeightingDisplayText())")
        
        // 4.3 设置校准偏移
        print("\n设置校准偏移为+2.5dB:")
        manager.setCalibrationOffset(2.5)
        print("当前校准: \(manager.getCalibrationOffset()) dB")
        
        // 4.4 重置所有数据
        print("\n重置所有数据:")
        manager.resetAllData()
        print("状态: \(manager.getCurrentState())")
        print("分贝值: \(manager.getCurrentDecibel())")
        print("校准: \(manager.getCalibrationOffset())")
    }
    
    // MARK: - 5. 完整工作流示例
    
    func exampleCompleteWorkflow() async {
        print("\n=== 完整工作流示例 ===")
        
        // 5.1 开始测量
        print("\n1. 开始测量...")
        await manager.startMeasurement()
        
        // 5.2 等待一段时间
        print("2. 测量中...")
        try? await Task.sleep(nanoseconds: 5_000_000_000) // 5秒
        
        // 5.3 获取实时数据
        print("\n3. 获取实时数据:")
        let indicator = manager.getRealTimeIndicatorData()
        print("当前: \(String(format: "%.1f", indicator.currentDecibel)) \(indicator.weightingDisplay)")
        print("LEQ: \(String(format: "%.1f", indicator.leq)) dB")
        
        // 5.4 获取图表数据
        print("\n4. 获取图表数据:")
        let chartData = manager.getTimeHistoryChartData(timeRange: 60.0)
        print("时间历程图数据点: \(chartData.dataPoints.count)")
        
        let spectrum = manager.getSpectrumChartData(bandType: "1/3")
        print("频谱数据点: \(spectrum.dataPoints.count)")
        
        // 5.5 切换权重
        print("\n5. 切换权重为C权重+Fast:")
        manager.setFrequencyWeighting(.cWeight)
        manager.setTimeWeighting(.fast)
        print("新权重: \(manager.getWeightingDisplayText())")
        
        // 5.6 继续测量一段时间
        try? await Task.sleep(nanoseconds: 3_000_000_000) // 3秒
        
        // 5.7 停止测量
        print("\n6. 停止测量...")
        manager.stopMeasurement()
        
        // 5.8 获取最终统计
        print("\n7. 最终统计:")
        let finalIndicator = manager.getRealTimeIndicatorData()
        print("测量时长: \(manager.getFormattedMeasurementDuration())")
        print("LEQ: \(String(format: "%.1f", finalIndicator.leq)) dB")
        print("MIN: \(String(format: "%.1f", finalIndicator.min)) dB")
        print("MAX: \(String(format: "%.1f", finalIndicator.max)) dB")
        print("PEAK: \(String(format: "%.1f", finalIndicator.peak)) dB")
        
        // 5.9 导出数据
        print("\n8. 导出数据为JSON:")
        if let json = finalIndicator.toJSON() {
            print(json)
        }
        
        // 5.10 重置
        print("\n9. 重置所有数据...")
        manager.resetAllData()
        print("状态: \(manager.getCurrentState())")
    }
    
    // MARK: - 6. 图表绘制示例（SwiftUI）
    
    func exampleSwiftUICharts() -> some View {
        VStack {
            // 6.1 时间历程图
            TimeHistoryChartView()
            
            // 6.2 频谱分析图
            SpectrumChartView()
            
            // 6.3 统计分布图
            StatisticalDistributionChartView()
            
            // 6.4 LEQ趋势图
            LEQTrendChartView()
        }
    }
}

// MARK: - SwiftUI图表视图示例

/// 时间历程图视图示例
struct TimeHistoryChartView: View {
    @State private var chartData: TimeHistoryChartData?
    let manager = DecibelMeterManager.shared
    
    var body: some View {
        VStack {
            Text("时间历程图")
                .font(.headline)
            
            if let data = chartData {
                // 使用Swift Charts绘制
                // Chart {
                //     ForEach(data.dataPoints) { point in
                //         LineMark(
                //             x: .value("时间", point.timestamp),
                //             y: .value("分贝", point.decibel)
                //         )
                //     }
                // }
                
                Text("数据点: \(data.dataPoints.count)")
                Text("范围: \(String(format: "%.1f", data.minDecibel)) - \(String(format: "%.1f", data.maxDecibel)) dB")
            }
        }
        .onAppear {
            updateChartData()
        }
    }
    
    func updateChartData() {
        chartData = manager.getTimeHistoryChartData(timeRange: 60.0)
    }
}

/// 频谱分析图视图示例
struct SpectrumChartView: View {
    @State private var chartData: SpectrumChartData?
    @State private var bandType: String = "1/3"
    let manager = DecibelMeterManager.shared
    
    var body: some View {
        VStack {
            Text("频谱分析图")
                .font(.headline)
            
            Picker("倍频程", selection: $bandType) {
                Text("1/1").tag("1/1")
                Text("1/3").tag("1/3")
            }
            .pickerStyle(.segmented)
            .onChange(of: bandType) { _ in
                updateChartData()
            }
            
            if let data = chartData {
                // 使用Swift Charts绘制
                // Chart {
                //     ForEach(data.dataPoints) { point in
                //         BarMark(
                //             x: .value("频率", point.frequency),
                //             y: .value("声压级", point.magnitude)
                //         )
                //     }
                // }
                
                Text("频率范围: \(Int(data.frequencyRange.min)) - \(Int(data.frequencyRange.max)) Hz")
                Text("数据点: \(data.dataPoints.count)")
            }
        }
        .onAppear {
            updateChartData()
        }
    }
    
    func updateChartData() {
        chartData = manager.getSpectrumChartData(bandType: bandType)
    }
}

/// 统计分布图视图示例
struct StatisticalDistributionChartView: View {
    @State private var chartData: StatisticalDistributionChartData?
    let manager = DecibelMeterManager.shared
    
    var body: some View {
        VStack {
            Text("统计分布图")
                .font(.headline)
            
            if let data = chartData {
                HStack(spacing: 20) {
                    VStack {
                        Text("L10")
                        Text(String(format: "%.1f", data.l10))
                            .font(.title2)
                    }
                    VStack {
                        Text("L50")
                        Text(String(format: "%.1f", data.l50))
                            .font(.title2)
                    }
                    VStack {
                        Text("L90")
                        Text(String(format: "%.1f", data.l90))
                            .font(.title2)
                    }
                }
                
                // 使用Swift Charts绘制
                // Chart {
                //     ForEach(data.dataPoints) { point in
                //         BarMark(
                //             x: .value("百分位", point.percentile),
                //             y: .value("分贝", point.decibel)
                //         )
                //     }
                // }
            }
        }
        .onAppear {
            updateChartData()
        }
    }
    
    func updateChartData() {
        chartData = manager.getStatisticalDistributionChartData()
    }
}

/// LEQ趋势图视图示例
struct LEQTrendChartView: View {
    @State private var chartData: LEQTrendChartData?
    let manager = DecibelMeterManager.shared
    
    var body: some View {
        VStack {
            Text("LEQ趋势图")
                .font(.headline)
            
            if let data = chartData {
                Text("当前LEQ: \(String(format: "%.1f", data.currentLeq)) dB")
                    .font(.title2)
                
                // 使用Swift Charts绘制
                // Chart {
                //     ForEach(data.dataPoints) { point in
                //         LineMark(
                //             x: .value("时间", point.timestamp),
                //             y: .value("LEQ", point.cumulativeLeq)
                //         )
                //         .foregroundStyle(.blue)
                //     }
                // }
                
                Text("时间范围: \(String(format: "%.1f", data.timeRange))秒")
                Text("数据点: \(data.dataPoints.count)")
            }
        }
        .onAppear {
            updateChartData()
        }
    }
    
    func updateChartData() {
        chartData = manager.getLEQTrendChartData(interval: 10.0)
    }
}

// MARK: - 7. 数据导出示例

extension DecibelMeterAPIExample {
    
    /// 导出所有图表数据为JSON文件
    func exportAllChartDataToJSON() {
        print("\n=== 导出所有图表数据 ===")
        
        let allData: [String: String?] = [
            "timeHistory": manager.getTimeHistoryChartData().toJSON(),
            "spectrum_1_1": manager.getSpectrumChartData(bandType: "1/1").toJSON(),
            "spectrum_1_3": manager.getSpectrumChartData(bandType: "1/3").toJSON(),
            "distribution": manager.getStatisticalDistributionChartData().toJSON(),
            "leqTrend": manager.getLEQTrendChartData().toJSON(),
            "indicator": manager.getRealTimeIndicatorData().toJSON(),
            "frequencyWeightings": manager.getFrequencyWeightingsList().toJSON(),
            "timeWeightings": manager.getTimeWeightingsList().toJSON()
        ]
        
        for (key, json) in allData {
            if let json = json {
                print("\n[\(key)]:")
                print("JSON长度: \(json.count) 字符")
                
                // 保存到文件
                if let data = json.data(using: .utf8) {
                    let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        .appendingPathComponent("\(key).json")
                    try? data.write(to: url)
                    print("已保存到: \(url.lastPathComponent)")
                }
            }
        }
    }
    
    /// 从JSON恢复数据示例
    func restoreFromJSON() {
        print("\n=== 从JSON恢复数据 ===")
        
        // 示例JSON字符串
        let jsonString = """
        {
            "currentDecibel": 72.5,
            "leq": 70.3,
            "min": 60.2,
            "max": 85.7,
            "peak": 92.1,
            "weightingDisplay": "dB(A)F",
            "timestamp": "2025-01-23T10:30:00Z"
        }
        """
        
        if let indicator = RealTimeIndicatorData.fromJSON(jsonString) {
            print("恢复成功:")
            print("当前: \(indicator.currentDecibel) dB")
            print("LEQ: \(indicator.leq) dB")
            print("权重: \(indicator.weightingDisplay)")
        }
    }
}

// MARK: - 8. 实时监控示例

class RealTimeMonitor: ObservableObject {
    @Published var currentStatus: String = ""
    @Published var chartData: TimeHistoryChartData?
    
    let manager = DecibelMeterManager.shared
    var timer: Timer?
    
    func startMonitoring() {
        // 每秒更新一次
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateData()
        }
    }
    
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateData() {
        // 获取实时指示器数据
        let indicator = manager.getRealTimeIndicatorData()
        currentStatus = """
        \(indicator.weightingDisplay)
        当前: \(String(format: "%.1f", indicator.currentDecibel)) dB
        LEQ: \(String(format: "%.1f", indicator.leq)) dB
        MIN: \(String(format: "%.1f", indicator.min)) dB
        MAX: \(String(format: "%.1f", indicator.max)) dB
        PEAK: \(String(format: "%.1f", indicator.peak)) dB
        """
        
        // 每5秒更新一次图表数据
        if Int(Date().timeIntervalSince1970) % 5 == 0 {
            chartData = manager.getTimeHistoryChartData(timeRange: 60.0)
        }
    }
}

