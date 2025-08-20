//
//  GroupExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct GroupExampleView: View {
    @State private var isExpanded = false
    
    var body: some View {
        VStack(spacing: 20) {
            // 基础分组
            Group {
                Text("分组项目1")
                Text("分组项目2")
                Text("分组项目3")
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            
            // 条件分组
            Group {
                if isExpanded {
                    Text("展开的内容1")
                    Text("展开的内容2")
                    Text("展开的内容3")
                } else {
                    Text("收起的内容")
                }
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(10)
            
            Button("切换展开") {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isExpanded.toggle()
                }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
#Preview {
    GroupExampleView()
}
