//
//  AboutView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/25.
//

import SwiftUI

/**
 * 关于视图
 */
struct AboutView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var globalState: GlobalStateManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // 应用图标
                Image(systemName: "party.popper.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.blue)
                
                // 应用名称
                Text("PartyGo")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // 版本信息
                VStack(spacing: 8) {
                    Text("版本 \(globalState.appVersion)")
                        .font(.title3)
                    
                    Text("构建 \(globalState.buildNumber)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 描述
                Text("让您的派对更加精彩")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                Spacer()
                
                // 版权信息
                Text("© 2025 PartyGo Team. All rights reserved.")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.bottom, 30)
            }
            .padding()
            .navigationTitle("关于")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("关闭") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AboutView()
}
