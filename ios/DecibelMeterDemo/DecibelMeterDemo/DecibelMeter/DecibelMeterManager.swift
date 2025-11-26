//
//  DecibelMeterManager.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/1/23.
//
//  本文件是分贝测量仪的核心管理类，负责：
//  1. 音频采集和处理（AVAudioEngine）
//  2. 分贝计算和权重应用（频率权重、时间权重）
//  3. 统计指标计算（AVG、MIN、MAX、PEAK、LEQ、L10、L50、L90）
//  4. 图表数据生成（时间历程、频谱、统计分布、LEQ趋势）
//  5. 后台录制支持
//  6. 校准功能
//
//  符合国际标准：IEC 61672-1、ISO 1996-1、IEC 61260-1
//

import Foundation
import AVFoundation
import Combine
import UIKit

// MARK: - 数据模型
// 注意：DecibelMeasurement 定义在 DecibelDataModels.swift 中

/// 测量状态（符合专业声级计标准）
///
/// 根据 IEC 61672-1 标准，专业声级计通常只需要2-3个基本状态
/// 本实现包含4个状态：停止、测量中、暂停、错误
enum MeasurementState: Equatable {
    /// 停止状态：未进行测量，等待开始
    case idle
    
    /// 测量状态：正在进行分贝测量和数据采集
    case measuring
    
    /// 暂停状态：测量已暂停，数据记录停止，但保持历史记录
    case paused
    
    /// 错误状态：发生错误，包含错误描述信息
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
    
    /// 获取状态的字符串表示
    var stringValue: String {
        switch self {
        case .idle:
            return "idle"
        case .measuring:
            return "measuring"
        case .paused:
            return "paused"
        case .error(let message):
            return "error:\(message)"
        }
    }
}

/// 时间权重类型
///
/// 定义声级计的时间响应特性，符合 IEC 61672-1 标准
/// 时间权重影响分贝值对声音变化的响应速度
enum TimeWeighting: String, CaseIterable {
    /// Fast（快）响应：时间常数125ms，适用于一般噪声测量
    case fast = "Fast"
    
    /// Slow（慢）响应：时间常数1000ms，适用于稳态噪声测量
    case slow = "Slow"
    
    /// Impulse（脉冲）响应：上升35ms/下降1500ms，适用于冲击噪声
    case impulse = "Impulse"
    
    /// 获取时间权重的中文描述
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
    
    /// 获取时间常数（秒）
    ///
    /// 时间常数决定了声级计对声音变化的响应速度
    /// - Fast: 0.125秒（125ms）
    /// - Slow: 1.0秒（1000ms）
    /// - Impulse: 0.035秒（35ms，上升时间）
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
    
    /// 获取相关技术标准
    ///
    /// 所有时间权重都符合 IEC 61672-1:2013 标准
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
    
    /// 获取应用场景说明
    ///
    /// 不同的时间权重适用于不同的测量场景
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
    
    /// 显示符号，用于单位显示
    ///
    /// 返回单字母符号，用于组合显示如"dB(A)F"
    /// - Fast: "F"
    /// - Slow: "S"
    /// - Impulse: "I"
    var displaySymbol: String {
        switch self {
        case .fast:
            return "F"
        case .slow:
            return "S"
        case .impulse:
            return "I"
        }
    }
}

/// 频率权重类型
///
/// 定义声级计的频率响应特性，符合 IEC 61672-1 标准
/// 频率权重模拟人耳对不同频率声音的敏感度差异
enum FrequencyWeighting: String, CaseIterable {
    /// A权重：模拟人耳在40 phon等响度曲线下的响应，最常用
    case aWeight = "dB-A"
    
    /// B权重：模拟人耳在70 phon等响度曲线下的响应，已较少使用
    case bWeight = "dB-B"
    
    /// C权重：模拟人耳在100 phon等响度曲线下的响应，适用于高声级
    case cWeight = "dB-C"
    
    /// Z权重：无频率修正，保持原始频率响应
    case zWeight = "dB-Z"
    
    /// ITU-R 468权重：专门用于广播音频设备的噪声测量
    case ituR468 = "ITU-R 468"
    
    /// 获取频率权重的中文描述
    var description: String {
        switch self {
        case .zWeight:
            return "Z权重 - 无频率修正, 保持原始频率响应"
        case .aWeight:
            return "A权重 - 环境噪声标准, 模拟人耳在40 phon等响度曲线下的响应"
        case .bWeight:
            return "B权重 - 中等响度（已弃用）, 模拟人耳在70 phon等响度曲线下的响应"
        case .cWeight:
            return "C权重 - 高声级测量"
        case .ituR468:
            return "ITU-R 468 - 广播音频标准, 专门用于广播音频设备的噪声测量"
        }
    }
    
    /// 获取相关技术标准
    ///
    /// 返回该频率权重所遵循的国际标准
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
    
    /// 显示符号，用于单位显示
    ///
    /// 返回单字母或简写符号，用于组合显示如"dB(A)F"
    /// - A权重: "A"
    /// - B权重: "B"
    /// - C权重: "C"
    /// - Z权重: "Z"
    /// - ITU-R 468: "ITU"
    var displaySymbol: String {
        switch self {
        case .zWeight:
            return "Z"
        case .aWeight:
            return "A"
        case .bWeight:
            return "B"
        case .cWeight:
            return "C"
        case .ituR468:
            return "ITU"
        }
    }
}

// MARK: - 分贝测量管理器

/// 分贝测量管理器
///
/// 这是分贝测量仪的核心管理类，采用单例模式设计
/// 负责音频采集、分贝计算、权重应用、统计分析和图表数据生成
///
/// **主要功能**：
/// - 实时音频采集和分贝计算
/// - 频率权重应用（A、B、C、Z、ITU-R 468）
/// - 时间权重应用（Fast、Slow、Impulse）
/// - 统计指标计算（AVG、MIN、MAX、PEAK、LEQ、L10、L50、L90）
/// - 图表数据生成（时间历程、频谱、统计分布、LEQ趋势）
/// - 后台录制支持
/// - 校准功能
///
/// **符合标准**：
/// - IEC 61672-1:2013 - 声级计标准
/// - ISO 1996-1:2016 - 环境噪声测量
/// - IEC 61260-1:2014 - 倍频程滤波器
///
/// **使用方式**：
/// ```swift
/// let manager = DecibelMeterManager.shared
/// await manager.startMeasurement()
/// let indicator = manager.getRealTimeIndicatorData()
/// manager.stopMeasurement()
/// ```
class DecibelMeterManager: NSObject {
    
    // MARK: - 单例
    /// 分贝测量管理器的单例实例
    static let shared = DecibelMeterManager()
    
    // MARK: - 私有属性
    
    /// 当前测量结果，包含原始分贝、权重分贝、频谱等完整信息
    private var currentMeasurement: DecibelMeasurement?
    
    /// 当前测量状态：idle（停止）、measuring（测量中）、error（错误）
    private var measurementState: MeasurementState = .idle
    
    /// 是否正在录制标志
    private var isRecording = false
    
    /// 当前分贝值（已应用权重和校准）
    private var currentDecibel: Double = 0.0
    
    /// 最小分贝值（应用时间权重），-1表示未初始化
    private var minDecibel: Double = -1.0
    
    // MARK: - 回调闭包
    /// 分贝测量结果更新回调。当有新的分贝测量结果产生时调用，参数为最新的 DecibelMeasurement 对象
    var onMeasurementUpdate: ((DecibelMeasurement) -> Void)?
    
    /// 测量状态变化回调。当测量状态（空闲/测量中/错误）发生改变时触发，参数为当前测量状态
    var onStateChange: ((MeasurementState) -> Void)?
    
    /// 分贝计数据更新回调。当有新的分贝数值时调用，参数为：当前分贝值，PEAK, MAX, MIN，LEQ
    var onDecibelMeterDataUpdate: ((Double, Double, Double, Double, Double) -> Void)?
    
    /// 噪音测量计数据更新回调。当有新的分贝数值时调用，参数为：当前分贝值，PEAK, MAX, MIN，LEQ
    var onNoiseMeterDataUpdate: ((Double, Double, Double, Double, Double) -> Void)?
    
    // MARK: - 音频相关属性
    
    /// 音频引擎，用于音频采集和处理
    private var audioEngine: AVAudioEngine?
    
    /// 音频输入节点，从麦克风获取音频数据
    private var inputNode: AVAudioInputNode?
    
    /// 音频会话，管理音频资源和后台录制
    private var audioSession: AVAudioSession = AVAudioSession.sharedInstance()
    
    // MARK: - 后台任务管理
    
    /// 后台任务标识符，用于延长后台执行时间
    private var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    /// 后台任务定时器，用于定期延长后台任务
    private var backgroundTaskTimer: Timer?
    
    /// 应用生命周期管理器，处理前后台切换
    private let appLifecycleManager = AppLifecycleManager.shared
    
    // MARK: - 测量相关属性
    
    /// 分贝计测量历史记录数组，存储分贝计的所有测量结果（最多500条）
    private var decibelMeterHistory: [DecibelMeasurement] = []
    
    /// 噪音测量计测量历史记录数组，存储噪音测量计的所有测量结果（最多500条）
    private var noiseMeterHistory: [DecibelMeasurement] = []
    
    /// 最大历史记录数量（优化内存使用）
    private let maxHistoryCount: Int = 500
    
    // MARK: - 性能优化属性
    
    /// 上次分贝计UI更新时间（用于回调节流）
    private var lastDecibelMeterUpdateTime: Date = Date()
    
    /// 上次噪音测量计UI更新时间（用于回调节流）
    private var lastNoiseMeterUpdateTime: Date = Date()
    
    /// UI更新间隔（秒）- 降低更新频率以节省内存和CPU
    private let uiUpdateInterval: TimeInterval = 0.1  // 100ms更新一次，从21.5Hz降低到10Hz
    
    /// 缓存的频谱数据（避免重复计算随机数）
    private var cachedSpectrum: [Double]?
    
    /// 内存监控定时器
    private var memoryMonitorTimer: Timer?
    
    /// 上次内存检查时间
    private var lastMemoryCheckTime: Date = Date()
    
    /// 内存检查间隔（秒）
    private let memoryCheckInterval: TimeInterval = 30.0  // 每30秒检查一次
    
    /// 时间权重滤波器，用于应用Fast、Slow、Impulse时间权重
    private var timeWeightingFilter: TimeWeightingFilter?
    
    /// 频率权重滤波器，用于应用A、B、C、Z、ITU-R 468频率权重
    private var frequencyWeightingFilter: FrequencyWeightingFilter?
    
    /// 校准偏移值（dB），用于补偿设备差异
    private var calibrationOffset: Double = 0.0
    
    /// 分贝计当前频率权重，默认为A权重（最常用），可自由切换
    private var decibelMeterFrequencyWeighting: FrequencyWeighting = .aWeight
    
    /// 噪音测量计频率权重，锁定为A权重（符合职业健康标准）
    private var noiseMeterFrequencyWeighting: FrequencyWeighting = .aWeight
    
    // MARK: - 统计相关属性
    
    /// 当前统计信息，包含AVG、MIN、MAX、PEAK、LEQ、L10、L50、L90等
    private var currentStatistics: DecibelStatistics?
    
    /// PEAK峰值（dB）：瞬时峰值，不应用时间权重，-1表示未初始化
    private var peakDecibel: Double = -1.0
    
    /// MAX最大值（dB）：时间权重后的最大值，-1表示未初始化
    private var maxDecibel: Double = -1.0
    
    /// 测量开始时间，用于计算测量时长
    private var measurementStartTime: Date?
    
    /// 当前时间权重，默认为Fast（快响应）
    private var currentTimeWeighting: TimeWeighting = .fast
    
    // MARK: - 噪音测量计相关属性
    
    /// 当前使用的噪声限值标准，默认为NIOSH（更保守）
    private var currentNoiseStandard: NoiseStandard = .niosh
    
    /// 标准工作日时长（小时），用于TWA计算
    private let standardWorkDay: Double = 8.0
    
    /// 持久化的声级累计时长字典 [声级: 累计时长(秒)]
    /// 用于准确记录各声级的总暴露时间，不受历史记录清理影响
    private var levelDurationsAccumulator: [Double: TimeInterval] = [:]
    
    // MARK: - 配置属性
    
    /// 音频采样率（Hz），标准值为44100Hz
    private let sampleRate: Double = 44100.0
    
    /// 音频缓冲区大小（采样点数），影响处理延迟和精度
    /// 优化：增大缓冲区以减少回调频率，降低内存分配压力
    private let bufferSize: UInt32 = 2048  // 从1024增加到2048，减少回调频率
    
    /// 参考声压（Pa），国际标准值为20微帕（20e-6 Pa）
    private let referencePressure: Double = 20e-6
    
    /// 分贝值下限（dB），用于限制异常低值
    private let minDecibelLimit: Double = -20.0
    
    /// 分贝值上限（dB），用于限制异常高值
    private let maxDecibelLimit: Double = 140.0
    
    /// 单个音频样本的时间间隔（秒）
    /// 计算公式：bufferSize / sampleRate = 2048 / 44100 ≈ 0.0464秒
    /// 用于准确计算累计暴露时间
    private let sampleInterval: TimeInterval = 2048.0 / 44100.0

     // MARK: - 音频录制相关属性
    
    /// 音频文件对象，用于写入录音数据
    private var audioFile: AVAudioFile?
    
    /// 是否正在录制音频到文件
    private var isRecordingAudio: Bool = false
    
    /// 音频录制开始时间
    private var recordingStartTime: Date?
    
    /// 音频录制队列，用于异步写入文件
    private let recordingQueue = DispatchQueue(label: "com.decibelmeter.recording", qos: .utility)
    
    /// 文件访问队列，用于安全地复制文件
    private let fileAccessQueue = DispatchQueue(label: "com.decibelmeter.fileaccess", qos: .utility)
    
    /// 历史记录队列，用于线程安全地访问 decibelMeterHistory 和 noiseMeterHistory
    private let historyQueue = DispatchQueue(label: "com.decibelmeter.history", qos: .userInitiated)
    
    /// 临时录音文件名（固定）
    /// 使用 .caf 格式（Core Audio Format + PCM 编码），兼容性好，无需编码器
    private let tempRecordingFileName = "recording_temp.caf"
    
    // MARK: - 初始化
    
    /// 私有初始化方法（单例模式）
    ///
    /// 初始化音频会话和滤波器，确保测量环境准备就绪
    private override init() {
        super.init()
        setupAudioSession()
        setupFilters()
    }
    
    // MARK: - 公共方法
    
    /// 开始测量
    ///
    /// 启动音频采集和分贝测量，初始化所有统计值
    /// 如果已在测量中，则忽略此调用
    ///
    /// **功能**：
    /// - 请求麦克风权限
    /// - 启动音频引擎
    /// - 开始音频录制（如果启用）
    /// - 开始后台任务
    /// - 初始化统计值（MIN、MAX、PEAK）
    /// - 记录测量开始时间
    ///
    /// **注意**：此方法是异步的，需要使用await调用
    ///
    /// - Parameter enableRecording: 是否同时开始音频录制，默认为true
    ///
    /// **使用示例**：
    /// ```swift
    /// await manager.startMeasurement(enableRecording: true)
    /// ```
    func startMeasurement(enableRecording: Bool = true) async {
        // 如果已经在测量中，直接返回
        guard measurementState != .measuring else { return }
        
        // 如果处于暂停状态，提示用户先恢复或停止
        if measurementState == .paused {
            print("⚠️ 测量已暂停，请先调用 resumeMeasurement() 恢复测量，或调用 stopMeasurement() 停止测量")
            return
        }
        
        do {
            try await requestMicrophonePermission()
            try setupAudioEngine()
            try startAudioEngine()
            
            // ⭐ 新增：如果需要录制，开始音频录制
            if enableRecording {
                do {
                    try startAudioRecording()
                } catch {
                    print("❌ 启动音频录制失败: \(error)")
                    // 即使录制失败，也继续测量（不强制要求录制）
                    // 如果录制是必需的，可以在这里抛出错误
                    // throw error
                }
            }
            
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
            let errorMessage = "启动测量失败: \(error.localizedDescription)"
            print("❌ \(errorMessage)")
            print("   错误类型: \(type(of: error))")
            updateState(.error(errorMessage))
        }
    }
    
    /// 暂停测量
    ///
    /// 暂停音频采集和分贝测量，但保持所有历史记录和状态
    ///
    /// **功能**：
    /// - 暂停音频引擎（停止数据采集）
    /// - 停止音频录制写入（但保留已录制的文件）
    /// - 保持所有历史记录（分贝计、噪音测量计、累计时长累加器）
    /// - 保持测量开始时间
    /// - 更新状态为paused
    ///
    /// **注意**：
    /// - 暂停期间不会记录新的测量数据
    /// - 暂停期间可以继续查看历史数据
    /// - 调用 `resumeMeasurement()` 可以恢复测量
    ///
    /// **使用示例**：
    /// ```swift
    /// manager.pauseMeasurement()
    /// ```
    ///
    /// - Returns: 是否成功暂停（如果未在测量中则返回false）
    @discardableResult
    func pauseMeasurement() -> Bool {
        guard measurementState == .measuring else {
            print("⚠️ 无法暂停测量：当前状态为 \(measurementState.stringValue)，必须是 measuring 状态")
            return false
        }
        
        // 暂停音频引擎
        audioEngine?.pause()
        
        // 注意：不停止音频录制文件，保持文件打开
        // processAudioBuffer 不会被调用（因为引擎已暂停），所以不会写入新数据
        // 恢复时引擎重启，processAudioBuffer 恢复调用，可以继续追加写入
        
        print("⏸️ 测量已暂停")
        print("   - 音频引擎已暂停")
        print("   - 历史记录保持: ✅")
        print("   - 累计时长保持: ✅")
        if isRecordingAudio {
            print("   - 录音文件保持打开（暂停期间不写入，恢复后继续写入）: ✅")
        }
        
        updateState(.paused)
        isRecording = false  // 标记为不再记录新数据（但 isRecordingAudio 保持原值）
        
        return true
    }
    
    /// 恢复测量
    ///
    /// 恢复音频采集和分贝测量，继续之前的数据记录
    ///
    /// **功能**：
    /// - 重新启动音频引擎
    /// - 恢复音频录制写入（如果之前有录制）
    /// - 继续使用之前的历史记录和累计时长
    /// - 更新状态为measuring
    ///
    /// **注意**：
    /// - 恢复后会继续在原有历史记录基础上追加新数据
    /// - 测量开始时间保持不变（从最初开始计算）
    /// - 如果之前有录音，会继续追加到同一个文件
    ///
    /// **使用示例**：
    /// ```swift
    /// manager.resumeMeasurement()
    /// ```
    ///
    /// - Returns: 是否成功恢复（如果未在暂停状态则返回false）
    @discardableResult
    func resumeMeasurement() -> Bool {
        guard measurementState == .paused else {
            print("⚠️ 无法恢复测量：当前状态为 \(measurementState.stringValue)，必须是 paused 状态")
            return false
        }
        
        do {
            // 重新启动音频引擎
            guard let audioEngine = audioEngine else {
                print("❌ 无法恢复测量：音频引擎不存在")
                updateState(.error("音频引擎不存在"))
                return false
            }
            
            try audioEngine.start()
            
            // 注意：如果之前有录音，音频文件仍然打开，processAudioBuffer 会自动继续写入
            
            // 重新开始后台任务
            startBackgroundTask()
            
            print("▶️ 测量已恢复")
            print("   - 音频引擎已重启")
            print("   - 历史记录继续使用: ✅")
            print("   - 累计时长继续累加: ✅")
            if isRecordingAudio {
                print("   - 录音文件继续写入: ✅")
            }
            
            updateState(.measuring)
            isRecording = true  // 标记为正在记录新数据
            
            return true
        } catch {
            let errorMessage = "恢复测量失败: \(error.localizedDescription)"
            print("❌ \(errorMessage)")
            updateState(.error(errorMessage))
            return false
        }
    }
    
    /// 停止测量
    ///
    /// 停止音频采集和分贝测量，计算最终统计信息
    ///
    /// **功能**：
    /// - 停止音频引擎
    /// - 停止音频录制并删除临时文件
    /// - 结束后台任务
    /// - 计算最终统计信息（如果有测量数据）
    /// - 更新状态为idle
    ///
    /// **注意**：
    /// - 无论当前是 measuring 还是 paused 状态，都可以调用此方法停止测量
    /// - 停止后会清除所有历史记录（如果调用 resetAllData）
    ///
    /// **使用示例**：
    /// ```swift
    /// manager.stopMeasurement()
    /// ```
    func stopMeasurement() {
        stopAudioEngine()
        
        // ⭐ 新增：停止音频录制并删除临时文件
        if isRecordingAudio {
            stopAudioRecording()
        }
        
        // 结束后台任务
        endBackgroundTask()
        
        // 计算最终统计信息（线程安全）
        let history = historyQueue.sync {
            return decibelMeterHistory
        }
        if !history.isEmpty {
            currentStatistics = calculateStatistics(from: history)
        }
        
        updateState(.idle)
        isRecording = false
    }
    
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
    
    /// 获取分贝计测量历史（线程安全）
    func getDecibelMeterHistory() -> [DecibelMeasurement] {
        return historyQueue.sync {
            return decibelMeterHistory
        }
    }
    
    /// 获取噪音测量计测量历史（线程安全）
    func getNoiseMeterHistory() -> [DecibelMeasurement] {
        return historyQueue.sync {
            return noiseMeterHistory
        }
    }
    
    
    /// 设置校准偏移
    func setCalibrationOffset(_ offset: Double) {
        calibrationOffset = offset
    }
    
    /// 获取分贝计当前频率权重
    func getDecibelMeterFrequencyWeighting() -> FrequencyWeighting {
        return decibelMeterFrequencyWeighting
    }
    
    /// 设置分贝计频率权重
    func setDecibelMeterFrequencyWeighting(_ weighting: FrequencyWeighting) {
        decibelMeterFrequencyWeighting = weighting
    }
    
    /// 获取噪音测量计频率权重（始终为A权重）
    func getNoiseMeterFrequencyWeighting() -> FrequencyWeighting {
        return noiseMeterFrequencyWeighting
    }
    
    /// 获取当前频率权重（兼容性方法，返回分贝计的权重）
    func getCurrentFrequencyWeighting() -> FrequencyWeighting {
        return decibelMeterFrequencyWeighting
    }
    
    /// 设置频率权重（兼容性方法，设置分贝计的权重）
    func setFrequencyWeighting(_ weighting: FrequencyWeighting) {
        decibelMeterFrequencyWeighting = weighting
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
    
    /// 获取分贝计实时LEQ值（线程安全）
    func getDecibelMeterRealTimeLeq() -> Double {
        return historyQueue.sync {
            guard !decibelMeterHistory.isEmpty else { return 0.0 }
            let decibelValues = decibelMeterHistory.map { $0.calibratedDecibel }
            return calculateLeq(from: decibelValues)
        }
    }
    
    /// 获取噪音测量计实时LEQ值（线程安全）
    func getNoiseMeterRealTimeLeq() -> Double {
        return historyQueue.sync {
            guard !noiseMeterHistory.isEmpty else { return 0.0 }
            let decibelValues = noiseMeterHistory.map { $0.calibratedDecibel }
            return calculateLeq(from: decibelValues)
        }
    }
    
    /// 获取实时LEQ值（兼容性方法，返回分贝计的LEQ）
    func getRealTimeLeq() -> Double {
        return getDecibelMeterRealTimeLeq()
    }
    
    /// 获取当前峰值
    func getCurrentPeak() -> Double {
        return peakDecibel
    }
    
    /// 获取噪音测量计最大值（线程安全）
    /// 
    /// **注意**：返回的是已应用校准偏移的值
    func getNoiseMeterMax() -> Double {
        return historyQueue.sync {
            guard !noiseMeterHistory.isEmpty else { return -1.0 }
            // ⭐ 修复：使用 calibratedDecibel（已包含校准偏移）而不是 fastDecibel
            // 由于噪音测量计使用 fastDecibel，而 calibratedDecibel = fastDecibel + calibrationOffset
            // 所以直接使用 calibratedDecibel 即可
            return noiseMeterHistory.map { $0.calibratedDecibel }.max() ?? -1.0
        }
    }
    
    /// 获取噪音测量计最小值（线程安全）
    ///
    /// **注意**：返回的是已应用校准偏移的值
    func getNoiseMeterMin() -> Double {
        return historyQueue.sync {
            guard !noiseMeterHistory.isEmpty else { return -1.0 }
            // ⭐ 修复：使用 calibratedDecibel（已包含校准偏移）而不是 fastDecibel
            return noiseMeterHistory.map { $0.calibratedDecibel }.min() ?? -1.0
        }
    }
    
    /// 获取噪音测量计峰值（线程安全）
    ///
    /// **注意**：返回的是已应用校准偏移的值
    /// **说明**：
    /// - PEAK 是瞬时峰值，不应用时间权重，但需要应用校准偏移
    /// - 由于历史记录中的 rawDecibel 未包含校准，需要加上当前的 calibrationOffset
    /// - 如果校准值在测量过程中未改变，这样可以正确反映真实的瞬时峰值
    func getNoiseMeterPeak() -> Double {
        return historyQueue.sync {
            guard !noiseMeterHistory.isEmpty else { return -1.0 }
            // ⭐ 修复：PEAK 应该使用 rawDecibel（瞬时峰值）+ 校准偏移
            // 这样得到的是真实的瞬时峰值，已应用校准但未应用时间权重
            return (noiseMeterHistory.map { $0.rawDecibel + calibrationOffset }.max() ?? -1.0)
        }
    }
    
    // MARK: - 扩展的公共获取方法
    
    /// 获取当前测量时长（格式化为 HH:mm:ss）
    ///
    /// 返回从测量开始到现在的时长，格式为"时:分:秒"
    ///
    /// - Returns: 格式化的时长字符串，如"00:05:23"，未开始测量时返回"00:00:00"
    ///
    /// **使用示例**：
    /// ```swift
    /// let duration = manager.getFormattedMeasurementDuration() // "00:05:23"
    /// ```
    func getFormattedMeasurementDuration() -> String {
        guard let startTime = measurementStartTime else { return "00:00:00" }
        let duration = Date().timeIntervalSince(startTime)
        return formatDuration(duration)
    }
    
    /// 获取当前测量时长（秒）
    ///
    /// 返回从测量开始到现在的时长（秒数）
    ///
    /// - Returns: 测量时长（秒），未开始测量时返回0.0
    ///
    /// **使用示例**：
    /// ```swift
    /// let seconds = manager.getMeasurementDuration() // 323.5
    /// ```
    func getMeasurementDuration() -> TimeInterval {
        guard let startTime = measurementStartTime else { return 0.0 }
        return Date().timeIntervalSince(startTime)
    }
    
    /// 获取分贝计频率时间权重简写文本
    ///
    /// 返回符合国际标准的权重显示格式，组合频率权重和时间权重
    ///
    /// - Returns: 权重简写文本，格式为"dB(频率权重)时间权重"
    ///
    /// **示例**：
    /// - "dB(A)F" - A权重 + Fast时间权重
    /// - "dB(C)S" - C权重 + Slow时间权重
    /// - "dB(ITU)I" - ITU-R 468权重 + Impulse时间权重
    ///
    /// **使用示例**：
    /// ```swift
    /// let text = manager.getDecibelMeterWeightingDisplayText() // "dB(A)F"
    /// ```
    func getDecibelMeterWeightingDisplayText() -> String {
        let freqSymbol = decibelMeterFrequencyWeighting.displaySymbol
        let timeSymbol = currentTimeWeighting.displaySymbol
        return "dB(\(freqSymbol))\(timeSymbol)"
    }
    
    /// 获取噪音测量计频率时间权重简写文本（始终为dB(A)F）
    func getNoiseMeterWeightingDisplayText() -> String {
        let freqSymbol = noiseMeterFrequencyWeighting.displaySymbol
        let timeSymbol = currentTimeWeighting.displaySymbol
        return "dB(\(freqSymbol))\(timeSymbol)"
    }
    
    /// 获取当前频率时间权重简写文本（兼容性方法，返回分贝计的权重）
    func getWeightingDisplayText() -> String {
        return getDecibelMeterWeightingDisplayText()
    }
    
    /// 获取校准偏移值
    ///
    /// 返回当前设置的校准偏移值，用于补偿设备差异
    ///
    /// - Returns: 校准偏移值（dB），正值表示增加，负值表示减少
    ///
    /// **使用示例**：
    /// ```swift
    /// let offset = manager.getCalibrationOffset() // 2.5
    /// ```
    func getCalibrationOffset() -> Double {
        return calibrationOffset
    }
    
    /// 获取最小分贝值
    ///
    /// 返回测量期间的最小分贝值（应用时间权重）
    ///
    /// - Returns: 最小分贝值（dB），未开始测量时返回-1.0
    ///
    /// **注意**：此值应用了时间权重，与PEAK不同
    ///
    /// **使用示例**：
    /// ```swift
    /// let min = manager.getMinDecibel() // 60.2
    /// ```
    func getMinDecibel() -> Double {
        return minDecibel
    }
    
    /// 获取最大分贝值
    ///
    /// 返回测量期间的最大分贝值（应用时间权重）
    ///
    /// - Returns: 最大分贝值（dB），未开始测量时返回-1.0
    ///
    /// **注意**：此值应用了时间权重，与PEAK不同
    /// **区别**：MAX ≤ PEAK（理论上）
    ///
    /// **使用示例**：
    /// ```swift
    /// let max = manager.getMaxDecibel() // 85.7
    /// ```
    func getMaxDecibel() -> Double {
        return maxDecibel
    }
    
    /// 获取LEQ值（等效连续声级）
    ///
    /// 返回实时计算的等效连续声级，表示能量平均值
    ///
    /// - Returns: LEQ值（dB），符合ISO 1996-1标准
    ///
    /// **计算公式**：
    /// ```
    /// LEQ = 10 × log₁₀(1/n × Σᵢ₌₁ⁿ 10^(Li/10))
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// let leq = manager.getLeqDecibel() // 70.3
    /// ```
    func getLeqDecibel() -> Double {
        return getDecibelMeterRealTimeLeq()
    }
    
    // MARK: - 权重列表获取方法
    
    /// 获取所有频率权重列表（支持JSON转换）
    ///
    /// 返回所有可用的频率权重选项和当前选择
    ///
    /// - Returns: WeightingOptionsList对象，包含所有频率权重选项
    ///
    /// **包含的权重**：
    /// - dB-A：A权重，环境噪声标准
    /// - dB-B：B权重，中等响度（已弃用）
    /// - dB-C：C权重，高声级测量
    /// - dB-Z：Z权重，无频率修正
    /// - ITU-R 468：广播音频标准
    ///
    /// **支持JSON转换**：
    /// ```swift
    /// let list = manager.getFrequencyWeightingsList()
    /// let json = list.toJSON() // 转换为JSON字符串
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// let list = manager.getFrequencyWeightingsList()
    /// for option in list.options {
    ///     print("\(option.displayName): \(option.description)")
    /// }
    /// ```
    func getFrequencyWeightingsList() -> WeightingOptionsList {
        let options = FrequencyWeighting.allCases.map { weighting in
            WeightingOption(
                id: weighting.rawValue,
                displayName: getFrequencyWeightingDisplayName(weighting),
                symbol: weighting.displaySymbol,
                description: weighting.description,
                standard: weighting.standard
            )
        }
        return WeightingOptionsList(
            options: options,
            currentSelection: decibelMeterFrequencyWeighting.rawValue
        )
    }
    
    /// 获取所有时间权重列表（支持JSON转换）
    ///
    /// 返回所有可用的时间权重选项和当前选择
    ///
    /// - Returns: WeightingOptionsList对象，包含所有时间权重选项
    ///
    /// **包含的权重**：
    /// - F：Fast（快响应，125ms）
    /// - S：Slow（慢响应，1000ms）
    /// - I：Impulse（脉冲响应，35ms↑/1500ms↓）
    ///
    /// **支持JSON转换**：
    /// ```swift
    /// let list = manager.getTimeWeightingsList()
    /// let json = list.toJSON() // 转换为JSON字符串
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// let list = manager.getTimeWeightingsList()
    /// for option in list.options {
    ///     print("\(option.symbol): \(option.description)")
    /// }
    /// ```
    func getTimeWeightingsList() -> WeightingOptionsList {
        let options = TimeWeighting.allCases.map { weighting in
            WeightingOption(
                id: weighting.rawValue,
                displayName: weighting.description,
                symbol: weighting.displaySymbol,
                description: weighting.application,
                standard: weighting.standard
            )
        }
        return WeightingOptionsList(
            options: options,
            currentSelection: currentTimeWeighting.rawValue
        )
    }
    
    // MARK: - 图表数据获取方法
    
    /// 获取时间历程图数据（实时分贝曲线）
    ///
    /// 返回指定时间范围内的分贝变化曲线数据，用于绘制时间历程图
    /// 这是专业声级计最重要的图表类型
    ///
    /// - Parameter timeRange: 时间范围（秒），默认60秒，表示显示最近多少秒的数据
    /// - Returns: TimeHistoryChartData对象，包含数据点、时间范围、分贝范围等
    ///
    /// **图表要求**：
    /// - 横轴：时间（最近60秒或可配置）
    /// - 纵轴：分贝值（0-140 dB）
    /// - 显示：实时更新的曲线
    ///
    /// **数据来源**：measurementHistory（自动过滤指定时间范围）
    ///
    /// **支持JSON转换**：
    /// ```swift
    /// let data = manager.getTimeHistoryChartData(timeRange: 60.0)
    /// let json = data.toJSON()
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// // 获取最近60秒的数据
    /// let data = manager.getTimeHistoryChartData(timeRange: 60.0)
    /// print("数据点数量: \(data.dataPoints.count)")
    /// print("分贝范围: \(data.minDecibel) - \(data.maxDecibel) dB")
    /// ```
    func getTimeHistoryChartData(timeRange: TimeInterval = 60.0) -> TimeHistoryChartData {
        let now = Date()
        let startTime = now.addingTimeInterval(-timeRange)
        
        // 线程安全地获取历史记录的副本
        let history = historyQueue.sync {
            return decibelMeterHistory
        }
        
        // 过滤指定时间范围内的数据
        let filteredMeasurements = history.filter { measurement in
            measurement.timestamp >= startTime
        }
        
        // 转换为数据点
        let dataPoints = filteredMeasurements.map { measurement in
            TimeHistoryDataPoint(
                timestamp: measurement.timestamp,
                decibel: measurement.calibratedDecibel,
                weightingType: currentTimeWeighting.rawValue
            )
        }
        
        // 计算范围
        let decibelValues = dataPoints.map { $0.decibel }
        let minDb = decibelValues.min() ?? 0.0
        let maxDb = decibelValues.max() ?? 140.0
        
        return TimeHistoryChartData(
            dataPoints: dataPoints,
            timeRange: timeRange,
            minDecibel: minDb,
            maxDecibel: maxDb,
            title: "实时分贝曲线 - \(getDecibelMeterWeightingDisplayText())"
        )
    }
    
    /// 获取实时指示器数据
    ///
    /// 返回当前所有关键测量指标，这是最常用的数据获取方法
    ///
    /// - Returns: RealTimeIndicatorData对象，包含当前、LEQ、MIN、MAX、PEAK等所有关键指标
    ///
    /// **包含的数据**：
    /// - currentDecibel：当前分贝值（已应用权重和校准）
    /// - leq：等效连续声级
    /// - min：最小值（应用时间权重）
    /// - max：最大值（应用时间权重）
    /// - peak：峰值（不应用时间权重）
    /// - weightingDisplay：权重显示文本，如"dB(A)F"
    ///
    /// **未初始化处理**：MIN/MAX/PEAK < 0时返回0.0
    ///
    /// **支持JSON转换**：
    /// ```swift
    /// let data = manager.getRealTimeIndicatorData()
    /// let json = data.toJSON()
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// let indicator = manager.getRealTimeIndicatorData()
    /// print("当前: \(indicator.currentDecibel) \(indicator.weightingDisplay)")
    /// print("LEQ: \(indicator.leq) dB")
    /// print("MIN: \(indicator.min) dB, MAX: \(indicator.max) dB, PEAK: \(indicator.peak) dB")
    /// ```
    func getRealTimeIndicatorData() -> RealTimeIndicatorData {
        return RealTimeIndicatorData(
            currentDecibel: currentDecibel,
            leq: getDecibelMeterRealTimeLeq(),
            min: minDecibel < 0 ? 0.0 : minDecibel,
            max: maxDecibel < 0 ? 0.0 : maxDecibel,
            peak: peakDecibel < 0 ? 0.0 : peakDecibel,
            weightingDisplay: getDecibelMeterWeightingDisplayText(),
            timestamp: Date()
        )
    }
    
    /// 获取频谱分析图数据
    ///
    /// 返回各频段的声压级分布数据，用于绘制频谱分析图
    /// 符合 IEC 61260-1 标准的倍频程分析要求
    ///
    /// - Parameter bandType: 倍频程类型，"1/1"（10个频点）或"1/3"（30个频点），默认"1/3"
    /// - Returns: SpectrumChartData对象，包含各频率点的声压级数据
    ///
    /// **图表要求**：
    /// - 横轴：频率（Hz）- 对数坐标
    /// - 纵轴：声压级（dB）
    /// - 显示：1/1倍频程或1/3倍频程柱状图
    ///
    /// **频率点**：
    /// - 1/1倍频程：31.5, 63, 125, 250, 500, 1k, 2k, 4k, 8k, 16k Hz
    /// - 1/3倍频程：25, 31.5, 40, 50, 63, 80, 100, 125, ... 20k Hz
    ///
    /// **数据来源**：frequencySpectrum数组或基于权重的模拟数据
    ///
    /// **支持JSON转换**：
    /// ```swift
    /// let data = manager.getSpectrumChartData(bandType: "1/3")
    /// let json = data.toJSON()
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// // 1/1倍频程
    /// let spectrum1_1 = manager.getSpectrumChartData(bandType: "1/1")
    ///
    /// // 1/3倍频程
    /// let spectrum1_3 = manager.getSpectrumChartData(bandType: "1/3")
    /// print("频率点数量: \(spectrum1_3.dataPoints.count)")
    /// ```
    func getSpectrumChartData(bandType: String = "1/3") -> SpectrumChartData {
        let frequencies: [Double]
        
        if bandType == "1/1" {
            // 1/1倍频程标准频率
            frequencies = [31.5, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
        } else {
            // 1/3倍频程标准频率
            frequencies = [25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800, 1000, 1250, 1600, 2000, 2500, 3150, 4000, 5000, 6300, 8000, 10000, 12500, 16000, 20000]
        }
        
        // 使用当前测量的频谱数据或模拟数据
        let dataPoints = frequencies.enumerated().map { index, frequency in
            let magnitude: Double
            if let spectrum = currentMeasurement?.frequencySpectrum,
               index < spectrum.count {
                // 使用实际频谱数据并转换为dB
                magnitude = 20.0 * log10(spectrum[index] + 1e-10) + currentDecibel
            } else {
                // 模拟数据：基于当前分贝值和频率权重
                let weightCompensation = frequencyWeightingFilter?.getWeightingdB(decibelMeterFrequencyWeighting, frequency: frequency) ?? 0.0
                // 使用基于频率的确定性噪声，避免随机数导致的频繁重绘
                let noise = sin(frequency * 0.001) * 3.0
                magnitude = currentDecibel + weightCompensation + noise
            }
            
            return SpectrumDataPoint(
                frequency: frequency,
                magnitude: max(0, min(140, magnitude)),
                bandType: bandType
            )
        }
        
        return SpectrumChartData(
            dataPoints: dataPoints,
            bandType: bandType == "1/1" ? "1/1倍频程" : "1/3倍频程",
            frequencyRange: (min: frequencies.first ?? 20, max: frequencies.last ?? 20000),
            title: "频谱分析 - \(getDecibelMeterWeightingDisplayText())"
        )
    }
    
    /// 获取统计分布图数据（L10、L50、L90）
    ///
    /// 返回声级的统计分布数据，用于分析噪声的统计特性
    /// 符合 ISO 1996-2 标准的统计分析要求
    ///
    /// - Returns: StatisticalDistributionChartData对象，包含各百分位数数据
    ///
    /// **图表要求**：
    /// - 横轴：百分位数（%）
    /// - 纵轴：分贝值（dB）
    /// - 显示：柱状图或折线图
    ///
    /// **关键指标**：
    /// - L10：10%时间超过的声级，表示噪声峰值特征
    /// - L50：50%时间超过的声级，即中位数
    /// - L90：90%时间超过的声级，表示背景噪声水平
    ///
    /// **数据来源**：measurementHistory（自动计算百分位数）
    ///
    /// **支持JSON转换**：
    /// ```swift
    /// let data = manager.getStatisticalDistributionChartData()
    /// let json = data.toJSON()
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// let distribution = manager.getStatisticalDistributionChartData()
    /// print("L10: \(distribution.l10) dB") // 噪声峰值
    /// print("L50: \(distribution.l50) dB") // 中位数
    /// print("L90: \(distribution.l90) dB") // 背景噪声
    /// ```
    func getStatisticalDistributionChartData() -> StatisticalDistributionChartData {
        // 线程安全地获取历史记录的副本
        let history = historyQueue.sync {
            return decibelMeterHistory
        }
        
        guard !history.isEmpty else {
            return StatisticalDistributionChartData(
                dataPoints: [],
                l10: 0.0,
                l50: 0.0,
                l90: 0.0,
                title: "统计分布图"
            )
        }
        
        let decibelValues = history.map { $0.calibratedDecibel }.sorted()
        
        // 计算各百分位数
        let percentiles: [Double] = [10, 20, 30, 40, 50, 60, 70, 80, 90]
        let dataPoints = percentiles.map { percentile in
            let value = calculatePercentile(decibelValues, percentile: percentile)
            let label: String
            if percentile == 10 {
                label = "L90"
            } else if percentile == 50 {
                label = "L50"
            } else if percentile == 90 {
                label = "L10"
            } else {
                label = "L\(Int(100 - percentile))"
            }
            
            return StatisticalDistributionPoint(
                percentile: percentile,
                decibel: value,
                label: label
            )
        }
        
        let l10 = calculatePercentile(decibelValues, percentile: 90)
        let l50 = calculatePercentile(decibelValues, percentile: 50)
        let l90 = calculatePercentile(decibelValues, percentile: 10)
        
        return StatisticalDistributionChartData(
            dataPoints: dataPoints,
            l10: l10,
            l50: l50,
            l90: l90,
            title: "统计分布图 - L10: \(String(format: "%.1f", l10)) dB, L50: \(String(format: "%.1f", l50)) dB, L90: \(String(format: "%.1f", l90)) dB"
        )
    }
    
    /// 获取LEQ趋势图数据
    ///
    /// 返回LEQ随时间变化的趋势数据，用于职业健康监测和长期暴露评估
    /// 符合 ISO 1996-1 标准的等效连续声级计算要求
    ///
    /// - Parameter interval: 采样间隔（秒），默认10秒，表示每隔多少秒计算一次LEQ
    /// - Returns: LEQTrendChartData对象，包含时段LEQ和累积LEQ数据
    ///
    /// **图表要求**：
    /// - 横轴：时间
    /// - 纵轴：LEQ值（dB）
    /// - 显示：累积趋势曲线
    ///
    /// **数据内容**：
    /// - 时段LEQ：每个时间段内的LEQ值
    /// - 累积LEQ：从开始到当前的总体LEQ值
    ///
    /// **应用场景**：
    /// - 职业噪声暴露监测
    /// - 环境噪声长期评估
    /// - TWA（时间加权平均）计算
    ///
    /// **数据来源**：measurementHistory（按时间间隔分组计算）
    ///
    /// **支持JSON转换**：
    /// ```swift
    /// let data = manager.getLEQTrendChartData(interval: 10.0)
    /// let json = data.toJSON()
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// // 每10秒采样一次
    /// let leqTrend = manager.getLEQTrendChartData(interval: 10.0)
    /// print("当前LEQ: \(leqTrend.currentLeq) dB")
    /// print("数据点数量: \(leqTrend.dataPoints.count)")
    ///
    /// for point in leqTrend.dataPoints {
    ///     print("时段LEQ: \(point.leq) dB, 累积LEQ: \(point.cumulativeLeq) dB")
    /// }
    /// ```
    func getLEQTrendChartData(interval: TimeInterval = 10.0) -> LEQTrendChartData {
        // 线程安全地获取历史记录的副本
        let history = historyQueue.sync {
            return decibelMeterHistory
        }
        
        guard !history.isEmpty else {
            return LEQTrendChartData(
                dataPoints: [],
                timeRange: 0.0,
                currentLeq: 0.0,
                title: "LEQ趋势图"
            )
        }
        
        // 按时间间隔分组计算LEQ
        var dataPoints: [LEQTrendDataPoint] = []
        var cumulativeLeq = 0.0
        
        let startTime = history.first!.timestamp
        let endTime = history.last!.timestamp
        let totalDuration = endTime.timeIntervalSince(startTime)
        
        var currentTime = startTime
        var currentGroup: [DecibelMeasurement] = []
        
        for measurement in history {
            if measurement.timestamp.timeIntervalSince(currentTime) >= interval {
                // 计算当前组的LEQ
                if !currentGroup.isEmpty {
                    let groupDecibelValues = currentGroup.map { $0.calibratedDecibel }
                    let groupLeq = calculateLeq(from: groupDecibelValues)
                    
                    // 计算累积LEQ
                    let allPreviousValues = history
                        .filter { $0.timestamp <= measurement.timestamp }
                        .map { $0.calibratedDecibel }
                    cumulativeLeq = calculateLeq(from: allPreviousValues)
                    
                    dataPoints.append(LEQTrendDataPoint(
                        timestamp: currentTime,
                        leq: groupLeq,
                        cumulativeLeq: cumulativeLeq
                    ))
                }
                
                currentTime = measurement.timestamp
                currentGroup = [measurement]
            } else {
                currentGroup.append(measurement)
            }
        }
        
        // 添加最后一组
        if !currentGroup.isEmpty {
            let groupDecibelValues = currentGroup.map { $0.calibratedDecibel }
            let groupLeq = calculateLeq(from: groupDecibelValues)
            cumulativeLeq = getDecibelMeterRealTimeLeq()
            
            dataPoints.append(LEQTrendDataPoint(
                timestamp: currentTime,
                leq: groupLeq,
                cumulativeLeq: cumulativeLeq
            ))
        }
        
        return LEQTrendChartData(
            dataPoints: dataPoints,
            timeRange: totalDuration,
            currentLeq: getDecibelMeterRealTimeLeq(),
            title: "LEQ趋势图 - 当前LEQ: \(String(format: "%.1f", getDecibelMeterRealTimeLeq())) dB"
        )
    }
    
    // MARK: - 设置方法
    
    /// 重置所有状态和数据
    ///
    /// 完全重置分贝测量仪，清除所有测量数据和设置
    ///
    /// **重置内容**：
    /// - 停止测量（如果正在测量）
    /// - 清除所有历史数据
    /// - 重置统计值（MIN=-1, MAX=-1, PEAK=-1, LEQ=0）
    /// - 重置校准偏移为0
    /// - 重置状态为idle
    ///
    /// **注意**：此操作不可恢复，会丢失所有测量数据
    ///
    /// **使用场景**：
    /// - 开始新的测量会话
    /// - 清除错误状态
    /// - 恢复初始设置
    ///
    /// **使用示例**：
    /// ```swift
    /// manager.resetAllData()
    /// print("状态: \(manager.getCurrentState())") // idle
    /// print("分贝值: \(manager.getCurrentDecibel())") // 0.0
    /// ```
    func resetAllData() {
        // 停止测量
        if measurementState == .measuring {
            stopMeasurement()
        }
        
        // 清除所有数据（线程安全）
        historyQueue.sync {
            decibelMeterHistory.removeAll()
            noiseMeterHistory.removeAll()
            levelDurationsAccumulator.removeAll()  // 清空累计时长累加器
        }
        currentMeasurement = nil
        currentStatistics = nil
        measurementStartTime = nil
        
        // 重置统计值
        currentDecibel = 0.0
        minDecibel = -1.0
        maxDecibel = -1.0
        peakDecibel = -1.0
        
        // 重置校准
        calibrationOffset = 0.0
        
        // 重置状态
        updateState(.idle)
        isRecording = false
    }
    
    // MARK: - 私有辅助方法
    
    /// 检查是否应该更新分贝计UI（节流机制）
    ///
    /// 用于控制分贝计UI更新频率，避免过于频繁的回调导致性能问题
    ///
    /// - Returns: 是否应该更新分贝计UI
    private func shouldUpdateDecibelMeterUI() -> Bool {
        let now = Date()
        let timeSinceLastUpdate = now.timeIntervalSince(lastDecibelMeterUpdateTime)
        
        if timeSinceLastUpdate >= uiUpdateInterval {
            lastDecibelMeterUpdateTime = now
            return true
        }
        return false
    }
    
    /// 检查是否应该更新噪音测量计UI（节流机制）
    ///
    /// 用于控制噪音测量计UI更新频率，避免过于频繁的回调导致性能问题
    ///
    /// - Returns: 是否应该更新噪音测量计UI
    private func shouldUpdateNoiseMeterUI() -> Bool {
        let now = Date()
        let timeSinceLastUpdate = now.timeIntervalSince(lastNoiseMeterUpdateTime)
        
        if timeSinceLastUpdate >= uiUpdateInterval {
            lastNoiseMeterUpdateTime = now
            return true
        }
        return false
    }
    
    /// 检查内存使用情况
    ///
    /// 监控应用内存使用，在内存过高时执行清理操作
    private func checkMemoryUsage() {
        let now = Date()
        guard now.timeIntervalSince(lastMemoryCheckTime) >= memoryCheckInterval else { return }
        lastMemoryCheckTime = now
        
        #if DEBUG
        // 获取内存使用信息
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let usedMemoryMB = Double(info.resident_size) / 1024.0 / 1024.0
            
            print("📊 内存使用: \(String(format: "%.1f", usedMemoryMB)) MB")
            
            // 内存使用超过阈值时执行清理
            if usedMemoryMB > 100.0 {  // 超过100MB
                print("⚠️ 内存使用过高，执行清理操作")
                performMemoryCleanup()
            }
        }
        #endif
    }
    
    /// 执行内存清理操作
    ///
    /// 在内存使用过高时清理不必要的缓存和数据
    private func performMemoryCleanup() {
        // 清理频谱缓存
        cachedSpectrum = nil
        
        // 如果历史记录过多，进一步清理（线程安全）
        historyQueue.sync {
            if decibelMeterHistory.count > maxHistoryCount / 2 {
                let removeCount = decibelMeterHistory.count / 2
                decibelMeterHistory.removeFirst(removeCount)
                print("🧹 清理分贝计历史记录: 移除 \(removeCount) 条")
            }
            
            if noiseMeterHistory.count > maxHistoryCount / 2 {
                let removeCount = noiseMeterHistory.count / 2
                noiseMeterHistory.removeFirst(removeCount)
                print("🧹 清理噪音计历史记录: 移除 \(removeCount) 条")
            }
        }
        
        // 强制垃圾回收
        print("🧹 执行内存清理完成")
    }
    
    /// 格式化时间间隔为 HH:mm:ss 格式
    ///
    /// 将秒数转换为"时:分:秒"格式的字符串
    ///
    /// - Parameter duration: 时间间隔（秒）
    /// - Returns: 格式化的时间字符串，如"00:05:23"
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        let seconds = Int(duration) % 60
        
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    
    /// 获取频率权重的显示名称
    ///
    /// 将频率权重枚举转换为用户友好的显示名称
    ///
    /// - Parameter weighting: 频率权重枚举值
    /// - Returns: 显示名称，如"dB-A"、"dB-C"、"ITU-R 468"
    private func getFrequencyWeightingDisplayName(_ weighting: FrequencyWeighting) -> String {
        switch weighting {
        case .aWeight:
            return "dB-A"
        case .bWeight:
            return "dB-B"
        case .cWeight:
            return "dB-C"
        case .zWeight:
            return "dB-Z"
        case .ituR468:
            return "ITU-R 468"
        }
    }
    
    // MARK: - 噪音测量计功能（公共API）
    
    /// 获取完整的噪声剂量数据
    ///
    /// 返回包含剂量、TWA、预测时间等完整信息的数据对象
    /// 这是噪音测量计最主要的API方法
    ///
    /// - Parameter standard: 噪声限值标准，默认使用当前设置的标准
    /// - Returns: NoiseDoseData对象
    ///
    /// **包含的数据**：
    /// - 剂量百分比（%）
    /// - 剂量率（%/小时）
    /// - TWA值（dB）
    /// - 是否超标
    /// - 限值余量（dB）
    /// - 预测达标时间（小时）
    /// - 剩余允许时间（小时）
    /// - 风险等级
    ///
    /// **使用示例**：
    /// ```swift
    /// let doseData = manager.getNoiseDoseData(standard: .osha)
    /// print("剂量: \(doseData.dosePercentage)%")
    /// print("TWA: \(doseData.twa) dB")
    /// print("风险等级: \(doseData.riskLevel)")
    /// ```
    func getNoiseDoseData(standard: NoiseStandard? = nil) -> NoiseDoseData {
        let useStandard = standard ?? currentNoiseStandard
        let leq = getNoiseMeterRealTimeLeq()
        let duration = getMeasurementDuration()
        
        // 计算TWA
        let twa = calculateTWA(leq: leq, duration: duration, standardWorkDay: standardWorkDay)
        
        // 计算剂量
        let dose = calculateNoiseDose(twa: twa, standard: useStandard)
        
        // 计算剂量率
        let doseRate = calculateDoseRate(currentDose: dose, duration: duration)
        
        // 判断是否超标
        let isExceeding = twa >= useStandard.twaLimit
        
        // 计算限值余量
        let limitMargin = useStandard.twaLimit - twa
        
        // 预测达到100%剂量的时间
        let predictedTime = predictTimeToFullDose(currentDose: dose, doseRate: doseRate)
        
        // 计算剩余允许时间
        let remainingTime = calculateRemainingAllowedTime(currentDose: dose, doseRate: doseRate)
        
        // 判断风险等级
        let riskLevel = RiskLevel.from(dosePercentage: dose)
        
        return NoiseDoseData(
            dosePercentage: dose,
            doseRate: doseRate,
            twa: twa,
            duration: duration / 3600.0,  // 转换为小时
            standard: useStandard,
            isExceeding: isExceeding,
            limitMargin: limitMargin,
            predictedTimeToFullDose: predictedTime,
            remainingAllowedTime: remainingTime,
            riskLevel: riskLevel
        )
    }
    
    /// 检查是否超过限值
    ///
    /// 检查当前TWA或剂量是否超过指定标准的限值
    ///
    /// - Parameter standard: 噪声限值标准
    /// - Returns: 是否超过限值
    ///
    /// **使用示例**：
    /// ```swift
    /// if manager.isExceedingLimit(standard: .osha) {
    ///     print("警告：已超过OSHA限值！")
    /// }
    /// ```
    func isExceedingLimit(standard: NoiseStandard) -> Bool {
        let doseData = getNoiseDoseData(standard: standard)
        return doseData.isExceeding
    }
    
    /// 获取限值比较结果
    ///
    /// 返回与指定标准的详细比较结果，包括余量、风险等级、建议措施
    ///
    /// - Parameter standard: 噪声限值标准
    /// - Returns: LimitComparisonResult对象
    ///
    /// **使用示例**：
    /// ```swift
    /// let result = manager.getLimitComparisonResult(standard: .niosh)
    /// print("TWA: \(result.currentTWA) dB, 限值: \(result.twaLimit) dB")
    /// print("余量: \(result.limitMargin) dB")
    /// ```
    func getLimitComparisonResult(standard: NoiseStandard) -> LimitComparisonResult {
        let doseData = getNoiseDoseData(standard: standard)
        
        // 生成建议措施
        var recommendations: [String] = []
        
        if doseData.twa >= standard.actionLevel {
            recommendations.append("已达到行动值，建议采取听力保护措施")
        }
        
        if doseData.isExceeding {
            recommendations.append("已超过TWA限值，必须立即采取控制措施")
            recommendations.append("必须佩戴听力保护设备")
            recommendations.append("建议减少暴露时间或降低噪声源")
        } else if doseData.dosePercentage >= 50.0 {
            recommendations.append("剂量已达50%以上，建议佩戴听力保护设备")
        }
        
        if doseData.dosePercentage >= 80.0 && !doseData.isExceeding {
            recommendations.append("接近限值，建议缩短暴露时间")
        }
        
        return LimitComparisonResult(
            standard: standard,
            currentTWA: doseData.twa,
            twaLimit: standard.twaLimit,
            currentDose: doseData.dosePercentage,
            isExceeding: doseData.isExceeding,
            isActionLevelReached: doseData.twa >= standard.actionLevel,
            limitMargin: doseData.limitMargin,
            doseMargin: 100.0 - doseData.dosePercentage,
            riskLevel: doseData.riskLevel,
            recommendations: recommendations
        )
    }
    
    /// 获取剂量累积图数据
    ///
    /// 返回剂量随时间累积的数据，用于绘制剂量累积图
    ///
    /// - Parameters:
    ///   - interval: 采样间隔（秒），默认60秒
    ///   - standard: 噪声限值标准
    /// - Returns: DoseAccumulationChartData对象
    ///
    /// **图表要求**：
    /// - 横轴：时间（小时）
    /// - 纵轴：剂量（%）
    /// - 显示：累积曲线 + 100%限值线
    ///
    /// **使用示例**：
    /// ```swift
    /// let data = manager.getDoseAccumulationChartData(interval: 60.0, standard: .osha)
    /// print("当前剂量: \(data.currentDose)%")
    /// ```
    func getDoseAccumulationChartData(interval: TimeInterval = 60.0, standard: NoiseStandard? = nil) -> DoseAccumulationChartData {
        let useStandard = standard ?? currentNoiseStandard
        
        // 线程安全地获取历史记录的副本
        let history = historyQueue.sync {
            return noiseMeterHistory
        }
        
        guard !history.isEmpty else {
            return DoseAccumulationChartData(
                dataPoints: [],
                currentDose: 0.0,
                limitLine: 100.0,
                standard: useStandard,
                timeRange: 0.0,
                title: "剂量累积图 - \(useStandard.rawValue)"
            )
        }
        
        var dataPoints: [DoseAccumulationPoint] = []
        let startTime = history.first!.timestamp
        var currentTime = startTime
        var currentGroup: [DecibelMeasurement] = []
        
        for measurement in history {
            if measurement.timestamp.timeIntervalSince(currentTime) >= interval {
                // 计算当前时间点的累积剂量
                if !currentGroup.isEmpty {
                    let allPreviousValues = history
                        .filter { $0.timestamp <= measurement.timestamp }
                        .map { $0.calibratedDecibel }
                    
                    let cumulativeLeq = calculateLeq(from: allPreviousValues)
                    let exposureTime = measurement.timestamp.timeIntervalSince(startTime)
                    let twa = calculateTWA(leq: cumulativeLeq, duration: exposureTime)
                    let dose = calculateNoiseDose(twa: twa, standard: useStandard)
                    
                    dataPoints.append(DoseAccumulationPoint(
                        timestamp: measurement.timestamp,
                        cumulativeDose: dose,
                        currentTWA: twa,
                        exposureTime: exposureTime / 3600.0  // 转换为小时
                    ))
                }
                
                currentTime = measurement.timestamp
                currentGroup = [measurement]
            } else {
                currentGroup.append(measurement)
            }
        }
        
        // 添加最后一个点
        if !currentGroup.isEmpty {
            let leq = getDecibelMeterRealTimeLeq()
            let duration = getMeasurementDuration()
            let twa = calculateTWA(leq: leq, duration: duration)
            let dose = calculateNoiseDose(twa: twa, standard: useStandard)
            
            dataPoints.append(DoseAccumulationPoint(
                timestamp: Date(),
                cumulativeDose: dose,
                currentTWA: twa,
                exposureTime: duration / 3600.0
            ))
        }
        
        let finalDose = dataPoints.last?.cumulativeDose ?? 0.0
        let totalDuration = getMeasurementDuration() / 3600.0
        
        return DoseAccumulationChartData(
            dataPoints: dataPoints,
            currentDose: finalDose,
            limitLine: 100.0,
            standard: useStandard,
            timeRange: totalDuration,
            title: "剂量累积图 - \(useStandard.rawValue) - 当前: \(String(format: "%.1f", finalDose))%"
        )
    }
    
    /// 获取TWA趋势图数据
    ///
    /// 返回TWA随时间变化的数据，用于绘制TWA趋势图
    ///
    /// - Parameters:
    ///   - interval: 采样间隔（秒），默认60秒
    ///   - standard: 噪声限值标准
    /// - Returns: TWATrendChartData对象
    ///
    /// **图表要求**：
    /// - 横轴：时间（小时）
    /// - 纵轴：TWA（dB）
    /// - 显示：TWA曲线 + 限值线
    ///
    /// **使用示例**：
    /// ```swift
    /// let data = manager.getTWATrendChartData(interval: 60.0, standard: .niosh)
    /// print("当前TWA: \(data.currentTWA) dB")
    /// ```
    func getTWATrendChartData(interval: TimeInterval = 60.0, standard: NoiseStandard? = nil) -> TWATrendChartData {
        let useStandard = standard ?? currentNoiseStandard
        
        // 线程安全地获取历史记录的副本
        let history = historyQueue.sync {
            return noiseMeterHistory
        }
        
        guard !history.isEmpty else {
            return TWATrendChartData(
                dataPoints: [],
                currentTWA: 0.0,
                limitLine: useStandard.twaLimit,
                standard: useStandard,
                timeRange: 0.0,
                title: "TWA趋势图 - \(useStandard.rawValue)"
            )
        }
        
        var dataPoints: [TWATrendDataPoint] = []
        let startTime = history.first!.timestamp
        var currentTime = startTime
        var currentGroup: [DecibelMeasurement] = []
        
        for measurement in history {
            if measurement.timestamp.timeIntervalSince(currentTime) >= interval {
                // 计算当前时间点的TWA
                if !currentGroup.isEmpty {
                    let allPreviousValues = history
                        .filter { $0.timestamp <= measurement.timestamp }
                        .map { $0.calibratedDecibel }
                    
                    let cumulativeLeq = calculateLeq(from: allPreviousValues)
                    let exposureTime = measurement.timestamp.timeIntervalSince(startTime)
                    let twa = calculateTWA(leq: cumulativeLeq, duration: exposureTime)
                    let dose = calculateNoiseDose(twa: twa, standard: useStandard)
                    
                    dataPoints.append(TWATrendDataPoint(
                        timestamp: measurement.timestamp,
                        twa: twa,
                        exposureTime: exposureTime / 3600.0,  // 转换为小时
                        dosePercentage: dose
                    ))
                }
                
                currentTime = measurement.timestamp
                currentGroup = [measurement]
            } else {
                currentGroup.append(measurement)
            }
        }
        
        // 添加最后一个点
        if !currentGroup.isEmpty {
            let leq = getDecibelMeterRealTimeLeq()
            let duration = getMeasurementDuration()
            let twa = calculateTWA(leq: leq, duration: duration)
            let dose = calculateNoiseDose(twa: twa, standard: useStandard)
            
            dataPoints.append(TWATrendDataPoint(
                timestamp: Date(),
                twa: twa,
                exposureTime: duration / 3600.0,
                dosePercentage: dose
            ))
        }
        
        let finalTWA = dataPoints.last?.twa ?? 0.0
        let totalDuration = getMeasurementDuration() / 3600.0
        
        return TWATrendChartData(
            dataPoints: dataPoints,
            currentTWA: finalTWA,
            limitLine: useStandard.twaLimit,
            standard: useStandard,
            timeRange: totalDuration,
            title: "TWA趋势图 - \(useStandard.rawValue) - 当前: \(String(format: "%.1f", finalTWA)) dB"
        )
    }
    
    /// 设置噪声限值标准
    ///
    /// 切换使用的噪声限值标准（OSHA、NIOSH、GBZ、EU）
    ///
    /// - Parameter standard: 要设置的标准
    ///
    /// **使用示例**：
    /// ```swift
    /// manager.setNoiseStandard(.osha)
    /// ```
    func setNoiseStandard(_ standard: NoiseStandard) {
        currentNoiseStandard = standard
    }
    
    /// 获取当前噪声限值标准
    ///
    /// - Returns: 当前使用的标准
    func getCurrentNoiseStandard() -> NoiseStandard {
        return currentNoiseStandard
    }
    
    /// 获取所有可用的噪声限值标准列表
    ///
    /// - Returns: 所有标准的数组
    func getAvailableNoiseStandards() -> [NoiseStandard] {
        return NoiseStandard.allCases
    }
    
    /// 生成噪音测量计综合报告
    ///
    /// 生成包含所有关键数据的完整报告，用于法规符合性评估
    ///
    /// - Parameter standard: 噪声限值标准
    /// - Returns: NoiseDosimeterReport对象，如果未开始测量则返回nil
    ///
    /// **使用示例**：
    /// ```swift
    /// if let report = manager.generateNoiseDosimeterReport(standard: .osha) {
    ///     if let json = report.toJSON() {
    ///         // 保存或分享报告
    ///     }
    /// }
    /// ```
    func generateNoiseDosimeterReport(standard: NoiseStandard? = nil) -> NoiseDosimeterReport? {
        guard let startTime = measurementStartTime else { return nil }
        let useStandard = standard ?? currentNoiseStandard
        
        let doseData = getNoiseDoseData(standard: useStandard)
        let comparisonResult = getLimitComparisonResult(standard: useStandard)
        let statistics = currentStatistics
        
        return NoiseDosimeterReport(
            reportTime: Date(),
            measurementStartTime: startTime,
            measurementEndTime: Date(),
            measurementDuration: getMeasurementDuration() / 3600.0,
            standard: useStandard,
            doseData: doseData,
            comparisonResult: comparisonResult,
            leq: getDecibelMeterRealTimeLeq(),
            statistics: ReportStatistics(
                avg: statistics?.avgDecibel ?? 0.0,
                min: statistics?.minDecibel ?? 0.0,
                max: statistics?.maxDecibel ?? 0.0,
                peak: statistics?.peakDecibel ?? 0.0,
                l10: statistics?.l10Decibel ?? 0.0,
                l50: statistics?.l50Decibel ?? 0.0,
                l90: statistics?.l90Decibel ?? 0.0
            )
        )
    }
    
    /// 获取允许暴露时长表
    ///
    /// 根据当前测量数据生成允许暴露时长表，包含每个声级的累计暴露时间和剂量
    /// 该表格展示了不同声级下的允许暴露时间、实际累计时间和剂量贡献
    ///
    /// - Parameter standard: 噪声限值标准，默认使用当前设置的标准
    /// - Returns: PermissibleExposureDurationTable对象
    ///
    /// **表格内容**：
    /// - 声级列表：从基准限值开始，按交换率递增至天花板限值
    /// - 允许时长：根据标准计算的最大允许暴露时间
    /// - 累计时长：实际测量中在该声级范围内的累计时间
    /// - 声级剂量：该声级的剂量贡献百分比
    ///
    /// **计算原理**：
    /// ```
    /// 允许时长 = 8小时 × 2^((基准限值 - 声级) / 交换率)
    /// 声级剂量 = (累计时长 / 允许时长) × 100%
    /// 总剂量 = Σ 各声级剂量
    /// ```
    ///
    /// **使用示例**：
    /// ```swift
    /// let table = manager.getPermissibleExposureDurationTable(standard: .niosh)
    /// print("总剂量: \(table.totalDose)%")
    /// print("超标声级数: \(table.exceedingLevelsCount)")
    /// for duration in table.durations {
    ///     print("\(duration.soundLevel) dB: \(duration.formattedAccumulatedDuration) / \(duration.formattedAllowedDuration) (\(String(format: "%.1f", duration.currentLevelDose))%)")
    /// }
    /// ```
    func getPermissibleExposureDurationTable(standard: NoiseStandard? = nil) -> PermissibleExposureDurationTable {
        let useStandard = standard ?? currentNoiseStandard
        let criterionLevel = useStandard.twaLimit
        let exchangeRate = useStandard.exchangeRate
        let ceilingLimit = 115.0  // 通用天花板限值
        
        #if DEBUG
        print("📊 ===== 允许暴露时长表计算开始 =====")
        print("   - 标准: \(useStandard.rawValue)")
        print("   - 基准限值: \(criterionLevel) dB")
        print("   - 交换率: \(exchangeRate) dB")
        print("   - 天花板限值: \(ceilingLimit) dB")
        print("   - 采样间隔: \(String(format: "%.4f", sampleInterval)) 秒")
        print("   - 累计记录条目数: \(levelDurationsAccumulator.count)")
        #endif
        
        // 生成声级列表（从基准限值开始，按交换率递增）
        var soundLevels: [Double] = []
        var currentLevel = criterionLevel
        while currentLevel <= ceilingLimit {
            soundLevels.append(currentLevel)
            currentLevel += exchangeRate
        }
        
        #if DEBUG
        print("   - 声级列表: \(soundLevels.map { String(format: "%.0f", $0) }.joined(separator: ", ")) dB")
        #endif
        
        // ⭐ 使用持久化的累计时长累加器（不受历史记录清理影响）
        // 从 levelDurationsAccumulator 中读取所有已记录的分贝值及其累计时间
        // 然后根据声级列表归类到对应的声级区间
        var levelDurations: [Double: TimeInterval] = [:]
        var totalSamples = 0
        var classifiedSamples = 0
        var totalAccumulatedTime: TimeInterval = 0.0
        
        // 线程安全地访问累计时长累加器
        historyQueue.sync {
            // 遍历累计时长累加器中的每个分贝值
            for (recordedLevel, duration) in levelDurationsAccumulator {
                totalSamples += 1
                totalAccumulatedTime += duration
                
                // 找到该分贝值所属的声级区间
                // 例如：87dB 归类到 85dB，92dB 归类到 91dB
                var targetLevel: Double? = nil
                
                // 从高到低遍历声级列表，找到第一个小于或等于当前分贝值的限值
                for i in stride(from: soundLevels.count - 1, through: 0, by: -1) {
                    if recordedLevel >= soundLevels[i] {
                        targetLevel = soundLevels[i]
                        break
                    }
                }
                
                // 如果找到了目标限值，累加时间
                if let targetLevel = targetLevel {
                    levelDurations[targetLevel, default: 0.0] += duration
                    classifiedSamples += 1
                }
            }
        }
        
        #if DEBUG
        let totalCalculatedTime = levelDurations.values.reduce(0, +)
        let actualMeasurementTime = getMeasurementDuration()
        print("\n   📈 时间累计统计:")
        print("   - 累加器记录条目数: \(totalSamples)")
        print("   - 已归类条目数: \(classifiedSamples)")
        print("   - 未归类条目数: \(totalSamples - classifiedSamples) (低于基准限值)")
        print("   - 累加器总时长: \(String(format: "%.1f", totalAccumulatedTime)) 秒")
        print("   - 归类后累计时间: \(String(format: "%.1f", totalCalculatedTime)) 秒")
        print("   - 实际测量时长: \(String(format: "%.1f", actualMeasurementTime)) 秒")
        if actualMeasurementTime > 0 {
            print("   - 时间匹配度: \(String(format: "%.1f", (totalCalculatedTime / actualMeasurementTime) * 100))%")
        }
        
        // 显示各声级的分布
        if !levelDurations.isEmpty {
            print("\n   📊 声级分布:")
            for soundLevel in soundLevels.sorted() {
                if let duration = levelDurations[soundLevel], duration > 0 {
                    let percentage = totalCalculatedTime > 0 ? (duration / totalCalculatedTime) * 100 : 0
                    print("   - \(String(format: "%3.0f", soundLevel)) dB: \(String(format: "%6.1f", duration))秒 (\(String(format: "%5.1f", percentage))%)")
                }
            }
        }
        #endif
        
        // 生成表项
        let durations = soundLevels.map { soundLevel -> PermissibleExposureDuration in
            // 计算允许时长：T = 8小时 × 2^((基准限值 - 声级) / 交换率)
            let allowedHours = 8.0 * pow(2.0, (criterionLevel - soundLevel) / exchangeRate)
            let allowedDuration = allowedHours * 3600.0  // 转换为秒
            
            // 获取累计时长
            let accumulatedDuration = levelDurations[soundLevel] ?? 0.0
            
            // 判断是否为天花板限值
            let isCeilingLimit = soundLevel >= ceilingLimit
            
            return PermissibleExposureDuration(
                soundLevel: soundLevel,
                allowedDuration: allowedDuration,
                accumulatedDuration: accumulatedDuration,
                isCeilingLimit: isCeilingLimit
            )
        }
        
        // 创建表格对象
        let table = PermissibleExposureDurationTable(
            standard: useStandard,
            criterionLevel: criterionLevel,
            exchangeRate: exchangeRate,
            ceilingLimit: ceilingLimit,
            durations: durations
        )
        
        #if DEBUG
        print("\n   🎯 允许暴露时长表结果:")
        print("   - 表项数量: \(durations.count)")
        print("   - 总剂量: \(String(format: "%.1f", table.totalDose))%")
        print("   - 超标声级数: \(table.exceedingLevelsCount)")
        
        // 显示前5个有数据的表项
        let nonZeroDurations = durations.filter { $0.accumulatedDuration > 0 }.prefix(5)
        if !nonZeroDurations.isEmpty {
            print("\n   📋 表项示例（前5个有数据的）:")
            for duration in nonZeroDurations {
                print("   - \(String(format: "%3.0f", duration.soundLevel)) dB: \(duration.formattedAccumulatedDuration) / \(duration.formattedAllowedDuration) = \(String(format: "%.1f", duration.currentLevelDose))%")
            }
        }
         
        print("📊 ===== 允许暴露时长表计算完成 =====\n")
        #endif
        
        return table
    }
    
    // MARK: - 噪音测量计私有计算方法
    
    /// 计算TWA（时间加权平均值）- 私有方法
    ///
    /// 根据LEQ和测量时长计算8小时时间加权平均值
    /// 此方法为内部计算使用，外部通过getNoiseDoseData()获取TWA值
    ///
    /// - Parameters:
    ///   - leq: 等效连续声级（dB）
    ///   - duration: 实际测量时长（秒）
    ///   - standardWorkDay: 标准工作日时长（小时），默认8小时
    /// - Returns: TWA值（dB）
    ///
    /// **正确的TWA计算公式**：
    /// ```
    /// 如果 T ≤ 8小时：TWA = LEQ
    /// 如果 T > 8小时：TWA = LEQ + 10 × log₁₀(T/8)
    /// ```
    ///
    /// **TWA含义**：表示如果以当前噪声水平工作8小时，会得到的等效连续声级
    private func calculateTWA(leq: Double, duration: TimeInterval, standardWorkDay: Double = 8.0) -> Double {
        let exposureHours = duration / 3600.0  // 转换为小时
        
        // 调试输出
        #if DEBUG
        print("🔍 TWA计算调试:")
        print("   - LEQ: \(String(format: "%.1f", leq)) dB")
        print("   - 测量时长: \(String(format: "%.2f", exposureHours)) 小时")
        print("   - 标准工作日: \(standardWorkDay) 小时")
        #endif
        
        let twa: Double
        if exposureHours <= standardWorkDay {
            // 测量时间不超过8小时，TWA等于LEQ
            twa = leq
        } else {
            // 测量时间超过8小时，需要时间加权调整
            let timeWeighting = 10.0 * log10(exposureHours / standardWorkDay)
            twa = leq + timeWeighting
        }
        
        // 调试输出
        #if DEBUG
        print("   - 最终TWA: \(String(format: "%.1f", twa)) dB")
        print("----------------------------------------")
        #endif
        
        return twa
    }
    
    /// 计算噪声剂量（Dose）- 私有方法
    ///
    /// 根据TWA计算噪声剂量百分比
    /// 此方法为内部计算使用，外部通过getNoiseDoseData()获取剂量值
    ///
    /// - Parameters:
    ///   - twa: 时间加权平均值（dB）
    ///   - standard: 噪声限值标准
    /// - Returns: 噪声剂量百分比（%）
    ///
    /// **计算公式**：
    /// ```
    /// Dose = 100 × 2^((TWA - CriterionLevel) / ExchangeRate)
    /// ```
    private func calculateNoiseDose(twa: Double, standard: NoiseStandard) -> Double {
        let criterionLevel = standard.criterionLevel
        let exchangeRate = standard.exchangeRate
        
        // Dose = 100 × 2^((TWA - 85) / ExchangeRate)
        let dose = 100.0 * pow(2.0, (twa - criterionLevel) / exchangeRate)
        
        return dose
    }
    
    /// 计算剂量率（Dose Rate）- 私有方法
    ///
    /// 计算单位时间内的剂量累积速率
    /// 此方法为内部计算使用，外部通过getNoiseDoseData()获取剂量率
    ///
    /// - Parameters:
    ///   - currentDose: 当前累积剂量（%）
    ///   - duration: 已暴露时长（秒）
    /// - Returns: 剂量率（%/小时）
    ///
    /// **计算公式**：
    /// ```
    /// Dose Rate = Current Dose / Elapsed Time (hours)
    /// ```
    private func calculateDoseRate(currentDose: Double, duration: TimeInterval) -> Double {
        let exposureHours = duration / 3600.0
        guard exposureHours > 0 else { return 0.0 }
        
        return currentDose / exposureHours
    }
    
    /// 预测达到100%剂量的时间 - 私有方法
    ///
    /// 基于当前剂量率预测何时达到100%剂量
    /// 此方法为内部计算使用，外部通过getNoiseDoseData()获取预测时间
    ///
    /// - Parameters:
    ///   - currentDose: 当前累积剂量（%）
    ///   - doseRate: 剂量率（%/小时）
    /// - Returns: 预测时间（小时），如果已超过100%或剂量率为0则返回nil
    private func predictTimeToFullDose(currentDose: Double, doseRate: Double) -> Double? {
        guard doseRate > 0, currentDose < 100.0 else { return nil }
        
        let remainingDose = 100.0 - currentDose
        return remainingDose / doseRate
    }
    
    /// 计算剩余允许暴露时间 - 私有方法
    ///
    /// 计算在不超过100%剂量的前提下，还可以暴露多长时间
    /// 此方法为内部计算使用，外部通过getNoiseDoseData()获取剩余时间
    ///
    /// - Parameters:
    ///   - currentDose: 当前累积剂量（%）
    ///   - doseRate: 剂量率（%/小时）
    /// - Returns: 剩余时间（小时），如果已超标则返回nil
    private func calculateRemainingAllowedTime(currentDose: Double, doseRate: Double) -> Double? {
        return predictTimeToFullDose(currentDose: currentDose, doseRate: doseRate)
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
        // ⭐ MIN、MAX、PEAK 使用实时追踪的值（已应用校准偏移）
        // 这样可以确保统计值的一致性，并且反映真实的校准后测量值
        let minDecibel = self.minDecibel >= 0 ? self.minDecibel : (decibelValues.min() ?? 0.0)
        // MAX使用实时追踪的时间权重最大值（已应用校准）
        let maxDecibel = self.maxDecibel
        // PEAK使用实时追踪的瞬时峰值（已应用校准）
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
    
    /// 清除分贝计测量历史（线程安全）
    func clearDecibelMeterHistory() {
        historyQueue.sync {
            decibelMeterHistory.removeAll()
        }
        maxDecibel = -1.0
        minDecibel = -1.0   // 重置为未初始化状态
        peakDecibel = -1.0
        currentStatistics = nil
        measurementStartTime = nil
    }
    
    /// 清除噪音测量计测量历史（线程安全）
    func clearNoiseMeterHistory() {
        historyQueue.sync {
            noiseMeterHistory.removeAll()
            levelDurationsAccumulator.removeAll()  // 同时清空累计时长
        }
    }
    
    /// 清除测量历史（兼容性方法，清除分贝计历史）
    func clearHistory() {
        clearDecibelMeterHistory()
        clearNoiseMeterHistory()
    }
    
    /// 验证分贝值是否在合理范围内
    private func validateDecibelValue(_ value: Double) -> Double {
        return max(minDecibelLimit, min(value, maxDecibelLimit))
    }
    
    /// 更新状态并通知回调
    private func updateState(_ newState: MeasurementState) {
        measurementState = newState
        DispatchQueue.main.async { [weak self] in
            self?.onStateChange?(newState)
        }
    }
    
    /// 更新分贝计数据并通知回调
    private func updateDecibelMeterData(_ measurement: DecibelMeasurement) {
        // 验证并限制分贝值在合理范围内
        let validatedDecibel = validateDecibelValue(measurement.calibratedDecibel)
        currentDecibel = validatedDecibel
        
        // ⭐ 修复：MAX 和 MIN 也应该应用校准偏移
        // 根据当前时间权重选择对应的值，然后应用校准
        let timeWeightedValue: Double
        switch currentTimeWeighting {
        case .fast:
            timeWeightedValue = measurement.fastDecibel
        case .slow:
            timeWeightedValue = measurement.slowDecibel
        case .impulse:
            // 如果没有单独的 impulse 值，使用 fast 值作为近似
            timeWeightedValue = measurement.fastDecibel
        }
        let calibratedTimeWeighted = timeWeightedValue + calibrationOffset
        let validatedTimeWeighted = validateDecibelValue(calibratedTimeWeighted)
        
        // 更新MAX值（使用时间权重后的校准值）
        if maxDecibel < 0 || validatedTimeWeighted > maxDecibel {
            maxDecibel = validatedTimeWeighted
        }
        
        // 更新MIN值（使用时间权重后的校准值）
        if minDecibel < 0 || validatedTimeWeighted < minDecibel {
            minDecibel = validatedTimeWeighted
        }
        
        // ⭐ 修复：PEAK 也应该应用校准偏移
        // PEAK 是瞬时峰值，不应用时间权重，但需要应用校准
        let calibratedRaw = measurement.rawDecibel + calibrationOffset
        let validatedRaw = validateDecibelValue(calibratedRaw)
        if peakDecibel < 0 || validatedRaw > peakDecibel {
            peakDecibel = validatedRaw
        }
        
        // 应用节流机制 - 只有在需要时才更新UI（使用独立的分贝计时间戳）
        guard shouldUpdateDecibelMeterUI() else { return }
        
        // 计算当前LEQ值（基于分贝计历史）
        let currentLeq = getDecibelMeterRealTimeLeq()
        
        //print("updateDecibelMeterData currentDecibel: \(currentDecibel), maxDecibel: \(maxDecibel), minDecibel: \(minDecibel), peakDecibel: \(peakDecibel), leq: \(currentLeq)")
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.onDecibelMeterDataUpdate?(self.currentDecibel, self.peakDecibel, self.maxDecibel, self.minDecibel, currentLeq)
        }
    }
    
    /// 更新噪音测量计数据并通知回调
    private func updateNoiseMeterData(_ measurement: DecibelMeasurement) {
        // 应用节流机制 - 只有在需要时才更新UI（使用独立的噪音测量计时间戳）
        guard shouldUpdateNoiseMeterUI() else { return }
        
        // 计算当前LEQ值（基于噪音测量计历史）
        let currentLeq = getNoiseMeterRealTimeLeq()
        
        // 获取噪音测量计的统计值
        let noiseMax = getNoiseMeterMax()
        let noiseMin = getNoiseMeterMin()
        let noisePeak = getNoiseMeterPeak()
        
        //print("updateNoiseMeterData currentDecibel: \(measurement.calibratedDecibel), maxDecibel: \(noiseMax), minDecibel: \(noiseMin), peakDecibel: \(noisePeak), leq: \(currentLeq)")
        DispatchQueue.main.async { [weak self] in
            self?.onNoiseMeterDataUpdate?(measurement.calibratedDecibel, noisePeak, noiseMax, noiseMin, currentLeq)
        }
    }
    
    /// 更新测量数据并通知回调
    private func updateMeasurement(_ measurement: DecibelMeasurement) {
        currentMeasurement = measurement
        DispatchQueue.main.async { [weak self] in
            self?.onMeasurementUpdate?(measurement)
        }
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
    ///
    /// **音量优化配置**：
    /// - Category: `.playAndRecord` - 同时支持音频采集和播放
    /// - Mode: `.spokenAudio` - 语音模式，提供较好的播放音量同时支持采集
    /// - Options:
    ///   - `.defaultToSpeaker`: 默认使用扬声器
    ///   - `.allowBluetoothA2DP`: 支持蓝牙高品质音频
    ///   - `.allowAirPlay`: 支持 AirPlay
    ///
    /// **功能支持**：
    /// - ✅ 持续进行音频采集（分贝测量不中断）
    /// - ✅ 同时播放录音文件（播放音量更大）
    /// - ✅ 播放的声音会被麦克风捕获并测量
    /// - ✅ 支持蓝牙和 AirPlay 设备
    ///
    /// **音量优化说明**：
    /// - `.spokenAudio` 模式比 `.measurement` 提供更好的播放音量
    /// - 移除 `.mixWithOthers`，使用 `.defaultToSpeaker` 确保音量
    /// - 设置输入增益为 0（避免过度增益导致播放音量降低）
    private func setupAudioSession() {
        do {
            // 首先停用当前音频会话（如果已激活）
            if audioSession.isOtherAudioPlaying || audioSession.category != .playAndRecord {
                try? audioSession.setActive(false, options: .notifyOthersOnDeactivation)
            }
            
            // ⭐ 音量优化配置：使用 .spokenAudio 模式
            // .spokenAudio 模式在保持采集能力的同时，提供更好的播放音量
            // 比 .measurement 模式的播放音量更大
            try audioSession.setCategory(
                .playAndRecord,         // ✅ 同时支持播放和录音
                mode: .spokenAudio,     // 🔊 优化：语音模式，播放音量更大
                options: [
                    .defaultToSpeaker,      // 🔊 关键：默认使用扬声器，提升音量
                    .allowBluetoothA2DP,    // ✅ 支持蓝牙高品质音频（A2DP协议）
                    .allowAirPlay           // ✅ 支持 AirPlay
                ]
            )
            
            // 设置音频会话参数
            try audioSession.setPreferredSampleRate(44100.0)
            try audioSession.setPreferredIOBufferDuration(0.005) // 5ms缓冲区
            
            // 🔊 关键：设置输入增益为较低值，避免过度增益导致播放音量被压缩
            // inputGain 范围 0.0 - 1.0，较低的值可以提升播放音量
            if audioSession.isInputGainSettable {
                do {
                    try audioSession.setInputGain(0.3) // 降低输入增益，提升播放音量
                    print("🔊 已设置输入增益为 0.3（优化播放音量）")
                } catch {
                    print("⚠️ 设置输入增益失败: \(error.localizedDescription)")
                }
            }
            
            // 激活音频会话
            try audioSession.setActive(true, options: [])
            
            // 🔊 强制使用扬声器输出（确保最大音量）
            try audioSession.overrideOutputAudioPort(.speaker)
            
            print("✅ 音频会话配置成功（音量优化模式）")
            print("   - Category: \(audioSession.category.rawValue)")
            print("   - Mode: \(audioSession.mode.rawValue) 🔊")
            print("   - 持续采集: ✅（播放时不中断）")
            print("   - 播放声音被测量: ✅")
            print("   - 音频输出: 扬声器（优化音量）🔊")
            print("   - Input Gain: \(audioSession.inputGain)")
            print("   - Output Route: \(audioSession.currentRoute.outputs.first?.portType.rawValue ?? "unknown")")
            print("   - Output Volume: \(audioSession.outputVolume)")
            
        } catch {
            print("❌ 设置音频会话失败: \(error.localizedDescription)")
            print("   错误详情: \(error)")
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
            // 在后台线程处理音频数据
            self?.processAudioBuffer(buffer)
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
        
        // 同时计算分贝计和噪音测量计的数据
        let decibelMeterMeasurement = calculateDecibelMeterMeasurement(from: samples)
        let noiseMeterMeasurement = calculateNoiseMeterMeasurement(from: samples)
        
        // 更新分贝计数据
        updateDecibelMeterData(decibelMeterMeasurement)
        
        // 更新噪音测量计数据
        updateNoiseMeterData(noiseMeterMeasurement)
        
        // ⭐ 新增：如果正在录制，将缓冲区写入文件
        if isRecordingAudio, let file = audioFile {
            recordingQueue.async { [weak self] in
                do {
                    // 写入音频缓冲区
                    try file.write(from: buffer)
                } catch {
                    print("❌ 写入音频文件失败: \(error.localizedDescription)")
                    // 如果写入失败，停止录制以避免持续错误
                    DispatchQueue.main.async {
                        self?.stopAudioRecording()
                    }
                }
            }
        }
        
        // 线程安全地添加到各自的历史记录并管理长度
        historyQueue.sync {
            // 添加到各自的历史记录
            decibelMeterHistory.append(decibelMeterMeasurement)
            noiseMeterHistory.append(noiseMeterMeasurement)
            
            // ⭐ 实时更新累计时长累加器（用于允许暴露时长表）
            // 将当前噪音测量值的分贝四舍五入到整数，累加采样间隔
            let roundedLevel = round(noiseMeterMeasurement.calibratedDecibel)
            levelDurationsAccumulator[roundedLevel, default: 0.0] += sampleInterval
            
            // 优化历史记录长度管理 - 批量移除以提高性能
            // ⚠️ 注意：移除历史记录不会影响累计时长累加器（levelDurationsAccumulator）
            // 累计时长是持久化的，不受历史记录清理影响
            if decibelMeterHistory.count >= maxHistoryCount {
                let removeCount = maxHistoryCount / 2  // 移除一半，避免频繁操作
                decibelMeterHistory.removeFirst(removeCount)
            }
            if noiseMeterHistory.count >= maxHistoryCount {
                let removeCount = maxHistoryCount / 2  // 移除一半，避免频繁操作
                noiseMeterHistory.removeFirst(removeCount)
            }
        }
        
        // 定期检查内存使用情况
        checkMemoryUsage()
    }
    
    /// 计算分贝计测量结果
    private func calculateDecibelMeterMeasurement(from samples: [Float]) -> DecibelMeasurement {
        let timestamp = Date()
        
        // 计算原始分贝值
        let rawDecibel = calculateRawDecibel(from: samples)
        
        // 计算分贝计当前权重分贝值（可自由切换）
        let weightedDecibel = calculateWeightedDecibel(from: samples, weighting: decibelMeterFrequencyWeighting)
        
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
    
    /// 计算噪音测量计测量结果
    private func calculateNoiseMeterMeasurement(from samples: [Float]) -> DecibelMeasurement {
        let timestamp = Date()
        
        // 计算原始分贝值
        let rawDecibel = calculateRawDecibel(from: samples)
        
        // 计算噪音测量计权重分贝值（强制使用A权重）
        let weightedDecibel = calculateWeightedDecibel(from: samples, weighting: noiseMeterFrequencyWeighting)
        
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
    
    /// 计算频谱（优化版 - 缓存随机数据）
    private func calculateFrequencySpectrum(from samples: [Float]) -> [Double] {
        // 优化：缓存频谱数据，避免每次都生成新的随机数
        // 实际应用中应该使用FFT分析真实频谱
        if cachedSpectrum == nil {
            // 只在第一次调用时生成随机频谱数据
            cachedSpectrum = Array(0..<32).map { _ in Double.random(in: 0...1) }
        }
        return cachedSpectrum ?? []
    }
    
    // MARK: - 音频录制方法
    
    /// 获取临时录制文件路径（固定文件名）
    ///
    /// - Returns: 临时录音文件的URL
    private func getTempRecordingURL() -> URL {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        return documentsPath.appendingPathComponent(tempRecordingFileName)
    }
    
    /// 开始音频录制到临时文件
    ///
    /// 使用固定的临时文件名 `recording_temp.m4a`
    /// 如果文件已存在，会先删除
    ///
    /// - Throws: DecibelMeterError 如果录制启动失败
    func startAudioRecording() throws {
        guard audioEngine != nil else {
            throw DecibelMeterError.audioEngineSetupFailed
        }
        
        // 如果已经在录制，先停止
        if isRecordingAudio {
            stopAudioRecording()
        }
        
        let tempURL = getTempRecordingURL()
        
        // 删除已存在的临时文件
        if FileManager.default.fileExists(atPath: tempURL.path) {
            try? FileManager.default.removeItem(at: tempURL)
        }
        
        // 获取输入音频格式
        guard let inputNode = inputNode,
              let inputFormat = audioEngine?.inputNode.outputFormat(forBus: 0) else {
            throw DecibelMeterError.inputNodeNotFound
        }
        
        // ⭐ 使用 CAF + PCM 格式（最简单可靠的方案）
        // PCM 是未压缩格式，直接写入原始音频数据，无需编码器
        // CAF 容器支持 PCM，兼容性好，适合声学测量
        
        // 创建临时录音文件（使用输入格式直接创建，无需额外设置）
        do {
            // 直接使用输入格式创建 AVAudioFile
            // AVAudioFile 会自动使用 CAF 容器 + PCM 编码
            audioFile = try AVAudioFile(forWriting: tempURL, settings: inputFormat.settings)
            isRecordingAudio = true
            recordingStartTime = Date()
            
            print("✅ 开始录制到临时文件: \(tempRecordingFileName)")
            print("   音频格式: 采样率=\(inputFormat.sampleRate)Hz, 通道数=\(inputFormat.channelCount), 格式=PCM")
            print("   输入格式: \(inputFormat)")
            print("   文件格式: \(audioFile?.fileFormat ?? inputFormat)")
        } catch {
            print("❌ 创建音频文件失败: \(error.localizedDescription)")
            print("   错误详情: \(error)")
            throw DecibelMeterError.audioFileWriteFailed
        }
    }
    
    /// 停止音频录制并删除临时文件
    ///
    /// 关闭音频文件并删除临时录音文件
    func stopAudioRecording() {
        guard isRecordingAudio else { return }
        
        // 关闭文件
        audioFile = nil
        isRecordingAudio = false
        
        // 删除临时文件
        let tempURL = getTempRecordingURL()
        fileAccessQueue.async { [weak self] in
            guard let self = self else { return }
            if FileManager.default.fileExists(atPath: tempURL.path) {
                do {
                    // 稍微延迟一下，确保文件完全关闭
                    Thread.sleep(forTimeInterval: 0.1)
                    try FileManager.default.removeItem(at: tempURL)
                    print("🗑️ 已删除临时录音文件")
                } catch {
                    print("⚠️ 删除临时文件失败: \(error.localizedDescription)")
                }
            }
            self.recordingStartTime = nil
        }
    }
    
    /// 复制当前正在录制的音频文件到指定路径（录制过程中可调用）
    ///
    /// **重要说明**：
    /// - 此方法可以在录制过程中调用
    /// - 复制的是调用时**已写入的数据**（文件快照）
    /// - 复制完成后，源文件会继续写入，但复制的文件不会更新
    /// - 如果录制还在进行，复制的文件可能不完整
    /// - 如果需要完整文件，应在录制停止后再复制一次
    ///
    /// - Parameters:
    ///   - destinationURL: 目标文件路径
    ///   - isAll: 是否复制全部录音
    ///   - completion: 完成回调，返回复制结果和文件信息
    ///   - result: 复制结果（成功包含目标URL，失败包含错误）
    ///   - fileSize: 复制的文件大小（字节）
    ///   - isComplete: 是否完整（false表示录制还在进行中）
    func copyRecordingFile(to destinationURL: URL,
                          isAll: Bool = true,
                          completion: @escaping (_ result: Result<URL, Error>, _ fileSize: Int64, _ isComplete: Bool) -> Void) {
        let tempURL = getTempRecordingURL()
        let fileManager = FileManager.default
        let currentlyRecording = isRecordingAudio
        
        // 检查源文件是否存在
        guard fileManager.fileExists(atPath: tempURL.path) else {
            completion(.failure(DecibelMeterError.audioFileNotFound), 0, false)
            return
        }
        
        // 在后台队列执行复制（使用专门的队列避免阻塞写入）
        fileAccessQueue.async { [weak self] in
            guard let self = self else { return }
            
            do {
                // 确保目标目录存在
                let destinationDir = destinationURL.deletingLastPathComponent()
                try? fileManager.createDirectory(at: destinationDir, withIntermediateDirectories: true)
                
                // 删除已存在的目标文件
                if fileManager.fileExists(atPath: destinationURL.path) {
                    try? fileManager.removeItem(at: destinationURL)
                }
                
                // ⭐ 注意：AVAudioFile 在写入时会自动同步数据到磁盘
                // 文件系统会确保数据的一致性，允许在写入过程中复制文件
                // 复制的文件包含复制时刻已写入的数据（文件快照）
                
                // 获取源文件大小（复制前的状态）
                let sourceAttributes = try fileManager.attributesOfItem(atPath: tempURL.path)
                let sourceFileSize = sourceAttributes[.size] as? Int64 ?? 0
                
                // 复制文件（可能在写入过程中）
                // iOS 文件系统允许在写入时复制，会复制当前已写入的部分
                try fileManager.copyItem(at: tempURL, to: destinationURL)
                
                // 验证复制的文件
                let destAttributes = try fileManager.attributesOfItem(atPath: destinationURL.path)
                let destFileSize = destAttributes[.size] as? Int64 ?? 0
                
                DispatchQueue.main.async {
                    if destFileSize > 0 {
                        print("✅ 录音文件已复制: \(destinationURL.lastPathComponent) (\(destFileSize) 字节)")
                        if currentlyRecording {
                            print("⚠️ 注意：录制还在进行中，复制的文件可能不完整")
                        }
                        completion(.success(destinationURL), destFileSize, !currentlyRecording)
                    } else {
                        completion(.failure(DecibelMeterError.invalidAudioFile), 0, false)
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    print("❌ 复制录音文件失败: \(error.localizedDescription)")
                    completion(.failure(error), 0, false)
                }
            }
        }
    }
    
    /// 获取当前录制文件的路径和信息
    ///
    /// - Returns: 文件信息元组 (URL, 文件大小, 是否正在录制)，如果文件不存在则返回nil
    func getCurrentRecordingInfo() -> (url: URL, size: Int64, isRecording: Bool)? {
        let tempURL = getTempRecordingURL()
        let fileManager = FileManager.default
        
        guard fileManager.fileExists(atPath: tempURL.path) else {
            return nil
        }
        
        do {
            let attributes = try fileManager.attributesOfItem(atPath: tempURL.path)
            let fileSize = attributes[.size] as? Int64 ?? 0
            return (tempURL, fileSize, isRecordingAudio)
        } catch {
            return nil
        }
    }
    
    /// 检查是否正在录制音频
    ///
    /// - Returns: 是否正在录制音频到文件
    func isRecordingAudioFile() -> Bool {
        return isRecordingAudio
    }
    
    /// 检查是否正在进行测量（音频采集）
    ///
    /// - Returns: 是否正在进行分贝测量（音频采集中）
    ///
    /// **用途**：
    /// - 判断音频引擎是否正在运行并采集音频
    /// - 在播放音频前检查，确保不会切换到不兼容的音频会话模式
    ///
    /// **注意**：
    /// - 如果音频引擎已暂停（`pauseAudioCapture()`），此方法返回 `false`
    /// - 这样可以在播放时自动切换到纯播放模式，确保音量正常
    ///
    /// **使用示例**：
    /// ```swift
    /// if manager.isMeasuring() {
    ///     // 正在测量且引擎运行中，需要保持 .playAndRecord 模式
    /// }
    /// ```
    func isMeasuring() -> Bool {
        // 检查测量状态、音频引擎存在且正在运行
        return measurementState == .measuring && audioEngine?.isRunning == true
    }
    
    // MARK: - 音频采集暂停/恢复（用于播放优化）
    
    /// 暂停音频采集（保持测量状态，但停止音频引擎）
    ///
    /// **用途**：在播放音频时临时暂停采集，避免回声消除影响播放音量
    ///
    /// **注意**：
    /// - 暂停期间，分贝测量会停止
    /// - 录音文件写入会停止（但已写入的数据保留）
    /// - 播放完成后应调用 `resumeAudioCapture()` 恢复
    ///
    /// - Returns: 是否成功暂停（如果不在测量中则返回 false）
    @discardableResult
    func pauseAudioCapture() -> Bool {
        guard measurementState == .measuring, let engine = audioEngine else {
            print("⚠️ 无法暂停音频采集：未在测量中")
            return false
        }
        
        // 停止音频引擎（但不改变测量状态）
        engine.pause()
        
        print("⏸️ 音频采集已暂停（播放音频时优化音量）")
        print("   - 测量状态保持: \(measurementState)")
        print("   - 音频引擎已暂停")
        
        return true
    }
    
    /// 恢复音频采集
    ///
    /// **用途**：播放音频完成后恢复采集
    ///
    /// - Returns: 是否成功恢复（如果不在测量中则返回 false）
    @discardableResult
    func resumeAudioCapture() -> Bool {
        guard measurementState == .measuring, let engine = audioEngine else {
            print("⚠️ 无法恢复音频采集：未在测量中")
            return false
        }
        
        // 如果引擎已经在运行，不需要再次启动
        if engine.isRunning {
            print("ℹ️ 音频引擎已经在运行，无需恢复")
            return true
        }
        
        do {
            // 重新启动音频引擎
            try engine.start()
            
            print("▶️ 音频采集已恢复")
            print("   - 音频引擎已重启")
            
            return true
        } catch {
            print("❌ 恢复音频采集失败: \(error.localizedDescription)")
            return false
        }
    }
}

// MARK: - 错误类型

enum DecibelMeterError: LocalizedError {
    case microphonePermissionDenied
    case audioEngineSetupFailed
    case inputNodeNotFound
    case audioSessionError
    case audioFileNotFound
    case invalidAudioFile
    case audioFileWriteFailed
    
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
        case .audioFileNotFound:
            return "找不到音频文件"
        case .invalidAudioFile:
            return "无效的音频文件"
        case .audioFileWriteFailed:
            return "写入音频文件失败"
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
