//
//  EnvironmentObjectExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct EnvironmentObjectExampleView: View {
    @StateObject private var appTheme = AppTheme()
    @StateObject private var userSession = UserSession()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text("@EnvironmentObject 示例")
                    .font(.title)
                    .padding()
                
                // 主题设置
                VStack {
                    Text("主题设置")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("当前主题:")
                            Spacer()
                            Text(appTheme.currentTheme.rawValue)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        HStack {
                            Text("字体大小:")
                            Spacer()
                            Text("\(appTheme.fontSize)")
                                .fontWeight(.bold)
                        }
                        
                        Slider(value: $appTheme.fontSize, in: 12...24, step: 1)
                            .accentColor(.blue)
                        
                        HStack {
                            Text("动画效果:")
                            Spacer()
                            Toggle("", isOn: $appTheme.animationsEnabled)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    HStack(spacing: 15) {
                        Button("浅色主题") {
                            appTheme.setTheme(.light)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("深色主题") {
                            appTheme.setTheme(.dark)
                        }
                        .buttonStyle(.bordered)
                        
                        Button("自动主题") {
                            appTheme.setTheme(.auto)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 用户会话
                VStack {
                    Text("用户会话")
                        .font(.headline)
                    
                    VStack(spacing: 15) {
                        HStack {
                            Text("登录状态:")
                            Spacer()
                            Text(userSession.isLoggedIn ? "已登录" : "未登录")
                                .fontWeight(.bold)
                                .foregroundColor(userSession.isLoggedIn ? .green : .red)
                        }
                        
                        if userSession.isLoggedIn {
                            HStack {
                                Text("用户名:")
                                Spacer()
                                Text(userSession.username)
                                    .fontWeight(.bold)
                            }
                            
                            HStack {
                                Text("登录时间:")
                                Spacer()
                                Text(userSession.loginTime)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                    
                    HStack(spacing: 15) {
                        Button("登录") {
                            userSession.login()
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(userSession.isLoggedIn)
                        
                        Button("登出") {
                            userSession.logout()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.red)
                        .disabled(!userSession.isLoggedIn)
                    }
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 子视图示例
                VStack {
                    Text("子视图示例")
                        .font(.headline)
                    
                    ChildView1()
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                    
                    ChildView2()
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(10)
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
                
                // 环境对象说明
                VStack {
                    Text("环境对象说明")
                        .font(.headline)
                    
                    VStack(spacing: 10) {
                        Text("• 通过环境传递全局状态")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("• 子视图自动访问环境对象")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text("• 适合主题、用户会话等全局状态")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                }
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
            }
            .padding()
        }
        .navigationTitle("@EnvironmentObject")
        .environmentObject(appTheme)
        .environmentObject(userSession)
    }
}

struct ChildView1: View {
    @EnvironmentObject var theme: AppTheme
    @EnvironmentObject var session: UserSession
    
    var body: some View {
        VStack(spacing: 10) {
            Text("子视图1")
                .font(.headline)
            
            HStack {
                Text("主题: \(theme.currentTheme.rawValue)")
                    .font(.caption)
                
                Spacer()
                
                Text("用户: \(session.isLoggedIn ? session.username : "未登录")")
                    .font(.caption)
            }
        }
    }
}

struct ChildView2: View {
    @EnvironmentObject var theme: AppTheme
    @EnvironmentObject var session: UserSession
    
    var body: some View {
        VStack(spacing: 10) {
            Text("子视图2")
                .font(.headline)
            
            VStack(spacing: 5) {
                Text("字体大小: \(theme.fontSize)")
                    .font(.caption)
                
                Text("动画: \(theme.animationsEnabled ? "开启" : "关闭")")
                    .font(.caption)
            }
        }
    }
}

// MARK: - ObservableObject 类

class AppTheme: ObservableObject {
    @Published var currentTheme: MyTheme = .light
    @Published var fontSize: Double = 16
    @Published var animationsEnabled = true
    
    func setTheme(_ theme: MyTheme) {
        currentTheme = theme
    }
}

enum MyTheme: String, CaseIterable {
    case light = "浅色"
    case dark = "深色"
    case auto = "自动"
}

class UserSession: ObservableObject {
    @Published var isLoggedIn = false
    @Published var username = ""
    @Published var loginTime = ""
    
    func login() {
        username = "用户\(Int.random(in: 100...999))"
        isLoggedIn = true
        loginTime = Date().formatted(date: .abbreviated, time: .shortened)
    }
    
    func logout() {
        isLoggedIn = false
        username = ""
        loginTime = ""
    }
}

#Preview {
    NavigationView {
        EnvironmentObjectExampleView()
    }
}
