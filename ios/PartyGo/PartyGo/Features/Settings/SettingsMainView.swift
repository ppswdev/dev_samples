//
//  SettingsMainView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/25.
//

import SwiftUI

struct SettingsMainView: View {
    @EnvironmentObject var globalState: GlobalStateManager
    @EnvironmentObject var rootManager: RootViewManager
    @State private var showingUpgradeSheet = false
    @State private var showingFeedbackSheet = false
    @State private var showingAboutSheet = false
    
    var body: some View {
        NavigationView {
            List {
                // MARK: - 分组1：升级会员
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: globalState.isVip ? "crown.fill" : "crown")
                                .font(.title2)
                                .foregroundColor(globalState.isVip ? .yellow : .gray)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text(globalState.isVip ? "VIP 会员" : "升级会员")
                                    .font(.headline)
                                    .foregroundColor(globalState.isVip ? .primary : .blue)
                                
                                Text(globalState.isVip ? "享受所有高级功能" : "解锁所有功能，享受无限制体验")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                            
                            if globalState.isVip {
                                Text("已激活")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.green.opacity(0.1))
                                    .cornerRadius(8)
                            } else {
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        if globalState.isVip {
                            Text("到期时间：\(Date(timeIntervalSince1970: globalState.vipExpireDate), style: .date)")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.vertical, 4)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !globalState.isVip {
                            showingUpgradeSheet = true
                        }
                    }
                } header: {
                    Text("会员服务")
                }
                
                // MARK: - 分组2：应用设置
                Section {
                     // 外观模式设置
                    NavigationLink {
                        AppearanceSettingsView()
                    } label: {
                        HStack {
                            Image(systemName: "paintbrush.fill")
                                .foregroundColor(.purple)
                                .frame(width: 24)
                            
                            Text("外观模式")
                            
                            Spacer()
                            
                            Text(globalState.appTheme.displayName)
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // 声音开关设置
                    HStack {
                        Image(systemName: "speaker.wave.2.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24)
                        
                        Text("声音效果")
                        
                        Spacer()
                        
                        Toggle("", isOn: $globalState.soundEnabled)
                            .labelsHidden()
                    }
                    
                    // 触觉反馈设置
                    HStack {
                        Image(systemName: "iphone.radiowaves.left.and.right")
                            .foregroundColor(.green)
                            .frame(width: 24)
                        
                        Text("触觉反馈")
                        
                        Spacer()
                        
                        Toggle("", isOn: $globalState.hapticFeedbackEnabled)
                            .labelsHidden()
                    }
                    
                    // 语言设置
                    NavigationLink {
                        LanguageSettingsView()
                    } label: {
                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            Text("语言设置")
                            
                            Spacer()
                            
                            Text(globalState.appLanguage.displayName)
                                .foregroundColor(.secondary)
                        }
                    }
                } header: {
                    Text("应用设置")
                }
                
                // MARK: - 分组3：支持与反馈
                Section {
                    // 分享给朋友
                    Button {
                        shareApp()
                    } label: {
                        HStack {
                            Image(systemName: "square.and.arrow.up")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("分享给朋友")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 给出评价
                    Button {
                        rateApp()
                    } label: {
                        HStack {
                            Image(systemName: "star.fill")
                                .foregroundColor(.yellow)
                                .frame(width: 24)
                            
                            Text("给出评价")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 意见反馈
                    Button {
                        showingFeedbackSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundColor(.purple)
                                .frame(width: 24)
                            
                            Text("意见反馈")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                    
                    // 建议功能
                    Button {
                        suggestFeature()
                    } label: {
                        HStack {
                            Image(systemName: "lightbulb.fill")
                                .foregroundColor(.orange)
                                .frame(width: 24)
                            
                            Text("建议功能")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                } header: {
                    Text("支持与反馈")
                }
                
                // MARK: - 分组4：关于
                Section {
                    // 隐私政策
                    NavigationLink {
                        PrivacyPolicyView()
                    } label: {
                        HStack {
                            Image(systemName: "hand.raised.fill")
                                .foregroundColor(.red)
                                .frame(width: 24)
                            
                            Text("隐私政策")
                        }
                    }
                    
                    // 用户协议
                    NavigationLink {
                        UserAgreementView()
                    } label: {
                        HStack {
                            Image(systemName: "doc.text.fill")
                                .foregroundColor(.blue)
                                .frame(width: 24)
                            
                            Text("用户协议")
                        }
                    }
                    
                    // 关于
                    Button {
                        showingAboutSheet = true
                    } label: {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.green)
                                .frame(width: 24)
                            
                            Text("关于")
                            
                            Spacer()
                            
                            Text("v\(globalState.appVersion)")
                                .foregroundColor(.secondary)
                            
                            Image(systemName: "chevron.right")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                } header: {
                    Text("关于")
                }
            }
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
        }
        .sheet(isPresented: $showingUpgradeSheet) {
            UpgradeMembershipView()
        }
        .sheet(isPresented: $showingFeedbackSheet) {
            FeedbackView()
        }
        .sheet(isPresented: $showingAboutSheet) {
            AboutView()
        }
    }
    
    // MARK: - 私有方法
    
    /**
     * 分享应用
     */
    private func shareApp() {
        let appUrl = URL(string: "https://apps.apple.com/app/partygoid")!
        let shareText = "推荐一个很棒的应用：PartyGo - 让派对更精彩！"
        
        let activityVC = UIActivityViewController(
            activityItems: [shareText, appUrl],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
    
    /**
     * 评价应用
     */
    private func rateApp() {
        let appId = "your-app-id-here"
        let urlString = "https://apps.apple.com/app/id\(appId)?action=write-review"
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
    
    /**
     * 建议功能
     */
    private func suggestFeature() {
        let email = "feedback@partygoid.com"
        let subject = "功能建议"
        let body = "请描述您希望添加的功能："
        
        let urlString = "mailto:\(email)?subject=\(subject)&body=\(body)"
            .addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview {
    SettingsMainView()
        .environmentObject(GlobalStateManager.shared)
        .environmentObject(RootViewManager.shared)
}
