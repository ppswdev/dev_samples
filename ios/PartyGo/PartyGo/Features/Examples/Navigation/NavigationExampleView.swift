//
//  NavigationExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct NavigationExampleView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink("基础导航", destination: BasicNavigationView())
                NavigationLink("导航栏样式", destination: NavigationBarStyleView())
                NavigationLink("导航栏按钮", destination: NavigationBarButtonsView())
                NavigationLink("导航栏标题", destination: NavigationBarTitleView())
            }
            .navigationTitle("NavigationView 示例")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct BasicNavigationView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("基础导航页面")
                .font(.title)
            
            Text("这是通过NavigationLink导航到的页面")
                .foregroundColor(.secondary)
            
            NavigationLink("继续导航", destination: Text("更深层的页面"))
        }
        .padding()
        .navigationTitle("基础导航")
    }
}

struct NavigationBarStyleView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("导航栏样式示例")
                .font(.title)
            
            Text("可以自定义导航栏的样式")
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("导航栏样式")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("完成") {
                    // 完成操作
                }
            }
        }
    }
}

struct NavigationBarButtonsView: View {
    @State private var showingAlert = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("导航栏按钮示例")
                .font(.title)
            
            Text("左侧和右侧都可以添加按钮")
                .foregroundColor(.secondary)
            
            Button("显示Alert") {
                showingAlert = true
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("导航栏按钮")
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button("返回") {
                    // 返回操作
                }
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("设置") {
                    // 设置操作
                }
            }
        }
        .alert("提示", isPresented: $showingAlert) {
            Button("确定") { }
        } message: {
            Text("这是一个Alert示例")
        }
    }
}

struct NavigationBarTitleView: View {
    var body: some View {
        VStack(spacing: 20) {
            Text("导航栏标题示例")
                .font(.title)
            
            Text("支持大标题、内联标题等不同样式")
                .foregroundColor(.secondary)
        }
        .padding()
        .navigationTitle("大标题样式")
        .navigationBarTitleDisplayMode(.large)
    }
}

#Preview {
    NavigationExampleView()
}
