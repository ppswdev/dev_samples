//
//  ContentView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import SwiftUI

struct ContentView: View {
    @Environment(\.appearanceManager) private var appearanceManager
    @State private var showingAppearanceSettings = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 当前外观模式显示
                VStack(spacing: 12) {
                    Image(systemName: appearanceManager.currentAppearanceMode.iconName)
                        .font(.system(size: 60))
                        .foregroundColor(.accentColor)
                    
                    Text("当前外观模式")
                        .font(.headline)
                    
                    Text(appearanceManager.currentAppearanceMode.displayName)
                        .font(.title2)
                        .foregroundColor(.secondary)
                    
                    if appearanceManager.isSystemMode {
                        Text("系统当前为: \(appearanceManager.currentEffectiveMode.displayName)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .background(Color(.systemBackground))
                .cornerRadius(12)
                .shadow(radius: 2)
                
                // 快速切换按钮
                AppearanceToggleButton()
                    .padding()
                
                // 设置按钮
                HStack(spacing: 16) {
                    Button("外观设置") {
                        showingAppearanceSettings = true
                    }
                    .buttonStyle(.borderedProminent)
                    
                    NavigationLink("查看示例") {
                        AppearanceExampleView()
                    }
                    .buttonStyle(.bordered)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("PartyGo")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showingAppearanceSettings) {
                AppearanceSettingsView()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(\.appearanceManager, AppearanceManager.shared)
}
