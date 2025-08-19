//
//  SheetExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct SheetExampleView: View {
    @State private var showingSheet = false
    @State private var showingCustomSheet = false
    @State private var showingFormSheet = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Sheet 示例")
                .font(.title)
            
            Text("点击按钮显示不同的Sheet")
                .foregroundColor(.secondary)
            
            // 基础Sheet
            Button("显示基础Sheet") {
                showingSheet = true
            }
            .buttonStyle(.borderedProminent)
            
            // 自定义Sheet
            Button("显示自定义Sheet") {
                showingCustomSheet = true
            }
            .buttonStyle(.bordered)
            
            // 表单Sheet
            Button("显示表单Sheet") {
                showingFormSheet = true
            }
            .buttonStyle(.bordered)
        }
        .padding()
        .navigationTitle("Sheet 示例")
        .sheet(isPresented: $showingSheet) {
            BasicSheetView()
        }
        .sheet(isPresented: $showingCustomSheet) {
            CustomSheetView()
        }
        .sheet(isPresented: $showingFormSheet) {
            FormSheetView()
        }
    }
}

struct BasicSheetView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "doc.text")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("基础Sheet")
                    .font(.title)
                
                Text("这是一个基础的Sheet视图")
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding()
            .navigationTitle("基础Sheet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct CustomSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedOption = 0
    let options = ["选项1", "选项2", "选项3"]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("自定义Sheet")
                    .font(.title)
                
                Picker("选择选项", selection: $selectedOption) {
                    ForEach(0..<options.count, id: \.self) { index in
                        Text(options[index]).tag(index)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                Text("当前选择: \(options[selectedOption])")
                    .foregroundColor(.secondary)
                
                Spacer()
            }
            .padding()
            .navigationTitle("自定义Sheet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("确定") {
                        dismiss()
                    }
                }
            }
        }
    }
}

struct FormSheetView: View {
    @Environment(\.dismiss) var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var isSubscribed = false
    
    var body: some View {
        NavigationView {
            Form {
                Section("个人信息") {
                    TextField("姓名", text: $name)
                    TextField("邮箱", text: $email)
                        .keyboardType(.emailAddress)
                }
                
                Section("设置") {
                    Toggle("订阅通知", isOn: $isSubscribed)
                }
                
                Section {
                    Button("提交") {
                        // 处理提交逻辑
                        dismiss()
                    }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.blue)
                }
            }
            .navigationTitle("表单Sheet")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("取消") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        SheetExampleView()
    }
}
