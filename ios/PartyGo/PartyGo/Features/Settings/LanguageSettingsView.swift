//
//  LanguageSettingsView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/25.
//

import SwiftUI

struct LanguageSettingsView: View {
    @EnvironmentObject var globalState: GlobalStateManager
    @Environment(\.dismiss) private var dismiss
    @State private var showingLanguageChangeAlert = false
    @State private var selectedLanguage: GlobalStateManager.AppLanguage?
    
    var body: some View {
        VStack(spacing: 0) {
            // 语言列表
            List {
                ForEach(GlobalStateManager.AppLanguage.allCases, id: \.self) { language in
                    LanguageRowView(
                        language: language,
                        isSelected: globalState.appLanguage == language,
                        onTap: {
                            selectedLanguage = language
                            showingLanguageChangeAlert = true
                        }
                    )
                }
            }
            .listStyle(PlainListStyle())
        }
        .navigationTitle("语言设置")
        .navigationBarTitleDisplayMode(.large)
        .alert("切换语言", isPresented: $showingLanguageChangeAlert) {
            Button("取消", role: .cancel) { }
            Button("确定") {
                if let language = selectedLanguage {
                    changeLanguage(to: language)
                }
            }
        } message: {
            if let language = selectedLanguage {
                Text("确定要切换到 \(language.displayName) 吗？应用将重新启动以应用新的语言设置。")
            }
        }
    }
    
    // MARK: - 计算属性
    
    // MARK: - 私有方法
    
    /**
     * 切换语言
     */
    private func changeLanguage(to language: GlobalStateManager.AppLanguage) {
        globalState.switchLanguage(language)
        
        // 显示切换成功提示
        showLanguageChangeSuccess(language: language)
    }
    
    /**
     * 显示语言切换成功提示
     */
    private func showLanguageChangeSuccess(language: GlobalStateManager.AppLanguage) {
        // 这里可以添加一个临时的成功提示
        print("✅ 语言已切换到: \(language.displayName)")
    }
}

// MARK: - 语言行视图

struct LanguageRowView: View {
    let language: GlobalStateManager.AppLanguage
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 16) {
                // 国旗图标
                Text(language.flag)
                    .font(.title2)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color(.systemGray6))
                    )
                
                // 语言信息
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text(language.displayName)
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        if language.isRTL {
                            Text("RTL")
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(4)
                        }
                    }
                    
                    Text(language.nativeName)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                // 选中状态
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.blue)
                        .font(.title2)
                }
            }
            .padding(.vertical, 8)
        }
        .buttonStyle(PlainButtonStyle())
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}

// MARK: - 语言分组视图（可选）

struct LanguageGroupView: View {
    let title: String
    let languages: [GlobalStateManager.AppLanguage]
    @EnvironmentObject var globalState: GlobalStateManager
    
    var body: some View {
        Section(header: Text(title)) {
            ForEach(languages, id: \.self) { language in
                LanguageRowView(
                    language: language,
                    isSelected: globalState.appLanguage == language
                ) {
                    globalState.switchLanguage(language)
                }
            }
        }
    }
}

// MARK: - 预览

#Preview {
    LanguageSettingsView()
        .environmentObject(GlobalStateManager.shared)
}
