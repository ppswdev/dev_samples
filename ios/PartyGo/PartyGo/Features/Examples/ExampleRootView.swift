//
//  ExampleRootView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct ExampleRootView: View {
    @StateObject private var globalState = GlobalStateManager.shared
    @State private var selectedTab = 0
    @State private var navigationPath = NavigationPath()
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            TabView(selection: $selectedTab) {
                // 第一个标签页
                ExamplesIndexView()
                    .tabItem {
                        Image(systemName: "house")
                        Text("SwiftUI")
                    }.tag(0)
                
                // 第二个标签页
                Swift6IndexView()
                    .tabItem {
                        Image(systemName: "magnifyingglass")
                        Text("Swift6")
                    }.tag(1)
                
                // 第三个标签页 - 游戏中心
                GamesMainView()
                    .tabItem {
                        Image(systemName: "gamecontroller")
                        Text("游戏")
                    }.tag(2)
                
                // 第四个标签页
                SettingsMainView()
                    .tabItem {
                        Image(systemName: "gear")
                        Text("设置")
                    }.tag(3)
            }
        }
        .animation(.none)
        .navigationTitle("SwiftUI+Swift6")
        .onAppear {
            print("✅ ExampleRootView - 当前是会员状态: \(globalState.isVip)")
            print("✅ ExampleRootView - 设置首次启动状态为 false")
        }
        .onChange(of: navigationPath.count) { oldValue,newValue in
            // 当导航路径有内容时（即发生了 push），隐藏 TabBar
            print("✅ ExampleRootView - navigationPath.count=\(newValue)")
            globalState.isTabBarVisible = newValue == 0
        }
//        .onChange(of: navigationPath.count) { count in
//            // 当导航路径有内容时（即发生了 push），隐藏 TabBar (iOS 17以下写法)
//            print("✅ ExampleRootView - navigationPath.count=\(count)")
//            globalState.isTabBarVisible = count == 0
//        }
        .toolbar(globalState.isTabBarVisible ? .visible : .hidden, for: .tabBar)
    }
}

#Preview {
    ExampleRootView()
}
