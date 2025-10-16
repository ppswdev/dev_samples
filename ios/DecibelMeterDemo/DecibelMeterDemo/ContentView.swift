//
//  ContentView.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/1/23.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = DecibelMeterViewModel()
    @State private var showingSettings = false
    @State private var showingHistory = false
    @State private var showingFrequencyWeightingSheet = false
    @State private var showingTimeWeightingSheet = false
    @State private var showingCalibrationSheet = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 标题
                Text("分贝测量仪")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // 主要显示区域
                VStack(spacing: 30) {
                    // 分贝值显示
                    DecibelDisplayView(
                        decibel: viewModel.currentDecibel,
                        measurement: viewModel.currentMeasurement,
                        frequencyWeighting: viewModel.currentFrequencyWeighting,
                        timeWeighting: viewModel.currentTimeWeighting
                    )
                    
                    // 状态指示器
                    StatusIndicatorView(state: viewModel.measurementState)
                    
                    // 后台状态指示器
                    if viewModel.isAppInBackground {
                        BackgroundStatusView(
                            backgroundTimeRemaining: viewModel.backgroundTimeRemaining
                        )
                    }
                    
                    // 测量时长
                    DurationView(duration: viewModel.getFormattedDuration())
                    
                    // 统计信息
                    EnhancedStatisticsView(
                        currentDecibel: viewModel.currentDecibel,
                        leqDecibel: viewModel.leqDecibel,
                        maxDecibel: viewModel.maxDecibel,
                        minDecibel: viewModel.minDecibel,
                        peakDecibel: viewModel.peakDecibel,
                        isRecording: viewModel.isRecording
                    )
                }
                .padding()
                
                Spacer()
                
                // 控制按钮
                EnhancedControlButtonsView(
                    isRecording: viewModel.isRecording,
                    measurementState: viewModel.measurementState,
                    onStart: {
                        viewModel.startMeasurement()
                    },
                    onStop: {
                        viewModel.stopMeasurement()
                    },
                    onReset: {
                        viewModel.resetAllData()
                    }
                )
                
                Spacer()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("历史") {
                        showingHistory = true
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("设置") {
                        showingSettings = true
                    }
                }
            })
        }
        .sheet(isPresented: $showingSettings) {
            SettingsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingHistory) {
            HistoryView(viewModel: viewModel)
        }
        .confirmationDialog("设置选项", isPresented: $showingSettings) {
            Button("频率权重 (\(viewModel.currentFrequencyWeighting.rawValue))") {
                showingFrequencyWeightingSheet = true
            }
            Button("时间权重 (\(viewModel.currentTimeWeighting.rawValue))") {
                showingTimeWeightingSheet = true
            }
            Button("校准") {
                showingCalibrationSheet = true
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("选择要调整的设置")
        }
        .confirmationDialog("选择频率权重", isPresented: $showingFrequencyWeightingSheet) {
            ForEach(viewModel.getAvailableFrequencyWeightings(), id: \.self) { weighting in
                Button(weighting.rawValue) {
                    viewModel.setFrequencyWeighting(weighting)
                }
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("当前: \(viewModel.currentFrequencyWeighting.rawValue)")
        }
        .confirmationDialog("选择时间权重", isPresented: $showingTimeWeightingSheet) {
            ForEach(viewModel.getAvailableTimeWeightings(), id: \.self) { weighting in
                Button(weighting.rawValue) {
                    viewModel.setTimeWeighting(weighting)
                }
            }
            Button("取消", role: .cancel) { }
        } message: {
            Text("当前: \(viewModel.currentTimeWeighting.rawValue)")
        }
        .sheet(isPresented: $showingCalibrationSheet) {
            CalibrationView(viewModel: viewModel)
        }
    }
}

// MARK: - 分贝显示视图

struct DecibelDisplayView: View {
    let decibel: Double
    let measurement: DecibelMeasurement?
    let frequencyWeighting: FrequencyWeighting
    let timeWeighting: TimeWeighting
    
    var body: some View {
        VStack(spacing: 10) {
            // 分贝数值
            Text(String(format: "%.1f", decibel))
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(decibelColor)

            // 等级描述
            if let measurement = measurement {
                Text(measurement.levelDescription)
                    .font(.title3)
                    .foregroundColor(decibelColor)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(decibelColor.opacity(0.1))
                    .cornerRadius(20)
            }
        }
    }
    
    /// 生成带权重信息的单位显示
    private var weightedUnitDisplay: String {
        let freqWeight = frequencyWeighting.displaySymbol
        let timeWeight = timeWeighting.displaySymbol
        
        // 格式：dB(频率权重)时间权重，如 dB(A)F, dB(C)S, dB(Z)I
        return "dB(\(freqWeight))\(timeWeight)"
    }
    
    private var decibelColor: Color {
        switch decibel {
        case 0..<50:
            return .green
        case 50..<70:
            return .yellow
        case 70..<85:
            return .orange
        case 85..<100:
            return .red
        case 100...:
            return .purple
        default:
            return .gray
        }
    }
}

// MARK: - 状态指示器视图

struct StatusIndicatorView: View {
    let state: MeasurementState
    
    var body: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 12, height: 12)
                .scaleEffect(isAnimating ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true), value: isAnimating)
            
            Text(statusText)
                .font(.headline)
                .foregroundColor(statusColor)
        }
    }
    
    private var statusColor: Color {
        switch state {
        case .idle:
            return .gray
        case .measuring:
            return .green
        case .error:
            return .red
        }
    }
    
    private var statusText: String {
        switch state {
        case .idle:
            return "待机"
        case .measuring:
            return "测量中"
        case .error(let message):
            return "错误: \(message)"
        }
    }
    
    private var isAnimating: Bool {
        switch state {
        case .measuring:
            return true
        default:
            return false
        }
    }
}

// MARK: - 后台状态视图

struct BackgroundStatusView: View {
    let backgroundTimeRemaining: TimeInterval
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "moon.fill")
                .foregroundColor(.orange)
                .font(.caption)
            
            Text("后台运行中")
                .font(.caption)
                .foregroundColor(.orange)
            
            if backgroundTimeRemaining > 0 && backgroundTimeRemaining < .greatestFiniteMagnitude {
                Text("(剩余 \(Int(backgroundTimeRemaining))s)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            } else if backgroundTimeRemaining == .greatestFiniteMagnitude {
                Text("(无限)")
                    .font(.caption2)
                    .foregroundColor(.green)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
    }
}

// MARK: - 测量时长视图

struct DurationView: View {
    let duration: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text("测量时长")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(duration)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
                .monospacedDigit()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
    }
}

// MARK: - 增强统计信息视图

struct EnhancedStatisticsView: View {
    let currentDecibel: Double
    let leqDecibel: Double
    let maxDecibel: Double
    let minDecibel: Double
    let peakDecibel: Double
    let isRecording: Bool
    
    var body: some View {
        VStack(spacing: 15) {
            // 第一行：当前值和Leq
            HStack(spacing: 30) {
                StatisticItemView(
                    label: "当前",
                    value: String(format: "%.1f", currentDecibel),
                    description: "分贝"
                )
                
                StatisticItemView(
                    label: "Leq",
                    value: String(format: "%.1f", leqDecibel),
                    description: "等效声级"
                )
            }
            
            // 第二行：MIN, MAX, PEAK
            HStack(spacing: 20) {
                StatisticItemView(
                    label: "MIN",
                    value: minDecibel < 0 ? "0.0" : String(format: "%.1f", minDecibel),
                    description: "最小值"
                )
                
                StatisticItemView(
                    label: "MAX",
                    value: maxDecibel < 0 ? "0.0" : String(format: "%.1f", maxDecibel),
                    description: "最大值"
                )
                
                StatisticItemView(
                    label: "PEAK",
                    value: peakDecibel < 0 ? "0.0" : String(format: "%.1f", peakDecibel),
                    description: "峰值"
                )
            }
        }
    }
}

// MARK: - 统计信息视图（保留原版本作为备用）

struct StatisticsView: View {
    let maxDecibel: Double
    let minDecibel: Double
    let isRecording: Bool
    
    var body: some View {
        HStack(spacing: 30) {
            StatisticItemView(
                label: "最大值",
                value: maxDecibel < 0 ? "--" : String(format: "%.1f", maxDecibel),
                description: "dB"
            )
            
            StatisticItemView(
                label: "最小值",
                value: minDecibel < 0 ? "--" : String(format: "%.1f", minDecibel),
                description: "dB"
            )
            
            StatisticItemView(
                label: "状态",
                value: isRecording ? "录音中" : "停止",
                description: ""
            )
        }
    }
}


// MARK: - 增强控制按钮视图

struct EnhancedControlButtonsView: View {
    let isRecording: Bool
    let measurementState: MeasurementState
    let onStart: () -> Void
    let onStop: () -> Void
    let onReset: () -> Void
    
    var body: some View {
        VStack(spacing: 15) {
            // 主要控制按钮
            HStack(spacing: 20) {
                // 开始/停止按钮
                Button(action: isRecording ? onStop : onStart) {
                    Image(systemName: isRecording ? "stop.circle.fill" : "play.circle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(isRecording ? .red : .green)
                }
            }
            
            // 重置按钮
            Button(action: onReset) {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.system(size: 20))
                    Text("重置")
                        .font(.headline)
                }
                .foregroundColor(.blue)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(20)
            }
        }
        .padding(.bottom, 30)
    }
}

// MARK: - 控制按钮视图（保留原版本作为备用）

struct ControlButtonsView: View {
    let isRecording: Bool
    let measurementState: MeasurementState
    let onStart: () -> Void
    let onStop: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            // 开始/停止按钮
            Button(action: isRecording ? onStop : onStart) {
                Image(systemName: isRecording ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(isRecording ? .red : .green)
            }
        }
        .padding(.bottom, 30)
    }
}

// MARK: - 设置视图

struct SettingsView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 分贝计设置
                VStack(alignment: .leading, spacing: 10) {
                    Text("分贝计设置")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("频率权重")
                            Spacer()
                            Text(viewModel.currentFrequencyWeighting.rawValue)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("时间权重")
                            Spacer()
                            Text(viewModel.currentTimeWeighting.rawValue)
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("校准偏移")
                            Spacer()
                            Text(String(format: "%.1f dB", viewModel.getCalibrationOffset()))
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                // 噪音测量计设置
                VStack(alignment: .leading, spacing: 10) {
                    Text("噪音测量计设置")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("频率权重")
                            Spacer()
                            Text("dB-A (锁定)")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("噪声标准")
                            Spacer()
                            Text("OSHA")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                // 应用信息
                VStack(alignment: .leading, spacing: 10) {
                    Text("应用信息")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("版本")
                            Spacer()
                            Text("1.0.0")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                        
                        HStack {
                            Text("开发者")
                            Spacer()
                            Text("xiaopin")
                                .foregroundColor(.secondary)
                        }
                        .padding(.horizontal)
                    }
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // 操作
                Button("重置所有数据") {
                    viewModel.resetAllData()
                }
                .foregroundColor(.red)
                .padding()
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 历史记录视图（占位符）

struct HistoryView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("历史记录功能开发中...")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("历史记录")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 校准视图

struct CalibrationView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var calibrationOffset: Double = 0.0
    @State private var showingCalibrationInstructions = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // 标题
                Text("分贝计校准")
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.top)
                
                // 当前校准值显示
                VStack(spacing: 10) {
                    Text("当前校准偏移")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    Text(String(format: "%.1f dB", calibrationOffset))
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(15)
                
                // 校准说明
                VStack(alignment: .leading, spacing: 10) {
                    Text("校准说明：")
                        .font(.headline)
                    
                    Text("• 使用标准声源（如94dB校准器）进行校准")
                    Text("• 将标准声源放置在麦克风前")
                    Text("• 调整偏移值使显示值与标准值一致")
                    Text("• 正值表示需要增加显示值，负值表示需要减少")
                }
                .font(.body)
                .foregroundColor(.secondary)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 校准控制
                VStack(spacing: 20) {
                    // 快速调整按钮
                    HStack(spacing: 15) {
                        Button("-10") {
                            calibrationOffset -= 10.0
                        }
                        .buttonStyle(CalibrationButtonStyle())
                        
                        Button("-1") {
                            calibrationOffset -= 1.0
                        }
                        .buttonStyle(CalibrationButtonStyle())
                        
                        Button("+1") {
                            calibrationOffset += 1.0
                        }
                        .buttonStyle(CalibrationButtonStyle())
                        
                        Button("+10") {
                            calibrationOffset += 10.0
                        }
                        .buttonStyle(CalibrationButtonStyle())
                    }
                    
                    // 精细调整滑块
                    VStack {
                        Text("精细调整")
                            .font(.headline)
                        
                        Slider(value: $calibrationOffset, in: -20...20, step: 0.1)
                            .accentColor(.blue)
                        
                        Text(String(format: "%.1f dB", calibrationOffset))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // 应用按钮
                Button("应用校准") {
                    viewModel.setCalibrationOffset(calibrationOffset)
                    dismiss()
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.blue)
                .cornerRadius(15)
            }
            .padding()
            .navigationTitle("校准")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - 校准按钮样式

struct CalibrationButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .frame(width: 60, height: 40)
            .background(configuration.isPressed ? Color.blue.opacity(0.7) : Color.blue)
            .cornerRadius(8)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
    }
}

#Preview {
    ContentView()
}
