//
//  DecibelMeterView.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/1/23.
//
//  分贝计专用界面，专注于实时分贝测量和显示
//  功能包括：
//  - 实时分贝值显示
//  - 频率权重和时间权重设置
//  - 统计信息显示（MIN、MAX、PEAK、LEQ）
//  - 测量控制（开始/停止/重置）
//  - 校准功能
//

import SwiftUI

struct DecibelMeterView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    @State private var showingFrequencyWeightingSheet = false
    @State private var showingTimeWeightingSheet = false
    @State private var showingCalibrationSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 主要显示区域
                    VStack(spacing: 30) {
                        // 分贝值显示
                        DecibelDisplayView(
                            decibel: viewModel.currentDecibel,
                            measurement: viewModel.currentMeasurement,
                            frequencyWeighting: viewModel.currentFrequencyWeighting,
                            timeWeighting: viewModel.currentTimeWeighting
                        )
                        
                        // 频率时间权重显示卡片
                        DecibelFrequencyTimeWeightingView(viewModel: viewModel) {
                            showingFrequencyWeightingSheet = true
                        }
                        
                        // 基础数据信息
                        DecibelBasicDataView(viewModel: viewModel)
                    }
                    .padding()
                    
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
                    .padding(.horizontal)
                    .padding(.bottom, 20)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("时间权重 (\(viewModel.currentTimeWeighting.rawValue))") {
                            showingTimeWeightingSheet = true
                        }
                        Button("校准") {
                            showingCalibrationSheet = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            })
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

// MARK: - 分贝计频率时间权重显示卡片

struct DecibelFrequencyTimeWeightingView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                headerRow
                contentRows
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.blue.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    @ViewBuilder
    private var headerRow: some View {
        HStack {
            Text("频率时间权重")
                .font(.headline)
                .foregroundColor(.primary)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
    
    @ViewBuilder
    private var contentRows: some View {
        VStack(spacing: 8) {
            // 频率权重
            frequencyWeightingRow
            
            // 时间权重
            timeWeightingRow
            
            // 组合显示
            combinationDisplayRow
        }
    }
    
    @ViewBuilder
    private var frequencyWeightingRow: some View {
        HStack {
            Text("频率权重:")
                .font(.title3)
                .foregroundColor(.secondary)
            Spacer()
            Text(viewModel.currentFrequencyWeighting.rawValue)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.blue)
        }
    }
    
    @ViewBuilder
    private var timeWeightingRow: some View {
        HStack {
            Text("时间权重:")
                .font(.title3)
                .foregroundColor(.secondary)
            Spacer()
            Text(viewModel.currentTimeWeighting.rawValue)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
        }
    }
    
    @ViewBuilder
    private var combinationDisplayRow: some View {
        HStack {
            Text("组合显示:")
                .font(.title3)
                .foregroundColor(.secondary)
            Spacer()
            Text(viewModel.getWeightingDisplayText())
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.purple)
        }
    }
}

// MARK: - 分贝计基础数据视图

struct DecibelBasicDataView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("基础数据")
                .font(.headline)
                .foregroundColor(.primary)
            
            // 第一行：当前分贝值、LEQ
            currentDecibelAndLeqRow
            
            // 第二行：MIN, MAX, PEAK
            minMaxPeakRow
            
            // 第三行：测量时长、测量状态
            durationAndStatusRow
            
            // 第四行：校准偏移
            calibrationOffsetRow
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    @ViewBuilder
    private var currentDecibelAndLeqRow: some View {
        HStack(spacing: 20) {
            DecibelDataItemView(
                title: "当前分贝",
                value: String(format: "%.1f", viewModel.currentDecibel),
                unit: "dB",
                color: .blue
            )
            
            DecibelDataItemView(
                title: "LEQ",
                value: String(format: "%.1f", viewModel.leqDecibel),
                unit: "dB",
                color: .green
            )
        }
    }
    
    @ViewBuilder
    private var minMaxPeakRow: some View {
        HStack(spacing: 15) {
            DecibelDataItemView(
                title: "MIN",
                value: viewModel.isRecording ? String(format: "%.1f", viewModel.minDecibel) : "0.0",
                unit: "dB",
                color: .blue
            )
            
            DecibelDataItemView(
                title: "MAX",
                value: viewModel.isRecording ? String(format: "%.1f", viewModel.maxDecibel) : "0.0",
                unit: "dB",
                color: .red
            )
            
            DecibelDataItemView(
                title: "PEAK",
                value: viewModel.isRecording ? String(format: "%.1f", viewModel.peakDecibel) : "0.0",
                unit: "dB",
                color: .purple
            )
        }
    }
    
    @ViewBuilder
    private var durationAndStatusRow: some View {
        HStack(spacing: 15) {
            DecibelDataItemView(
                title: "测量时长",
                value: viewModel.getFormattedDuration(),
                unit: "",
                color: .orange
            )
            
            DecibelDataItemView(
                title: "状态",
                value: getMeasurementStateText(),
                unit: "",
                color: getMeasurementStateColor()
            )
        }
    }
    
    @ViewBuilder
    private var calibrationOffsetRow: some View {
        HStack(spacing: 15) {
            DecibelDataItemView(
                title: "校准偏移",
                value: String(format: "%.1f", viewModel.getCalibrationOffset()),
                unit: "dB",
                color: .secondary
            )
            
            Spacer()
        }
    }
    
    private func getMeasurementStateText() -> String {
        switch viewModel.measurementState {
        case .idle:
            return "停止"
        case .measuring:
            return "测量中"
        case .error(_):
            return "错误"
        }
    }
    
    private func getMeasurementStateColor() -> Color {
        switch viewModel.measurementState {
        case .idle:
            return .gray
        case .measuring:
            return .green
        case .error:
            return .red
        }
    }
}

// MARK: - 分贝计数据项视图

struct DecibelDataItemView: View {
    let title: String
    let value: String
    let unit: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 2) {
                Text(value)
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(color)
                
                if !unit.isEmpty {
                    Text(unit)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    DecibelMeterView(viewModel: DecibelMeterViewModel())
}
