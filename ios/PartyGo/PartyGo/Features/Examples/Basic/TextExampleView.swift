//
//  TextExamplesView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct TextExampleView: View {
    var body: some View {
        VStack(spacing: 20) {
            // 基础文本
            Text("Hello SwiftUI")
            
            // 字体样式
            Text("大标题")
                .font(.largeTitle)
            
            Text("标题")
                .font(.title)
            
            Text("正文")
                .font(.body)
            
            Text("小字")
                .font(.caption)
            
            // 颜色和样式
            Text("彩色文本")
                .foregroundColor(.blue)
                .fontWeight(.bold)
            
            // 多行文本
            Text("这是一段很长的文本，用来演示多行文本的显示效果。SwiftUI会自动处理文本的换行和对齐。")
                .multilineTextAlignment(.center)
                .lineLimit(3)
            
            // 富文本
            Text("混合样式文本")
                .font(.title)
                .foregroundColor(.blue) +
            Text(" 普通文本")
                .font(.body)
                .foregroundColor(.black)
        }
        .padding()
    }
}

#Preview {
    TextExampleView()
}
