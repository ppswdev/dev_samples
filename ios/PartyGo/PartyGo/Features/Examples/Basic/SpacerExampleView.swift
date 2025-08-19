//
//  SpacerExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct SpacerExampleView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("间距组件示例")
                .font(.title)
            
            // 基础间距
            HStack {
                Text("左侧")
                Spacer()
                Text("右侧")
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            
            // 固定间距
            HStack {
                Text("左侧")
                Spacer(minLength: 50)
                Text("中间")
                Spacer(minLength: 50)
                Text("右侧")
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(10)
            
            // 垂直间距
            VStack {
                Text("顶部")
                Spacer()
                Text("中间")
                Spacer()
                Text("底部")
            }
            .frame(height: 150)
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(10)
            
            // 复杂布局
            HStack {
                VStack {
                    Text("左上")
                    Spacer()
                    Text("左下")
                }
                
                Spacer()
                
                VStack {
                    Text("右上")
                    Spacer()
                    Text("右下")
                }
            }
            .frame(height: 100)
            .padding()
            .background(Color.purple.opacity(0.1))
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    SpacerExampleView()
}
