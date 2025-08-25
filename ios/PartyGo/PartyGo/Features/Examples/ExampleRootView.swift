//
//  ExampleRootView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct ExampleRootView: View {
    @AppStorage("isFirstLaunch") private var isFirstLaunch = true
    @AppStorage("isVip") private var isVip = false

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
            SettingsMainView()
            .tabItem {
                Image(systemName: "gear")
                Text("设置")
            }
        }
        .navigationTitle("SwiftUI+Swift6")
        .onAppear {
            // 当进入首页时，设置首次启动为 false
            print("✅ ExampleRootView - 当前是会员状态: \(isVip)")
            print("✅ ExampleRootView - 设置首次启动状态为 false")
//            isFirstLaunch = true
//            isVip = false
        }
    }
}

#Preview {
    ExampleRootView()
}
