//
//  TimerExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct TimerExampleView: View {
    @State private var currentTime = Date()
    @State private var countdown = 60
    @State private var isTimerRunning = false
    @State private var stopwatchTime = 0.0
    @State private var isStopwatchRunning = false
    @State private var timerLogs: [String] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("Timer 示例")
                    .font(.title)
                    .padding()
                
                // 时钟
                VStack {
                    Text("实时时钟")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        Text(currentTime, style: .time)
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundColor(.blue)
                        
                        Text(currentTime, style: .date)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                    currentTime = Date()
                }
                
                // 倒计时器
                VStack {
                    Text("倒计时器")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        Text("\(countdown)")
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(countdown <= 10 ? .red : .blue)
                        
                        HStack(spacing: 20) {
                            Button(isTimerRunning ? "暂停" : "开始") {
                                isTimerRunning.toggle()
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("重置") {
                                countdown = 60
                                isTimerRunning = false
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .onReceive(Timer.publish(every: 1, on: .main, in: .common).autoconnect()) { _ in
                    if isTimerRunning && countdown > 0 {
                        countdown -= 1
                        addLog("倒计时: \(countdown)")
                        
                        if countdown == 0 {
                            isTimerRunning = false
                            addLog("倒计时结束!")
                        }
                    }
                }
                
                // 秒表
                VStack {
                    Text("秒表")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        Text(String(format: "%.1f", stopwatchTime))
                            .font(.system(size: 36, weight: .bold, design: .monospaced))
                            .foregroundColor(.green)
                        
                        HStack(spacing: 20) {
                            Button(isStopwatchRunning ? "暂停" : "开始") {
                                isStopwatchRunning.toggle()
                            }
                            .buttonStyle(.borderedProminent)
                            
                            Button("重置") {
                                stopwatchTime = 0.0
                                isStopwatchRunning = false
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .onReceive(Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()) { _ in
                    if isStopwatchRunning {
                        stopwatchTime += 0.1
                    }
                }
                
                // 定时任务
                VStack {
                    Text("定时任务")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        Button("5秒后执行任务") {
                            addLog("5秒定时任务已设置")
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                                addLog("5秒定时任务执行完成!")
                            }
                        }
                        .buttonStyle(.bordered)
                        
                        Button("10秒后执行任务") {
                            addLog("10秒定时任务已设置")
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                addLog("10秒定时任务执行完成!")
                            }
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 定时器日志
                VStack {
                    Text("定时器日志")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(timerLogs.suffix(6), id: \.self) { log in
                            HStack {
                                Image(systemName: "clock")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(log)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                
                                Spacer()
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    Button("清空日志") {
                        timerLogs.removeAll()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 重置按钮
                Button("重置所有状态") {
                    currentTime = Date()
                    countdown = 60
                    isTimerRunning = false
                    stopwatchTime = 0.0
                    isStopwatchRunning = false
                    timerLogs.removeAll()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
        }
        .navigationTitle("Timer")
    }
    
    private func addLog(_ message: String) {
        let timestamp = Date().formatted(date: .omitted, time: .standard)
        timerLogs.append("[\(timestamp)] \(message)")
    }
}

#Preview {
    NavigationView {
        TimerExampleView()
    }
}
