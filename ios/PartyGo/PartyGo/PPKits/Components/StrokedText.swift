//
//  StrokedText.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/25.
//

import SwiftUI

struct StrokedText: View {
    let text: String
    let font: Font
    let strokeColor: Color
    let fillColor: Color
    let strokeWidth: CGFloat
    
    init(_ text: String, font: Font = .body, strokeColor: Color = .black, fillColor: Color = .white, strokeWidth: CGFloat = 2) {
        self.text = text
        self.font = font
        self.strokeColor = strokeColor
        self.fillColor = fillColor
        self.strokeWidth = strokeWidth
    }
    
    var body: some View {
        Canvas { context, size in
            // 创建文本
            let textView = Text(text)
                .font(font)
                .foregroundColor(fillColor)
            
            // 绘制描边（多个方向）
            for x in stride(from: -strokeWidth, through: strokeWidth, by: 1) {
                for y in stride(from: -strokeWidth, through: strokeWidth, by: 1) {
                    if x != 0 || y != 0 {
                        context.draw(
                            Text(text)
                                .font(font)
                                .foregroundColor(strokeColor),
                            at: CGPoint(x: size.width/2 + x, y: size.height/2 + y)
                        )
                    }
                }
            }
            
            // 绘制填充
            context.draw(
                textView,
                at: CGPoint(x: size.width/2, y: size.height/2)
            )
        }
        .frame(height: 50) // 设置合适的高度
    }
}