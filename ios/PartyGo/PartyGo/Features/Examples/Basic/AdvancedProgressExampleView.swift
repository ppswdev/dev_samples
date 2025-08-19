import SwiftUI

// Swift 6 并发安全的进度管理器
@MainActor
class ProgressManager: ObservableObject {
    @Published var progress = 0.0
    @Published var isRunning = false
    @Published var status = "就绪"
    
    private var currentTask: Task<Void, Never>?
    
    // 开始进度 - 使用 Swift 6 现代并发
    func startProgress() {
        guard !isRunning else { return }
        
        isRunning = true
        status = "开始..."
        
        currentTask = Task {
            await runProgress()
        }
    }
    
    // 停止进度
    func stopProgress() {
        currentTask?.cancel()
        currentTask = nil
        isRunning = false
        status = "已停止"
    }
    
    // 重置进度
    func resetProgress() {
        stopProgress()
        progress = 0.0
        status = "就绪"
    }
    
    // 核心进度逻辑 - 完全并发安全
    private func runProgress() async {
        progress = 0.0
        
        for step in 1...100 {
            // 检查任务是否被取消
            if Task.isCancelled {
                status = "已取消"
                return
            }
            
            // 模拟工作负载
            await simulateWork()
            
            // 更新进度
            progress = Double(step) / 100.0
            status = "处理中... \(step)%"
            
            // 等待一段时间
            try? await Task.sleep(nanoseconds: 50_000_000) // 0.05秒
        }
        
        // 完成
        status = "完成！"
        isRunning = false
    }
    
    // 模拟异步工作
    private func simulateWork() async {
        // 模拟一些异步操作
        try? await Task.sleep(nanoseconds: 10_000_000) // 0.01秒
    }
}

// 高级进度视图
struct AdvancedProgressExampleView: View {
    @StateObject private var progressManager = ProgressManager()
    @State private var selectedStyle = ProgressStyle.linear
    @State private var showAdvancedControls = false
    
    enum ProgressStyle: String, CaseIterable {
        case linear = "线性"
        case circular = "圆形"
        case custom = "自定义"
        case gradient = "渐变"
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    // 标题
                    Text("高级进度组件")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding()
                    
                    // 状态显示
                    ProgressStatusCard(progressManager: progressManager)
                    
                    // 进度样式选择
                    StyleSelectorView(selectedStyle: $selectedStyle)
                    
                    // 进度显示
                    ProgressDisplayView(
                        progress: progressManager.progress,
                        style: selectedStyle
                    )
                    
                    // 控制按钮
                    ControlButtonsView(progressManager: progressManager)
                    
                    // 高级控制
                    if showAdvancedControls {
                        AdvancedControlsView(progressManager: progressManager)
                    }
                    
                    // 切换高级控制按钮
                    Button(showAdvancedControls ? "隐藏高级控制" : "显示高级控制") {
                        withAnimation(.easeInOut(duration: 0.3)) {
                            showAdvancedControls.toggle()
                        }
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
            }
            .navigationTitle("Swift 6 进度示例")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// 状态卡片
struct ProgressStatusCard: View {
    @ObservedObject var progressManager: ProgressManager
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Image(systemName: statusIcon)
                    .foregroundColor(statusColor)
                    .font(.title2)
                
                Text(progressManager.status)
                    .font(.headline)
                    .foregroundColor(statusColor)
            }
            
            Text("进度: \(Int(progressManager.progress * 100))%")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
    
    private var statusIcon: String {
        if progressManager.isRunning {
            return "arrow.clockwise"
        } else if progressManager.progress >= 1.0 {
            return "checkmark.circle.fill"
        } else {
            return "circle"
        }
    }
    
    private var statusColor: Color {
        if progressManager.isRunning {
            return .blue
        } else if progressManager.progress >= 1.0 {
            return .green
        } else {
            return .gray
        }
    }
}

// 样式选择器
struct StyleSelectorView: View {
    @Binding var selectedStyle: AdvancedProgressExampleView.ProgressStyle
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("进度样式")
                .font(.headline)
            
            Picker("样式", selection: $selectedStyle) {
                ForEach(AdvancedProgressExampleView.ProgressStyle.allCases, id: \.self) { style in
                    Text(style.rawValue).tag(style)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// 进度显示视图
struct ProgressDisplayView: View {
    let progress: Double
    let style: AdvancedProgressExampleView.ProgressStyle
    
    var body: some View {
        VStack(spacing: 15) {
            Text("进度显示")
                .font(.headline)
            
            switch style {
            case .linear:
                LinearProgressView(progress: progress)
            case .circular:
                CircularProgressView(progress: progress)
            case .custom:
                CustomProgressView(progress: progress)
            case .gradient:
                GradientProgressView(progress: progress)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// 线性进度视图
struct LinearProgressView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 10) {
            ProgressView(value: progress)
                .progressViewStyle(LinearProgressViewStyle())
                .scaleEffect(y: 3)
            
            Text("\(Int(progress * 100))%")
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}

// 圆形进度视图
struct CircularProgressView: View {
    let progress: Double
    
    var body: some View {
        VStack(spacing: 10) {
            ZStack {
                ProgressView(value: progress)
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2)
                
                Text("\(Int(progress * 100))%")
                    .font(.caption)
                    .fontWeight(.bold)
            }
        }
    }
}

// 自定义进度视图
struct CustomProgressView: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景轨道
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 50)
                
                // 进度条
                RoundedRectangle(cornerRadius: 25)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 50)
                    .animation(.easeInOut(duration: 0.3), value: progress)
                
                // 进度文本
                Text("\(Int(progress * 100))%")
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
            }
        }
        .frame(height: 50)
    }
}

// 渐变进度视图
struct GradientProgressView: View {
    let progress: Double
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // 背景
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 40)
                
                // 渐变进度条
                RoundedRectangle(cornerRadius: 20)
                    .fill(
                        LinearGradient(
                            gradient: Gradient(colors: [.red, .orange, .yellow, .green, .blue, .purple]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: geometry.size.width * progress, height: 40)
                    .animation(.easeInOut(duration: 0.3), value: progress)
                
                // 进度指示器
                Circle()
                    .fill(Color.white)
                    .frame(width: 30, height: 30)
                    .shadow(radius: 2)
                    .offset(x: (geometry.size.width * progress) - 15)
                    .animation(.easeInOut(duration: 0.3), value: progress)
            }
        }
        .frame(height: 40)
    }
}

// 控制按钮视图
struct ControlButtonsView: View {
    @ObservedObject var progressManager: ProgressManager
    
    var body: some View {
        VStack(spacing: 15) {
            Text("控制")
                .font(.headline)
            
            HStack(spacing: 20) {
                Button("开始") {
                    progressManager.startProgress()
                }
                .buttonStyle(.borderedProminent)
                .disabled(progressManager.isRunning)
                
                Button("停止") {
                    progressManager.stopProgress()
                }
                .buttonStyle(.bordered)
                .disabled(!progressManager.isRunning)
                
                Button("重置") {
                    progressManager.resetProgress()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// 高级控制视图
struct AdvancedControlsView: View {
    @ObservedObject var progressManager: ProgressManager
    @State private var speed = 1.0
    
    var body: some View {
        VStack(spacing: 15) {
            Text("高级控制")
                .font(.headline)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("速度: \(String(format: "%.1f", speed))x")
                    .font(.subheadline)
                
                Slider(value: $speed, in: 0.1...5.0, step: 0.1)
                    .accentColor(.blue)
            }
            
            HStack {
                Text("当前状态:")
                    .font(.subheadline)
                Spacer()
                Text(progressManager.isRunning ? "运行中" : "已停止")
                    .font(.subheadline)
                    .foregroundColor(progressManager.isRunning ? .green : .red)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(15)
    }
}

// 预览
#Preview {
    AdvancedProgressExampleView()
}
