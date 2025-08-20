//
//  ObservedObjectExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct ObservedObjectExampleView: View {
    @ObservedObject private var userProfile = UserProfile()
    @ObservedObject private var settings = AppSettings()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("@ObservedObject 示例")
                    .font(.title)
                    .padding()
                
                // 用户资料示例
                VStack {
                    Text("用户资料管理")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("用户名:")
                            Spacer()
                            Text(userProfile.username)
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Text("年龄:")
                            Spacer()
                            Text("\(userProfile.age)")
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Text("邮箱:")
                            Spacer()
                            Text(userProfile.email)
                                .fontWeight(.bold)
                        }
                        
                        HStack {
                            Text("会员等级:")
                            Spacer()
                            Text(userProfile.membershipLevel)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    HStack(spacing: 15) {
                        Button("更新资料") {
                            userProfile.updateProfile()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("升级会员") {
                            userProfile.upgradeMembership()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 应用设置示例
                VStack {
                    Text("应用设置管理")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("深色模式:")
                            Spacer()
                            Toggle("", isOn: $settings.isDarkMode)
                        }
                        
                        HStack {
                            Text("通知:")
                            Spacer()
                            Toggle("", isOn: $settings.notificationsEnabled)
                        }
                        
                        HStack {
                            Text("字体大小:")
                            Spacer()
                            Text("\(settings.fontSize)")
                                .fontWeight(.bold)
                        }
                        
                        Slider(value: $settings.fontSize, in: 12...24, step: 1)
                            .accentColor(.blue)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    HStack(spacing: 15) {
                        Button("重置设置") {
                            settings.resetSettings()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("保存设置") {
                            settings.saveSettings()
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 数据统计示例
                VStack {
                    Text("数据统计")
                        .font(.headline)
                    
                    VStack(spacing: 10) {
                        HStack {
                            Text("更新次数:")
                            Spacer()
                            Text("\(userProfile.updateCount)")
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                        
                        HStack {
                            Text("设置变更:")
                            Spacer()
                            Text("\(settings.changeCount)")
                                .fontWeight(.bold)
                                .foregroundColor(.orange)
                        }
                        
                        HStack {
                            Text("最后更新:")
                            Spacer()
                            Text(userProfile.lastUpdateTime)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 状态信息
                VStack {
                    Text("状态信息")
                        .font(.headline)
                    
                    VStack(spacing: 10) {
                        Text("用户资料对象: \(userProfile.username)")
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        Text("设置对象: \(settings.isDarkMode ? "深色" : "浅色")模式")
                            .font(.caption)
                            .foregroundColor(.green)
                    }
                    .padding()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("@ObservedObject")
    }
}

// MARK: - ObservableObject 类

class UserProfile: ObservableObject {
    @Published var username = "用户123"
    @Published var age = 25
    @Published var email = "user@example.com"
    @Published var membershipLevel = "普通会员"
    @Published var updateCount = 0
    @Published var lastUpdateTime = "从未更新"
    
    func updateProfile() {
        username = "用户\(Int.random(in: 100...999))"
        age = Int.random(in: 18...65)
        email = "user\(Int.random(in: 100...999))@example.com"
        updateCount += 1
        lastUpdateTime = Date().formatted(date: .abbreviated, time: .shortened)
    }
    
    func upgradeMembership() {
        let levels = ["普通会员", "银卡会员", "金卡会员", "钻石会员"]
        if let currentIndex = levels.firstIndex(of: membershipLevel),
           currentIndex < levels.count - 1 {
            membershipLevel = levels[currentIndex + 1]
        }
        updateCount += 1
        lastUpdateTime = Date().formatted(date: .abbreviated, time: .shortened)
    }
}

class AppSettings: ObservableObject {
    @Published var isDarkMode = false
    @Published var notificationsEnabled = true
    @Published var fontSize: Double = 16
    @Published var changeCount = 0
    
    func resetSettings() {
        isDarkMode = false
        notificationsEnabled = true
        fontSize = 16
        changeCount += 1
    }
    
    func saveSettings() {
        changeCount += 1
        // 模拟保存操作
    }
}

#Preview {
    NavigationView {
        ObservedObjectExampleView()
    }
}
