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
import Charts
import AVFoundation
import Combine

struct DecibelMeterView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    @State private var showingFrequencyWeightingSheet = false
    @State private var showingTimeWeightingSheet = false
    @State private var showingCalibrationSheet = false
    
    // MARK: - 音频录制和播放相关状态
    @State private var savedAudioFiles: [AudioFileInfo] = []
    @State private var currentPlayingFile: AudioFileInfo?
    @State private var audioPlayer: AVAudioPlayer?
    @State private var isPlaying = false
    @State private var showSaveSuccessAlert = false
    @State private var showSaveErrorAlert = false
    @State private var saveErrorMessage = ""
    @State private var showShareSheet = false
    @State private var shareFileURL: URL?
    
    // 音频播放器观察器
    @StateObject private var audioPlayerObserver = AudioPlayerObserver()
    
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
                        
                        // 音频录制和播放控制
                        AudioRecordingControlView(
                            viewModel: viewModel,
                            savedAudioFiles: $savedAudioFiles,
                            currentPlayingFile: $currentPlayingFile,
                            audioPlayer: $audioPlayer,
                            isPlaying: $isPlaying,
                            showSaveSuccessAlert: $showSaveSuccessAlert,
                            showSaveErrorAlert: $showSaveErrorAlert,
                            saveErrorMessage: $saveErrorMessage,
                            onSave: { saveRecording() },
                            onPlay: { fileInfo in playAudio(fileInfo: fileInfo) },
                            onStop: { stopAudio() },
                            onShare: { fileInfo in shareAudioFile(fileInfo: fileInfo) }
                        )
                        
                        // 专业图表区域
                        VStack(spacing: 20) {
                            // 时间历程图 - 实时分贝曲线
                            TimeHistoryChartView(viewModel: viewModel)
                            
                           // 频谱分析图 - 1/1倍频程
                           SpectrumAnalysis11ChartView(viewModel: viewModel)

                           // 频谱分析图 - 1/3倍频程
                           SpectrumAnalysis13ChartView(viewModel: viewModel)

                           // 频谱分析图 - FFT
                           SpectrumAnalysisFFTChartView(viewModel: viewModel)
                           
                           // 统计分布图 - L10、L50、L90
                           StatisticalDistributionChartView(viewModel: viewModel)
                           
                           // LEQ趋势图 - LEQ随时间变化
                           LEQTrendChartView(viewModel: viewModel)
                        }
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
        .alert("保存成功", isPresented: $showSaveSuccessAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text("录音已保存到 document/saved/ 目录")
        }
        .alert("保存失败", isPresented: $showSaveErrorAlert) {
            Button("确定", role: .cancel) { }
        } message: {
            Text(saveErrorMessage)
        }
        .onAppear {
            loadSavedAudioFiles()
        }
        .onDisappear {
            stopAudio()
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = shareFileURL {
                ShareSheet(activityItems: [url])
            }
        }
    }
    
    // MARK: - 音频录制和播放方法
    
    /// 保存当前录音到 document/saved/ 目录
    private func saveRecording() {
        let manager = DecibelMeterManager.shared
        
        print("🔘 保存录音按钮被点击")
        print("   - viewModel.isRecording: \(viewModel.isRecording)")
        print("   - manager.isRecordingAudioFile(): \(manager.isRecordingAudioFile())")
        
        // 检查是否正在录制
        guard manager.isRecordingAudioFile() else {
            saveErrorMessage = "当前没有正在录制的音频"
            showSaveErrorAlert = true
            print("❌ 无法保存：当前没有正在录制的音频")
            return
        }
        
        print("✅ 开始保存录音...")
        
        // 创建保存目录
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let savedDirectory = documentsPath.appendingPathComponent("saved")
        
        // 确保目录存在
        do {
            try FileManager.default.createDirectory(at: savedDirectory, withIntermediateDirectories: true)
        } catch {
            saveErrorMessage = "创建保存目录失败: \(error.localizedDescription)"
            showSaveErrorAlert = true
            return
        }
        
        // 生成文件名（带时间戳）
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        let fileName = "recording_\(dateFormatter.string(from: Date())).caf"
        let destinationURL = savedDirectory.appendingPathComponent(fileName)
        
        // 复制录音文件
        manager.copyRecordingFile(to: destinationURL) { result, fileSize, isComplete in
            switch result {
            case .success(let url):
                // 添加到保存列表
                let fileInfo = AudioFileInfo(
                    url: url,
                    fileName: fileName,
                    fileSize: fileSize,
                    createdAt: Date(),
                    isComplete: isComplete
                )
                
                DispatchQueue.main.async {
                    savedAudioFiles.append(fileInfo)
                    showSaveSuccessAlert = true
                    print("✅ 录音已保存: \(url.lastPathComponent) (\(fileSize) 字节)")
                }
                
            case .failure(let error):
                DispatchQueue.main.async {
                    saveErrorMessage = "保存失败: \(error.localizedDescription)"
                    showSaveErrorAlert = true
                }
            }
        }
    }
    
    /// 播放音频文件
    ///
    /// **与竞品一致的行为**：
    /// - 播放时测量持续进行，不会暂停
    /// - 播放的声音会被麦克风捕获并测量
    /// - 音频会话保持 `.playAndRecord` 模式
    private func playAudio(fileInfo: AudioFileInfo) {
        // 如果正在播放其他文件，先停止
        if isPlaying, currentPlayingFile?.url != fileInfo.url {
            stopAudio()
        }
        
        // 如果已经在播放当前文件，则暂停/继续
        if isPlaying, currentPlayingFile?.url == fileInfo.url {
            if let player = audioPlayer {
                if player.isPlaying {
                    player.pause()
                    isPlaying = false
                } else {
                    player.play()
                    isPlaying = true
                }
            }
            return
        }
        
        // 开始播放新文件
        do {
            // 检查文件是否存在
            guard FileManager.default.fileExists(atPath: fileInfo.url.path) else {
                saveErrorMessage = "文件不存在: \(fileInfo.fileName)"
                showSaveErrorAlert = true
                print("❌ 文件不存在: \(fileInfo.url.path)")
                return
            }
            
            // 检查文件大小
            let fileAttributes = try FileManager.default.attributesOfItem(atPath: fileInfo.url.path)
            let fileSize = fileAttributes[.size] as? Int64 ?? 0
            guard fileSize > 0 else {
                saveErrorMessage = "文件为空，无法播放"
                showSaveErrorAlert = true
                print("❌ 文件为空: \(fileInfo.fileName)")
                return
            }
            
            // 在播放前确保音频会话配置正确
            // 保持 .playAndRecord 模式，测量持续进行
            try setupAudioSessionForPlayback()
            
            // 创建播放器
            let player = try AVAudioPlayer(contentsOf: fileInfo.url)
            player.delegate = audioPlayerObserver
            player.volume = 1.0 // 设置音量为最大
            
            // 准备播放，确保资源已加载
            guard player.prepareToPlay() else {
                saveErrorMessage = "播放器准备失败，可能文件格式不支持或文件损坏"
                showSaveErrorAlert = true
                print("❌ 播放器准备失败: \(fileInfo.fileName)")
                print("   文件大小: \(fileSize) 字节")
                print("   文件格式: \(fileInfo.url.pathExtension)")
                return
            }
            
            // 检查播放器是否有效
            guard player.duration > 0 else {
                saveErrorMessage = "音频文件无效或损坏，无法播放"
                showSaveErrorAlert = true
                print("❌ 音频文件无效: \(fileInfo.fileName)")
                print("   持续时间: \(player.duration) 秒")
                return
            }
            
            audioPlayer = player
            
            // 设置播放完成回调
            audioPlayerObserver.onPlaybackFinished = {
                DispatchQueue.main.async {
                    self.isPlaying = false
                    self.currentPlayingFile = nil
                    
                    // 🔊 恢复输入增益到测量模式（0.0 → 0.3）
                    let audioSession = AVAudioSession.sharedInstance()
                    if audioSession.isInputGainSettable {
                        do {
                            try audioSession.setInputGain(0.3)
                            print("🔊 播放完成：输入增益 0.0 → 0.3（恢复测量精度）")
                        } catch {
                            print("⚠️ 恢复输入增益失败: \(error.localizedDescription)")
                        }
                    }
                    
                    print("✅ 播放完成")
                }
            }
            
            // 开始播放
            let playResult = player.play()
            if playResult {
                isPlaying = true
                currentPlayingFile = fileInfo
                print("▶️ 开始播放: \(fileInfo.fileName)")
                print("   文件路径: \(fileInfo.url.path)")
                print("   文件大小: \(fileInfo.formattedFileSize)")
                print("   持续时间: \(String(format: "%.2f", player.duration)) 秒")
                print("   采样率: \(player.format.sampleRate) Hz")
                print("   通道数: \(player.format.channelCount)")
                print("   📊 测量持续进行，播放声音会被测量")
            } else {
                saveErrorMessage = "播放启动失败，请检查音频会话设置"
                showSaveErrorAlert = true
                print("❌ 播放启动失败: \(fileInfo.fileName)")
                print("   播放器状态: isPlaying=\(player.isPlaying), duration=\(player.duration)")
            }
        } catch {
            saveErrorMessage = "播放失败: \(error.localizedDescription)\n错误类型: \(type(of: error))"
            showSaveErrorAlert = true
            print("❌ 播放错误: \(error)")
            print("   文件: \(fileInfo.fileName)")
            print("   路径: \(fileInfo.url.path)")
            print("   错误详情: \(error.localizedDescription)")
            if let nsError = error as NSError? {
                print("   错误域: \(nsError.domain)")
                print("   错误码: \(nsError.code)")
            }
        }
    }
    
    /// 停止播放音频
    private func stopAudio() {
        audioPlayer?.stop()
        audioPlayer = nil
        isPlaying = false
        currentPlayingFile = nil
        
        // 🔊 恢复输入增益到测量模式（0.0 → 0.3）
        let audioSession = AVAudioSession.sharedInstance()
        if audioSession.isInputGainSettable {
            do {
                try audioSession.setInputGain(0.3)
                print("🔊 停止播放：输入增益 0.0 → 0.3（恢复测量精度）")
            } catch {
                print("⚠️ 恢复输入增益失败: \(error.localizedDescription)")
            }
        }
        
        print("⏹️ 停止播放（测量持续进行）")
    }
    
    /// 分享音频文件
    private func shareAudioFile(fileInfo: AudioFileInfo) {
        // 检查文件是否存在
        guard FileManager.default.fileExists(atPath: fileInfo.url.path) else {
            saveErrorMessage = "文件不存在，无法分享"
            showSaveErrorAlert = true
            return
        }
        
        // 设置分享文件URL并显示分享面板
        shareFileURL = fileInfo.url
        showShareSheet = true
        print("📤 准备分享文件: \(fileInfo.fileName)")
    }
    
    /// 加载已保存的音频文件列表
    private func loadSavedAudioFiles() {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let savedDirectory = documentsPath.appendingPathComponent("saved")
        
        guard FileManager.default.fileExists(atPath: savedDirectory.path) else {
            return
        }
        
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(
                at: savedDirectory,
                includingPropertiesForKeys: [.fileSizeKey, .creationDateKey],
                options: .skipsHiddenFiles
            )
            
            let audioFiles = fileURLs
                .filter { $0.pathExtension == "m4a" || $0.pathExtension == "aac" || $0.pathExtension == "wav" || $0.pathExtension == "caf" }
                .compactMap { url -> AudioFileInfo? in
                    do {
                        let resourceValues = try url.resourceValues(forKeys: [.fileSizeKey, .creationDateKey])
                        let fileSize = resourceValues.fileSize ?? 0
                        let createdAt = resourceValues.creationDate ?? Date()
                        
                        return AudioFileInfo(
                            url: url,
                            fileName: url.lastPathComponent,
                            fileSize: Int64(fileSize),
                            createdAt: createdAt,
                            isComplete: true
                        )
                    } catch {
                        return nil
                    }
                }
                .sorted { $0.createdAt > $1.createdAt } // 按创建时间倒序排列
            
            savedAudioFiles = audioFiles
        } catch {
            print("加载音频文件列表失败: \(error)")
        }
    }
    
    /// 优化播放音量
    ///
    /// **核心优化**：动态降低输入增益，最大化播放音量
    /// - DecibelMeterManager 已配置好音频会话（.playAndRecord + .spokenAudio）
    /// - 这里只需调整输入增益即可提升播放音量
    private func setupAudioSessionForPlayback() throws {
        let audioSession = AVAudioSession.sharedInstance()
        
        // 🔊 核心优化：降低输入增益到最小值，最大化播放音量
        // 输入增益 ↓ → 麦克风灵敏度 ↓ → 系统对播放音量的压制 ↓ → 播放音量 ↑
        if audioSession.isInputGainSettable {
            do {
                try audioSession.setInputGain(0.0)  // 最小增益 = 最大播放音量
                print("🔊 播放优化：输入增益 0.3 → 0.0（最大化播放音量）")
                print("   - Current Gain: \(audioSession.inputGain)")
                print("   - Output Volume: \(audioSession.outputVolume)")
            } catch {
                print("⚠️ 设置输入增益失败: \(error.localizedDescription)")
            }
        } else {
            print("⚠️ 当前设备不支持输入增益调整")
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
        case .paused:
            return "暂停"
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
        case .paused:
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

// MARK: - 专业图表视图

/// 时间历程图视图 - 实时分贝曲线
///
/// 显示最近60秒的分贝变化曲线，符合 IEC 61672-1 标准的时间历程记录要求
/// 横轴为时间，纵轴为分贝值，实时更新显示
struct TimeHistoryChartView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // 图表标题和权重信息
            HStack {
                Text("时间历程图")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text(viewModel.getWeightingDisplayText())
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Swift Charts 实现
            Chart {
                ForEach(getChartData().dataPoints, id: \.id) { dataPoint in
                    LineMark(
                        x: .value("时间", timeIntervalFromNow(dataPoint.timestamp)),
                        y: .value("分贝", dataPoint.decibel)
                    )
                    .foregroundStyle(.blue)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                }
            }
            .frame(height: 200)
            .chartXScale(domain: -60...0) // 明确X轴范围：-60到0秒（相对于现在）
            .chartYScale(domain: 20...120) // 明确Y轴范围：20-120dB
            .chartXAxis {
                AxisMarks(values: .stride(by: 10)) { value in
                    AxisGridLine()
                    AxisTick()
                    if let timeValue = value.as(TimeInterval.self) {
                        AxisValueLabel {
                            Text(formatTimeAxis(timeValue))
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
            
            // 图表信息
            HStack {
                Text("时间范围: 60秒")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("数据点: \(getChartData().dataPoints.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func getChartData() -> TimeHistoryChartData {
        return viewModel.getTimeHistoryChartData(timeRange: 60.0)
    }
    
    /// 计算时间戳相对于现在的时间间隔（秒）
    private func timeIntervalFromNow(_ timestamp: Date) -> TimeInterval {
        return timestamp.timeIntervalSinceNow
    }
    
    /// 格式化时间轴标签
    private func formatTimeAxis(_ timeInterval: TimeInterval) -> String {
        let absTime = abs(timeInterval)
        
        if absTime < 60 {
            return "\(Int(absTime))s"
        } else if absTime < 3600 {
            return "\(Int(absTime/60))m"
        } else {
            return "\(Int(absTime/3600))h"
        }
    }
}

/// 频谱分析图视图 - 1/1倍频程
///
/// 显示1/1倍频程频谱数据，符合 IEC 61260-1 标准
/// 使用柱状图显示10个标准倍频程频段
struct SpectrumAnalysis11ChartView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // 图表标题
            HStack {
                Text("频谱分析图 - 1/1倍频程")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Swift Charts 实现 - 使用柱状图显示倍频程频段
            let chartData = getChartData()
            
            Chart {
                ForEach(chartData.dataPoints, id: \.id) { dataPoint in
                    BarMark(
                        x: .value("频率", dataPoint.frequency),
                        yStart: .value("基线", 0),
                        yEnd: .value("声压级", dataPoint.magnitude)
                    )
                    .foregroundStyle(.orange)
                }
            }
            .frame(height: 220)
            .chartXScale(
                domain: 31.5...16000,
                type: .log
            ) // 使用对数坐标轴
            .chartYScale(domain: 0...120) // Y轴范围：0-120dB
            .chartXAxis {
                AxisMarks(values: getLogAxisValues()) { value in
                    AxisGridLine()
                    AxisTick()
                    if let freqValue = value.as(Double.self) {
                        AxisValueLabel {
                            Text(formatFrequency(freqValue))
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 20)) { value in
                    AxisGridLine()
                    AxisTick()
                    if let magnitudeValue = value.as(Double.self) {
                        AxisValueLabel {
                            Text("\(Int(magnitudeValue))dB")
                                .font(.caption2)
                        }
                    }
                }
            }
            .padding()
            .background(Color.orange.opacity(0.05))
            .cornerRadius(12)
            
            // 图表信息
            HStack {
                Text("频率范围: \(formatFrequency(chartData.frequencyRange.min)) - \(formatFrequency(chartData.frequencyRange.max))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("频段数: \(chartData.dataPoints.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(15)
    }
    
    // MARK: - 数据获取
    
    /// 获取图表数据
    /// 
    /// 每次视图刷新时都会调用，实现实时更新
    private func getChartData() -> SpectrumChartData {
        return viewModel.getSpectrumChartData(bandType: "1/1")
    }
    
    private func formatFrequency(_ frequency: Double) -> String {
        if frequency >= 1000 {
            return "\(String(format: "%.0f", frequency/1000))k"
        } else {
            return "\(Int(frequency))"
        }
    }
    
    /// 生成1/1倍频程的对数坐标轴刻度值
    private func getLogAxisValues() -> [Double] {
        // 1/1倍频程的标准中心频率：31.5, 63, 125, 250, 500, 1k, 2k, 4k, 8k, 16k Hz
        return [31.5, 63, 125, 250, 500, 1000, 2000, 4000, 8000, 16000]
    }
}

/// 频谱分析图视图 - 1/3倍频程
///
/// 显示1/3倍频程频谱数据，符合 IEC 61260-1 标准
/// 使用曲线图显示30个标准倍频程频段
struct SpectrumAnalysis13ChartView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // 图表标题
            HStack {
                Text("频谱分析图 - 1/3倍频程")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Swift Charts 实现 - 使用线条图实现平滑的频谱曲线
            let chartData = getChartData()
            
            Chart {
                ForEach(chartData.dataPoints, id: \.id) { dataPoint in
                    LineMark(
                        x: .value("频率", dataPoint.frequency),
                        y: .value("声压级", dataPoint.magnitude)
                    )
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                }
            }
            .frame(height: 220)
            .chartXScale(
                domain: 25...20000,
                type: .log
            ) // 使用对数坐标轴
            .chartYScale(domain: 0...120) // Y轴范围：0-120dB
            .chartXAxis {
                AxisMarks(values: getLogAxisValues()) { value in
                    AxisGridLine()
                    AxisTick()
                    if let freqValue = value.as(Double.self) {
                        AxisValueLabel {
                            Text(formatFrequency(freqValue))
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 20)) { value in
                    AxisGridLine()
                    AxisTick()
                    if let magnitudeValue = value.as(Double.self) {
                        AxisValueLabel {
                            Text("\(Int(magnitudeValue))dB")
                                .font(.caption2)
                        }
                    }
                }
            }
            .padding()
            .background(Color.green.opacity(0.05))
            .cornerRadius(12)
            
            // 图表信息
            HStack {
                Text("频率范围: \(formatFrequency(chartData.frequencyRange.min)) - \(formatFrequency(chartData.frequencyRange.max))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("频段数: \(chartData.dataPoints.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(15)
    }
    
    // MARK: - 数据获取
    
    /// 获取图表数据
    /// 
    /// 每次视图刷新时都会调用，实现实时更新
    private func getChartData() -> SpectrumChartData {
        return viewModel.getSpectrumChartData(bandType: "1/3")
    }
    
    private func formatFrequency(_ frequency: Double) -> String {
        if frequency >= 1000 {
            return "\(String(format: "%.0f", frequency/1000))k"
        } else {
            return "\(Int(frequency))"
        }
    }
    
    /// 生成1/3倍频程的对数坐标轴刻度值
    private func getLogAxisValues() -> [Double] {
        // 1/3倍频程的主要中心频率，用于轴标记：25, 31.5, 40, 50, 63, 80, 100, 125, 160, 200, 250, 315, 400, 500, 630, 800, 1k, 1.25k, 1.6k, 2k, 2.5k, 3.15k, 4k, 5k, 6.3k, 8k, 10k, 12.5k, 16k, 20k Hz
        // 选择部分关键频率作为刻度显示，避免过于密集
        return [25, 50, 100, 200, 400, 800, 1600, 3150, 6300, 12500, 20000]
    }
}

/// 频谱分析图视图 - FFT
/// 
/// 显示FFT频谱数据，符合 IEC 61260-1 标准
/// 使用曲线图显示FFT频谱数据
struct SpectrumAnalysisFFTChartView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // 图表标题
            HStack {
                Text("频谱分析图 - FFT")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
            }
            
            // Swift Charts 实现 - 使用线条图实现平滑的频谱曲线
            let chartData = getChartData()
            
            Chart {
                ForEach(chartData.dataPoints, id: \.id) { dataPoint in
                    LineMark(
                        x: .value("频率", dataPoint.frequency),
                        y: .value("声压级", dataPoint.magnitude)
                    )
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 2.0, lineCap: .round, lineJoin: .round))
                }
            }
            .frame(height: 220)
            .chartXScale(
                domain: 25...20000,
                type: .log
            ) // 使用对数坐标轴
            .chartYScale(domain: 0...120) // Y轴范围：0-120dB
            .chartXAxis {
                AxisMarks(values: getLogAxisValues()) { value in
                    AxisGridLine()
                    AxisTick()
                    if let freqValue = value.as(Double.self) {
                        AxisValueLabel {
                            Text(formatFrequency(freqValue))
                                .font(.caption2)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 20)) { value in
                    AxisGridLine()
                    AxisTick()
                    if let magnitudeValue = value.as(Double.self) {
                        AxisValueLabel {
                            Text("\(Int(magnitudeValue))dB")
                                .font(.caption2)
                        }
                    }
                }
            }
            .padding()
            .background(Color.green.opacity(0.05))
            .cornerRadius(12)
            
            // 图表信息
            HStack {
                Text("频率范围: \(formatFrequency(chartData.frequencyRange.min)) - \(formatFrequency(chartData.frequencyRange.max))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("频段数: \(chartData.dataPoints.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.green.opacity(0.1))
        .cornerRadius(15)
    }
    
    // MARK: - 数据获取
    
    /// 获取图表数据
    /// 
    /// 每次视图刷新时都会调用，实现实时更新
    private func getChartData() -> SpectrumChartData {
        return viewModel.getSpectrumChartData(bandType: "FFT")
    }
    
    private func formatFrequency(_ frequency: Double) -> String {
        if frequency >= 1000 {
            return "\(String(format: "%.0f", frequency/1000))k"
        } else {
            return "\(Int(frequency))"
        }
    }
    
    /// 生成1/3倍频程的对数坐标轴刻度值
    private func getLogAxisValues() -> [Double] { 
        // FFT频谱的主要中心频率，用于轴标记：20, 50, 100, 200, 500, 1k, 2k, 5k, 10k, 20k Hz
        // 选择部分关键频率作为刻度显示，避免过于密集
        return [20, 50, 100, 200, 500, 1000, 2000, 5000, 10000, 20000]
    }
}


/// 统计分布图视图 - L10、L50、L90
///
/// 显示声级的统计分布，分析噪声的统计特性
/// 符合 ISO 1996-2 标准的统计分析要求
struct StatisticalDistributionChartView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // 图表标题
            HStack {
                Text("统计分布图")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                Text("L10/L50/L90")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(8)
            }
            
            // Swift Charts 实现
            Chart {
                ForEach(getChartData().dataPoints, id: \.id) { dataPoint in
                    BarMark(
                        x: .value("百分位", dataPoint.percentile),
                        y: .value("分贝", dataPoint.decibel)
                    )
                    .foregroundStyle(barColor(for: dataPoint.percentile))
                    .annotation(position: .top) {
                        Text(dataPoint.label)
                            .font(.caption2)
                            .foregroundColor(.primary)
                    }
                }
            }
            .frame(height: 200)
            .chartXScale(domain: 0...100) // 明确X轴范围：0-100%
            .chartYScale(domain: 20...120) // 明确Y轴范围：20-120dB
            .chartXAxis {
                AxisMarks(values: .stride(by: 10)) { value in
                    AxisGridLine()
                    AxisTick()
                    if let percentileValue = value.as(Double.self) {
                        AxisValueLabel {
                            Text("\(Int(percentileValue))%")
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
            .background(Color.orange.opacity(0.05))
            .cornerRadius(12)
            
            // 关键指标显示
            HStack(spacing: 20) {
                StatisticItemView(
                    label: "L10",
                    value: String(format: "%.1f", getChartData().l10),
                    description: "噪声峰值"
                )
                
                StatisticItemView(
                    label: "L50",
                    value: String(format: "%.1f", getChartData().l50),
                    description: "中位数"
                )
                
                StatisticItemView(
                    label: "L90",
                    value: String(format: "%.1f", getChartData().l90),
                    description: "背景噪声"
                )
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func getChartData() -> StatisticalDistributionChartData {
        return viewModel.getStatisticalDistributionChartData()
    }
    
    private func barColor(for percentile: Double) -> Color {
        switch percentile {
        case 10: return .red      // L90 - 背景噪声
        case 50: return .orange   // L50 - 中位数
        case 90: return .green    // L10 - 噪声峰值
        default: return .gray
        }
    }
}

/// LEQ趋势图视图 - LEQ随时间变化
///
/// 显示LEQ随时间变化的趋势，用于职业健康监测和长期暴露评估
/// 符合 ISO 1996-1 标准的等效连续声级计算要求
struct LEQTrendChartView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    
    var body: some View {
        VStack(spacing: 15) {
            // 图表标题和当前LEQ值
            HStack {
                Text("LEQ趋势图")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 2) {
                    Text("当前LEQ")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text(String(format: "%.1f dB", getChartData().currentLeq))
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(.purple)
                }
            }
            
            // Swift Charts 实现
            Chart {
                ForEach(getChartData().dataPoints, id: \.id) { dataPoint in
                    LineMark(
                        x: .value("时间", timeIntervalFromStart(dataPoint.timestamp)),
                        y: .value("LEQ", dataPoint.cumulativeLeq)
                    )
                    .foregroundStyle(.purple)
                    .lineStyle(StrokeStyle(lineWidth: 2))
                    .symbol(Circle())
                    .symbolSize(20)
                }
            }
            .frame(height: 200)
            .chartXScale(domain: 0...3600) // 明确X轴范围：0-3600秒（1小时）
            .chartYScale(domain: 20...120) // 明确Y轴范围：20-120dB
            .chartXAxis {
                AxisMarks(values: .stride(by: 300)) { value in // 每5分钟显示一个刻度
                    AxisGridLine()
                    AxisTick()
                    if let timeValue = value.as(TimeInterval.self) {
                        AxisValueLabel {
                            Text(formatLEQTimeAxis(timeValue))
                                .font(.caption)
                            }
                    }
                }
            }
            .chartYAxis {
                AxisMarks(values: .stride(by: 20)) { value in
                    AxisGridLine()
                    AxisTick()
                    if let leqValue = value.as(Double.self) {
                        AxisValueLabel {
                            Text("\(Int(leqValue))dB")
                                .font(.caption)
                            }
                    }
                }
            }
            .padding()
            .background(Color.purple.opacity(0.05))
            .cornerRadius(12)
            
            // 图表信息
            HStack {
                Text("测量时长: \(formatDuration(getChartData().timeRange))")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("数据点: \(getChartData().dataPoints.count)")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color.purple.opacity(0.1))
        .cornerRadius(15)
    }
    
    private func getChartData() -> LEQTrendChartData {
        return viewModel.getLEQTrendChartData(interval: 10.0)
    }
    
    private func timeIntervalFromStart(_ timestamp: Date) -> TimeInterval {
        guard let firstTimestamp = getChartData().dataPoints.first?.timestamp else {
            return 0
        }
        return timestamp.timeIntervalSince(firstTimestamp)
    }
    
    private func formatLEQTimeAxis(_ timeInterval: TimeInterval) -> String {
        if timeInterval < 60 {
            return "\(Int(timeInterval))s"
        } else if timeInterval < 3600 {
            let minutes = Int(timeInterval / 60)
            return "\(minutes)m"
        } else {
            let hours = Int(timeInterval / 3600)
            let minutes = Int((timeInterval.truncatingRemainder(dividingBy: 3600)) / 60)
            if minutes > 0 {
                return "\(hours)h\(minutes)m"
            } else {
                return "\(hours)h"
            }
        }
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
}

// MARK: - 辅助视图

/// 统计指标项视图
struct StatisticItemView: View {
    let label: String
    let value: String
    let description: String
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Text(value)
                .font(.title3)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            Text(description)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - 音频文件信息结构

struct AudioFileInfo: Identifiable {
    let id = UUID()
    let url: URL
    let fileName: String
    let fileSize: Int64
    let createdAt: Date
    let isComplete: Bool
    
    var formattedFileSize: String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: fileSize)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: createdAt)
    }
}

// MARK: - 音频播放器观察器

class AudioPlayerObserver: NSObject, ObservableObject, AVAudioPlayerDelegate {
    var onPlaybackFinished: (() -> Void)?
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        DispatchQueue.main.async {
            self.onPlaybackFinished?()
        }
    }
    
    func audioPlayerDecodeErrorDidOccur(_ player: AVAudioPlayer, error: Error?) {
        print("音频播放错误: \(error?.localizedDescription ?? "未知错误")")
        DispatchQueue.main.async {
            self.onPlaybackFinished?()
        }
    }
}

// MARK: - 音频录制和播放控制视图

struct AudioRecordingControlView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    @Binding var savedAudioFiles: [AudioFileInfo]
    @Binding var currentPlayingFile: AudioFileInfo?
    @Binding var audioPlayer: AVAudioPlayer?
    @Binding var isPlaying: Bool
    @Binding var showSaveSuccessAlert: Bool
    @Binding var showSaveErrorAlert: Bool
    @Binding var saveErrorMessage: String
    
    let onSave: () -> Void
    let onPlay: (AudioFileInfo) -> Void
    let onStop: () -> Void
    let onShare: (AudioFileInfo) -> Void
    
    // 使用 ViewModel 的 @Published 属性，自动触发 UI 更新
    private var isRecordingAudio: Bool {
        viewModel.isRecordingAudio
    }
    
    private var canSaveRecording: Bool {
        viewModel.isRecording && viewModel.isRecordingAudio
    }
    
    var body: some View {
        VStack(spacing: 15) {
            // 标题和录制状态
            HStack {
                Text("音频录制")
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 录制状态指示器
                HStack(spacing: 6) {
                    Circle()
                        .fill(isRecordingAudio ? Color.red : Color.gray)
                        .frame(width: 8, height: 8)
                    
                    Text(isRecordingAudio ? "录制中" : "未录制")
                        .font(.caption)
                        .foregroundColor(isRecordingAudio ? .red : .secondary)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(12)
            }
            
            // 保存按钮
            Button(action: {
                print("🔘 保存按钮点击 - canSave: \(canSaveRecording), isRecording: \(viewModel.isRecording), isRecordingAudio: \(isRecordingAudio)")
                onSave()
            }) {
                HStack(spacing: 8) {
                    Image(systemName: canSaveRecording ? "square.and.arrow.down.fill" : "square.and.arrow.down")
                    Text(canSaveRecording ? "保存录音" : "请先开始测量")
                }
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(canSaveRecording ? Color.blue : Color.gray)
                .cornerRadius(10)
            }
            .disabled(!canSaveRecording)
            
            // 已保存的音频文件列表
            if !savedAudioFiles.isEmpty {
                VStack(alignment: .leading, spacing: 10) {
                    Text("已保存的录音")
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                    
                    ForEach(savedAudioFiles.reversed()) { fileInfo in
                        AudioFileRowView(
                            fileInfo: fileInfo,
                            isPlaying: isPlaying && currentPlayingFile?.id == fileInfo.id,
                            onPlay: { onPlay(fileInfo) },
                            onStop: onStop,
                            onShare: { onShare(fileInfo) }
                        )
                    }
                }
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(15)
    }
}

// MARK: - 音频文件行视图

struct AudioFileRowView: View {
    let fileInfo: AudioFileInfo
    let isPlaying: Bool
    let onPlay: () -> Void
    let onStop: () -> Void
    let onShare: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 播放/停止按钮
            Button(action: {
                if isPlaying {
                    onStop()
                } else {
                    onPlay()
                }
            }) {
                Image(systemName: isPlaying ? "stop.circle.fill" : "play.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(isPlaying ? .red : .green)
            }
            
            // 文件信息
            VStack(alignment: .leading, spacing: 4) {
                Text(fileInfo.fileName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .truncationMode(.middle)
                
                HStack(spacing: 12) {
                    Text(fileInfo.formattedDate)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text("•")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    
                    Text(fileInfo.formattedFileSize)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // 分享按钮
            Button(action: onShare) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 20))
                    .foregroundColor(.blue)
                    .frame(width: 44, height: 44)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

#Preview {
    DecibelMeterView(viewModel: DecibelMeterViewModel())
}
