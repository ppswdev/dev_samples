//
//  ListExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct ListExampleView: View {
    @State private var items = [
        ListItem(title: "第一项", subtitle: "这是第一项的描述", icon: "1.circle.fill", color: .blue),
        ListItem(title: "第二项", subtitle: "这是第二项的描述", icon: "2.circle.fill", color: .green),
        ListItem(title: "第三项", subtitle: "这是第三项的描述", icon: "3.circle.fill", color: .orange),
        ListItem(title: "第四项", subtitle: "这是第四项的描述", icon: "4.circle.fill", color: .purple),
        ListItem(title: "第五项", subtitle: "这是第五项的描述", icon: "5.circle.fill", color: .red)
    ]
    
    @State private var showingAddItem = false
    @State private var newItemTitle = ""
    @State private var newItemSubtitle = ""
    
    var body: some View {
        List {
            Section("基础列表") {
                ForEach(items) { item in
                    HStack {
                        Image(systemName: item.icon)
                            .foregroundColor(item.color)
                            .font(.title2)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.title)
                                .font(.headline)
                            Text(item.subtitle)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.gray)
                            .font(.caption)
                    }
                    .padding(.vertical, 4)
                }
                .onDelete(perform: deleteItems)
                .onMove(perform: moveItems)
            }
            
            Section("分组列表") {
                ForEach(0..<3) { index in
                    NavigationLink(destination: Text("详情页面 \(index + 1)")) {
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 40, height: 40)
                                .overlay(
                                    Text("\(index + 1)")
                                        .foregroundColor(.white)
                                        .fontWeight(.bold)
                                )
                            
                            VStack(alignment: .leading) {
                                Text("分组项目 \(index + 1)")
                                    .font(.headline)
                                Text("点击查看详情")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                    }
                }
            }
            
            Section("可编辑列表") {
                ForEach(items) { item in
                    HStack {
                        Image(systemName: item.icon)
                            .foregroundColor(item.color)
                        
                        Text(item.title)
                        
                        Spacer()
                        
                        Button("编辑") {
                            // 编辑操作
                        }
                        .buttonStyle(.bordered)
                        .scaleEffect(0.8)
                    }
                }
            }
        }
        .navigationTitle("List 示例")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("添加") {
                    showingAddItem = true
                }
            }
            
            ToolbarItem(placement: .navigationBarLeading) {
                EditButton()
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemView(
                title: $newItemTitle,
                subtitle: $newItemSubtitle,
                onAdd: addItem
            )
        }
    }
    
    func deleteItems(offsets: IndexSet) {
        items.remove(atOffsets: offsets)
    }
    
    func moveItems(from source: IndexSet, to destination: Int) {
        items.move(fromOffsets: source, toOffset: destination)
    }
    
    func addItem() {
        let newItem = ListItem(
            title: newItemTitle.isEmpty ? "新项目" : newItemTitle,
            subtitle: newItemSubtitle.isEmpty ? "新项目描述" : newItemSubtitle,
            icon: "plus.circle.fill",
            color: [.blue, .green, .orange, .purple, .red].randomElement() ?? .blue
        )
        items.append(newItem)
        newItemTitle = ""
        newItemSubtitle = ""
    }
}

struct ListItem: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
}

struct AddItemView: View {
    @Binding var title: String
    @Binding var subtitle: String
    let onAdd: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section("项目信息") {
                    TextField("标题", text: $title)
                    TextField("描述", text: $subtitle)
                }
            }
            .navigationTitle("添加项目")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("添加") {
                        onAdd()
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        ListExampleView()
    }
}
