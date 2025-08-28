//
//  PrivacyPolicyView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/25.
//

import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("隐私政策")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("这里是隐私政策的详细内容...")
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("隐私政策")
        .navigationBarTitleDisplayMode(.inline)
        .hideTabBar()
    }
}

struct UserAgreementView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("用户协议")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("这里是用户协议的详细内容...")
                    .font(.body)
            }
            .padding()
        }
        .navigationTitle("用户协议")
        .navigationBarTitleDisplayMode(.inline)
    }
}
#Preview {
    PrivacyPolicyView()
}
