//
//  MainTabView.swift
//  DecibelMeterDemo
//
//  Created by xiaopin on 2025/1/23.
//
//  主TabView界面，包含三个Tab：
//  1. 分贝计 - 实时分贝测量和显示
//  2. 噪音测量计 - 职业健康噪声监测
//  3. 设置 - 应用设置和配置
//

import SwiftUI

struct MainTabView: View {
    @StateObject private var viewModel = DecibelMeterViewModel()
    
    var body: some View {
        TabView {
            // 分贝计Tab
            DecibelMeterView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "waveform")
                    Text("分贝计")
                }
            
            // 噪音测量计Tab
            NoiseDosimeterView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "ear")
                    Text("噪音测量计")
                }
            
            // 设置Tab
            SettingsView(viewModel: viewModel)
                .tabItem {
                    Image(systemName: "gear")
                    Text("设置")
                }
        }
        .accentColor(.blue)
    }
}

#Preview {
    MainTabView()
}
