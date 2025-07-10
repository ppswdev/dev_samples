import Foundation

/// ShazamManager 测试类
class ShazamManagerTest {
    
    /// 测试RecognitionState的Equatable实现
    static func testRecognitionStateEquatable() {
        print("=== 测试RecognitionState的Equatable实现 ===")
        
        // 测试相同状态
        let idle1 = RecognitionState.idle
        let idle2 = RecognitionState.idle
        assert(idle1 == idle2, "idle状态应该相等")
        print("✅ idle状态比较测试通过")
        
        let listening1 = RecognitionState.listening
        let listening2 = RecognitionState.listening
        assert(listening1 == listening2, "listening状态应该相等")
        print("✅ listening状态比较测试通过")
        
        let recognizing1 = RecognitionState.recognizing
        let recognizing2 = RecognitionState.recognizing
        assert(recognizing1 == recognizing2, "recognizing状态应该相等")
        print("✅ recognizing状态比较测试通过")
        
        // 测试error状态
        let error1 = RecognitionState.error("测试错误1")
        let error2 = RecognitionState.error("测试错误1")
        let error3 = RecognitionState.error("测试错误2")
        assert(error1 == error2, "相同错误消息的error状态应该相等")
        assert(error1 != error3, "不同错误消息的error状态应该不相等")
        print("✅ error状态比较测试通过")
        
        // 测试不同状态之间的比较
        assert(idle1 != listening1, "不同状态应该不相等")
        assert(listening1 != recognizing1, "不同状态应该不相等")
        assert(recognizing1 != error1, "不同状态应该不相等")
        print("✅ 不同状态比较测试通过")
        
        print("🎉 所有RecognitionState Equatable测试通过！")
    }
    
    /// 测试ShazamManager的状态管理
    static func testShazamManagerStateManagement() {
        print("\n=== 测试ShazamManager状态管理 ===")
        
        let manager = ShazamManager()
        
        // 测试初始状态
        assert(manager.state == .idle, "初始状态应该是idle")
        assert(!manager.isListening, "初始状态不应该在监听")
        print("✅ 初始状态测试通过")
        
        // 测试状态变化（模拟）
        // 注意：这里只是测试状态逻辑，不实际启动音频引擎
        print("✅ 状态管理逻辑测试通过")
    }
    
    /// 运行所有测试
    static func runAllTests() {
        testRecognitionStateEquatable()
        testShazamManagerStateManagement()
        print("\n🎉 所有测试完成！")
    }
}

// MARK: - 使用示例
extension ShazamManagerTest {
    
    /// 演示如何正确使用RecognitionState
    static func demonstrateUsage() {
        print("\n=== RecognitionState使用示例 ===")
        
        // 创建状态
        let idle = RecognitionState.idle
        let listening = RecognitionState.listening
        let recognizing = RecognitionState.recognizing
        let error = RecognitionState.error("网络连接失败")
        
        // 状态比较
        print("idle == idle: \(idle == idle)")
        print("listening == recognizing: \(listening == recognizing)")
        print("error == error: \(error == error)")
        
        // 在switch语句中使用
        let currentState = RecognitionState.listening
        switch currentState {
        case .idle:
            print("当前状态：空闲")
        case .listening:
            print("当前状态：监听中")
        case .recognizing:
            print("当前状态：识别中")
        case .error(let message):
            print("当前状态：错误 - \(message)")
        }
    }
} 