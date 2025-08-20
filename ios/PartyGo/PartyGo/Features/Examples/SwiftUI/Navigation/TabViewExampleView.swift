//
//  TabViewExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct TabViewExampleView: View {
    var body: some View {
        TabView {
            // 第一个标签页
            VStack(spacing: 20) {
                Image(systemName: "house.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.blue)
                
                Text("首页")
                    .font(.title)
                
                Text("这是第一个标签页的内容")
                    .foregroundColor(.secondary)
            }
            .tabItem {
                Image(systemName: "house")
                Text("首页")
            }
            
            // 第二个标签页
            VStack(spacing: 20) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 50))
                    .foregroundColor(.green)
                
                Text("搜索")
                    .font(.title)
                
                Text("这是第二个标签页的内容")
                    .foregroundColor(.secondary)
            }
            .tabItem {
                Image(systemName: "magnifyingglass")
                Text("搜索")
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
                Text("个人")
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
        .navigationTitle("TabView 示例")
    }
}

#Preview {
    NavigationView {
        TabViewExampleView()
    }
}
