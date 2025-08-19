//
//  PickerExampleView.swift
//  PartyGo
//
//  Created by xiaopin on 2025/8/19.
//

import SwiftUI

struct PickerExampleView: View {
    @State private var selectedColor = "红色"
    @State private var selectedIndex = 0
    @State private var selectedDate = Date()
    
    let colors = ["红色", "绿色", "蓝色", "黄色", "紫色"]
    
    var body: some View {
        VStack(spacing: 20) {
            // 菜单样式选择器
            Picker("选择颜色", selection: $selectedColor) {
                ForEach(colors, id: \.self) { color in
                    Text(color).tag(color)
                }
            }
            .pickerStyle(MenuPickerStyle())
            
            // 分段选择器
            Picker("选择类型", selection: $selectedIndex) {
                Text("类型1").tag(0)
                Text("类型2").tag(1)
                Text("类型3").tag(2)
            }
            .pickerStyle(SegmentedPickerStyle())
            
            // 轮盘选择器
            Picker("选择颜色", selection: $selectedColor) {
                ForEach(colors, id: \.self) { color in
                    Text(color).tag(color)
                }
            }
            .pickerStyle(WheelPickerStyle())
            
            // 日期选择器
            DatePicker("选择日期", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(CompactDatePickerStyle())
        }
        .padding()
    }
}
#Preview {
    PickerExampleView()
}
