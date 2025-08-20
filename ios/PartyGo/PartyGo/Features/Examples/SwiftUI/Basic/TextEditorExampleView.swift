//
//  TextEditorExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct TextEditorExampleView: View {
    @State private var text = ""
    
    var body: some View {
        VStack {
            Text("文本编辑器")
                .font(.headline)
            
            TextEditor(text: $text)
                .frame(height: 200)
                .border(Color.gray, width: 1)
                .padding()
            
            Text("字符数: \(text.count)")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
    }
}

#Preview {
    TextEditorExampleView()
}
