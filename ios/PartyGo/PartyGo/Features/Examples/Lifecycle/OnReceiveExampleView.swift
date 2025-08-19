//
//  OnReceiveExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI
import Combine

struct OnReceiveExampleView: View {
    @StateObject private var notificationManager = NotificationManager()
    @State private var receivedMessages: [String] = []
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("onReceive 示例")
                    .font(.title)
                    .padding()
                
                // 通知接收
                VStack {
                    Text("通知接收")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("通知数量:")
                            Spacer()
                            Text("\(notificationManager.notificationCount)")
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("最后通知:")
                            Spacer()
                            Text(notificationManager.lastNotification)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Button("发送测试通知") {
                            notificationManager.sendNotification("测试通知 \(Date().formatted(date: .omitted, time: .standard))")
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .onReceive(notificationManager.$notificationCount) { count in
                    receivedMessages.append("收到通知，总数: \(count)")
                }
                .onReceive(notificationManager.$lastNotification) { notification in
                    if !notification.isEmpty {
                        receivedMessages.append("新通知: \(notification)")
                    }
                }
                
                // 消息接收
                VStack {
                    Text("消息接收")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        Button("发送消息1") {
                            notificationManager.sendMessage("消息1")
                        }
                        .buttonStyle(.bordered)
                        
                        Button("发送消息2") {
                            notificationManager.sendMessage("消息2")
                        }
                        .buttonStyle(.bordered)
                        
                        Button("发送错误消息") {
                            notificationManager.sendError("这是一个错误消息")
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                .onReceive(notificationManager.$currentMessage) { message in
                    if !message.isEmpty {
                        receivedMessages.append("收到消息: \(message)")
                    }
                }
                .onReceive(notificationManager.$errorMessage) { error in
                    if !error.isEmpty {
                        alertMessage = error
                        showingAlert = true
                        receivedMessages.append("收到错误: \(error)")
                    }
                }
                
                // 接收日志
                VStack {
                    Text("接收日志")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(receivedMessages.suffix(8), id: \.self) { message in
                            HStack {
                                Image(systemName: "message")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                
                                Text(message)
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
                        receivedMessages.removeAll()
                    }
                    .buttonStyle(.bordered)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 状态监控
                VStack {
                    Text("状态监控")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("连接状态:")
                            Spacer()
                            Text(notificationManager.isConnected ? "已连接" : "未连接")
                                .fontWeight(.bold)
                                .foregroundColor(notificationManager.isConnected ? .green : .red)
                        }
                        
                        HStack {
                            Text("消息队列:")
                            Spacer()
                            Text("\(notificationManager.messageQueue.count)")
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        
                        Button("切换连接状态") {
                            notificationManager.toggleConnection()
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
                .onReceive(notificationManager.$isConnected) { connected in
                    receivedMessages.append("连接状态变化: \(connected ? "已连接" : "未连接")")
                }
                
                // 重置按钮
                Button("重置所有状态") {
                    notificationManager.reset()
                    receivedMessages.removeAll()
                }
                .buttonStyle(.borderedProminent)
                .padding()
            }
            .padding()
        }
        .navigationTitle("onReceive")
        .alert("错误消息", isPresented: $showingAlert) {
            Button("确定") { }
        } message: {
            Text(alertMessage)
        }
    }
}

// MARK: - NotificationManager

class NotificationManager: ObservableObject {
    @Published var notificationCount = 0
    @Published var lastNotification = ""
    @Published var currentMessage = ""
    @Published var errorMessage = ""
    @Published var isConnected = false
    @Published var messageQueue: [String] = []
    
    func sendNotification(_ message: String) {
        lastNotification = message
        notificationCount += 1
    }
    
    func sendMessage(_ message: String) {
        currentMessage = message
        messageQueue.append(message)
    }
    
    func sendError(_ error: String) {
        errorMessage = error
    }
    
    func toggleConnection() {
        isConnected.toggle()
    }
    
    func reset() {
        notificationCount = 0
        lastNotification = ""
        currentMessage = ""
        errorMessage = ""
        isConnected = false
        messageQueue.removeAll()
    }
}

#Preview {
    NavigationView {
        OnReceiveExampleView()
    }
}
