//
//  View+ColorModifiers.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/18.
//

import SwiftUI

struct TextStrokeModifier: ViewModifier {
    let strokeColor: Color
    let strokeWidth: CGFloat
    let offset: CGSize
    
    init(strokeColor: Color = .black, strokeWidth: CGFloat = 2, offset: CGSize = CGSize(width: 1, height: 1)) {
        self.strokeColor = strokeColor
        self.strokeWidth = strokeWidth
        self.offset = offset
    }
    
    func body(content: Content) -> some View {
        ZStack {
            // 描边层
            content
                .foregroundColor(strokeColor)
                .offset(offset)
            
            // 文字层
            content
        }
    }
}