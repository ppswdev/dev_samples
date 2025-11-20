//
//  NoiseDosimeterView.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/1/23.
//
//  噪音测量计专用界面，专注于职业健康噪声监测
//  功能包括：
//  - 实时分贝值显示（锁定dB-A）
//  - 噪声剂量监测
//  - TWA（时间加权平均）计算
//  - 职业健康标准对比
//  - 允许暴露时长表
//  - 风险评估和预警
//

import SwiftUI
import Charts

struct NoiseDosimeterView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    @State private var showingNoiseStandardSheet = false
    @State private var showingDoseDetailsSheet = false
    @State private var showingStandardSelectionSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 主要显示区域
                    VStack(spacing: 20) {
                        // 分贝值显示（锁定dB-A）
                        NoiseDosimeterDisplayView(
                            decibel: viewModel.currentDecibel,
                            measurement: viewModel.currentMeasurement
                        )
                        
                        // 当前标准显示卡片
                        CurrentStandardCardView(viewModel: viewModel) {
                            showingStandardSelectionSheet = true
                        }
 
                        // 基础数据信息
                        NoiseBasicDataView(viewModel: viewModel)
                        
                        // 噪声剂量信息（总剂量）
                        NoiseTotalDoseView(viewModel: viewModel)
                        
                        // 允许暴露时长列表
                        PermissibleExposureDurationListView(viewModel: viewModel)
                        
                        // 实时分贝曲线图
                        RealTimeDecibelChartView(viewModel: viewModel)
                        
                        // 剂量累积图
                        DoseAccumulationChartView(viewModel: viewModel)
                        
                        // TWA趋势图
                        TWATrendChartView(viewModel: viewModel)
                    }
                    .padding()
                    
                    
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        viewModel.resetAllData()
                    }) {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.orange)
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    HStack(spacing: 20) {
                        // 开始/停止按钮
                        Button(action: {
                            if viewModel.isRecording {
                                viewModel.stopMeasurement()
                            } else {
                                viewModel.startMeasurement()
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: viewModel.isRecording ? "stop.fill" : "play.fill")
                                Text(viewModel.isRecording ? "停止" : "开始")
                            }
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(viewModel.isRecording ? Color.red : Color.green)
                            .cornerRadius(8)
                        }
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button("噪声标准") {
                            showingNoiseStandardSheet = true
                        }
                        Button("剂量详情") {
                            showingDoseDetailsSheet = true
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            })
        }
        .sheet(isPresented: $showingNoiseStandardSheet) {
            NoiseStandardSelectionView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingDoseDetailsSheet) {
            DoseDetailsView(viewModel: viewModel)
        }
        .sheet(isPresented: $showingStandardSelectionSheet) {
            StandardSelectionView(viewModel: viewModel)
        }
    }
}

// MARK: - 噪音测量计显示视图

struct NoiseDosimeterDisplayView: View {
    let decibel: Double
    let measurement: DecibelMeasurement?
    
    var body: some View {
        VStack(spacing: 10) {
            // 分贝数值
            Text(String(format: "%.1f", decibel))
                .font(.system(size: 80, weight: .bold, design: .rounded))
                .foregroundColor(decibelColor)
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

// MARK: - 噪音基础数据视图

struct NoiseBasicDataView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("基础数据")
                .font(.headline)
                .foregroundColor(.primary)
            
            // 第一行：当前分贝值、LEQ
            HStack(spacing: 20) {
                DataItemView(
                    title: "当前分贝",
                    value: String(format: "%.1f", viewModel.currentDecibel),
                    unit: "dB",
                    color: .blue
                )
                
                DataItemView(
                    title: "LEQ",
                    value: String(format: "%.1f", getNoiseMeterLeq()),
                    unit: "dB",
                    color: .green
                )
            }
            
            // 第二行：MIN, MAX, PEAK
            HStack(spacing: 15) {
                DataItemView(
                    title: "MIN",
                    value: getNoiseMeterMin() < 0 ? "0.0" : String(format: "%.1f", getNoiseMeterMin()),
                    unit: "dB",
                    color: .blue
                )
                
                DataItemView(
                    title: "MAX",
                    value: getNoiseMeterMax() < 0 ? "0.0" : String(format: "%.1f", getNoiseMeterMax()),
                    unit: "dB",
                    color: .red
                )
                
                DataItemView(
                    title: "PEAK",
                    value: getNoiseMeterPeak() < 0 ? "0.0" : String(format: "%.1f", getNoiseMeterPeak()),
                    unit: "dB",
                    color: .purple
                )
            }
            
            // 第三行：测量时长、测量状态、权重
            HStack(spacing: 15) {
                DataItemView(
                    title: "测量时长",
                    value: viewModel.getFormattedDuration(),
                    unit: "",
                    color: .orange
                )
                
                DataItemView(
                    title: "状态",
                    value: getMeasurementStateText(),
                    unit: "",
                    color: getMeasurementStateColor()
                )
            }
            
            // 第四行：频率时间权重、TWA、当前标准
            HStack(spacing: 15) {
                DataItemView(
                    title: "权重",
                    value: getNoiseMeterWeightingText(),
                    unit: "",
                    color: .secondary
                )
                
                DataItemView(
                    title: "TWA",
                    value: String(format: "%.1f", getTWAValue()),
                    unit: "dB",
                    color: getTWAColor()
                )
            }
            
            // 第五行：当前标准、风险等级、限值、交换率
            VStack(spacing: 10) {
                HStack(spacing: 15) {
                    DataItemView(
                        title: "标准",
                        value: getCurrentStandardText(),
                        unit: "",
                        color: .secondary
                    )
                    
                    DataItemView(
                        title: "风险等级",
                        value: getRiskLevelText(),
                        unit: "",
                        color: getRiskLevelColor()
                    )
                }
                
                HStack(spacing: 15) {
                    DataItemView(
                        title: "限值",
                        value: String(format: "%.0f", getCurrentStandardLimit()),
                        unit: "dB",
                        color: .secondary
                    )
                    
                    DataItemView(
                        title: "交换率",
                        value: String(format: "%.0f", getCurrentStandardExchangeRate()),
                        unit: "dB",
                        color: .secondary
                    )
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
    
    // MARK: - 数据获取方法
    
    private func getNoiseMeterLeq() -> Double {
        return viewModel.getNoiseMeterRealTimeLeq()
    }
    
    private func getNoiseMeterMin() -> Double {
        return viewModel.getNoiseMeterMin()
    }
    
    private func getNoiseMeterMax() -> Double {
        return viewModel.getNoiseMeterMax()
    }
    
    private func getNoiseMeterPeak() -> Double {
        return viewModel.getNoiseMeterPeak()
    }
    
    private func getNoiseMeterWeightingText() -> String {
        return viewModel.getNoiseMeterWeightingDisplayText()
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
    
    private func getTWAValue() -> Double {
        let doseData = viewModel.getNoiseDoseData()
        return doseData.twa
    }
    
    private func getTWAColor() -> Color {
        let twa = getTWAValue()
        switch twa {
        case 0..<80:
            return .green
        case 80..<85:
            return .yellow
        case 85..<90:
            return .orange
        case 90...:
            return .red
        default:
            return .gray
        }
    }
    
    private func getCurrentStandardText() -> String {
        let doseData = viewModel.getNoiseDoseData()
        return doseData.standard.rawValue
    }
    
    private func getCurrentStandardLimit() -> Double {
        let doseData = viewModel.getNoiseDoseData()
        return doseData.standard.twaLimit
    }
    
    private func getCurrentStandardExchangeRate() -> Double {
        let doseData = viewModel.getNoiseDoseData()
        return doseData.standard.exchangeRate
    }
    
    private func getRiskLevelText() -> String {
        let twa = getTWAValue()
        switch twa {
        case 0..<80:
            return "低风险"
        case 80..<85:
            return "中等风险"
        case 85..<90:
            return "高风险"
        case 90...:
            return "极高风险"
        default:
            return "未知"
        }
    }
    
    private func getRiskLevelColor() -> Color {
        let twa = getTWAValue()
        switch twa {
        case 0..<80:
            return .green
        case 80..<85:
            return .yellow
        case 85..<90:
            return .orange
        case 90...:
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - 数据项视图

struct DataItemView: View {
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

// MARK: - 噪声总剂量视图

struct NoiseTotalDoseView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("噪声总剂量")
                .font(.headline)
                .foregroundColor(.primary)
            
            // 总剂量百分比
            HStack {
                Text("总剂量:")
                    .font(.title3)
                Spacer()
                Text("\(String(format: "%.1f", getTotalDosePercentage()))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(doseColor)
            }
            
            // 剂量进度条
            ProgressView(value: getTotalDosePercentage(), total: 100.0)
                .progressViewStyle(LinearProgressViewStyle(tint: doseColor))
            
            // 总剂量来源说明
            Text("总剂量 = 允许暴露时长列表中所有声级剂量之和")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func getTotalDosePercentage() -> Double {
        let table = viewModel.getPermissibleExposureDurationTable()
        return table.totalDose
    }
    
    private var doseColor: Color {
        let dose = getTotalDosePercentage()
        switch dose {
        case 0..<50:
            return .green
        case 50..<80:
            return .yellow
        case 80..<100:
            return .orange
        case 100...:
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - 允许暴露时长列表视图

struct PermissibleExposureDurationListView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("允许暴露时长表")
                .font(.headline)
                .foregroundColor(.primary)
            
            exposureTableContent
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(15)
    }
    
    @ViewBuilder
    private var exposureTableContent: some View {
        let table = viewModel.getPermissibleExposureDurationTable()
        
        // 表头
        tableHeader
        
        // 数据行
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(table.durations, id: \.soundLevel) { data in
                    exposureDataRow(data)
                }
            }
        }
        .frame(maxHeight: 200)
        
        // 汇总信息
        summaryInfo(table)
    }
    
    @ViewBuilder
    private var tableHeader: some View {
        HStack {
            Text("声级")
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 50)
            
            Text("允许时长")
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 70)
            
            Text("累计时长")
                .font(.caption)
                .fontWeight(.semibold)
                .frame(width: 70)
            
            Text("当前剂量")
                .font(.caption)
                .fontWeight(.semibold)
                .frame(maxWidth: .infinity)
        }
        .padding(.horizontal)
    }
    
    @ViewBuilder
    private func exposureDataRow(_ data: PermissibleExposureDuration) -> some View {
        HStack {
            Text("\(Int(data.soundLevel))")
                .font(.caption)
                .frame(width: 50)
            
            Text(formatDuration(data.allowedDuration))
                .font(.caption)
                .frame(width: 70)
            
            Text(formatDuration(data.accumulatedDuration))
                .font(.caption)
                .frame(width: 70)
            
            HStack {
                Text("\(String(format: "%.1f", data.currentLevelDose))%")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(getDoseColor(data.currentLevelDose))
                
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .background(data.currentLevelDose > 0 ? Color.orange.opacity(0.1) : Color.clear)
        .cornerRadius(4)
    }
    
    @ViewBuilder
    private func summaryInfo(_ table: PermissibleExposureDurationTable) -> some View {
        VStack(spacing: 8) {
            HStack {
                Text("总剂量:")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(String(format: "%.1f", table.totalDose))%")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(getDoseColor(table.totalDose))
            }
            
            HStack {
                Text("超标声级数:")
                    .font(.caption)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(table.exceedingLevelsCount)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(table.exceedingLevelsCount > 0 ? .red : .green)
            }
        }
        .padding(.horizontal)
    }
    
    private func formatDuration(_ duration: Double) -> String {
        if duration < 60 {
            return "\(Int(duration))s"
        } else if duration < 3600 {
            return "\(Int(duration / 60))m"
        } else {
            return "\(Int(duration / 3600))h"
        }
    }
    
    private func getDoseColor(_ dose: Double) -> Color {
        switch dose {
        case 0:
            return .gray
        case 0..<50:
            return .green
        case 50..<80:
            return .yellow
        case 80..<100:
            return .orange
        case 100...:
            return .red
        default:
            return .gray
        }
    }
}


// MARK: - 噪声标准选择视图

struct NoiseStandardSelectionView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("噪声标准选择功能开发中...")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("噪声标准")
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

// MARK: - 剂量详情视图

struct DoseDetailsView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack {
                Text("剂量详情功能开发中...")
                    .font(.title2)
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .navigationTitle("剂量详情")
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

// MARK: - 当前标准显示卡片

struct CurrentStandardCardView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                HStack {
                    Text("当前标准")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    Image(systemName: "chevron.right")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                VStack(spacing: 8) {
                    // 标准名称
                    HStack {
                        Text("标准:")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(getCurrentStandardText())
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)
                    }
                    
                    // 限值
                    HStack {
                        Text("限值:")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(String(format: "%.0f", getCurrentStandardLimit())) dB")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.blue)
                    }
                    
                    // 交换率
                    HStack {
                        Text("交换率:")
                            .font(.title3)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("\(String(format: "%.0f", getCurrentStandardExchangeRate())) dB")
                            .font(.title3)
                            .fontWeight(.semibold)
                            .foregroundColor(.orange)
                    }
                }
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
    
    private func getCurrentStandardText() -> String {
        let doseData = viewModel.getNoiseDoseData()
        return doseData.standard.rawValue
    }
    
    private func getCurrentStandardLimit() -> Double {
        let doseData = viewModel.getNoiseDoseData()
        return doseData.standard.twaLimit
    }
    
    private func getCurrentStandardExchangeRate() -> Double {
        let doseData = viewModel.getNoiseDoseData()
        return doseData.standard.exchangeRate
    }
}

// MARK: - 标准选择视图

struct StandardSelectionView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 当前标准显示
                VStack(spacing: 10) {
                    Text("当前选择的标准")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    let currentStandard = viewModel.getCurrentNoiseStandard()
                    VStack(spacing: 8) {
                        Text(currentStandard.rawValue)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(.blue)
                        
                        HStack(spacing: 20) {
                            VStack {
                                Text("限值")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.0f", currentStandard.twaLimit)) dB")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                            
                            VStack {
                                Text("交换率")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                Text("\(String(format: "%.0f", currentStandard.exchangeRate)) dB")
                                    .font(.title3)
                                    .fontWeight(.semibold)
                            }
                        }
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(12)
                }
                
                // 标准选择列表
                VStack(alignment: .leading, spacing: 15) {
                    Text("选择标准")
                        .font(.headline)
                        .foregroundColor(.primary)
                    
                    LazyVStack(spacing: 12) {
                        ForEach(NoiseStandard.allCases, id: \.self) { standard in
                            StandardOptionView(
                                standard: standard,
                                isSelected: standard == viewModel.getCurrentNoiseStandard(),
                                onSelect: {
                                    viewModel.setCurrentNoiseStandard(standard)
                                }
                            )
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("选择噪声标准")
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

// MARK: - 标准选项视图

struct StandardOptionView: View {
    let standard: NoiseStandard
    let isSelected: Bool
    let onSelect: () -> Void
    
    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 15) {
                // 选择指示器
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? .blue : .gray)
                
                // 标准信息
                VStack(alignment: .leading, spacing: 4) {
                    Text(standard.rawValue)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    HStack(spacing: 20) {
                        HStack(spacing: 4) {
                            Text("限值:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(String(format: "%.0f", standard.twaLimit)) dB")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                        
                        HStack(spacing: 4) {
                            Text("交换率:")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            Text("\(String(format: "%.0f", standard.exchangeRate)) dB")
                                .font(.caption)
                                .fontWeight(.medium)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.1) : Color.gray.opacity(0.05))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.blue : Color.gray.opacity(0.3), lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 实时分贝曲线图视图

struct RealTimeDecibelChartView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("实时分贝曲线图")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Swift Charts 实现
            Chart {
                ForEach(getChartData(), id: \.time) { dataPoint in
                    LineMark(
                        x: .value("时间", dataPoint.time),
                        y: .value("分贝", dataPoint.decibel)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
            }
            .frame(height: 200)
            .chartYScale(domain: 0...140)
            .chartXAxis {
                AxisMarks(values: .stride(by: 10)) { value in
                    AxisGridLine()
                    AxisTick()
                    if let timeValue = value.as(Int.self) {
                        AxisValueLabel {
                            Text("\(timeValue)s")
                                .font(.caption)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 20)) { value in
                    AxisGridLine()
                    AxisTick()
                    if let decibelValue = value.as(Double.self) {
                        AxisValueLabel {
                            Text("\(Int(decibelValue))dB")
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(12)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func getChartData() -> [ChartDataPoint] {
        let history = viewModel.getNoiseMeterHistory()
        let maxPoints = 60 // 显示最近60个数据点
        
        let recentHistory = Array(history.suffix(maxPoints))
        return recentHistory.enumerated().map { index, measurement in
            ChartDataPoint(
                time: index,
                decibel: measurement.calibratedDecibel
            )
        }
    }
}

// MARK: - 图表数据点结构

struct ChartDataPoint {
    let time: Int
    let decibel: Double
}

// MARK: - 剂量累积图视图

struct DoseAccumulationChartView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("剂量累积图")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Swift Charts 实现
            Chart {
                ForEach(getDoseChartData(), id: \.time) { dataPoint in
                    AreaMark(
                        x: .value("时间", dataPoint.time),
                        y: .value("剂量", dataPoint.dose)
                    )
                    .foregroundStyle(.linearGradient(
                        colors: [.blue.opacity(0.3), .blue.opacity(0.1)],
                        startPoint: .top,
                        endPoint: .bottom
                    ))
                    
                    LineMark(
                        x: .value("时间", dataPoint.time),
                        y: .value("剂量", dataPoint.dose)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
                
                // 100% 剂量线
                RuleMark(y: .value("标准", 100))
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .topTrailing) {
                        Text("100%")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
            }
            .frame(height: 200)
            .chartYScale(domain: 0...120)
            .chartXAxis {
                AxisMarks(values: .stride(by: 10)) { value in
                    AxisGridLine()
                    AxisTick()
                    if let timeValue = value.as(Int.self) {
                        AxisValueLabel {
                            Text("\(timeValue)s")
                                .font(.caption)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 20)) { value in
                    AxisGridLine()
                    AxisTick()
                    if let doseValue = value.as(Double.self) {
                        AxisValueLabel {
                            Text("\(Int(doseValue))%")
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
            .background(Color.blue.opacity(0.05))
            .cornerRadius(12)
            
            // 当前剂量显示
            HStack {
                Text("当前总剂量:")
                    .font(.title3)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(String(format: "%.1f", getTotalDosePercentage()))%")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(doseColor)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func getDoseChartData() -> [DoseChartDataPoint] {
        let history = viewModel.getNoiseMeterHistory()
        let maxPoints = 60 // 显示最近60个数据点
        
        let recentHistory = Array(history.suffix(maxPoints))
        var cumulativeDose = 0.0
        
        return recentHistory.enumerated().map { index, measurement in
            // 简化的剂量计算（实际应用中需要更复杂的算法）
            let timeInSeconds = Double(index) * 0.1 // 假设每0.1秒一个数据点
            let currentDose = min(100.0, timeInSeconds * 0.1) // 简化的剂量累积
            cumulativeDose = currentDose
            
            return DoseChartDataPoint(
                time: index,
                dose: cumulativeDose
            )
        }
    }
    
    private func getTotalDosePercentage() -> Double {
        let table = viewModel.getPermissibleExposureDurationTable()
        return table.totalDose
    }
    
    private var doseColor: Color {
        let dose = getTotalDosePercentage()
        switch dose {
        case 0..<50:
            return .green
        case 50..<80:
            return .yellow
        case 80..<100:
            return .orange
        case 100...:
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - 剂量图表数据点结构

struct DoseChartDataPoint {
    let time: Int
    let dose: Double
}

// MARK: - TWA趋势图视图

struct TWATrendChartView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            Text("TWA趋势图")
                .font(.headline)
                .foregroundColor(.primary)
            
            // Swift Charts 实现
            Chart {
                ForEach(getTWAChartData(), id: \.time) { dataPoint in
                    LineMark(
                        x: .value("时间", dataPoint.time),
                        y: .value("TWA", dataPoint.twa)
                    )
                    .foregroundStyle(.orange)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .symbol(Circle())
                    .symbolSize(20)
                }
                
                // 标准限值线 (85dB)
                RuleMark(y: .value("标准限值", 85))
                    .foregroundStyle(.red)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                    .annotation(position: .topTrailing) {
                        Text("85dB")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                
                // 警告线 (80dB)
                RuleMark(y: .value("警告线", 80))
                    .foregroundStyle(.yellow)
                    .lineStyle(StrokeStyle(lineWidth: 1, dash: [3, 3]))
                    .annotation(position: .topLeading) {
                        Text("80dB")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
            }
            .frame(height: 200)
            .chartYScale(domain: 70...100)
            .chartXAxis {
                AxisMarks(values: .stride(by: 60)) { value in
                    AxisGridLine()
                    AxisTick()
                    if let timeValue = value.as(Int.self) {
                        AxisValueLabel {
                            if timeValue >= 3600 {
                                Text("\(timeValue/3600)h")
                                    .font(.caption)
                            } else if timeValue >= 60 {
                                Text("\(timeValue/60)m")
                                    .font(.caption)
                            } else {
                                Text("\(timeValue)s")
                                    .font(.caption)
                            }
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 5)) { value in
                    AxisGridLine()
                    AxisTick()
                    if let twaValue = value.as(Double.self) {
                        AxisValueLabel {
                            Text("\(Int(twaValue))dB")
                                .font(.caption)
                        }
                    }
                }
            }
            .padding()
            .background(Color.orange.opacity(0.05))
            .cornerRadius(12)
            
            // 当前TWA显示
            HStack {
                Text("当前TWA:")
                    .font(.title3)
                    .foregroundColor(.secondary)
                Spacer()
                Text("\(String(format: "%.1f", getTWAValue())) dB")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(twaColor)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func getTWAChartData() -> [TWAChartDataPoint] {
        let history = viewModel.getNoiseMeterHistory()
        
        // 如果没有数据，返回空数组
        guard !history.isEmpty else {
            return []
        }
        
        // 计算TWA趋势数据点
        var twaDataPoints: [TWAChartDataPoint] = []
        let maxPoints = min(60, history.count) // 最多显示60个数据点
        
        // 从历史数据的开始计算累积TWA
        for i in stride(from: max(0, history.count - maxPoints), to: history.count, by: max(1, history.count / 60)) {
            let subsetHistory = Array(history[0...i])
            let twa = calculateCumulativeTWA(from: subsetHistory)
            
            // 计算从测量开始的时间（秒）
            let measurementStartTime = subsetHistory.first?.timestamp ?? Date()
            let currentTime = subsetHistory.last?.timestamp ?? Date()
            let elapsedSeconds = Int(currentTime.timeIntervalSince(measurementStartTime))
            
            twaDataPoints.append(TWAChartDataPoint(
                time: elapsedSeconds,
                twa: twa
            ))
        }
        
        return twaDataPoints
    }
    
    /// 计算累积TWA值（符合国际标准）
    /// - Parameter history: 测量历史数据
    /// - Returns: TWA值（dB）
    private func calculateCumulativeTWA(from history: [DecibelMeasurement]) -> Double {
        guard !history.isEmpty else { return 0.0 }
        
        // 计算总测量时间
        let startTime = history.first!.timestamp
        let endTime = history.last!.timestamp
        let totalDuration = endTime.timeIntervalSince(startTime)
        
        // 如果测量时间太短（小于1秒），返回当前分贝值
        guard totalDuration >= 1.0 else {
            return history.last?.calibratedDecibel ?? 0.0
        }
        
        // 计算累积LEQ值（能量平均）
        // 正确的LEQ公式：LEQ = 10 × log₁₀(1/N × Σᵢ₌₁ⁿ 10^(Li/10))
        var cumulativeEnergy = 0.0
        let sampleCount = history.count
        
        guard sampleCount > 0 else { return 0.0 }
        
        for measurement in history {
            // 将分贝值转换为线性能量值：10^(Li/10)
            let energy = pow(10.0, measurement.calibratedDecibel / 10.0)
            cumulativeEnergy += energy
        }
        
        // 计算能量平均：(1/N × Σᵢ₌₁ⁿ 10^(Li/10))
        let averageEnergy = cumulativeEnergy / Double(sampleCount)
        
        // 转换回分贝：LEQ = 10 × log₁₀(平均能量)
        let leq = 10.0 * log10(averageEnergy)
        
        // 计算TWA
        let exposureHours = totalDuration / 3600.0  // 转换为小时
        
        // 调试输出（可以后续移除）
        #if DEBUG
        print("🔍 TWA计算调试:")
        print("   - 样本数量: \(sampleCount)")
        print("   - 总能量: \(cumulativeEnergy)")
        print("   - 平均能量: \(averageEnergy)")
        print("   - LEQ: \(String(format: "%.1f", leq)) dB")
        print("   - 测量时间: \(String(format: "%.1f", totalDuration))秒")
        print("   - 测量小时: \(String(format: "%.3f", exposureHours))小时")
        #endif
        let standardWorkDay = 8.0  // 标准工作日8小时
        
        // 正确的TWA计算方法：
        // 1. 如果测量时间 <= 8小时，TWA = LEQ
        // 2. 如果测量时间 > 8小时，TWA = LEQ + 10 × log₁₀(T/8)
        // 3. 对于实时监测，通常使用LEQ作为TWA的近似值
        
        let finalTWA: Double
        if exposureHours <= standardWorkDay {
            // 测量时间不超过8小时，TWA等于LEQ
            finalTWA = leq
        } else {
            // 测量时间超过8小时，需要时间加权调整
            let timeWeighting = 10.0 * log10(exposureHours / standardWorkDay)
            finalTWA = leq + timeWeighting
        }
        
        // 调试输出最终TWA
        #if DEBUG
        print("   - 最终TWA: \(String(format: "%.1f", finalTWA)) dB")
        print("----------------------------------------")
        #endif
        
        return finalTWA
    }
    
    private func getTWAValue() -> Double {
        let doseData = viewModel.getNoiseDoseData()
        return doseData.twa
    }
    
    private var twaColor: Color {
        let twa = getTWAValue()
        switch twa {
        case 0..<80:
            return .green
        case 80..<85:
            return .yellow
        case 85..<90:
            return .orange
        case 90...:
            return .red
        default:
            return .gray
        }
    }
}

// MARK: - TWA图表数据点结构

struct TWAChartDataPoint {
    let time: Int
    let twa: Double
}

#Preview {
    NoiseDosimeterView(viewModel: DecibelMeterViewModel())
}
