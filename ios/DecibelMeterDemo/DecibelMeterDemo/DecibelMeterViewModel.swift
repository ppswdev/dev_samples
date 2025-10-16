//
//  DecibelMeterViewModel.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/1/23.
//
//  本文件是SwiftUI的状态管理层，采用MVVM架构模式
//  负责连接DecibelMeterManager和SwiftUI视图，管理UI状态和数据流
//

import Foundation
import Combine
import SwiftUI

/// 分贝测量仪视图模型
///
/// 这是SwiftUI的状态管理类，采用MVVM架构模式
/// 负责管理UI状态、处理用户交互、订阅数据更新
///
/// **主要职责**：
/// - 管理UI状态（@Published属性）
/// - 连接DecibelMeterManager和SwiftUI视图
/// - 处理用户交互（开始、停止、设置等）
/// - 订阅数据更新回调
/// - 管理定时器和生命周期
///
/// **使用方式**：
/// ```swift
/// @StateObject private var viewModel = DecibelMeterViewModel()
/// ```
@MainActor
class DecibelMeterViewModel: ObservableObject {
    
    // MARK: - 发布属性（UI状态）
    
    /// 当前分贝值（dB），已应用权重和校准
    @Published var currentDecibel: Double = 0.0
    
    /// 等效连续声级LEQ（dB），实时计算
    @Published var leqDecibel: Double = 0.0
    
    /// 最大分贝值（dB），应用时间权重，-1表示未初始化
    @Published var maxDecibel: Double = 0.0
    
    /// 最小分贝值（dB），应用时间权重，-1表示未初始化
    @Published var minDecibel: Double = -1.0
    
    /// 峰值PEAK（dB），不应用时间权重，-1表示未初始化
    @Published var peakDecibel: Double = -1.0
    
    /// 是否正在录制标志
    @Published var isRecording: Bool = false
    
    /// 是否已经开始过测量（用于控制MIN/MAX/PEAK的显示）
    @Published var hasStartedMeasurement: Bool = false
    
    /// 当前测量状态：idle、measuring、error
    @Published var measurementState: MeasurementState = .idle
    
    /// 当前测量结果
    @Published var currentMeasurement: DecibelMeasurement?
    
    /// 测量历史记录数组
    @Published var measurementHistory: [DecibelMeasurement] = []
    
    /// 测量开始时间
    @Published var measurementStartTime: Date?
    
    /// 当前统计信息
    @Published var currentStatistics: DecibelStatistics?
    
    // MARK: 设置相关属性
    
    /// 当前频率权重，默认A权重
    @Published var currentFrequencyWeighting: FrequencyWeighting = .aWeight
    
    /// 当前时间权重，默认Fast
    @Published var currentTimeWeighting: TimeWeighting = .fast
    
    // MARK: 应用生命周期相关属性
    
    /// 应用是否在后台运行
    @Published var isAppInBackground: Bool = false
    
    /// 后台剩余时间（秒）
    @Published var backgroundTimeRemaining: TimeInterval = 0
    
    // MARK: - 私有属性
    
    /// 分贝测量管理器实例
    private let decibelManager = DecibelMeterManager.shared
    
    /// Combine订阅集合
    private var cancellables = Set<AnyCancellable>()
    
    /// 统计更新定时器，每秒更新一次LEQ等统计值
    private var statisticsTimer: Timer?
    
    /// 应用生命周期管理器
    private let appLifecycleManager = AppLifecycleManager.shared
    
    // MARK: - 初始化
    
    /// 初始化视图模型
    ///
    /// 设置与DecibelMeterManager的回调连接和应用生命周期监听
    init() {
        setupCallbacks()
    }
    
    // MARK: - 公共方法
    
    /// 开始测量
    ///
    /// 启动分贝测量，标记已开始测量，启动统计定时器
    ///
    /// **功能**：
    /// - 调用DecibelMeterManager开始测量
    /// - 设置hasStartedMeasurement标志
    /// - 启动统计更新定时器
    ///
    /// **使用示例**：
    /// ```swift
    /// viewModel.startMeasurement()
    /// ```
    func startMeasurement() {
        Task {
            await decibelManager.startMeasurement()
            hasStartedMeasurement = true  // 标记已经开始测量
            startStatisticsTimer()
        }
    }
    
    /// 停止测量
    ///
    /// 停止分贝测量，停止统计定时器
    ///
    /// **功能**：
    /// - 调用DecibelMeterManager停止测量
    /// - 停止统计更新定时器
    ///
    /// **使用示例**：
    /// ```swift
    /// viewModel.stopMeasurement()
    /// ```
    func stopMeasurement() {
        decibelManager.stopMeasurement()
        stopStatisticsTimer()
    }
    
    /// 清除历史记录
    ///
    /// 清除所有测量历史数据，重置MIN和MAX值
    ///
    /// **注意**：不会停止当前测量，只清除历史数据
    ///
    /// **使用示例**：
    /// ```swift
    /// viewModel.clearHistory()
    /// ```
    func clearHistory() {
        decibelManager.clearHistory()
        measurementHistory.removeAll()
        maxDecibel = -1.0  // 重置为未初始化状态
        minDecibel = -1.0  // 重置为未初始化状态
    }
    
    /// 设置校准偏移
    ///
    /// 设置校准偏移值，用于补偿设备差异
    ///
    /// - Parameter offset: 校准偏移值（dB），正值增加分贝，负值减少分贝
    ///
    /// **使用示例**：
    /// ```swift
    /// viewModel.setCalibrationOffset(2.5) // 增加2.5dB
    /// ```
    func setCalibrationOffset(_ offset: Double) {
        decibelManager.setCalibrationOffset(offset)
    }
    
    /// 重置所有数据
    ///
    /// 完全重置分贝测量仪，清除所有数据和设置
    ///
    /// **重置内容**：
    /// - 停止测量
    /// - 清除历史数据
    /// - 重置所有统计值
    /// - 重置校准偏移
    /// - 重置测量状态标志
    ///
    /// **使用示例**：
    /// ```swift
    /// viewModel.resetAllData()
    /// ```
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
    ///
    /// 切换频率权重，测量会继续进行（不会停止）
    ///
    /// - Parameter weighting: 要设置的频率权重
    ///
    /// **可选值**：
    /// - .aWeight：A权重（默认，最常用）
    /// - .bWeight：B权重（已弃用）
    /// - .cWeight：C权重（高声级）
    /// - .zWeight：Z权重（无修正）
    /// - .ituR468：ITU-R 468（广播音频）
    ///
    /// **注意**：切换权重时继续录制，符合专业标准
    ///
    /// **使用示例**：
    /// ```swift
    /// viewModel.setFrequencyWeighting(.cWeight)
    /// ```
    func setFrequencyWeighting(_ weighting: FrequencyWeighting) {
        currentFrequencyWeighting = weighting
        decibelManager.setDecibelMeterFrequencyWeighting(weighting)
    }
    
    /// 设置时间权重
    ///
    /// 切换时间权重，测量会继续进行（不会停止）
    ///
    /// - Parameter weighting: 要设置的时间权重
    ///
    /// **可选值**：
    /// - .fast：Fast（快响应，125ms，默认）
    /// - .slow：Slow（慢响应，1000ms）
    /// - .impulse：Impulse（脉冲响应，35ms↑/1500ms↓）
    ///
    /// **注意**：切换权重时继续录制，符合专业标准
    ///
    /// **使用示例**：
    /// ```swift
    /// viewModel.setTimeWeighting(.slow)
    /// ```
    func setTimeWeighting(_ weighting: TimeWeighting) {
        currentTimeWeighting = weighting
        decibelManager.setTimeWeighting(weighting)
    }
    
    /// 获取当前测量时长（格式化）
    ///
    /// 返回格式化的测量时长字符串
    ///
    /// - Returns: 时长字符串，格式为"HH:mm:ss"
    ///
    /// **使用示例**：
    /// ```swift
    /// let duration = viewModel.getFormattedDuration() // "00:05:23"
    /// ```
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
        
        // 测量数据更新回调
        decibelManager.onMeasurementUpdate = { [weak self] measurement in
            self?.currentMeasurement = measurement
        }
        
        // 分贝计数据更新回调
        decibelManager.onDecibelMeterDataUpdate = { [weak self] current, peak, max, min, leq in
            Task { @MainActor in
                self?.currentDecibel = current
                // 只在已经开始测量后更新统计值
                if self?.hasStartedMeasurement == true {
                    self?.peakDecibel = peak
                    self?.maxDecibel = max
                    self?.minDecibel = min
                    self?.leqDecibel = leq
                }
            }
        }
        
        // 噪音测量计数据更新回调（暂时不处理，因为当前UI主要显示分贝计数据）
        decibelManager.onNoiseMeterDataUpdate = { current, peak, max, min, leq in
            // 噪音测量计的数据更新可以在这里处理
            // 目前主要用于后台计算，UI显示仍以分贝计为主
        }
        
        // 初始化当前设置
        currentFrequencyWeighting = decibelManager.getDecibelMeterFrequencyWeighting()
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
    
    /// 获取校准偏移值
    func getCalibrationOffset() -> Double {
        return decibelManager.getCalibrationOffset()
    }
    
    // MARK: - 噪音测量计数据获取方法
    
    /// 获取噪音测量计实时LEQ值
    func getNoiseMeterRealTimeLeq() -> Double {
        return decibelManager.getNoiseMeterRealTimeLeq()
    }
    
    /// 获取噪音测量计最小值
    func getNoiseMeterMin() -> Double {
        return decibelManager.getNoiseMeterMin()
    }
    
    /// 获取噪音测量计最大值
    func getNoiseMeterMax() -> Double {
        return decibelManager.getNoiseMeterMax()
    }
    
    /// 获取噪音测量计峰值
    func getNoiseMeterPeak() -> Double {
        return decibelManager.getNoiseMeterPeak()
    }
    
    /// 获取噪音测量计频率时间权重简写文本
    func getNoiseMeterWeightingDisplayText() -> String {
        return decibelManager.getNoiseMeterWeightingDisplayText()
    }
    
    /// 获取噪音剂量数据
    func getNoiseDoseData() -> NoiseDoseData {
        return decibelManager.getNoiseDoseData()
    }
    
    /// 获取允许暴露时长表
    func getPermissibleExposureDurationTable() -> PermissibleExposureDurationTable {
        return decibelManager.getPermissibleExposureDurationTable()
    }
    
    /// 获取噪声测量计历史数据（用于图表）
    func getNoiseMeterHistory() -> [DecibelMeasurement] {
        return decibelManager.getNoiseMeterHistory()
    }
    
    /// 设置当前噪声标准
    func setCurrentNoiseStandard(_ standard: NoiseStandard) {
        decibelManager.setNoiseStandard(standard)
    }
    
    /// 获取当前噪声标准
    func getCurrentNoiseStandard() -> NoiseStandard {
        return decibelManager.getCurrentNoiseStandard()
    }
    
    /// 获取频率时间权重显示文本
    func getWeightingDisplayText() -> String {
        return decibelManager.getDecibelMeterWeightingDisplayText()
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
        leqDecibel = decibelManager.getDecibelMeterRealTimeLeq()
        
        // 如果有完整统计信息，也更新它
        if let statistics = decibelManager.getCurrentStatistics() {
            currentStatistics = statistics
        }
    }
}
