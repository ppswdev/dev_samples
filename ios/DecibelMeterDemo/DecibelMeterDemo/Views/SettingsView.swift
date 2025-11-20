//
//  SettingsView.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/1/23.
//

import SwiftUI

struct SettingsView: View {
    @ObservedObject var viewModel: DecibelMeterViewModel
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - 颜色定义
    private let primaryColor = Color(red: 110/255, green: 91/255, blue: 255/255)
    private let primaryTextColor = Color(red: 42/255, green: 42/255, blue: 74/255)
    private let secondaryTextColor = Color(red: 90/255, green: 90/255, blue: 122/255)
    private let iconBackgroundColor = Color(red: 110/255, green: 91/255, blue: 255/255).opacity(0.1)
    
    // MARK: - 状态
    @State private var isNotificationEnabled = true
    @State private var selectedLanguage = "简体中文"
    @State private var selectedTheme = "默认"
    @State private var showShareSheet = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 0) {
                    // 账户部分
                    SettingsSection(title: "账户") {
                        SettingsRow(
                            icon: "person.circle",
                            title: "账号信息",
                            action: {
                                // TODO: 导航到账号信息页面
                            }
                        )
                        
                        SettingsRow(
                            icon: "lock.shield",
                            title: "隐私设置",
                            action: {
                                // TODO: 导航到隐私设置页面
                            }
                        )
                    }
                    .padding(.top, 20)
                    
                    // 偏好部分
                    SettingsSection(title: "偏好") {
                        SettingsRowWithToggle(
                            icon: "bell",
                            title: "通知设置",
                            isOn: $isNotificationEnabled
                        )
                        
                        SettingsRowWithValue(
                            icon: "globe",
                            title: "语言",
                            value: selectedLanguage,
                            action: {
                                // TODO: 显示语言选择器
                            }
                        )
                        
                        SettingsRowWithValue(
                            icon: "paintbrush",
                            title: "主题颜色",
                            value: selectedTheme,
                            action: {
                                // TODO: 显示主题选择器
                            }
                        )
                    }
                    .padding(.top, 30)
                    
                    // 关于部分
                    SettingsSection(title: "关于") {
                        SettingsRow(
                            icon: "star",
                            title: "评价应用",
                            action: {
                                // TODO: 打开App Store评价页面
                                openAppStore()
                            }
                        )
                        
                        SettingsRow(
                            icon: "square.and.arrow.up",
                            title: "分享应用",
                            action: {
                                // TODO: 显示分享选项
                                shareApp()
                            }
                        )
                        
                        SettingsRow(
                            icon: "info.circle",
                            title: "关于我们",
                            action: {
                                // TODO: 导航到关于页面
                            }
                        )
                    }
                    .padding(.top, 30)
                    
                    Spacer(minLength: 30)
                }
                .padding(.horizontal, 20)
            }
            .background(Color.white)
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showShareSheet) {
                if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID") {
                    ShareSheet(activityItems: [url])
                }
            }
        }
    }
    
    // MARK: - 私有方法
    
    private func openAppStore() {
        // TODO: 实现打开App Store评价页面
        if let url = URL(string: "https://apps.apple.com/app/idYOUR_APP_ID?action=write-review") {
            UIApplication.shared.open(url)
        }
    }
    
    private func shareApp() {
        showShareSheet = true
    }
}

// MARK: - 设置部分组件

struct SettingsSection<Content: View>: View {
    let title: String
    let content: Content
    
    private let primaryColor = Color(red: 110/255, green: 91/255, blue: 255/255)
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // 标题
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(primaryColor)
                .padding(.leading, 10)
                .padding(.bottom, 15)
            
            // 内容
            VStack(spacing: 10) {
                content
            }
        }
    }
}

// MARK: - 设置行组件（带箭头）

struct SettingsRow: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    private let primaryTextColor = Color(red: 42/255, green: 42/255, blue: 74/255)
    private let iconBackgroundColor = Color(red: 110/255, green: 91/255, blue: 255/255).opacity(0.1)
    private let cardBackgroundColor = Color.white
    private let shadowColor = Color(red: 110/255, green: 91/255, blue: 255/255).opacity(0.12)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // 图标容器
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBackgroundColor)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 110/255, green: 91/255, blue: 255/255))
                }
                
                // 标题
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(primaryTextColor)
                
                Spacer()
                
                // 箭头
                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(red: 90/255, green: 90/255, blue: 122/255))
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(cardBackgroundColor)
            .cornerRadius(18)
            .shadow(color: shadowColor, radius: 15, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}


// MARK: - 设置行组件（带开关）

struct SettingsRowWithToggle: View {
    let icon: String
    let title: String
    @Binding var isOn: Bool
    
    private let primaryTextColor = Color(red: 42/255, green: 42/255, blue: 74/255)
    private let iconBackgroundColor = Color(red: 110/255, green: 91/255, blue: 255/255).opacity(0.1)
    private let cardBackgroundColor = Color.white
    private let shadowColor = Color(red: 110/255, green: 91/255, blue: 255/255).opacity(0.12)
    private let toggleColor = Color(red: 110/255, green: 91/255, blue: 255/255)
    
    var body: some View {
        HStack(spacing: 15) {
            // 图标容器
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(iconBackgroundColor)
                    .frame(width: 40, height: 40)
                
                Image(systemName: icon)
                    .font(.system(size: 18))
                    .foregroundColor(Color(red: 110/255, green: 91/255, blue: 255/255))
            }
            
            // 标题
            Text(title)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(primaryTextColor)
            
            Spacer()
            
            // 开关
            Toggle("", isOn: $isOn)
                .toggleStyle(SwitchToggleStyle(tint: toggleColor))
                .frame(width: 50, height: 26)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 15)
        .background(cardBackgroundColor)
        .cornerRadius(18)
        .shadow(color: shadowColor, radius: 15, x: 0, y: 4)
    }
}

// MARK: - 设置行组件（带值）

struct SettingsRowWithValue: View {
    let icon: String
    let title: String
    let value: String
    let action: () -> Void
    
    private let primaryTextColor = Color(red: 42/255, green: 42/255, blue: 74/255)
    private let secondaryTextColor = Color(red: 90/255, green: 90/255, blue: 122/255)
    private let iconBackgroundColor = Color(red: 110/255, green: 91/255, blue: 255/255).opacity(0.1)
    private let cardBackgroundColor = Color.white
    private let shadowColor = Color(red: 110/255, green: 91/255, blue: 255/255).opacity(0.12)
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 15) {
                // 图标容器
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(iconBackgroundColor)
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18))
                        .foregroundColor(Color(red: 110/255, green: 91/255, blue: 255/255))
                }
                
                // 标题
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(primaryTextColor)
                
                Spacer()
                
                // 值和箭头
                HStack(spacing: 4) {
                    Text(value)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(secondaryTextColor)
                    
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(secondaryTextColor)
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 15)
            .background(cardBackgroundColor)
            .cornerRadius(18)
            .shadow(color: shadowColor, radius: 15, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 分享组件

struct ShareSheet: UIViewControllerRepresentable {
    let activityItems: [Any]
    let applicationActivities: [UIActivity]? = nil
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: applicationActivities
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // 不需要更新
    }
}
