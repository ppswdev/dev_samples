//
//  NetworkService.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import Foundation
import Network

// MARK: - 网络状态枚举
enum NetworkStatus: Equatable {
    case connected
    case disconnected
    case connecting
    
    var description: String {
        switch self {
        case .connected:
            return "已连接"
        case .disconnected:
            return "已断开"
        case .connecting:
            return "连接中"
        }
    }
}

// MARK: - 网络类型枚举
enum NetworkType: Equatable {
    case wifi
    case cellular
    case ethernet
    case unknown
    
    var description: String {
        switch self {
        case .wifi:
            return "WiFi"
        case .cellular:
            return "移动网络"
        case .ethernet:
            return "以太网"
        case .unknown:
            return "未知"
        }
    }
}

// MARK: - 网络错误枚举
enum NetworkError: LocalizedError {
    case invalidResponse
    case decodingError
    case networkError
    case noConnection
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "无效的响应"
        case .decodingError:
            return "数据解析错误"
        case .networkError:
            return "网络连接错误"
        case .noConnection:
            return "无网络连接"
        }
    }
}

// MARK: - 网络服务单例类
@MainActor
class NetworkService: ObservableObject {
    // MARK: - 单例
    static let shared = NetworkService()
    
    // MARK: - 发布状态
    @Published var networkStatus: NetworkStatus = .disconnected
    @Published var networkType: NetworkType = .unknown
    
    // MARK: - 计算属性
    var isNetworkAvailable: Bool {
        return networkStatus == .connected
    }
    
    // MARK: - 网络监控
    private let networkMonitor = NWPathMonitor()
    private let networkQueue = DispatchQueue(label: "NetworkMonitor")
    
    // MARK: - 回调
    var onNetworkRestored: (() -> Void)?
    var onNetworkStatusChanged: ((NetworkStatus) -> Void)?
    
    private init() {
        setupNetworkMonitoring()
    }
    
    // MARK: - 网络监控设置
    private func setupNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                self?.updateNetworkStatus(path)
            }
        }
        networkMonitor.start(queue: networkQueue)
        print("🌐 NetworkService - 网络监控已启动")
    }
    
    // MARK: - 更新网络状态
    private func updateNetworkStatus(_ path: NWPath) {
        let previousStatus = networkStatus
        
        // 确定网络类型
        let type: NetworkType
        if path.usesInterfaceType(.wifi) {
            type = .wifi
        } else if path.usesInterfaceType(.cellular) {
            type = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            type = .ethernet
        } else {
            type = .unknown
        }
        
        // 更新网络类型
        networkType = type
        
        // 创建新的网络状态
        let newStatus: NetworkStatus = path.status == .satisfied ? .connected : .disconnected
        
        // 更新状态
        networkStatus = newStatus
        
        // 检测状态变化
        if previousStatus != newStatus {
            // 触发回调
            onNetworkStatusChanged?(newStatus)
            
            // 发送通知
            sendNetworkStatusNotification(newStatus)
            
            // 检测网络恢复
            if newStatus == .connected && previousStatus == .disconnected {
                onNetworkRestored?()
            }
            
            print("🌐 NetworkService - 网络状态变化: \(previousStatus.description) -> \(newStatus.description) (\(type.description))")
        }
    }
    
    // MARK: - 发送网络状态通知
    private func sendNetworkStatusNotification(_ status: NetworkStatus) {
        let userInfo: [String: Any] = ["status": status]
        NotificationCenter.default.post(
            name: .networkStatusChanged,
            object: nil,
            userInfo: userInfo
        )
    }
    
    // MARK: - 网络连接检测
    func checkNetworkConnection() async -> Bool {
        guard isNetworkAvailable else { return false }
        
        do {
            let url = URL(string: "https://www.apple.com")!
            let (_, response) = try await URLSession.shared.data(from: url)
            
            if let httpResponse = response as? HTTPURLResponse {
                return httpResponse.statusCode == 200
            }
            return false
        } catch {
            return false
        }
    }
    
    // MARK: - 获取当前网络状态描述
    func getCurrentNetworkStatusDescription() -> String {
        if isNetworkAvailable {
            return "网络已连接 (\(networkType.description))"
        } else {
            return "网络连接已断开"
        }
    }
    
    // MARK: - 停止网络监控
    func stopNetworkMonitoring() {
        networkMonitor.cancel()
        print("🌐 NetworkService - 网络监控已停止")
    }
    
    // MARK: - 通用网络请求
    func fetchData<T: Codable>(from url: URL) async throws -> T {
        let (data, response) = try await URLSession.shared.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw NetworkError.invalidResponse
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }
}

// MARK: - 通知扩展
extension Notification.Name {
    static let networkStatusChanged = Notification.Name("networkStatusChanged")
}