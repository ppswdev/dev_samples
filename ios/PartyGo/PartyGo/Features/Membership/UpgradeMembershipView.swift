//
//  UpgradeMembershipView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/25.
//

import SwiftUI

struct UpgradeMembershipView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var globalState: GlobalStateManager
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // VIP 图标
                Image(systemName: "crown.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.yellow)
                
                // 标题
                Text("升级为 VIP 会员")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // 描述
                Text("解锁所有功能，享受无限制的派对体验")
                    .font(.title3)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                
                // 功能列表
                VStack(alignment: .leading, spacing: 15) {
                    MembershipFeatureRow(icon: "infinity", title: "无限制创建派对")
                    MembershipFeatureRow(icon: "star.fill", title: "高级主题和装饰")
                    MembershipFeatureRow(icon: "person.3.fill", title: "无限邀请好友")
                    MembershipFeatureRow(icon: "crown.fill", title: "专属 VIP 标识")
                }
                .padding(.horizontal, 40)
                
                Spacer()
                
                // 订阅按钮
                Button("立即订阅") {
                    // 模拟订阅成功
                    globalState.upgradeToVip(expireDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())?.timeIntervalSince1970 ?? 0)
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
            .padding()
            .navigationTitle("升级会员")
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

/**
 * 功能行组件
 */
struct MembershipFeatureRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: icon)
                .foregroundColor(.blue)
                .frame(width: 20)
            
            Text(title)
                .font(.body)
        }
    }
}


#Preview {
    UpgradeMembershipView()
}
