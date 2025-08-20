//
//  NonetworkDetectedView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/20.
//

import SwiftUI
import Network

struct NonetworkDetectedView: View {
    // MARK: - 状态管理
    @StateObject private var networkService = NetworkService.shared
    @State private var isRetrying = false
    @State private var autoRetryCount = 0
    private let maxAutoRetries = 3
    
    // MARK: - 回调
    var onRetry: (() -> Void)?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 32) {
                Spacer()
                
                // MARK: - 图标
                Image(systemName: "wifi.slash")
                    .font(.system(size: 80, weight: .light))
                    .foregroundColor(.red)
                    .padding(.bottom, 20)
                
                // MARK: - 标题
                Text("网络连接失败")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                
                // MARK: - 描述
                VStack(spacing: 16) {
                    Text("无法连接到互联网")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                    
                    Text("请检查您的网络设置，确保设备已连接到WiFi或移动网络。")
                        .font(.body)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // MARK: - 网络状态信息
                if networkService.networkType != .unknown {
                    HStack(spacing: 8) {
                        Image(systemName: networkIcon)
                            .foregroundColor(.blue)
                        Text("当前网络: \(networkService.networkType.description)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                }
                
                // MARK: - 自动重试状态
                if autoRetryCount > 0 && autoRetryCount <= maxAutoRetries {
                    HStack(spacing: 8) {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("自动检测网络连接中... (\(autoRetryCount)/\(maxAutoRetries))")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 8)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // MARK: - 按钮组
                VStack(spacing: 16) {
                    // 重试按钮
                    Button(action: retryConnection) {
                        HStack {
                            if isRetrying {
                                ProgressView()
                                    .scaleEffect(0.8)
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                            } else {
                                Image(systemName: "arrow.clockwise")
                            }
                            Text(isRetrying ? "检查中..." : "重试连接")
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            LinearGradient(
                                colors: [Color.blue, Color.blue.opacity(0.8)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: .blue.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(isRetrying)
                    
                    // 网络设置按钮
                    Button(action: openNetworkSettings) {
                        HStack {
                            Image(systemName: "gear")
                            Text("打开网络设置")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                    }
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 50)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                LinearGradient(
                    colors: [
                        Color(.systemBackground),
                        Color(.systemBackground).opacity(0.95)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .onAppear {
            // 页面出现时检查网络状态
            checkNetworkStatus()
            // 开始自动重试
            startAutoRetry()
        }
    }
    
    // MARK: - 计算属性
    
    private var networkIcon: String {
        switch networkService.networkType {
        case .wifi:
            return "wifi"
        case .cellular:
            return "antenna.radiowaves.left.and.right"
        case .ethernet:
            return "network"
        case .unknown:
            return "questionmark.circle"
        }
    }
    
    // MARK: - 私有方法
    
    /**
     * 重试网络连接
     */
    private func retryConnection() {
        isRetrying = true
        
        Task {
            // 等待一小段时间以显示加载状态
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            
            // 检查网络连接
            let isConnected = await networkService.checkNetworkConnection()
            
            await MainActor.run {
                isRetrying = false
                
                if isConnected {
                    // 网络连接成功，调用重试回调
                    onRetry?()
                } else {
                    // 网络仍然不可用，可以显示提示
                    print("网络连接仍然不可用")
                }
            }
        }
    }
    
    /**
     * 打开网络设置
     */
    private func openNetworkSettings() {
        if let settingsUrl = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(settingsUrl) { success in
                if success {
                    print("成功打开设置页面")
                } else {
                    print("无法打开设置页面")
                }
            }
        }
    }
    
    /**
     * 检查网络状态
     */
    private func checkNetworkStatus() {
        Task {
            let isConnected = await networkService.checkNetworkConnection()
            if isConnected {
                await MainActor.run {
                    onRetry?()
                }
            }
        }
    }
    
    /**
     * 开始自动重试
     */
    private func startAutoRetry() {
        // 每5秒自动重试一次，最多重试3次
//        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] timer in
//            Task { @MainActor in
//                guard let self = self else {
//                    timer.invalidate()
//                    return
//                }
//                
//                if self.autoRetryCount >= self.maxAutoRetries {
//                    timer.invalidate()
//                    return
//                }
//                
//                self.autoRetryCount += 1
//                self.checkNetworkStatus()
//            }
//        }
    }
    
    /**
     * 处理网络恢复
     */
    private func handleNetworkRestored() {
        // 网络恢复，立即检查连接
        Task {
            let isConnected = await networkService.checkNetworkConnection()
            if isConnected {
                await MainActor.run {
                    // 网络恢复，调用重试回调
                    onRetry?()
                }
            }
        }
    }
}

#Preview {
    NonetworkDetectedView()
}
