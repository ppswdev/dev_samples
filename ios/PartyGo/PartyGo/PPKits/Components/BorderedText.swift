//
//  BorderedText.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/25.
//

import SwiftUI

struct BorderedText: View {
    let text: String
    let strokeWidth: CGFloat
    let strokeColor: Color
    let textColor: Color
    let font: Font
    let fontWeight: Font.Weight
    
    init(
        _ text: String,
        strokeWidth: CGFloat = 1.0,
        strokeColor: Color = .black,
        textColor: Color = .white,
        font: Font = .body,
        fontWeight: Font.Weight = .regular
    ) {
        self.text = text
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.textColor = textColor
        self.font = font
        self.fontWeight = fontWeight
    }
    
    var body: some View {
        ZStack {
            // 描边层 - 8个方向
            ForEach(0..<8, id: \.self) { index in
                let angle = Double(index) * .pi / 4
                let x = cos(angle) * strokeWidth
                let y = sin(angle) * strokeWidth
                
                Text(text)
                    .font(font)
                    .fontWeight(fontWeight)
                    .foregroundColor(strokeColor)
                    .offset(x: x, y: y)
            }
            
            // 文字层
            Text(text)
                .font(font)
                .fontWeight(fontWeight)
                .foregroundColor(textColor)
        }
    }
}

struct PreciseBorderedText: View {
    let text: String
    let strokeWidth: CGFloat
    let strokeColor: Color
    let textColor: Color
    let font: Font
    let fontWeight: Font.Weight
    
    init(
        _ text: String,
        strokeWidth: CGFloat = 1.0,
        strokeColor: Color = .black,
        textColor: Color = .white,
        font: Font = .body,
        fontWeight: Font.Weight = .regular
    ) {
        self.text = text
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.textColor = textColor
        self.font = font
        self.fontWeight = fontWeight
    }
    
    var body: some View {
        ZStack {
            // 描边层 - 使用更密集的描边点
            ForEach(0..<16, id: \.self) { index in
                let angle = Double(index) * .pi / 8
                let x = cos(angle) * strokeWidth
                let y = sin(angle) * strokeWidth
                
                Text(text)
                    .font(font)
                    .fontWeight(fontWeight)
                    .foregroundColor(strokeColor)
                    .offset(x: x, y: y)
            }
            
            // 文字层
            Text(text)
                .font(font)
                .fontWeight(fontWeight)
                .foregroundColor(textColor)
        }
    }
}

// 创建一个简单的 ViewModifier 替代扩展
struct BorderedTextModifier: ViewModifier {
    let strokeWidth: CGFloat
    let strokeColor: Color
    let textColor: Color
    
    init(strokeWidth: CGFloat = 1.0, strokeColor: Color = .black, textColor: Color = .white) {
        self.strokeWidth = strokeWidth
        self.strokeColor = strokeColor
        self.textColor = textColor
    }
    
    func body(content: Content) -> some View {
        // 这里需要获取 Text 的内容，但 SwiftUI 的限制使得这很困难
        // 所以建议直接使用 BorderedText 组件
        content
    }
}

extension View {
    func bordered(
        strokeWidth: CGFloat = 1.0,
        strokeColor: Color = .black,
        textColor: Color = .white
    ) -> some View {
        // 由于无法从 View 中提取文本内容，这个扩展实际上不可行
        // 建议直接使用 BorderedText 组件
        self
    }
}