//
//  MoviesView.swift
//  StoreKit2
//
//  Created by Jordan Calhoun on 8/28/23.
//

import SwiftUI

struct UnlocksListView: View {
    @EnvironmentObject var store: StoreViewModel
    @State var vm: UnlocksViewModel
    @State var showingStore: Bool = false
    
    var body: some View {
        VStack {
            title
            Divider()
            
            VStack(alignment: .leading) {
                about
                todos
            }
            .padding()
            .foregroundStyle(.primary)
            
            Spacer()
            storeButton
        }
    }
    
}

#Preview {
    UnlocksListView(vm: UnlocksViewModel())
        .environmentObject(StoreViewModel())
}

extension UnlocksListView {
    var storeButton: some View {
        Button(action: { showingStore.toggle() }) {
            HStack(alignment: .center) {
                Image(systemName: "bag")
                Text("商店")
            }
            .padding()
            .frame(maxWidth: .infinity)
        }
        .buttonStyle(.borderedProminent)
        .padding()
        .popover(isPresented: $showingStore, content: {
            StoreView(showingStore: $showingStore)
        })
    }
    
    var title: some View {
        Group {
            Text("欢迎使用 StoreKit 2")
                .font(.title)
                .fontWeight(.bold)
            .foregroundStyle(.primary)
            
            Text("基于 MVVM 架构")
                .font(.headline)
                .foregroundStyle(.secondary)
        }
    }
    
    var todos: some View {
        let todos = [
            "将可消耗品存储到 AppStorage 中",
            "添加优惠码输入框",
            "设置取消/退款按钮",
            "显示待处理购买状态"
        ]
        return ForEach(todos, id: \.self) {
            Text("- \($0)")
        }
    }
    
    var about: some View {
        Text("本应用实现了基于 MVVM 架构的 StoreKit 2 API。下面是一些仍需完成的事项：")
            .padding(.bottom)
    }
}
