//
//  ExampleRootView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct ExampleRootView: View {
    var body: some View {
        TabView {
            // 第一个标签页
            ExamplesIndexView()
            .tabItem {
                Image(systemName: "house")
                Text("SwiftUI")
            }
            
            // 第二个标签页
            Swift6IndexView()
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("Swift6")
            }
            
            // 第三个标签页
            VStack(spacing: 20) {
                Image(systemName: "person.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)
                
                Text("个人")
                    .font(.title)
                
                Text("这是第三个标签页的内容")
                    .foregroundColor(.secondary)
            }
            .tabItem {
                Image(systemName: "person")
                Text("Samples")
            }
            
            // 第四个标签页
            VStack(spacing: 20) {
                Image(systemName: "gear")
                    .font(.system(size: 50))
                    .foregroundColor(.purple)
                
                Text("设置")
                    .font(.title)
                
                Text("这是第四个标签页的内容")
                    .foregroundColor(.secondary)
            }
            .tabItem {
                Image(systemName: "gear")
                Text("设置")
            }
        }
        .navigationTitle("SwiftUI+Swift6")
    }
}

#Preview {
    ExampleRootView()
}
