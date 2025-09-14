//
//  TextExamplesView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct TextExampleView: View {
    var body: some View {
        ScrollView {
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
                
                // MARK: - 文字描边示例（使用 ViewModifier）
                Group {
                    Text("文字描边")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .textStroke(strokeColor: .yellow, strokeWidth: 5)
                    
                    Text("彩色描边")
                        .font(.title)
                        .fontWeight(.bold)
                        .textStroke(strokeColor: .red, strokeWidth: 5)
                    
                    Text("渐变描边")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.red)
                        .textStroke(strokeColor: .blue, strokeWidth: 2)
                    
                    // 使用 Canvas（iOS 15+）
                    if #available(iOS 15.0, *) {
                        StrokedText("Canvas描边2ABCDEFG", font: .largeTitle, strokeColor: .purple, fillColor: .yellow, strokeWidth: 2)
                    }
                }

                 // MARK: - BorderedText 示例（类似 Flutter 效果）
                Group {
                    BorderedText(
                        "Bordered Text Widget",
                        strokeWidth: 1.0,
                        strokeColor: .black,
                        textColor: .white,
                        font: .title,
                        fontWeight: .bold
                    )
                    
                    BorderedText(
                        "彩色描边文本",
                        strokeWidth: 2.0,
                        strokeColor: .red,
                        textColor: .yellow,
                        font: .title2,
                        fontWeight: .semibold
                    )
                    
                    BorderedText(
                        "细描边效果",
                        strokeWidth: 0.5,
                        strokeColor: .blue,
                        textColor: .white,
                        font: .headline,
                        fontWeight: .medium
                    )
                    
                    BorderedText(
                        "粗描边效果",
                        strokeWidth: 3.0,
                        strokeColor: .green,
                        textColor: .white,
                        font: .largeTitle,
                        fontWeight: .bold
                    )
                    
                    // 使用 PreciseBorderedText 获得更精确的描边
                    PreciseBorderedText(
                        "精确描边文本",
                        strokeWidth: 1.5,
                        strokeColor: .purple,
                        textColor: .white,
                        font: .title3,
                        fontWeight: .bold
                    )
                }
                
                // MARK: - 渐变色文本示例
                Group {
                    // 上下渐变
                    Text("上下渐变文本 + 上下渐变文本 + ABCDEFG")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red, .orange, .yellow],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                    
                    // 左右渐变
                    Text("左右渐变文本")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.blue, .purple, .pink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    // 对角线渐变
                    Text("对角线渐变")
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.green, .cyan, .blue],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                    
                    // 彩虹渐变
                    Text("彩虹渐变")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.red, .orange, .yellow, .green, .blue, .indigo, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    // 径向渐变
                    Text("径向渐变")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundStyle(
                            RadialGradient(
                                colors: [.yellow, .orange, .red],
                                center: .center,
                                startRadius: 0,
                                endRadius: 50
                            )
                        )
                }
                
                // MARK: - 组合效果示例
                Group {
                    Text("边框+渐变")
                        .font(.title2)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.purple, .pink],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 15)
                                .stroke(
                                    LinearGradient(
                                        colors: [.blue, .cyan],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    ),
                                    lineWidth: 3
                                )
                        )
                    
                    Text("阴影+渐变")
                        .font(.title3)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundStyle(
                            LinearGradient(
                                colors: [.white, .gray],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(
                                    LinearGradient(
                                        colors: [.black, .gray],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                        )
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 2, y: 2)
                }
            }
            .padding()
        }
    }
}

#Preview {
    TextExampleView()
}
