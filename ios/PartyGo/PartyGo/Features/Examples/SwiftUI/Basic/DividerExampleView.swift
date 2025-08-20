//
//  DividerExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct DividerExampleView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("分割线示例")
                .font(.title)
            
            // 基础分割线
            Text("上方内容")
            Divider()
            Text("下方内容")
            
            // 自定义分割线
            Text("自定义分割线")
            Divider()
                .background(Color.blue)
                .frame(height: 2)
            Text("自定义样式")
            
            // 水平分割线
            HStack {
                Text("左侧")
                Divider()
                    .frame(height: 50)
                Text("右侧")
            }
            
            // 列表中的分割线
            VStack(spacing: 0) {
                ForEach(1...5, id: \.self) { index in
                    HStack {
                        Text("项目 \(index)")
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                    }
                    .padding()
                    
                    if index < 5 {
                        Divider()
                            .padding(.leading)
                    }
                }
            }
            .background(Color(.systemBackground))
            .cornerRadius(10)
        }
        .padding()
    }
}

#Preview {
    DividerExampleView()
}
