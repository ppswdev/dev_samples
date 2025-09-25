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
                        measurement: viewModel.currentMeasurement
                    )
                    
                    // 状态指示器
                    StatusIndicatorView(state: viewModel.measurementState)
                    
                    // 统计信息
                    StatisticsView(
                        maxDecibel: viewModel.maxDecibel,
                        minDecibel: viewModel.minDecibel,
                        isRecording: viewModel.isRecording
                    )
                }
                .padding()
                
                Spacer()
                
                // 控制按钮
                ControlButtonsView(
                    isRecording: viewModel.isRecording,
                    measurementState: viewModel.measurementState,
                    onStart: {
                        viewModel.startMeasurement()
                    },
                    onStop: {
                        viewModel.stopMeasurement()
                    },
                    onPause: {
                        viewModel.pauseMeasurement()
                    },
                    onResume: {
                        viewModel.resumeMeasurement()
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
    }
}

// MARK: - 分贝显示视图

struct DecibelDisplayView: View {
    let decibel: Double
    let measurement: DecibelMeasurement?
    
    var body: some View {
        VStack(spacing: 10) {
            // 分贝数值
            Text(String(format: "%.1f", decibel))
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(decibelColor)
            
            // 单位
            Text("dB")
                .font(.title2)
                .foregroundColor(.secondary)
            
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
        case .paused:
            return .orange
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
        case .paused:
            return "已暂停"
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

// MARK: - 统计信息视图

struct StatisticsView: View {
    let maxDecibel: Double
    let minDecibel: Double
    let isRecording: Bool
    
    var body: some View {
        HStack(spacing: 30) {
            StatisticItemView(
                title: "最大值",
                value: String(format: "%.1f", maxDecibel),
                color: .red
            )
            
            StatisticItemView(
                title: "最小值",
                value: String(format: "%.1f", minDecibel),
                color: .blue
            )
            
            StatisticItemView(
                title: "状态",
                value: isRecording ? "录音中" : "停止",
                color: isRecording ? .green : .gray
            )
        }
    }
}

struct StatisticItemView: View {
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(color)
        }
    }
}

// MARK: - 控制按钮视图

struct ControlButtonsView: View {
    let isRecording: Bool
    let measurementState: MeasurementState
    let onStart: () -> Void
    let onStop: () -> Void
    let onPause: () -> Void
    let onResume: () -> Void
    
    var body: some View {
        HStack(spacing: 20) {
            // 开始/停止按钮
            Button(action: isRecording ? onStop : onStart) {
                Image(systemName: isRecording ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(isRecording ? .red : .green)
            }
            
            // 暂停/恢复按钮
            if isRecording {
                Button(action: measurementState == .paused ? onResume : onPause) {
                    Image(systemName: measurementState == .paused ? "play.circle.fill" : "pause.circle.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                }
            }
        }
        .padding(.bottom, 30)
    }
}

// MARK: - 设置视图（占位符）

struct SettingsView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("设置功能开发中...")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("设置")
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

#Preview {
    ContentView()
}
