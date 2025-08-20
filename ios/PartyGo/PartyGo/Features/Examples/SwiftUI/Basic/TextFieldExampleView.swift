//
//  TextFieldExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct TextFieldExampleView: View {
    @State private var text = ""
    @State private var email = ""
    @State private var password = ""
    @State private var number = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // 基础文本输入
            TextField("请输入文本", text: $text)
                .textFieldStyle(.roundedBorder)
            
            // 邮箱输入
            TextField("邮箱地址", text: $email)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.emailAddress)
                .textContentType(.emailAddress)
                .autocapitalization(.none)
            
            // 密码输入
            SecureField("密码", text: $password)
                .textFieldStyle(.roundedBorder)
                .textContentType(.password)
            
            // 数字输入
            TextField("数字", text: $number)
                .textFieldStyle(.roundedBorder)
                .keyboardType(.numberPad)
            
            // 多行文本输入
            TextField("多行文本", text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
        }
        .padding()
    }
}

#Preview {
    TextFieldExampleView()
}
