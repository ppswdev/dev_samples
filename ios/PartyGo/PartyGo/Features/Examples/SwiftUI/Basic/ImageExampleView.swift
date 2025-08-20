//
//  ImageExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct ImageExampleView: View {
    var body: some View {
        VStack(spacing: 20) {
            // SF Symbols (系统图标)
            Image(systemName: "star.fill")
                .font(.largeTitle)
                .foregroundColor(.yellow)
            
            // 自定义图片
            Image("LaunchImageV1") // 从 Assets 加载
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 200, height: 200)
            
            // 图片修饰符
            Image(systemName: "heart.fill")
                .font(.system(size: 50))
                .foregroundColor(.red)
                .shadow(color: .black.opacity(0.3), radius: 5)
                .scaleEffect(1.2)
            
            // 图片组合
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title)
                Text("用户头像")
            }
        }
        .padding()
    }
}

#Preview {
    ImageExampleView()
}
