//
//  DecibelMeterManager.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/1/23.
//

import Foundation
import AVFoundation
import Combine
import UIKit

// MARK: - 数据模型
// 注意：DecibelMeasurement 定义在 DecibelDataModels.swift 中

/// 测量状态
enum MeasurementState: Equatable {
    case idle
    case measuring
    case paused
    case error(String)
    
    static func == (lhs: MeasurementState, rhs: MeasurementState) -> Bool {
        switch (lhs, rhs) {
        case (.idle, .idle), (.measuring, .measuring), (.paused, .paused):
            return true
        case (.error(let lhsMessage), .error(let rhsMessage)):
            return lhsMessage == rhsMessage
        default:
            return false
        }
    }
}

/// 时间权重类型
enum TimeWeighting: String, CaseIterable {
    case fast = "Fast"
    case slow = "Slow"
    case impulse = "Impulse"
    
    var description: String {
        switch self {
        case .fast:
            return "快响应 - 125ms"
        case .slow:
            return "慢响应 - 1000ms"
        case .impulse:
            return "脉冲响应 - 35ms↑/1500ms↓"
        }
    }
    
    var timeConstant: Double {
        switch self {
        case .fast:
            return 0.125  // 125ms
        case .slow:
            return 1.0    // 1000ms
        case .impulse:
            return 0.035  // 35ms (上升时间)
        }
    }
    
    var standard: String {
        switch self {
        case .fast:
            return "IEC 61672-1"
        case .slow:
            return "IEC 61672-1"
        case .impulse:
            return "IEC 61672-1"
        }
    }
    
    var application: String {
        switch self {
        case .fast:
            return "一般噪声测量、交通噪声"
        case .slow:
            return "稳态噪声测量、环境监测"
        case .impulse:
            return "冲击噪声、爆炸声、瞬时峰值"
        }
    }
}

/// 频率权重类型
enum FrequencyWeighting: String, CaseIterable {
    case aWeight = "A-weight"
    case bWeight = "B-weight"
    case cWeight = "C-weight"
    case zWeight = "Z-weight"
    case ituR468 = "ITU-R 468"
    
    var description: String {
        switch self {
        case .zWeight:
            return "Z权重 - 无频率修正"
        case .aWeight:
            return "A权重 - 环境噪声标准"
        case .bWeight:
            return "B权重 - 中等响度（已弃用）"
        case .cWeight:
            return "C权重 - 高声级测量"
        case .ituR468:
            return "ITU-R 468 - 广播音频标准"
        }
    }
    
    var standard: String {
        switch self {
        case .zWeight:
            return "无标准"
        case .aWeight:
            return "IEC 61672-1, ISO 226"
        case .bWeight:
            return "已从IEC 61672-1移除"
        case .cWeight:
            return "IEC 61672-1"
        case .ituR468:
            return "ITU-R BS.468-4"
        }
    }
}

// MARK: - 分贝测量管理器

class DecibelMeterManager: NSObject {
    
    // MARK: - 单例
    static let shared = DecibelMeterManager()
    
    // MARK: - 私有属性
    private var currentMeasurement: DecibelMeasurement?
    private var measurementState: MeasurementState = .idle
    private var isRecording = false
    private var currentDecibel: Double = 0.0
    private var minDecibel: Double = -1.0  // -1表示未初始化
    
    // MARK: - 回调闭包
    var onMeasurementUpdate: ((DecibelMeasurement) -> Void)?
    var onStateChange: ((MeasurementState) -> Void)?
    var onDecibelUpdate: ((Double) -> Void)?
    var onStatisticsUpdate: ((Double, Double, Double) -> Void)?
    var onAdvancedStatisticsUpdate: ((Double, Double, Double, Double) -> Void)?
    
    // MARK: - 音频相关属性
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    // MARK: - 后台任务管理
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    private var backgroundTaskTimer: Timer?
    private let appLifecycleManager = AppLifecycleManager.shared
    
    // MARK: - 测量相关属性
    private var measurementHistory: [DecibelMeasurement] = []
    private var timeWeightingFilter: TimeWeightingFilter?
    private var frequencyWeightingFilter: FrequencyWeightingFilter?
    private var calibrationOffset: Double = 0.0
    private var currentFrequencyWeighting: FrequencyWeighting = .aWeight
    
    // MARK: - 统计相关属性
    private var currentStatistics: DecibelStatistics?
    private var peakDecibel: Double = -1.0  // PEAK: 瞬时峰值，无时间权重，-1表示未初始化
    private var maxDecibel: Double = -1.0   // MAX: 时间权重后的最大值，-1表示未初始化
    private var measurementStartTime: Date?
    
    // MARK: - 时间权重相关属性
    private var currentTimeWeighting: TimeWeighting = .fast
    
    // MARK: - 配置属性
    private let sampleRate: Double = 44100.0
    private let bufferSize: UInt32 = 1024
    private let referencePressure: Double = 20e-6 // 20 μPa
    
    // 分贝值边界限制
    private let minDecibelLimit: Double = -20.0  // 合理下限值
    private let maxDecibelLimit: Double = 140.0  // 合理上限值
    
    // MARK: - 初始化
    private override init() {
        super.init()
        setupAudioSession()
        setupFilters()
    }
    
    // MARK: - 公共方法
    
    /// 获取当前测量状态
    func getCurrentState() -> MeasurementState {
        return measurementState
    }
    
    /// 获取当前分贝值
    func getCurrentDecibel() -> Double {
        return currentDecibel
    }
    
    /// 获取当前测量数据
    func getCurrentMeasurement() -> DecibelMeasurement? {
        return currentMeasurement
    }
    
    /// 获取统计信息
    func getStatistics() -> (current: Double, max: Double, min: Double) {
        return (currentDecibel, maxDecibel, minDecibel)
    }
    
    /// 获取测量历史
    func getMeasurementHistory() -> [DecibelMeasurement] {
        return measurementHistory
    }
    
    // MARK: - 私有辅助方法
    
    /// 验证分贝值是否在合理范围内
    private func validateDecibelValue(_ value: Double) -> Double {
        return max(minDecibelLimit, min(value, maxDecibelLimit))
    }
    
    /// 更新状态并通知回调
    private func updateState(_ newState: MeasurementState) {
        measurementState = newState
        onStateChange?(newState)
    }
    
    /// 更新分贝值并通知回调
    private func updateDecibel(_ newDecibel: Double, timeWeightedDecibel: Double, rawDecibel: Double) {
        // 验证并限制分贝值在合理范围内
        let validatedDecibel = validateDecibelValue(newDecibel)
        currentDecibel = validatedDecibel
        onDecibelUpdate?(validatedDecibel)
        
        // 更新MAX值（使用时间权重后的值）
        let validatedTimeWeighted = validateDecibelValue(timeWeightedDecibel)
        if maxDecibel < 0 || validatedTimeWeighted > maxDecibel {
            maxDecibel = validatedTimeWeighted
        }
        
        // 更新MIN值（使用时间权重后的值）
        if minDecibel < 0 || validatedTimeWeighted < minDecibel {
            minDecibel = validatedTimeWeighted
        }
        
        // 更新PEAK值（使用原始未加权的瞬时峰值）
        let validatedRaw = validateDecibelValue(rawDecibel)
        if peakDecibel < 0 || validatedRaw > peakDecibel {
            peakDecibel = validatedRaw
        }
        
        onStatisticsUpdate?(currentDecibel, maxDecibel, minDecibel)
        onAdvancedStatisticsUpdate?(currentDecibel, peakDecibel, maxDecibel, minDecibel)
    }
    
    /// 更新测量数据并通知回调
    private func updateMeasurement(_ measurement: DecibelMeasurement) {
        currentMeasurement = measurement
        onMeasurementUpdate?(measurement)
    }
    
    /// 开始测量
    func startMeasurement() async {
        guard measurementState != .measuring else { return }
        
        do {
            try await requestMicrophonePermission()
            try setupAudioEngine()
            try startAudioEngine()
            
            // 开始后台任务
            startBackgroundTask()
            
            // 初始化统计相关属性
            measurementStartTime = Date()
            peakDecibel = -1.0  // 重置为未初始化状态
            maxDecibel = -1.0   // 重置为未初始化状态
            minDecibel = -1.0   // 重置为未初始化状态，准备记录真实最小值
            
            updateState(.measuring)
            isRecording = true
            
        } catch {
            updateState(.error("启动测量失败: \(error.localizedDescription)"))
        }
    }
    
    /// 停止测量
    func stopMeasurement() {
        stopAudioEngine()
        
        // 结束后台任务
        endBackgroundTask()
        
        // 计算最终统计信息
        if !measurementHistory.isEmpty {
            currentStatistics = calculateStatistics(from: measurementHistory)
        }
        
        updateState(.idle)
        isRecording = false
    }
    
    /// 暂停测量
    func pauseMeasurement() {
        guard measurementState == .measuring else { return }
        updateState(.paused)
        isRecording = false
    }
    
    /// 恢复测量
    func resumeMeasurement() {
        guard measurementState == .paused else { return }
        updateState(.measuring)
        isRecording = true
    }
    
    /// 设置校准偏移
    func setCalibrationOffset(_ offset: Double) {
        calibrationOffset = offset
    }
    
    /// 获取当前频率权重
    func getCurrentFrequencyWeighting() -> FrequencyWeighting {
        return currentFrequencyWeighting
    }
    
    /// 设置频率权重
    func setFrequencyWeighting(_ weighting: FrequencyWeighting) {
        currentFrequencyWeighting = weighting
    }
    
    /// 获取所有可用的频率权重
    func getAvailableFrequencyWeightings() -> [FrequencyWeighting] {
        return FrequencyWeighting.allCases
    }
    
    /// 获取频率权重曲线数据（用于图表显示）
    func getFrequencyWeightingCurve(_ weighting: FrequencyWeighting) -> [Double] {
        let frequencies = Array(stride(from: 10.0, through: 20000.0, by: 10.0))
        return frequencyWeightingFilter?.getWeightingCurve(weighting, frequencies: frequencies) ?? []
    }
    
    /// 获取当前时间权重
    func getCurrentTimeWeighting() -> TimeWeighting {
        return currentTimeWeighting
    }
    
    /// 设置时间权重
    func setTimeWeighting(_ weighting: TimeWeighting) {
        currentTimeWeighting = weighting
    }
    
    /// 获取所有可用的时间权重
    func getAvailableTimeWeightings() -> [TimeWeighting] {
        return TimeWeighting.allCases
    }
    
    /// 获取当前统计信息
    func getCurrentStatistics() -> DecibelStatistics? {
        return currentStatistics
    }
    
    /// 获取实时LEQ值
    func getRealTimeLeq() -> Double {
        guard !measurementHistory.isEmpty else { return 0.0 }
        let decibelValues = measurementHistory.map { $0.calibratedDecibel }
        return calculateLeq(from: decibelValues)
    }
    
    /// 获取当前峰值
    func getCurrentPeak() -> Double {
        return peakDecibel
    }
    
    /// 计算统计指标
    func calculateStatistics(from measurements: [DecibelMeasurement]) -> DecibelStatistics {
        guard !measurements.isEmpty else {
            return createEmptyStatistics()
        }
        
        let decibelValues = measurements.map { $0.calibratedDecibel }
        let timestamps = measurements.map { $0.timestamp }
        
        // 基本统计
        let avgDecibel = decibelValues.reduce(0, +) / Double(decibelValues.count)
        let minDecibel = decibelValues.min() ?? 0.0
        // MAX使用实时追踪的时间权重最大值，不是历史数据的最大值
        let maxDecibel = self.maxDecibel
        // PEAK使用实时追踪的瞬时峰值，不是历史数据的最大值
        let peakDecibel = self.peakDecibel
        
        // 等效连续声级 (Leq)
        let leqDecibel = calculateLeq(from: decibelValues)
        
        // 百分位数统计
        let sortedDecibels = decibelValues.sorted()
        let l10Decibel = calculatePercentile(sortedDecibels, percentile: 90) // L10 = 90%位
        let l50Decibel = calculatePercentile(sortedDecibels, percentile: 50) // L50 = 50%位
        let l90Decibel = calculatePercentile(sortedDecibels, percentile: 10) // L90 = 10%位
        
        // 标准偏差
        let standardDeviation = calculateStandardDeviation(from: decibelValues, mean: avgDecibel)
        
        // 测量时长
        let measurementDuration = timestamps.last?.timeIntervalSince(timestamps.first ?? Date()) ?? 0.0
        
        return DecibelStatistics(
            timestamp: Date(),
            measurementDuration: measurementDuration,
            sampleCount: measurements.count,
            avgDecibel: avgDecibel,
            minDecibel: minDecibel,
            maxDecibel: maxDecibel,
            peakDecibel: peakDecibel,
            leqDecibel: leqDecibel,
            l10Decibel: l10Decibel,
            l50Decibel: l50Decibel,
            l90Decibel: l90Decibel,
            standardDeviation: standardDeviation
        )
    }
    
    /// 清除测量历史
    func clearHistory() {
        measurementHistory.removeAll()
        maxDecibel = 0.0
        minDecibel = -1.0   // 重置为未初始化状态
        peakDecibel = 0.0
        currentStatistics = nil
        measurementStartTime = nil
    }
    
    // MARK: - 私有统计计算方法
    
    /// 创建空统计信息
    private func createEmptyStatistics() -> DecibelStatistics {
        return DecibelStatistics(
            timestamp: Date(),
            measurementDuration: 0.0,
            sampleCount: 0,
            avgDecibel: 0.0,
            minDecibel: 0.0,
            maxDecibel: 0.0,
            peakDecibel: 0.0,
            leqDecibel: 0.0,
            l10Decibel: 0.0,
            l50Decibel: 0.0,
            l90Decibel: 0.0,
            standardDeviation: 0.0
        )
    }
    
    /// 计算等效连续声级 (Leq)
    private func calculateLeq(from decibelValues: [Double]) -> Double {
        guard !decibelValues.isEmpty else { return 0.0 }
        
        let sum = decibelValues.reduce(0.0) { sum, value in
            sum + pow(10.0, value / 10.0)
        }
        
        return 10.0 * log10(sum / Double(decibelValues.count))
    }
    
    /// 计算百分位数
    private func calculatePercentile(_ sortedValues: [Double], percentile: Double) -> Double {
        guard !sortedValues.isEmpty else { return 0.0 }
        
        let index = Int(ceil(Double(sortedValues.count) * percentile / 100.0)) - 1
        let clampedIndex = max(0, min(index, sortedValues.count - 1))
        return sortedValues[clampedIndex]
    }
    
    /// 计算标准偏差
    private func calculateStandardDeviation(from values: [Double], mean: Double) -> Double {
        guard values.count > 1 else { return 0.0 }
        
        let variance = values.reduce(0.0) { sum, value in
            sum + pow(value - mean, 2)
        } / Double(values.count - 1)
        
        return sqrt(variance)
    }
    
    // MARK: - 私有方法
    
    /// 设置音频会话
    private func setupAudioSession() {
        do {
            // 配置音频会话支持后台录制
            try audioSession.setCategory(
                .record, 
                mode: .measurement, 
                options: [.allowBluetooth, .allowBluetoothA2DP, .defaultToSpeaker]
            )
            
            // 启用后台音频处理
            try audioSession.setActive(true, options: [])
            
            // 设置音频会话为支持后台处理
            try audioSession.setPreferredSampleRate(44100.0)
            try audioSession.setPreferredIOBufferDuration(0.005) // 5ms缓冲区，提高响应速度
            
        } catch {
            print("设置音频会话失败: \(error)")
            updateState(.error("音频会话配置失败: \(error.localizedDescription)"))
        }
    }
    
    /// 开始后台任务
    private func startBackgroundTask() {
        endBackgroundTask() // 确保之前的任务已结束
        
        // 使用AppLifecycleManager管理后台任务
        backgroundTaskID = appLifecycleManager.startBackgroundTaskForMeasurement()
        
        // 打印后台配置信息
        appLifecycleManager.printBackgroundConfiguration()
        
        print("开始后台测量任务，ID: \(backgroundTaskID.rawValue)")
    }
    
    /// 延长后台任务
    private func extendBackgroundTask() {
        guard backgroundTaskID != .invalid else { return }
        
        print("尝试延长后台任务")
        
        // 使用AppLifecycleManager延长任务
        let newTaskID = appLifecycleManager.startBackgroundTaskForMeasurement()
        
        if newTaskID != .invalid {
            backgroundTaskID = newTaskID
            print("成功延长后台任务，新ID: \(newTaskID.rawValue)")
        } else {
            print("无法延长后台任务")
        }
    }
    
    /// 结束后台任务
    private func endBackgroundTask() {
        if backgroundTaskID != .invalid {
            print("结束后台测量任务，ID: \(backgroundTaskID.rawValue)")
            appLifecycleManager.endBackgroundTask()
            backgroundTaskID = .invalid
        }
        
        backgroundTaskTimer?.invalidate()
        backgroundTaskTimer = nil
    }
    
    /// 设置滤波器
    private func setupFilters() {
        timeWeightingFilter = TimeWeightingFilter()
        frequencyWeightingFilter = FrequencyWeightingFilter()
    }
    
    /// 请求麦克风权限
    private func requestMicrophonePermission() async throws {
        let status = AVAudioSession.sharedInstance().recordPermission
        
        switch status {
        case .granted:
            return
        case .denied:
            throw DecibelMeterError.microphonePermissionDenied
        case .undetermined:
            let granted = await withCheckedContinuation { continuation in
                AVAudioSession.sharedInstance().requestRecordPermission { granted in
                    continuation.resume(returning: granted)
                }
            }
            if !granted {
                throw DecibelMeterError.microphonePermissionDenied
            }
        @unknown default:
            throw DecibelMeterError.microphonePermissionDenied
        }
    }
    
    /// 设置音频引擎
    private func setupAudioEngine() throws {
        audioEngine = AVAudioEngine()
        guard let audioEngine = audioEngine else {
            throw DecibelMeterError.audioEngineSetupFailed
        }
        
        inputNode = audioEngine.inputNode
        guard let inputNode = inputNode else {
            throw DecibelMeterError.inputNodeNotFound
        }
        
        // 设置输入格式
        let inputFormat = inputNode.outputFormat(forBus: 0)
        print("输入格式: \(inputFormat)")
        
        // 安装音频处理块
        inputNode.installTap(onBus: 0, bufferSize: bufferSize, format: inputFormat) { [weak self] buffer, time in
            Task { @MainActor in
                self?.processAudioBuffer(buffer)
            }
        }
    }
    
    /// 启动音频引擎
    private func startAudioEngine() throws {
        guard let audioEngine = audioEngine else {
            throw DecibelMeterError.audioEngineSetupFailed
        }
        
        try audioEngine.start()
    }
    
    /// 停止音频引擎
    private func stopAudioEngine() {
        audioEngine?.stop()
        inputNode?.removeTap(onBus: 0)
        audioEngine = nil
        inputNode = nil
    }
    
    /// 处理音频缓冲区
    private func processAudioBuffer(_ buffer: AVAudioPCMBuffer) {
        guard let channelData = buffer.floatChannelData?[0] else { return }
        let frameCount = Int(buffer.frameLength)
        
        // 转换为数组
        let samples = Array(UnsafeBufferPointer(start: channelData, count: frameCount))
        
        // 计算分贝值
        let measurement = calculateDecibelMeasurement(from: samples)
        
        // 获取用于MAX和PEAK计算的值
        let currentTimeWeightedDecibel = timeWeightingFilter?.applyWeighting(currentTimeWeighting, currentValue: measurement.aWeightedDecibel) ?? measurement.aWeightedDecibel
        let rawDecibel = measurement.rawDecibel
        
        // 更新测量数据并通知回调
        updateMeasurement(measurement)
        updateDecibel(
            measurement.calibratedDecibel,
            timeWeightedDecibel: currentTimeWeightedDecibel,
            rawDecibel: rawDecibel
        )
        
        // 添加到历史记录
        measurementHistory.append(measurement)
        
        // 限制历史记录长度
        if measurementHistory.count > 1000 {
            measurementHistory.removeFirst()
        }
    }
    
    /// 计算分贝测量结果
    private func calculateDecibelMeasurement(from samples: [Float]) -> DecibelMeasurement {
        let timestamp = Date()
        
        // 计算原始分贝值
        let rawDecibel = calculateRawDecibel(from: samples)
        
        // 计算当前权重分贝值
        let weightedDecibel = calculateWeightedDecibel(from: samples, weighting: currentFrequencyWeighting)
        
        // 应用当前时间权重
        let currentTimeWeightedDecibel = timeWeightingFilter?.applyWeighting(currentTimeWeighting, currentValue: weightedDecibel) ?? weightedDecibel
        
        // 计算所有时间权重的值（用于存储和比较）
        let fastDecibel = timeWeightingFilter?.applyFastWeighting(weightedDecibel) ?? weightedDecibel
        let slowDecibel = timeWeightingFilter?.applySlowWeighting(weightedDecibel) ?? weightedDecibel
        
        // 应用校准
        let calibratedDecibel = currentTimeWeightedDecibel + calibrationOffset
        
        // 计算频谱（简化版）
        let frequencySpectrum = calculateFrequencySpectrum(from: samples)
        
        return DecibelMeasurement(
            timestamp: timestamp,
            rawDecibel: rawDecibel,
            aWeightedDecibel: weightedDecibel,
            fastDecibel: fastDecibel,
            slowDecibel: slowDecibel,
            calibratedDecibel: calibratedDecibel,
            frequencySpectrum: frequencySpectrum
        )
    }
    
    /// 计算原始分贝值
    private func calculateRawDecibel(from samples: [Float]) -> Double {
        // 计算RMS值
        let sum = samples.reduce(0.0) { $0 + Double($1 * $1) }
        let rms = sqrt(sum / Double(samples.count))
        
        // 转换为分贝
        let pressure = rms * 1.0 // 假设灵敏度为1
        return 20.0 * log10(pressure / referencePressure + 1e-10)
    }
    
    /// 计算频率权重分贝值
    private func calculateWeightedDecibel(from samples: [Float], weighting: FrequencyWeighting) -> Double {
        // 简化版频率权重计算
        // 实际应用中需要FFT分析
        let rawDecibel = calculateRawDecibel(from: samples)
        
        // 根据权重类型应用不同的补偿
        let weightCompensation = getWeightCompensation(for: weighting)
        return rawDecibel + weightCompensation
    }
    
    /// 获取权重补偿值（简化实现）
    private func getWeightCompensation(for weighting: FrequencyWeighting) -> Double {
        switch weighting {
        case .aWeight:
            return -2.0 // A权重补偿
        case .bWeight:
            return -1.0 // B权重补偿
        case .cWeight:
            return 0.0 // C权重补偿
        case .zWeight:
            return 0.0 // 无补偿
        case .ituR468:
            return -1.5 // ITU-R 468权重补偿
        }
    }
    
    /// 计算频谱（简化版）
    private func calculateFrequencySpectrum(from samples: [Float]) -> [Double] {
        // 简化版频谱计算
        // 实际应用中需要使用FFT
        let spectrum = Array(0..<32).map { _ in Double.random(in: 0...1) }
        return spectrum
    }
}

// MARK: - 错误类型

enum DecibelMeterError: LocalizedError {
    case microphonePermissionDenied
    case audioEngineSetupFailed
    case inputNodeNotFound
    case audioSessionError
    
    var errorDescription: String? {
        switch self {
        case .microphonePermissionDenied:
            return "麦克风权限被拒绝"
        case .audioEngineSetupFailed:
            return "音频引擎设置失败"
        case .inputNodeNotFound:
            return "找不到输入节点"
        case .audioSessionError:
            return "音频会话错误"
        }
    }
}

// MARK: - 时间权重滤波器

class TimeWeightingFilter {
    // 存储各权重类型的上一次值
    private var fastPreviousValue: Double = 0.0
    private var slowPreviousValue: Double = 0.0
    private var impulsePreviousValue: Double = 0.0
    private var lastUpdateTime: Date = Date()
    
    // 时间常数（秒）
    private let fastTimeConstant: Double = 0.125   // 125ms
    private let slowTimeConstant: Double = 1.0     // 1000ms
    private let impulseRiseTime: Double = 0.035    // 35ms (上升时间)
    private let impulseFallTime: Double = 1.5      // 1500ms (下降时间)
    
    /// 应用指定的时间权重
    func applyWeighting(_ weighting: TimeWeighting, currentValue: Double) -> Double {
        switch weighting {
        case .fast:
            return applyFastWeighting(currentValue)
        case .slow:
            return applySlowWeighting(currentValue)
        case .impulse:
            return applyImpulseWeighting(currentValue)
        }
    }
    
    func applyFastWeighting(_ currentValue: Double) -> Double {
        return applyExponentialFilter(currentValue, previousValue: &fastPreviousValue, timeConstant: fastTimeConstant)
    }
    
    func applySlowWeighting(_ currentValue: Double) -> Double {
        return applyExponentialFilter(currentValue, previousValue: &slowPreviousValue, timeConstant: slowTimeConstant)
    }
    
    func applyImpulseWeighting(_ currentValue: Double) -> Double {
        return applyImpulseFilter(currentValue, previousValue: &impulsePreviousValue)
    }
    
    private func applyExponentialFilter(_ currentValue: Double, previousValue: inout Double, timeConstant: Double) -> Double {
        let now = Date()
        let dt = now.timeIntervalSince(lastUpdateTime)
        
        if dt <= 0 {
            return previousValue
        }
        
        let alpha = 1.0 - exp(-dt / timeConstant)
        let filteredValue = previousValue + alpha * (currentValue - previousValue)
        
        previousValue = filteredValue
        lastUpdateTime = now
        
        return filteredValue
    }
    
    /// 应用Impulse权重滤波器
    /// Impulse权重：快速上升（35ms），缓慢下降（1.5s）
    private func applyImpulseFilter(_ currentValue: Double, previousValue: inout Double) -> Double {
        let now = Date()
        let dt = now.timeIntervalSince(lastUpdateTime)
        
        if dt <= 0 {
            return previousValue
        }
        
        // 判断是上升还是下降
        if currentValue > previousValue {
            // 上升阶段：使用快速时间常数（35ms）
            let alpha = 1.0 - exp(-dt / impulseRiseTime)
            let filteredValue = previousValue + alpha * (currentValue - previousValue)
            previousValue = filteredValue
            lastUpdateTime = now
            return filteredValue
        } else {
            // 下降阶段：使用慢速时间常数（1.5s）
            let alpha = 1.0 - exp(-dt / impulseFallTime)
            let filteredValue = previousValue + alpha * (currentValue - previousValue)
            previousValue = filteredValue
            lastUpdateTime = now
            return filteredValue
        }
    }
}

// MARK: - 频率权重滤波器

class FrequencyWeightingFilter {
    
    /// 应用指定的频率权重
    func applyWeighting(_ weighting: FrequencyWeighting, frequency: Double) -> Double {
        switch weighting {
        case .aWeight:
            return applyAWeighting(frequency: frequency)
        case .bWeight:
            return applyBWeighting(frequency: frequency)
        case .cWeight:
            return applyCWeighting(frequency: frequency)
        case .zWeight:
            return applyZWeighting(frequency: frequency)
        case .ituR468:
            return applyITU468Weighting(frequency: frequency)
        }
    }
    
    /// Z权重（无权重）
    func applyZWeighting(frequency: Double) -> Double {
        return 1.0 // 对所有频率返回1
    }
    
    /// A权重（环境噪声标准）
    func applyAWeighting(frequency: Double) -> Double {
        let f = frequency
        let f1 = 20.6
        let f2 = 107.7
        let f3 = 737.9
        let f4 = 12194.2
        
        let numerator = pow(f4, 2) * pow(f, 4)
        let denominator = (pow(f, 2) + pow(f1, 2)) * 
                         sqrt((pow(f, 2) + pow(f2, 2)) * (pow(f, 2) + pow(f3, 2))) * 
                         (pow(f, 2) + pow(f4, 2))
        
        return numerator / denominator
    }
    
    /// B权重（中等响度，已弃用）
    func applyBWeighting(frequency: Double) -> Double {
        let f = frequency
        let f1 = 20.6
        let f2 = 158.5
        let f3 = 12194.2
        
        let numerator = pow(f3, 2) * pow(f, 3)
        let denominator = (pow(f, 2) + pow(f1, 2)) * 
                         sqrt(pow(f, 2) + pow(f2, 2)) * 
                         (pow(f, 2) + pow(f3, 2))
        
        return numerator / denominator
    }
    
    /// C权重（高声级测量）
    func applyCWeighting(frequency: Double) -> Double {
        let f = frequency
        let f1 = 20.6
        let f2 = 12194.2
        
        let numerator = pow(f2, 2) * pow(f, 2)
        let denominator = (pow(f, 2) + pow(f1, 2)) * (pow(f, 2) + pow(f2, 2))
        
        return numerator / denominator
    }
    
    /// ITU-R 468权重（广播音频标准）
    func applyITU468Weighting(frequency: Double) -> Double {
        let f = frequency
        
        // ITU-R 468权重曲线的简化实现
        // 实际应用中需要完整的频率响应表
        
        if f < 10 {
            return 0.0
        } else if f < 31.5 {
            return -12.0
        } else if f < 63 {
            return -9.0
        } else if f < 125 {
            return -6.0
        } else if f < 250 {
            return -4.0
        } else if f < 500 {
            return -3.0
        } else if f < 1000 {
            return -1.0
        } else if f < 2000 {
            return 0.0
        } else if f < 4000 {
            return 1.0
        } else if f < 8000 {
            return 0.0
        } else if f < 16000 {
            return -2.0
        } else {
            return -5.0
        }
    }
    
    /// 获取权重在特定频率的dB值
    func getWeightingdB(_ weighting: FrequencyWeighting, frequency: Double) -> Double {
        let weight = applyWeighting(weighting, frequency: frequency)
        return 20.0 * log10(weight + 1e-10) // 转换为dB
    }
    
    /// 获取权重曲线的频率响应表（用于显示）
    func getWeightingCurve(_ weighting: FrequencyWeighting, frequencies: [Double]) -> [Double] {
        return frequencies.map { frequency in
            getWeightingdB(weighting, frequency: frequency)
        }
    }
}
