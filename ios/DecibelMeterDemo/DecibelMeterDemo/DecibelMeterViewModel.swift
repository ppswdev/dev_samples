//
//  DecibelMeterViewModel.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/1/23.
//

import Foundation
import Combine
import SwiftUI

/// 分贝测量仪视图模型
@MainActor
class DecibelMeterViewModel: ObservableObject {
    
    // MARK: - 发布属性
    @Published var currentDecibel: Double = 0.0
    @Published var leqDecibel: Double = 0.0
    @Published var maxDecibel: Double = 0.0
    @Published var minDecibel: Double = -1.0  // -1表示未初始化
    @Published var peakDecibel: Double = -1.0  // -1表示未初始化
    @Published var isRecording: Bool = false
    @Published var hasStartedMeasurement: Bool = false  // 是否已经开始过测量
    @Published var measurementState: MeasurementState = .idle
    @Published var currentMeasurement: DecibelMeasurement?
    @Published var measurementHistory: [DecibelMeasurement] = []
    @Published var measurementStartTime: Date?
    @Published var currentStatistics: DecibelStatistics?
    
    // 设置相关
    @Published var currentFrequencyWeighting: FrequencyWeighting = .aWeight
    @Published var currentTimeWeighting: TimeWeighting = .fast
    
    // 应用生命周期相关
    @Published var isAppInBackground: Bool = false
    @Published var backgroundTimeRemaining: TimeInterval = 0
    
    // MARK: - 私有属性
    private let decibelManager = DecibelMeterManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var statisticsTimer: Timer?
    private let appLifecycleManager = AppLifecycleManager.shared
    
    // MARK: - 初始化
    init() {
        setupCallbacks()
    }
    
    // MARK: - 公共方法
    
    /// 开始测量
    func startMeasurement() {
        Task {
            await decibelManager.startMeasurement()
            hasStartedMeasurement = true  // 标记已经开始测量
            startStatisticsTimer()
        }
    }
    
    /// 停止测量
    func stopMeasurement() {
        decibelManager.stopMeasurement()
        stopStatisticsTimer()
    }
    
    /// 暂停测量
    func pauseMeasurement() {
        decibelManager.pauseMeasurement()
    }
    
    /// 恢复测量
    func resumeMeasurement() {
        decibelManager.resumeMeasurement()
    }
    
    /// 清除历史记录
    func clearHistory() {
        decibelManager.clearHistory()
        measurementHistory.removeAll()
        maxDecibel = -1.0  // 重置为未初始化状态
        minDecibel = -1.0  // 重置为未初始化状态
    }
    
    /// 设置校准偏移
    func setCalibrationOffset(_ offset: Double) {
        decibelManager.setCalibrationOffset(offset)
    }
    
    /// 重置所有数据
    func resetAllData() {
        decibelManager.clearHistory()
        measurementHistory.removeAll()
        maxDecibel = -1.0  // 重置为未初始化状态
        minDecibel = -1.0  // 重置为未初始化状态
        peakDecibel = -1.0  // 重置为未初始化状态
        leqDecibel = 0.0
        currentStatistics = nil
        measurementStartTime = nil
        hasStartedMeasurement = false  // 重置测量状态
    }
    
    /// 设置频率权重
    func setFrequencyWeighting(_ weighting: FrequencyWeighting) {
        currentFrequencyWeighting = weighting
        decibelManager.setFrequencyWeighting(weighting)
    }
    
    /// 设置时间权重
    func setTimeWeighting(_ weighting: TimeWeighting) {
        currentTimeWeighting = weighting
        decibelManager.setTimeWeighting(weighting)
    }
    
    /// 获取当前测量时长（格式化）
    func getFormattedDuration() -> String {
        guard let startTime = measurementStartTime else { return "00:00:00" }
        let duration = Date().timeIntervalSince(startTime)
        return formatDuration(duration)
    }
    
    /// 获取可用的频率权重
    func getAvailableFrequencyWeightings() -> [FrequencyWeighting] {
        return decibelManager.getAvailableFrequencyWeightings()
    }
    
    /// 获取可用的时间权重
    func getAvailableTimeWeightings() -> [TimeWeighting] {
        return decibelManager.getAvailableTimeWeightings()
    }
    
    /// 获取当前状态描述
    func getStateDescription() -> String {
        switch measurementState {
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
    
    /// 获取分贝等级描述
    func getLevelDescription(for decibel: Double) -> String {
        switch decibel {
        case 0..<30:
            return "非常安静"
        case 30..<50:
            return "安静"
        case 50..<70:
            return "正常对话"
        case 70..<85:
            return "繁忙街道"
        case 85..<100:
            return "吵闹，需保护听力"
        case 100...:
            return "极度吵闹，可能损害听力"
        default:
            return "未知"
        }
    }
    
    /// 获取分贝等级颜色
    func getLevelColor(for decibel: Double) -> Color {
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
    
    // MARK: - 私有方法
    
    /// 设置回调
    private func setupCallbacks() {
        // 状态变化回调
        decibelManager.onStateChange = { [weak self] newState in
            self?.measurementState = newState
            self?.isRecording = (newState == .measuring)
            
            // 记录开始时间
            if newState == .measuring && self?.measurementStartTime == nil {
                self?.measurementStartTime = Date()
            }
        }
        
        // 分贝值更新回调
        decibelManager.onDecibelUpdate = { [weak self] newDecibel in
            self?.currentDecibel = newDecibel
        }
        
        // 测量数据更新回调
        decibelManager.onMeasurementUpdate = { [weak self] measurement in
            self?.currentMeasurement = measurement
        }
        
        // 统计信息更新回调
        decibelManager.onStatisticsUpdate = { [weak self] current, max, min in
            Task { @MainActor in
                self?.currentDecibel = current
                // 只在已经开始测量后更新统计值
                if self?.hasStartedMeasurement == true {
                    self?.maxDecibel = max
                    self?.minDecibel = min
                }
            }
        }
        
        // 高级统计信息更新回调
        decibelManager.onAdvancedStatisticsUpdate = { [weak self] current, peak, max, min in
            Task { @MainActor in
                self?.currentDecibel = current
                // 只在已经开始测量后更新统计值
                if self?.hasStartedMeasurement == true {
                    self?.peakDecibel = peak
                    self?.maxDecibel = max
                    self?.minDecibel = min
                }
            }
        }
        
        // 初始化当前设置
        currentFrequencyWeighting = decibelManager.getCurrentFrequencyWeighting()
        currentTimeWeighting = decibelManager.getCurrentTimeWeighting()
        
        // 监听应用生命周期
        setupAppLifecycleCallbacks()
    }
    
    /// 设置应用生命周期回调
    private func setupAppLifecycleCallbacks() {
        // 监听后台状态
        appLifecycleManager.$isAppInBackground
            .assign(to: \.isAppInBackground, on: self)
            .store(in: &cancellables)
        
        // 监听剩余后台时间
        appLifecycleManager.$backgroundTimeRemaining
            .assign(to: \.backgroundTimeRemaining, on: self)
            .store(in: &cancellables)
    }
}

// MARK: - 扩展方法

extension DecibelMeterViewModel {
    
    /// 获取当前测量会话的持续时间
    func getCurrentSessionDuration() -> TimeInterval? {
        guard let measurement = currentMeasurement else { return nil }
        return Date().timeIntervalSince(measurement.timestamp)
    }
    
    /// 获取平均分贝值
    func getAverageDecibel() -> Double {
        guard !measurementHistory.isEmpty else { return 0.0 }
        let sum = measurementHistory.reduce(0.0) { $0 + $1.calibratedDecibel }
        return sum / Double(measurementHistory.count)
    }
    
    /// 获取分贝值趋势（最近10个测量值的趋势）
    func getDecibelTrend() -> [Double] {
        let recentMeasurements = Array(measurementHistory.suffix(10))
        return recentMeasurements.map { $0.calibratedDecibel }
    }
    
    /// 检查是否需要听力保护警告
    func shouldShowHearingProtectionWarning() -> Bool {
        return currentDecibel >= 85.0
    }
    
    /// 获取听力保护建议
    func getHearingProtectionAdvice() -> String {
        switch currentDecibel {
        case 85..<90:
            return "建议佩戴耳塞或耳罩"
        case 90..<100:
            return "强烈建议佩戴听力保护设备"
        case 100...:
            return "必须佩戴听力保护设备，避免长时间暴露"
        default:
            return "当前环境安全"
        }
    }
    
    /// 格式化时间间隔为时分秒格式
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    /// 开始统计定时器
    private func startStatisticsTimer() {
        stopStatisticsTimer()
        statisticsTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updateStatistics()
            }
        }
    }
    
    /// 停止统计定时器
    private func stopStatisticsTimer() {
        statisticsTimer?.invalidate()
        statisticsTimer = nil
    }
    
    /// 更新统计信息
    private func updateStatistics() {
        // 实时更新LEQ值（不需要等待测量结束）
        leqDecibel = decibelManager.getRealTimeLeq()
        
        // 如果有完整统计信息，也更新它
        if let statistics = decibelManager.getCurrentStatistics() {
            currentStatistics = statistics
        }
    }
}
