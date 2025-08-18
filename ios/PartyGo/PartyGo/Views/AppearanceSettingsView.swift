//
//  AppearanceSettingsView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import SwiftUI

/// 外观模式设置视图
struct AppearanceSettingsView: View {
    @Environment(\.appearanceManager) private var appearanceManager
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    ForEach(AppearanceMode.allCases, id: \.self) { mode in
                        AppearanceModeRow(
                            mode: mode,
                            isSelected: appearanceManager.currentAppearanceMode == mode
                        ) {
                            appearanceManager.setAppearanceMode(mode)
                        }
                    }
                } header: {
                    Text("选择外观模式")
                } footer: {
                    Text("选择您喜欢的外观模式，或跟随系统设置自动切换")
                }
            }
            .navigationTitle("外观设置")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

/// 外观模式选择行
struct AppearanceModeRow: View {
    let mode: AppearanceMode
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack {
                Image(systemName: mode.iconName)
                    .foregroundColor(.accentColor)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(mode.displayName)
                        .font(.body)
                        .foregroundColor(.primary)
                    
                    if mode == .system {
                        Text("跟随系统设置")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundColor(.accentColor)
                        .font(.body.bold())
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

/// 快速外观模式切换按钮
struct AppearanceToggleButton: View {
    @Environment(\.appearanceManager) private var appearanceManager
    
    var body: some View {
        Button(action: {
            appearanceManager.toggleAppearanceMode()
        }) {
            Image(systemName: appearanceManager.currentAppearanceMode.iconName)
                .font(.title2)
                .foregroundColor(.primary)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }
}

#Preview {
    AppearanceSettingsView()
        .environment(\.appearanceManager, AppearanceManager.shared)
}
