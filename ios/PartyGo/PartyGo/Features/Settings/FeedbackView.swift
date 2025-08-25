//
//  FeedbackView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/25.
//

import SwiftUI

/**
 * 反馈视图
 */
struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var feedbackText = ""
    @State private var contactEmail = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("意见反馈")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("我们非常重视您的意见，请告诉我们您的想法")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("反馈内容")
                        .font(.headline)
                    
                    TextEditor(text: $feedbackText)
                        .frame(height: 120)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("联系邮箱（可选）")
                        .font(.headline)
                    
                    TextField("your@email.com", text: $contactEmail)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                .padding(.horizontal)
                
                Spacer()
                
                Button("提交反馈") {
                    // 这里实现反馈提交逻辑
                    dismiss()
                }
                .buttonStyle(.borderedProminent)
                .disabled(feedbackText.isEmpty)
                .padding(.horizontal, 40)
                .padding(.bottom, 30)
            }
            .padding()
            .navigationTitle("意见反馈")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    FeedbackView()
}
