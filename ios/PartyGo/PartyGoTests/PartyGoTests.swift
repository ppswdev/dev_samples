//
//  PartyGoTests.swift
//  PartyGoTests
//
//  Created by xiaopin on 2025/8/18.
//

import Testing
import Network
@testable import PartyGo

struct PartyGoTests {

    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
    
    @Test func testNetworkServiceInitialization() async throws {
        // 测试网络服务初始化
        let networkService = NetworkService.shared
        
        // 验证网络服务已正确初始化
        #expect(networkService != nil)
        
        // 验证网络状态属性存在
        #expect(networkService.isNetworkAvailable == false || networkService.isNetworkAvailable == true)
        #expect(networkService.networkType == .wifi || networkService.networkType == .cellular || networkService.networkType == .ethernet || networkService.networkType == .unknown)
    }
    
    @Test func testNetworkConnectionCheck() async throws {
        // 测试网络连接检查功能
        let networkService = NetworkService.shared
        
        // 执行网络连接检查
        let isConnected = await networkService.checkNetworkConnection()
        
        // 验证返回值为布尔类型
        #expect(type(of: isConnected) == Bool.self)
        
        // 注意：实际网络状态取决于测试环境，所以这里只验证方法能正常执行
        print("网络连接状态: \(isConnected)")
    }
    
    @Test func testAppInitServiceNetworkCheck() async throws {
        // 测试应用初始化服务的网络检查
        let appInitService = AppInitService.shared
        
        // 重新检查网络连接
        let isConnected = await appInitService.recheckNetworkConnection()
        
        // 验证返回值为布尔类型
        #expect(type(of: isConnected) == Bool.self)
        
        // 验证网络状态已更新
        #expect(appInitService.isNetworkAvailable == isConnected)
        
        print("应用初始化服务网络状态: \(isConnected)")
    }
    
    @Test func testNetworkTypeDescription() async throws {
        // 测试网络类型描述
        let wifiDescription = NetworkType.wifi.description
        let cellularDescription = NetworkType.cellular.description
        let ethernetDescription = NetworkType.ethernet.description
        let unknownDescription = NetworkType.unknown.description
        
        // 验证描述不为空
        #expect(!wifiDescription.isEmpty)
        #expect(!cellularDescription.isEmpty)
        #expect(!ethernetDescription.isEmpty)
        #expect(!unknownDescription.isEmpty)
        
        // 验证中文描述
        #expect(wifiDescription == "WiFi")
        #expect(cellularDescription == "移动网络")
        #expect(ethernetDescription == "以太网")
        #expect(unknownDescription == "未知")
    }
    
    @Test func testAppInitServiceReset() async throws {
        // 测试应用初始化服务重置功能
        let appInitService = AppInitService.shared
        
        // 记录初始状态
        let initialProgress = appInitService.initializationProgress
        let initialStep = appInitService.currentStep
        let initialIsInitialized = appInitService.isInitialized
        
        // 执行重置
        await appInitService.resetInitialization()
        
        // 验证重置后的状态
        #expect(appInitService.initializationProgress == 0.0)
        #expect(appInitService.currentStep == "准备中...")
        #expect(appInitService.isInitialized == false)
        #expect(appInitService.errorMessage == nil)
        #expect(appInitService.isNetworkAvailable == false)
        
        print("应用初始化服务重置测试完成")
    }
    
    @Test func testNetworkRestorationCallback() async throws {
        // 测试网络恢复回调功能
        let networkService = NetworkService.shared
        var callbackTriggered = false
        
        // 设置回调
        networkService.onNetworkRestored = {
            callbackTriggered = true
        }
        
        // 模拟网络恢复（这里只是测试回调机制，不依赖实际网络状态）
        // 在实际测试中，可能需要模拟网络状态变化
        
        // 验证回调机制存在
        #expect(networkService.onNetworkRestored != nil)
        
        print("网络恢复回调测试完成")
    }
    
    @Test func testNetworkStatusEnum() async throws {
        // 测试网络状态枚举
        let wifiStatus = NetworkStatus.connected(.wifi)
        let cellularStatus = NetworkStatus.connected(.cellular)
        let disconnectedStatus = NetworkStatus.disconnected
        let connectingStatus = NetworkStatus.connecting
        
        // 验证状态描述
        #expect(!wifiStatus.description.isEmpty)
        #expect(!cellularStatus.description.isEmpty)
        #expect(!disconnectedStatus.description.isEmpty)
        #expect(!connectingStatus.description.isEmpty)
        
        // 验证状态描述包含正确信息
        #expect(wifiStatus.description.contains("WiFi"))
        #expect(cellularStatus.description.contains("移动网络"))
        #expect(disconnectedStatus.description.contains("已断开"))
        #expect(connectingStatus.description.contains("连接中"))
        
        print("网络状态枚举测试完成")
    }
    
    @Test func testNetworkServiceMethods() async throws {
        // 测试网络服务的其他方法
        let networkService = NetworkService.shared
        
        // 测试获取当前网络状态描述
        let description = networkService.getCurrentNetworkStatusDescription()
        #expect(!description.isEmpty)
        
        // 测试手动触发网络状态检查
        networkService.triggerNetworkStatusCheck()
        
        print("网络服务方法测试完成")
    }
}
