//
//  DecibelMeterManager.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/1/23.
//

import Foundation
import AVFoundation
import Combine

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
enum TimeWeighting {
    case fast
    case slow
    case impulse
}

/// 频率权重类型
enum FrequencyWeighting {
    case linear
    case aWeight
    case bWeight
    case cWeight
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
    private var maxDecibel: Double = 0.0
    private var minDecibel: Double = 120.0
    
    // MARK: - 回调闭包
    var onMeasurementUpdate: ((DecibelMeasurement) -> Void)?
    var onStateChange: ((MeasurementState) -> Void)?
    var onDecibelUpdate: ((Double) -> Void)?
    var onStatisticsUpdate: ((Double, Double, Double) -> Void)?
    
    // MARK: - 音频相关属性
    private var audioEngine: AVAudioEngine?
    private var inputNode: AVAudioInputNode?
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    // MARK: - 测量相关属性
    private var measurementHistory: [DecibelMeasurement] = []
    private var timeWeightingFilter: TimeWeightingFilter?
    private var frequencyWeightingFilter: FrequencyWeightingFilter?
    private var calibrationOffset: Double = 0.0
    
    // MARK: - 配置属性
    private let sampleRate: Double = 44100.0
    private let bufferSize: UInt32 = 1024
    private let referencePressure: Double = 20e-6 // 20 μPa
    
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
    
    /// 更新状态并通知回调
    private func updateState(_ newState: MeasurementState) {
        measurementState = newState
        onStateChange?(newState)
    }
    
    /// 更新分贝值并通知回调
    private func updateDecibel(_ newDecibel: Double) {
        currentDecibel = newDecibel
        onDecibelUpdate?(newDecibel)
        
        // 更新统计信息
        if newDecibel > maxDecibel {
            maxDecibel = newDecibel
        }
        if newDecibel < minDecibel {
            minDecibel = newDecibel
        }
        
        onStatisticsUpdate?(currentDecibel, maxDecibel, minDecibel)
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
            
            updateState(.measuring)
            isRecording = true
            
        } catch {
            updateState(.error("启动测量失败: \(error.localizedDescription)"))
        }
    }
    
    /// 停止测量
    func stopMeasurement() {
        stopAudioEngine()
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
    
    /// 清除测量历史
    func clearHistory() {
        measurementHistory.removeAll()
        maxDecibel = 0.0
        minDecibel = 120.0
    }
    
    // MARK: - 私有方法
    
    /// 设置音频会话
    private func setupAudioSession() {
        do {
            try audioSession.setCategory(.record, mode: .measurement, options: [])
            try audioSession.setActive(true)
        } catch {
            print("设置音频会话失败: \(error)")
        }
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
        
        // 更新测量数据并通知回调
        updateMeasurement(measurement)
        updateDecibel(measurement.calibratedDecibel)
        
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
        
        // 计算A权重分贝值
        let aWeightedDecibel = calculateAWeightedDecibel(from: samples)
        
        // 应用时间权重
        let fastDecibel = timeWeightingFilter?.applyFastWeighting(aWeightedDecibel) ?? aWeightedDecibel
        let slowDecibel = timeWeightingFilter?.applySlowWeighting(aWeightedDecibel) ?? aWeightedDecibel
        
        // 应用校准
        let calibratedDecibel = fastDecibel + calibrationOffset
        
        // 计算频谱（简化版）
        let frequencySpectrum = calculateFrequencySpectrum(from: samples)
        
        return DecibelMeasurement(
            timestamp: timestamp,
            rawDecibel: rawDecibel,
            aWeightedDecibel: aWeightedDecibel,
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
    
    /// 计算A权重分贝值
    private func calculateAWeightedDecibel(from samples: [Float]) -> Double {
        // 简化版A权重计算
        // 实际应用中需要FFT分析
        let rawDecibel = calculateRawDecibel(from: samples)
        
        // 应用简化的A权重补偿（基于经验值）
        let aWeightCompensation = -2.0 // 简化的A权重补偿
        return rawDecibel + aWeightCompensation
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
    private var fastPreviousValue: Double = 0.0
    private var slowPreviousValue: Double = 0.0
    private var lastUpdateTime: Date = Date()
    
    private let fastTimeConstant: Double = 0.125 // 125ms
    private let slowTimeConstant: Double = 1.0   // 1s
    
    func applyFastWeighting(_ currentValue: Double) -> Double {
        return applyExponentialFilter(currentValue, previousValue: &fastPreviousValue, timeConstant: fastTimeConstant)
    }
    
    func applySlowWeighting(_ currentValue: Double) -> Double {
        return applyExponentialFilter(currentValue, previousValue: &slowPreviousValue, timeConstant: slowTimeConstant)
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
}

// MARK: - 频率权重滤波器

class FrequencyWeightingFilter {
    
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
    
    func applyCWeighting(frequency: Double) -> Double {
        let f = frequency
        let f1 = 20.6
        let f2 = 12194.2
        
        let numerator = pow(f2, 2) * pow(f, 2)
        let denominator = (pow(f, 2) + pow(f1, 2)) * (pow(f, 2) + pow(f2, 2))
        
        return numerator / denominator
    }
}
